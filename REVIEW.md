# Code review and polish

## Scope and preservation

Reviewed the project pipeline and experiment variants: temporal SSMs, log-polar
HOG, vocabulary learning/VQ, sparse coding, temporal pyramids, classifiers,
loaders and preprocessing. Project MATLAB/C/C++ formatting and MATLAB help were
updated. Published experiment parameters, commented alternative methods, data
paths and executable algorithm choices were retained. Third-party code and the
vendored `iid/` snapshot are preserved; this is not a certification of those
libraries or of the published numerical results.

Use four spaces for indentation, LF line endings, a final newline, no trailing
spaces and at most one empty line between ordinary statements. MATLAB help belongs
immediately after the function declaration and should describe actual argument
shapes, outputs and file side effects. Preserve attribution and experimental
alternatives. Do not apply a text-only formatter to MATLAB matrix expressions
without checking whitespace-sensitive concatenation, strings and transpose syntax.

## Remaining issues after portable validation (2026-09-24)

| Severity | File / branch | Finding |
|---|---|---|
| High | `experiments/MSRAction3D/gene_TSSM.m` | Declaration is named `GeneTSSM` and takes two inputs; its caller passes six and its body refers to four missing descriptor arrays. Do not confuse it with the separate `GeneTSSM.m` implementation. |
| High | `experiments/MSRAction3D/costFunctionReg.m` | `nargout < 7` always holds for its three declared outputs, resetting the supplied `initTheta`. Objective/gradient consistency also needs finite-difference verification before changing optimisation behaviour. |
| High | `loghog/src/LogHog.cpp` | MEX gateway reads `prhs[0]` and writes `plhs[0]` without checking argument counts, numeric type, complexity or dimensions; invalid calls can crash MATLAB. Source changes would require rebuilding the binary. |
| Medium | `experiments/MSRC12/Query_distance.m` | Distance computations are commented out; returned distances are all zero. |
| Medium | ASL/MSRAction3D `dtw_orien.m` | Passes five arguments to a four-argument local-distance helper. |
| Medium | `experiments/MSRAction3D/repreprocess_bat.m` | Builds a filename from undefined `marker` instead of selecting a joint in the loop. |
| Medium | `rand_sampling_ts.m` variants | ASL assumes every sequence contains enough descriptors; the other versions repeat only once and still fail for sufficiently short/empty sequences. |
| Medium | Descriptor scaling and pooling | Several paths divide by a maximum or norm without an explicit zero-input policy. Constant trajectories/empty features require targeted tests. |

The ASL condition syntax, LocalSSM explicit-call normalization, and zero sparse
pooling have now been corrected. Other findings above remain unresolved. The
portable reference pipelines pass, but original MATLAB experiments are not yet
verified as runnable end to end. See [validation scope](docs/VALIDATION.md).

## Verification and recovery

The final formatting command in local commit `577587b` accidentally truncated six
scripts by opening each destination for writing before reading its contents.
All six were recovered from `bd95ad7`, with help text restored. The recovery is a
separate commit so the correction remains auditable; no history was rewritten.

Validation compares every changed MATLAB file with pre-polish commit `85771fe`
using the previous formatter's code normalisation, and checks file inventory,
unchanged binary/vendor files and whitespace errors. This is a static regression
check, not a MATLAB parser or a proof of semantic equivalence. MATLAB execution,
MATLAB MEX compilation and published-result reproduction have not been performed.
Subsequent native distance-kernel checks and portable numerical validation are
recorded separately in `docs/VALIDATION.md`.
