# Portable pipeline validation

Run from the repository root (Python 3.9–3.12 and Clang C++ are required):

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r tools/validation/requirements.txt
.venv/bin/python tools/validation/validate.py --report /tmp/tssm-validation.json
```

A nonzero exit means a numerical assertion, solver convergence, compilation, or
pipeline check failed. Binaries and intermediate classifier files live in a
TemporaryDirectory and are removed. The report is optional. Do not run Python
with `-O`, which disables pipeline assertions. No datasets or MATLAB are needed.

## What ran

The committed `PIPELINE_VALIDATION.json` records the actual local run, dependency
versions, numerical results, and source hashes. Eight test methods passed, followed
by six native distance fixtures and four complete synthetic classification paths:

- raw Euclidean SSM → log-polar HOG → k-means/VQ → temporal pyramid match → native LIBSVM;
- sigmoid Euclidean SSM → the same VQ/KTPM/SVM path;
- raw Euclidean SSM → log-polar HOG → learned sparse dictionary → sparse codes → temporal max pooling → native linear LIBSVM;
- sigmoid Euclidean SSM → the same sparse coding/pooling/SVM path.

Each path uses 18 training and 9 held-out noisy 3-D trajectories, three classes,
32 frames per trajectory, 150-dimensional HOG, eight words/atoms, and levels
1/2/4. Training and testing use separate fixed random seeds. Vocabulary and sparse
dictionary fitting receive training descriptors only. Test encoding does not
modify fitted parameters. All four paths classified all nine held-out examples
correctly. The gate is at least 8/9; this is an easy smoke dataset, **not a research
benchmark or an estimate of ASL/MSRAction3D/MSRC12 accuracy**.

## Evidence and source mapping

| Stage | Reference/source | Verification and substitution |
|---|---|---|
| SSM | `ssm/Temporal_SSM.m`, `iid/matching/src/distance_matrix/distance_matrix_norm{1,2}.cpp` | Python odd-window L1/L2 distances compared with direct nested-loop formula; translation, rotation (L2), reversal and sigmoid checks. Original C++ kernels compiled unmodified under ASan/UBSan and compared with SciPy on six valid unequal-size/fractional-input fixtures. |
| Log-HOG | `descriptor/Log_hogcalculator.m` | Default unsigned MATLAB path ported to NumPy; independent direct triangular-basis integration on a nonzero fixture, plus zero/one-frame/shape checks. Preserves zero padding, epsilon, cropped orientation votes, 0.6 L2-Hys threshold, and merging centre cells after normalization. |
| VQ | `thirdparty/computeBoV/computeBoV.m`, ASL `gene_codebook_pyramid.m` | SciPy k-means replaces Yael. Nearest-centroid assignment and normalized histograms checked by hand fixtures, including uneven round-based bins. Training initialization/centroids need not match Yael. |
| KTPM | ASL `PyramidMatching.m` | Histogram-intersection formula checked against independently expanded positive level weights and a positive-semidefinite Gram matrix check. |
| Sparse coefficients | `thirdparty/ScSPM/sparse_coding/L1QP_FeatureSign_yang.m` | Coordinate descent solves the same convex coefficient objective at the pooling ridge (2e-4) and gamma=.15. Checked against the identity-dictionary closed form, independent constrained L-BFGS-B solution and KKT residual below 1e-8. This does not execute FeatureSign itself. |
| Dictionary | `reg_sparse_coding.m` concept | Small alternating unit-ball atom updates replace the historical dual optimizer. Objective descent and atom constraints checked. Five fixture epochs/eight atoms are not original experiment hyperparameters; regularization is aligned with the pooling objective, not claimed identical to ScSPM training. |
| Pooling | `experiments/*/sc_pooling_ts.m` | Ceil-based assignment, absolute max per bin, global L2; hand fixture and zero/short sequence checks. |
| SVM | `thirdparty/libsvm-3.17/svm.cpp`, `svm-train.c`, `svm-predict.c` | Actual bundled C++ implementation compiled and run, with precomputed KTPM and linear sparse features. No sklearn replacement. |

The shim headers under `tools/validation` only implement the few array operations
needed by the two distance kernels. They do not validate MATLAB ABI, invalid-input
safety, or the prebuilt MEX binaries. Do not place that directory on a MEX include
path for production builds.

## Functional corrections in this change

- ASL `gene_descriptor` and `gene_descriptor_samples`: `if ssm_flag == 1` fixes
  assignment syntax in the condition.
- `LocalSsmcalculator`: initialize L2-Hys for both default and explicit calls.
- All three `sc_pooling_ts` copies: leave an all-zero pooled vector at zero rather
  than dividing by zero. Nonzero vectors use the same normalization as before.

MATLAB changes were inspected and guarded with targeted source checks; the numeric
zero policy is tested in the Python reference. This is not MATLAB execution.

## Boundaries and outstanding work

This validates complete **portable core algorithm paths**, not all historical
MATLAB experiment scripts. Dataset parsers, Kalman preprocessing, integral
invariants, joint-group fusion, SameBlock/LocalSSM alternatives, HMM/DTW/regression,
Yael, MATLAB FeatureSign and the OpenCV LogHog MEX are not exercised end to end.
The distinct MSRAction3D Temporal_SSM signature is not replaced. The two ASL
experimental settings and retained NTU historical code are unchanged.

Known unresolved experimental blockers remain in `REVIEW.md`, including the
incomplete `gene_TSSM` branch, regression objective/gradient inconsistency, and
legacy distance/DTW branches. A passing reference run must not be represented as
proof these scripts run. To establish MATLAB parity later, export identical
trajectory/descriptor fixtures from MATLAB, compare each intermediate array,
rebuild MEX modules for the target ABI, and run the actual dataset protocols.
The Cross-View checkout contained no reusable validation suite at the time of
this work; these checks make the alternative numerical/smoke strategy reproducible
inside this repository.
