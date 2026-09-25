#!/usr/bin/env python3
"""Execute original MATLAB functions in Octave and compare with Python oracles."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import traceback

import numpy as np
from numpy.testing import assert_allclose
from scipy.io import loadmat, savemat
from scipy.spatial.distance import cdist

from reference import ssm, log_hog, sparse_codes, sparse_pool, pyramid_kernel, kkt_residual
from validate import fixtures

ROOT = Path(__file__).resolve().parents[2]


def run(octave, work, conda_prefix=None):
    rng = np.random.default_rng(37)
    (train_x, train_y), (test_x, test_y) = fixtures()
    def cells(xs):
        values = np.empty((1, len(xs)), dtype=object)
        for i, x in enumerate(xs):
            values[0, i] = x
        return values
    dictionary = rng.normal(size=(6, 4))
    dictionary /= np.linalg.norm(dictionary, axis=0)
    features = rng.normal(size=(13, 6))
    centers = rng.normal(size=(5, 6))
    histograms = rng.uniform(size=(7, 14))
    initial = rng.normal(size=(150, 8))
    initial -= initial.mean(axis=0)
    initial /= np.linalg.norm(initial, axis=0)
    x = train_x[0]
    savemat(work/'fixtures.mat', dict(trajectory=x, dictionary=dictionary,
            features=features, centers=centers, histograms=histograms,
            init_dictionary=initial, train_x=cells(train_x), test_x=cells(test_x),
            train_y=train_y.astype(float)[:, None], test_y=test_y.astype(float)[:, None]))
    quote = lambda x: str(x).replace("'", "''")
    expression = (f"addpath('{quote(Path(__file__).parent)}'); "
                  f"run_octave_validation('{quote(ROOT)}', '{quote(work)}');")
    env = os.environ.copy()
    if conda_prefix:
        if sys.platform != 'darwin':
            raise ValueError('--conda-prefix is a macOS relocation workaround only')
        prefix = str(conda_prefix.resolve())
        env.update(OCTAVE_HOME=prefix, OCTAVE_EXEC_HOME=prefix,
                   CPPFLAGS='-DTSSM_VALIDATION_BUILD', CFLAGS='-O2',
                   CXXFLAGS='-O2 -std=c++17', XTRA_CFLAGS='-fPIC', XTRA_CXXFLAGS='-fPIC',
                   LDFLAGS=f'-L{prefix}/lib -Wl,-rpath,{prefix}/lib',
                   DL_LDFLAGS='-bundle -Wl,-undefined,dynamic_lookup')
    with (work/'octave.log').open('w') as log:
        process = subprocess.run([octave, '--quiet', '--no-gui', '--eval', expression],
                                 stdout=log, stderr=subprocess.STDOUT, env=env, timeout=900)
    if process.returncode:
        raise RuntimeError(f'Octave failed; see {work / "octave.log"}\n'
                           + (work/'octave.log').read_text()[-3500:])
    actual = loadmat(work/'octave_results.mat', squeeze_me=True)
    comparisons = {}
    def compare(name, expected, tolerance=1e-9):
        got = actual[name]
        assert_allclose(got, expected, atol=tolerance, rtol=tolerance, err_msg=name)
        comparisons[name] = float(np.max(np.abs(got - expected)))
    raw, sig = ssm(x), ssm(x, sigmoid=True)
    compare('raw', raw)
    compare('sig', sig)
    compare('win', ssm(x, 3))
    compare('l1', ssm(np.c_[x, x], 3, 'cityblock'))
    compare('hog_raw', log_hog(raw))
    compare('hog_sig', log_hog(sig))
    compare('generated_raw', log_hog(np.floor(raw/raw.max()*65535)))
    compare('generated_sig', log_hog(np.floor(sig/sig.max()*65535)))
    codes = sparse_codes(features, dictionary)
    compare('codes', codes.T, 2e-7)
    compare('pools', np.tile(sparse_pool(codes), (3, 1)), 2e-7)
    labels = cdist(features.astype(np.float32), centers.astype(np.float32)).argmin(axis=1)
    compare('bov', np.bincount(labels, minlength=5)/len(features))
    compare('kernel', pyramid_kernel(histograms, histograms, 2))
    kkt = kkt_residual(actual['codes'].T, dictionary.T@dictionary+.0002*np.eye(4),
                       -features@dictionary, .15)
    assert kkt < 1e-8
    for objective in actual['dictionary_objectives']:
        assert np.all(np.diff(objective) <= 1e-7)
    accuracy = actual['accuracies']
    assert np.all(accuracy >= 8/9)
    assert np.all(actual['random_init_norms'] <= 1+1e-12)
    assert np.all(actual['random_init_residuals'] <= 1e-9)
    assert np.all(np.diff(actual['random_init_objectives'], axis=1) <= 1e-7)
    hashes = {}
    # Bind to all tracked active numerical sources and validation files; no data.
    for folder in ('ssm', 'descriptor', 'experiments', 'thirdparty/computeBoV',
                   'thirdparty/ScSPM/sparse_coding', 'thirdparty/yael_v438',
                   'thirdparty/libsvm-3.17', 'iid/matching/src', 'tools/validation'):
        for path in sorted((ROOT/folder).rglob('*')):
            if path.suffix in {'.m', '.c', '.cpp', '.h', '.py'}:
                hashes[str(path.relative_to(ROOT))] = hashlib.sha256(path.read_bytes().replace(b'\r\n', b'\n')).hexdigest()
    return dict(timestamp_utc=datetime.now(timezone.utc).isoformat(), passed=True,
                octave_version=str(actual['octave_version']),
                package_versions=actual['package_versions'].tolist(),
                scope='Original .m and seven rebuilt Octave MEX modules; synthetic data only',
                comparison_max_abs_error=comparisons, feature_sign_kkt_residual=kkt,
                pipeline_accuracy_rows=['raw', 'sigmoid'],
                pipeline_accuracy_columns=['VQ_KTPM_SVM', 'BoF_linear_SVM', 'ScSPM_linear_SVM'],
                pipeline_accuracies=accuracy.tolist(),
                dictionary_objectives=[np.atleast_1d(v).tolist() for v in actual['dictionary_objectives']],
                dictionary_norm_max=[float(np.max(v)) for v in actual['dictionary_norms']],
                random_initialization_regressions={
                    'names': actual['random_init_names'].tolist(),
                    'max_atom_norm_per_epoch': actual['random_init_norms'].tolist(),
                    'stationarity_residual_per_epoch': actual['random_init_residuals'].tolist(),
                    'objective_per_epoch': actual['random_init_objectives'].tolist(),
                    'passed': bool(np.all(actual['random_init_norms'] <= 1+1e-12)
                                   and np.all(actual['random_init_residuals'] <= 1e-9)
                                   and np.all(np.diff(actual['random_init_objectives'], axis=1) <= 1e-7))},
                source_hash_convention='Text CRLF normalized to LF', source_sha256=hashes)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--octave', required=True, help='Path to octave-cli')
    parser.add_argument('--work-dir', type=Path, help='Retain generated fixtures and logs')
    parser.add_argument('--conda-prefix', type=Path, help='macOS Conda relocation workaround')
    parser.add_argument('--report', type=Path, required=True)
    args = parser.parse_args()
    if not __debug__:
        raise SystemExit('Validation requires assertions: do not use python -O')
    # An explicit runtime path must work; never silently downgrade to Python.
    temporary = None
    if args.work_dir:
        work = args.work_dir.resolve()
        work.mkdir(parents=True, exist_ok=True)
    else:
        temporary = tempfile.TemporaryDirectory(prefix='tssm-octave-')
        work = Path(temporary.name)
    try:
        report = run(args.octave, work, args.conda_prefix)
    except Exception:
        report = dict(passed=False, error=traceback.format_exc())
        if not args.work_dir and (work/'octave.log').exists():
            report['octave_log'] = (work/'octave.log').read_text()
    args.report.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'source_sha256'}, indent=2))
    if temporary:
        temporary.cleanup()
    raise SystemExit(0 if report['passed'] else 1)


if __name__ == '__main__':
    main()
