#!/usr/bin/env python3
"""Compare actual MATLAB basis updates against independent constrained SciPy fits."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
import traceback

import numpy as np
from numpy.testing import assert_allclose
from scipy.io import loadmat, savemat
from scipy.optimize import minimize

ROOT = Path(__file__).resolve().parents[2]


def project(b, radius):
    return b * np.minimum(1, radius / np.maximum(np.linalg.norm(b, axis=0), np.finfo(float).tiny))


def fixtures():
    rng = np.random.default_rng(91)
    cases = []
    def add(name, s, x=None, radius=1):
        if x is None:
            x = rng.normal(size=(3, s.shape[1]))
        cases.append(dict(name=name, S=s, X=x, radius=float(radius),
                          initial=rng.normal(size=(x.shape[0], s.shape[0]))))
    add('orthogonal_closed_form', np.eye(4), rng.normal(size=(3, 4))*3)
    add('full_rank', rng.normal(size=(4, 12)))
    add('unused_atoms', np.vstack((rng.normal(size=(3, 11)), np.zeros((2, 11)))))
    row = rng.normal(size=(1, 10))
    add('duplicate_rows', np.vstack((row, row, 2*row, np.zeros((1, 10)))))
    add('near_duplicate_rows', np.vstack((row, row+1e-10*rng.normal(size=row.shape), 2*row)))
    add('more_atoms_than_samples', rng.normal(size=(10, 4)))
    add('zero_codes', np.zeros((4, 9)))
    add('zero_data', rng.normal(size=(4, 9)), np.zeros((3, 9)))
    add('zero_radius', rng.normal(size=(4, 9)), radius=0)
    add('small_radius', rng.normal(size=(4, 9)), radius=.2)
    for seed in range(6):
        r = np.random.default_rng(seed)
        s = r.normal(size=(5, 9)); s[3:] = 0
        add(f'random_inactive_{seed}', s)
    return cases


def run(octave, prefix, work):
    cases = fixtures()
    cells = np.empty((1, len(cases)), dtype=object)
    for i, case in enumerate(cases):
        cells[0, i] = case
    savemat(work/'basis_fixtures.mat', {'cases': cells})
    env = os.environ.copy()
    if prefix:
        env.update(OCTAVE_HOME=str(prefix.resolve()), OCTAVE_EXEC_HOME=str(prefix.resolve()))
    quote = lambda p: str(p).replace("'", "''")
    expression = (f"addpath('{quote(Path(__file__).parent)}'); "
                  f"basis_regression('{quote(ROOT)}','{quote(work)}');")
    with (work/'basis.log').open('w') as log:
        subprocess.run([octave, '--quiet', '--eval', expression], check=True,
                       stdout=log, stderr=subprocess.STDOUT, env=env, timeout=300)
    results = loadmat(work/'basis_results.mat', squeeze_me=True)
    evidence = []
    for c, b, method, pg in zip(cases, results['solutions'], results['methods'], results['residuals']):
        x, s, radius = c['X'], c['S'], c['radius']
        d, k = b.shape
        initial = project(c['initial'], radius)
        def objective(v):
            z = v.reshape(d, k)
            error = z@s-x
            return .5*np.sum(error**2), (error@s.T).ravel()
        def constraint(v):
            return radius**2-np.sum(v.reshape(d, k)**2, axis=0)
        def jac(v):
            z = v.reshape(d, k)
            out = np.zeros((k, d, k))
            for j in range(k):
                out[j, :, j] = -2*z[:, j]
            return out.reshape(k, -1)
        got = objective(b.ravel())[0]
        assert got <= objective(initial.ravel())[0]+1e-8
        assert np.max(np.linalg.norm(b, axis=0)) <= radius*(1+1e-12)
        inactive = np.all(s == 0, axis=1)
        assert_allclose(b[:, inactive], initial[:, inactive], atol=1e-12)
        if radius == 0:
            oracle = .5*np.sum(x*x)
            assert_allclose(b, 0, atol=0)
        else:
            opt = minimize(objective, initial.ravel(), jac=True, method='SLSQP',
                           constraints={'type': 'ineq', 'fun': constraint, 'jac': jac},
                           options={'ftol': 1e-11, 'maxiter': 3000})
            if not opt.success:
                raise AssertionError(f"Independent solver failed for {c['name']}: {opt.message}")
            oracle = opt.fun
            assert_allclose(got, oracle, atol=1e-7, rtol=1e-7, err_msg=c['name'])
        if c['name'] == 'orthogonal_closed_form':
            assert_allclose(b, project(x, radius), atol=1e-8)
        evidence.append(dict(name=c['name'], method=str(method), objective=float(got),
                             oracle_objective=float(oracle), max_atom_norm=float(np.max(np.linalg.norm(b, axis=0))),
                             projected_gradient_residual=float(pg)))
    sources = ['thirdparty/ScSPM/sparse_coding/l2ls_learn_basis_dual.m',
               'thirdparty/ScSPM/sparse_coding/reg_sparse_coding.m',
               'tools/validation/basis_regression.m', 'tools/validation/basis_validation.py']
    return dict(passed=True, timestamp_utc=datetime.now(timezone.utc).isoformat(), cases=evidence,
                injected_solver_failure_cases=2, invalid_input_cases=int(results['invalid']),
                source_hash_convention='Text CRLF normalized to LF',
                source_sha256={n: hashlib.sha256((ROOT/n).read_bytes().replace(b'\r\n', b'\n')).hexdigest() for n in sources})


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--octave', required=True)
    p.add_argument('--conda-prefix', type=Path)
    p.add_argument('--work-dir', type=Path)
    p.add_argument('--report', required=True, type=Path)
    args = p.parse_args()
    if not __debug__:
        raise SystemExit('Do not disable validation assertions with -O')
    with tempfile.TemporaryDirectory(prefix='tssm-basis-') as temp:
        work = args.work_dir.resolve() if args.work_dir else Path(temp)
        work.mkdir(parents=True, exist_ok=True)
        try:
            result = run(args.octave, args.conda_prefix, work)
        except Exception:
            result = dict(passed=False, error=traceback.format_exc())
            if (work/'basis.log').exists():
                result['octave_log'] = (work/'basis.log').read_text()
        args.report.write_text(json.dumps(result, indent=2)+'\n')
        print(json.dumps({k:v for k,v in result.items() if k!='source_sha256'}, indent=2))
        raise SystemExit(0 if result['passed'] else 1)


if __name__ == '__main__':
    main()
