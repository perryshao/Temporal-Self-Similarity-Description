# Rank-deficient sparse dictionary updates

The previously failing fixed Gaussian initialization is now a mandatory passing
regression, together with six runs of the actual default uniform initializer.
See `BASIS_VALIDATION.json` for independent fixed-code solver checks and
`OCTAVE_VALIDATION.json` for original-code training and classifier results.

## Cause

For fixed coefficients S, dictionary learning minimizes
`0.5 * ||X - B*S||_F^2` subject to each atom norm being at most the given radius.
Unused coefficient rows and dependent active rows make `S*S'` singular. The old
dual objective explicitly inverted `S*S' + diag(lambda)` even when a multiplier
was zero. It also used the optimizer's output despite unsuccessful termination,
without checking atom feasibility or stationarity. The recorded failing atom
norm was 1.1225191149073246 for a radius of 1.

## Correction

`l2ls_learn_basis_dual` keeps the dual formulation for well-conditioned active
codes, uses Cholesky solves, and accepts a candidate only after feasibility and
projected-gradient certification. An exception, failed exit flag, or an invalid
candidate triggers cyclic constrained block minimization of the **same primal
objective**. Each atom update solves its single-block least-squares problem
exactly by projecting onto its permitted Euclidean ball. No ridge term is added,
and final clipping alone is not used as proof of a valid solution.

Unused atoms are excluded from the linear system. They retain their feasible
warm-start values because they do not influence the fixed-code objective. The
training loop now supplies its current dictionary as that warm start, rather
than allowing unused atoms to be discarded. All-zero coefficients and radius
zero have explicit solutions. The public one-output API still works; an optional
second output exposes method, objective and convergence diagnostics.

Every successful update must have finite values, atom norms within floating-point
tolerance, a scaled projected-gradient residual no larger than 1e-9, and no
increase in the fixed-code objective. The fallback is bounded at 10,000 sweeps;
if it cannot certify convergence, it raises `TSSM:DictionaryConvergence` instead
of returning an unchecked dictionary. Training records maximum residual and atom
norm per epoch. Parameter values and the sparse coding objective are unchanged.

## Tests

```sh
python3 tools/validation/basis_validation.py \
  --octave /tmp/iid-octave/bin/octave-cli --conda-prefix /tmp/iid-octave \
  --work-dir /tmp/tssm-basis-check --report /tmp/tssm-basis.json
python3 tools/validation/octave_validation.py \
  --octave /tmp/iid-octave/bin/octave-cli --conda-prefix /tmp/iid-octave \
  --work-dir /tmp/tssm-pipeline-check --report /tmp/tssm-pipeline.json
```

Use a normal Octave path and omit `--conda-prefix` outside this local Conda setup.
The package requirements are listed in `OCTAVE_VALIDATION.md`.

- Sixteen fixed-code cases cover full rank, zero codes/data/radius, unused atoms,
  duplicate and nearly duplicate rows, more atoms than samples, and six random
  inactive-row fixtures. MATLAB/Octave solutions are compared with independent
  SciPy SLSQP solutions; the orthogonal case also has a closed-form oracle.
  Nonunique dictionaries are compared by objective and optimality, not by bytes.
- Two injected dual-solver failures cover an exception and a false success flag
  returning an infeasible unconstrained solution. Both must fall back correctly.
- Three invalid-input cases check explicit errors. Singular-matrix warnings are
  promoted to errors during Octave tests.
- Seven original-code training regressions include the former Gaussian failure,
  raw SSM default-uniform seeds 0/1/7/71 and sigmoid default-uniform seeds 0/1.
  All epoch norms must be <= 1+1e-12, residuals <= 1e-9, and objectives must not
  increase. This is much stricter than the old 1.01 diagnostic limit.
- Six existing BoF/VQ/ScSPM classifier paths and Python/C++ sanitizer checks remain
  in the full validation run.

This fixes the observed singular-system and norm-violation defect. Alternating
sparse dictionary learning is still nonconvex: different initializations may
produce different dictionaries and recognition accuracy. These synthetic tests
do not establish global optimality or published benchmark reproduction.
