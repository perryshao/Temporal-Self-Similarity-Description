# Original-code validation with Python, C++ sanitizers and Octave

This extends the Python-only reference layer using the approach in the IID
project: independent Python calculations, instrumented native code, and actual
MATLAB source execution under GNU Octave. Results are in
[OCTAVE_VALIDATION.json](OCTAVE_VALIDATION.json) and
[PIPELINE_VALIDATION.json](PIPELINE_VALIDATION.json).

## Reproduce

Python 3.9–3.12, NumPy/SciPy from `tools/validation/requirements.txt`, Clang C/C++,
Octave with its MEX compiler, LP64 BLAS/LAPACK libraries and these Octave packages
are required. Tested: Octave 10.3.0, image 2.20.1, statistics 1.7.5, optim 1.6.3,
struct 1.0.18. Newer statistics versions may require a newer Octave. Optim 1.6.2
failed to compile against Octave 10; 1.6.3 worked.

```sh
python3 tools/validation/validate.py --report /tmp/tssm-native.json
python3 tools/validation/octave_validation.py \
  --octave /path/to/octave-cli \
  --work-dir /tmp/tssm-octave-check \
  --report /tmp/tssm-octave.json
```

On this Mac the IID Conda runtime can be reused with:

```sh
python3 tools/validation/octave_validation.py \
  --octave /tmp/iid-octave/bin/octave-cli --conda-prefix /tmp/iid-octave \
  --work-dir /tmp/tssm-octave-check --report /tmp/tssm-octave.json
```

`--conda-prefix` applies only the macOS child-process environment workaround for
that runtime's relocated compiler flags; normal Octave installations do not need
it. Packages are registered through Octave's normal per-user package mechanism.
No runtime, datasets, compiled modules or generated descriptors are added to Git.
`--work-dir` retains fixtures and `octave.log`; omit it to use temporary storage.
An explicit invalid runtime or failed comparison exits nonzero, without falling
back to a Python substitute. Running Python with `-O` is rejected.

## What executes

Seven fresh Octave MEX modules are built from repository sources: L1/L2 distances,
histogram intersection, Yael k-means/nearest-neighbour, and LIBSVM train/predict.
Builds stay in the test directory; historical binaries are never overwritten.
The two distance kernels and native LIBSVM CLI train/predict also run under
AddressSanitizer and UndefinedBehaviorSanitizer. Reports stop on the first
sanitizer error. Leak detection is disabled for platform compatibility. This
checks the exercised native paths, not every MEX gateway or invalid input.

The suite runs original `.m` functions for:

- Raw and sigmoid SSM, odd frame windows and L1 distances; the separate MSRAction3D
  Temporal_SSM signature is checked against the common sigmoid formula.
- Log-HOG, LocalSSM, and both SameBlock variants. LocalSSM default and explicit
  calls must agree. The main Log-HOG path is compared numerically with Python.
- Both ASL raw/sigmoid training/test descriptor-generator pairs, including their
  16-bit-range scaling, file names, MAT save/load, and all-zero trajectories.
- Actual Yael codebook learning, BoF/VQ, temporal histogram pyramids and matching.
- Original FeatureSign coefficient optimization and each ASL/MSRAction3D/MSRC12
  `sc_pooling_ts` copy, including empty temporal bins and a zero-code sequence.
- Original ScSPM `reg_sparse_coding` and its dual constrained basis optimizer,
  followed by actual LIBSVM MEX training and prediction.

Twelve intermediate arrays are compared with Python. SSM/HOG/VQ/kernel errors
are around machine precision; sparse coefficients agree within 2e-7 and their
independent KKT residual must be below 1e-8. Dictionary norms, projected-gradient residuals and objective
descent are checked. Independent constrained-basis tests are documented in
[the sparse dictionary correction](SPARSE_DICTIONARY_FIX.md). SameBlock/LocalSSM coverage is execution/finiteness coverage,
not full cross-language parity of every descriptor variant.

Six complete synthetic paths combine raw/sigmoid SSM with BoF-linear-SVM,
VQ-KTPM-SVM and ScSPM-linear-SVM. Each starts at the actual ASL descriptor
generators and uses 18 training/9 held-out noisy 3-D sequences across three
classes. All six scored 9/9 in the recorded run; the smoke gate is at least 8/9.
This is not a benchmark accuracy estimate. VQ retains K=floor(training rows/10).
The small sparse fixture uses eight atoms and three learning epochs. Its initial
atoms come from Yael fitted to training descriptors only; no test data is fitted.
Published experiment sample counts, repetitions and other settings are unchanged.

## Corrections supported by runtime evidence

1. `learnCodebook.m` requested five outputs from a different Yael options-struct
   interface. The bundled v438 wrapper rejected it. It now uses single-precision
   vectors and the bundled name/value interface, retaining the seed and iteration
   limit. This is a documented local adaptation to the vendored BoF helper.
2. Four ASL generator entry points divided zero SSMs by zero; Log-HOG then failed
   with a NaN subscript. Zero SSMs now stay zero. Nonzero scaling is unchanged.
3. Octave optim rejected the legacy ambiguous `Hessian` option. The sparse basis
   learner uses `HessianFcn='objective'` only under Octave; the original MATLAB
   branch and objective are retained. Octave and MATLAB optimization backends
   are not claimed to produce identical dictionaries.

## Known failing case and remaining limits

The previously failing random-initialization case is repaired; see
[the diagnosis, algorithm and regression checks](SPARSE_DICTIONARY_FIX.md).
It and six actual default-uniform initialization runs are now required to pass
strict per-epoch feasibility, stationarity and objective-descent checks. Results
appear under `random_initialization_regressions` in JSON, not as an accepted
known failure. Random initialization can still change learned dictionaries and
accuracy because alternating sparse learning is nonconvex.

There is no MATLAB runtime/ABI certification, published dataset reproduction,
OpenCV LogHog-MEX parity, exhaustive malformed-input memory audit, or end-to-end
coverage of DTW/HMM/regression/integral-invariant alternatives. The vendored IID
snapshot is not automatically upgraded by borrowing IID's validation strategy.
Existing issues in `REVIEW.md` remain unless explicitly corrected above.
Compiler warnings in historical code (including the LIBSVM quiet callback return
and Yael verbose printf format) remain outside the exercised sanitizer harness.

JSON source hashes normalize CRLF to LF so Git line-ending conversion does not
invalidate source identity. The Octave report includes the mapped source tree,
not a claim that every hashed function was executed.
