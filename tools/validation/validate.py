#!/usr/bin/env python3
"""Run deterministic numerical checks and two native-LIBSVM pipeline smoke tests."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import tempfile
import unittest

import numpy as np
import scipy
from scipy.optimize import minimize
from numpy.testing import assert_allclose

from reference import (ssm, log_hog, vocabulary, vq_pyramid, pyramid_kernel,
                       sparse_codes, sparse_pool, learn_dictionary, kkt_residual)

ROOT = Path(__file__).resolve().parents[2]
METRICS = {}
SANITIZER_ENV = {
    **os.environ,
    'ASAN_OPTIONS': 'detect_leaks=0:halt_on_error=1',
    'UBSAN_OPTIONS': 'halt_on_error=1:print_stacktrace=1',
}


class NumericalChecks(unittest.TestCase):
    def test_ssm_oracle_and_invariance(self):
        x = np.random.default_rng(3).normal(size=(13, 6))
        for window in (1, 3, 5):
            for metric, power in [('euclidean', 2), ('cityblock', 1)]:
                actual = ssm(x, window, metric)
                expected = np.array([[np.sum(np.abs(x[i:i+window] - x[j:j+window]) ** power) ** (1 / power)
                                      for j in range(len(actual))] for i in range(len(actual))])
                assert_allclose(actual, expected, atol=1e-12)
                assert_allclose(ssm(x + 100, window, metric), actual, atol=1e-12)
                assert_allclose(ssm(x[::-1], window, metric), actual[::-1, ::-1], atol=1e-12)
        rotation, _ = np.linalg.qr(np.random.default_rng(4).normal(size=(6, 6)))
        assert_allclose(ssm(x @ rotation), ssm(x), atol=1e-12)
        assert_allclose(ssm(x, sigmoid=True), np.tanh(0.0005 * ssm(x)))
        for window in (0, 2, 15):
            with self.assertRaises(ValueError):
                ssm(x, window)

    def test_hog_zero_shape_and_repeatability(self):
        assert_allclose(log_hog(np.zeros((7, 7))), np.zeros((7, 150)))
        assert_allclose(log_hog(np.zeros((1, 1))), np.zeros((1, 150)))
        img = ssm(np.arange(39).reshape(13, 3))
        h = log_hog(img)
        self.assertEqual(h.shape, (13, 150))
        self.assertTrue(np.isfinite(h).all() and (h >= 0).all() and np.any(h > 0))
        assert_allclose(h, log_hog(img), atol=0)

    def test_hog_independent_triangular_integration(self):
        # Evaluate the triangular basis at every cell centre directly, without
        # floor/bin assignment or scatter-add used by the vectorized port.
        from scipy.ndimage import correlate
        img = ssm(np.random.default_rng(12).normal(size=(6, 3)))
        gx = correlate(img, np.array([[-1., 0., 1.]]), mode='constant')
        gy = correlate(img, np.array([[1.], [0.], [-1.]]), mode='constant')
        orientation = np.arctan(gy / (gx + .0001)) % np.pi
        sizes = [np.pi/8, np.log(30)/4, np.pi/6]
        expected = []
        for c in range(len(img)):
            hist = np.zeros((8, 4, 6))
            for i in range(len(img)):
                for j in range(i, len(img)):
                    r = np.hypot(i-c, j-c)
                    magnitude = np.hypot(gx[i, j], gy[i, j])
                    if r == 0 or r > 30 or magnitude < 1e-5:
                        continue
                    coords = [np.arctan2(j-i, i+j-2*c), np.log(r), orientation[i, j]]
                    weights = [np.maximum(1 - np.abs(value/size - (np.arange(n)+.5)), 0)
                               for value, size, n in zip(coords, sizes, (8, 4, 6))]
                    hist += magnitude * np.einsum('i,j,k->ijk', *weights)
            hist /= np.sqrt(np.sum(hist**2) + 1e-6)
            hist = np.minimum(hist, .6)
            hist /= np.sqrt(np.sum(hist**2) + 1e-6)
            expected.append(np.r_[hist[:, 0].sum(axis=0), hist[:, 1:].ravel()])
        assert_allclose(log_hog(img), expected, atol=1e-12)

    def test_vq_hand_fixture_and_uneven_boundaries(self):
        centers = np.array([[0.], [10.]])
        x = np.array([[0.], [1.], [9.], [10.]])
        assert_allclose(vq_pyramid(x, centers, 1), [.5, .5, 1, 0, 0, 1])
        # MATLAB round(1:2.5:5) is [1,4], unlike ceil-based sparse bins.
        assert_allclose(vq_pyramid(np.array([[0.], [0.], [10.], [10.], [10.]]), centers, 1),
                        [.4, .6, 2/3, 1/3, 0, 1])
        with self.assertRaises(ValueError):
            vq_pyramid(x[:1], centers, 2)

    def test_kernel_weight_identity_and_psd(self):
        rng = np.random.default_rng(3)
        x = rng.random((8, 14))
        k = pyramid_kernel(x, x, 2, 2)
        # Independent expanded positive weights: 1/4, 1/4, 1/2.
        oracle = sum(w * np.minimum(x[:, None, a:b], x[None, :, a:b]).sum(axis=2)
                     for w, a, b in [(0.25, 0, 2), (0.25, 2, 6), (0.5, 6, 14)])
        assert_allclose(k, oracle)
        self.assertGreaterEqual(np.linalg.eigvalsh(k).min(), -1e-10)

    def test_sparse_closed_form_and_independent_optimizer(self):
        rng = np.random.default_rng(5)
        x = rng.normal(size=(5, 4))
        expected = np.sign(x) * np.maximum(np.abs(x) - .15, 0) / 1.0002
        assert_allclose(sparse_codes(x, np.eye(4)), expected, atol=1e-10)
        b = rng.normal(size=(4, 3))
        codes = sparse_codes(x, b)
        for row, code in zip(x, codes):
            # Independent smooth constrained formulation with positive/negative parts.
            def objective(z):
                c = z[:3] - z[3:]
                error = b @ c - row
                value = .5 * error @ error + .0001 * (c @ c) + .15 * z.sum()
                grad = b.T @ error + .0002 * c
                return value, np.r_[grad + .15, -grad + .15]
            opt = minimize(objective, np.zeros(6), jac=True, bounds=[(0, None)]*6,
                           method='L-BFGS-B', options={'ftol': 1e-14, 'gtol': 1e-10})
            self.assertTrue(opt.success)
            assert_allclose(code, opt.x[:3] - opt.x[3:], atol=2e-6)
        self.assertLess(kkt_residual(codes, b.T @ b + .0002*np.eye(3), -x @ b, .15), 1e-8)

    def test_sparse_pool_zero_short_and_hand_fixture(self):
        assert_allclose(sparse_pool(np.zeros((1, 3))), np.zeros(21))
        c = np.array([[1., -2.], [-3., 1.]])
        expected = np.array([3, 2, 1, 2, 3, 1], dtype=float)
        assert_allclose(sparse_pool(c, (1, 2)), expected / np.linalg.norm(expected))

    def test_matlab_blockers_fixed(self):
        for name in ('gene_descriptor.m', 'gene_descriptor_samples.m'):
            self.assertIn('if ssm_flag == 1', (ROOT/'experiments/ASL'/name).read_text())
        for dataset in ('ASL', 'MSRAction3D', 'MSRC12'):
            self.assertIn('if pooledNorm > 0', (ROOT/'experiments'/dataset/'sc_pooling_ts.m').read_text())


def fixtures():
    """Distinct line/circle/helical trajectories with disjoint seeded noise."""
    sets = []
    for seed, count in [(17, 6), (29, 3)]:
        rng = np.random.default_rng(seed)
        sequences, labels = [], []
        for label in range(3):
            for _ in range(count):
                t = np.linspace(0, 2*np.pi, 32)
                if label == 0:
                    x = np.column_stack((t, 0*t, 0*t))
                elif label == 1:
                    x = np.column_stack((np.cos(t), np.sin(t), 0*t))
                else:
                    x = np.column_stack((np.cos(3*t), np.sin(3*t), t/3))
                x = 1000 * (x + rng.normal(scale=.01, size=x.shape))
                sequences.append(x)
                labels.append(label)
        sets.append((sequences, np.asarray(labels)))
    return sets


def libsvm(train, test, train_y, test_y, kernel, directory, suffix):
    paths = [directory / (suffix + ext) for ext in ('.train', '.test', '.model', '.prediction')]
    for path, matrix, labels in zip(paths, (train, test), (train_y, test_y)):
        with path.open('w') as output:
            for i, (row, label) in enumerate(zip(matrix, labels)):
                values = ' '.join(f'{j+1}:{v:.17g}' for j, v in enumerate(row))
                serial = f'0:{i+1} ' if kernel == 4 else ''
                output.write(f'{label} {serial}{values}\n')
    subprocess.run([str(directory/'svm-train'), '-q', '-t', str(kernel), '-c', '10',
                    str(paths[0]), str(paths[2])], check=True, capture_output=True, env=SANITIZER_ENV)
    subprocess.run([str(directory/'svm-predict'), str(paths[1]), str(paths[2]), str(paths[3])],
                   check=True, capture_output=True, env=SANITIZER_ENV)
    predictions = np.loadtxt(paths[3])
    return float(np.mean(predictions == test_y))


def native_distance_checks(directory):
    from scipy.spatial.distance import cdist
    rng = np.random.default_rng(11)
    for norm, metric in [(1, 'cityblock'), (2, 'euclidean')]:
        source = ROOT / f'iid/matching/src/distance_matrix/distance_matrix_norm{norm}.cpp'
        binary = directory / f'distance{norm}'
        support = ROOT / 'tools/validation'
        subprocess.run(['clang++', '-std=c++11', '-fsanitize=address,undefined',
                        '-I', str(support), str(source), str(support/'distance_driver.cpp'),
                        '-o', str(binary)], check=True, capture_output=True)
        for m, n, d in [(1, 1, 3), (5, 7, 6), (17, 13, 9)]:
            a, b = rng.normal(size=(m, d)), rng.normal(size=(n, d))
            values = np.r_[a.ravel(order='F'), b.ravel(order='F')]
            payload = f'{m} {n} {d}\n' + ' '.join(format(x, '.17g') for x in values)
            output = subprocess.run([str(binary)], input=payload, text=True, capture_output=True, check=True, env=SANITIZER_ENV)
            actual = np.fromstring(output.stdout, sep=' ').reshape((m, n), order='F')
            assert_allclose(actual, cdist(a, b, metric), atol=1e-12)
    METRICS['native_distance'] = {'fixtures': 6, 'sanitizers': ['address', 'undefined'],
                                  'scope': 'valid inputs only; MEX test shim, not MATLAB ABI'}


def pipeline():
    (train_x, train_y), (test_x, test_y) = fixtures()
    with tempfile.TemporaryDirectory(prefix='tssm-native-') as temp:
        directory = Path(temp)
        native_distance_checks(directory)
        source = ROOT/'thirdparty/libsvm-3.17'
        for binary in ('svm-train', 'svm-predict'):
            subprocess.run(['clang++', '-O1', '-g', '-fsanitize=address,undefined', '-x', 'c++', str(source/(binary+'.c')),
                            str(source/'svm.cpp'), '-o', str(directory/binary)],
                           check=True, capture_output=True)
        for sigmoid in (False, True):
            train = [log_hog(ssm(x, sigmoid=sigmoid)) for x in train_x]
            test = [log_hog(ssm(x, sigmoid=sigmoid)) for x in test_x]
            centers = vocabulary(train)
            saved = centers.copy()
            a = np.array([vq_pyramid(x, centers) for x in train])
            b = np.array([vq_pyramid(x, centers) for x in test])
            assert_allclose(centers, saved, atol=0)
            assert_allclose(vocabulary(train), centers, atol=0)
            kt = pyramid_kernel(a, a, 8)
            kv = pyramid_kernel(b, a, 8)
            assert np.linalg.eigvalsh(kt).min() > -1e-8
            vq_accuracy = libsvm(kt, kv, train_y, test_y, 4, directory, 'vq')
            dictionary, objectives = learn_dictionary(train)
            assert np.max(np.diff(objectives)) < 1e-7
            assert np.max(np.linalg.norm(dictionary, axis=0)) <= 1 + 1e-10
            saved = dictionary.copy()
            a = np.array([sparse_pool(sparse_codes(x, dictionary)) for x in train])
            b = np.array([sparse_pool(sparse_codes(x, dictionary)) for x in test])
            assert_allclose(dictionary, saved, atol=0)
            assert np.isfinite(a).all() and np.isfinite(b).all()
            sc_accuracy = libsvm(a, b, train_y, test_y, 0, directory, 'sc')
            assert vq_accuracy >= 8/9 and sc_accuracy >= 8/9, (vq_accuracy, sc_accuracy)
            METRICS['sigmoid' if sigmoid else 'raw'] = {
                'train_sequences': len(train), 'held_out_sequences': len(test),
                'descriptor_shape': list(train[0].shape), 'vq_shape': [len(train), 56],
                'sparse_shape': list(a.shape), 'libsvm_sanitizers': ['address', 'undefined'], 'vq_ktpm_accuracy': vq_accuracy,
                'sparse_linear_accuracy': sc_accuracy, 'dictionary_objective': objectives}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, help='Write a JSON evidence report')
    args = parser.parse_args()
    if not __debug__:
        raise SystemExit('Validation requires assertions: do not use python -O')
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(NumericalChecks)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    if not result.wasSuccessful():
        raise SystemExit(1)
    pipeline()
    sources = ['ssm/Temporal_SSM.m', 'descriptor/Log_hogcalculator.m',
               'experiments/ASL/gene_codebook_pyramid.m', 'experiments/ASL/PyramidMatching.m',
               'experiments/ASL/sc_pooling_ts.m', 'thirdparty/libsvm-3.17/svm.cpp',
               'thirdparty/ScSPM/sparse_coding/L1QP_FeatureSign_yang.m']
    sources += ['iid/matching/src/distance_matrix/distance_matrix_norm1.cpp',
                'iid/matching/src/distance_matrix/distance_matrix_norm2.cpp']
    sources += [str(path.relative_to(ROOT)) for path in sorted((ROOT/'tools/validation').iterdir())
                if path.is_file()]
    evidence = {'scope': 'Python numerical reference and native LIBSVM; not MATLAB parity',
                'python': platform.python_version(), 'numpy': np.__version__, 'scipy': scipy.__version__,
                'unit_tests': result.testsRun, 'pipelines': METRICS,
                'source_hash_convention': 'Text CRLF normalized to LF',
                'source_sha256': {p: hashlib.sha256((ROOT/p).read_bytes().replace(b'\r\n', b'\n')).hexdigest() for p in sources}}
    if args.report:
        args.report.write_text(json.dumps(evidence, indent=2) + '\n')
    print(json.dumps(evidence, indent=2))


if __name__ == '__main__':
    main()
