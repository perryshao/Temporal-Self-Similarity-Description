# Recovered MEX sources — 2026-09-24

Source: `OneTouch/Phd-Related/MyWork/Mexfunction_C` on the historical SMB server.
The old workspaces are being retired; original bytes and paths are preserved in
`~/Documents/Projects/LegacyResearchAssets/legacy-source-only/manifest.json`.
See `MEX_RECOVERY_PROVENANCE.json` for the source and installed SHA-256 hashes.

No existing precompiled MEX was replaced. New source does not prove provenance or
numerical equality of an old binary. Build into a separate output folder first.
The machine's /Applications/MATLAB.app is an unresolved alias; no MATLAB MEX build
or end-to-end MATLAB experiment was performed in this recovery.

## Validation

The recovered Melkman and two orientation-distance entry points were compiled with
Clang AddressSanitizer/UndefinedBehaviorSanitizer against a small MEX API test shim.
Batch/incremental hulls, a 1201-point input, invalid inputs, and 12 numerical fixtures
per distance variant passed. The distance fixtures independently calculate all eight
output matrices and check the 8/9-output contract. These are native C++ checks, not
MATLAB ABI/runtime tests. The ssdesc C++ core passed a separate syntax-only compile.

## Interface adaptations

- Melkman retains the original hull calculation. It now sizes its buffer per call,
  accepts one N-by-2 matrix plus at most one new point, checks real/full/finite input,
  rejects a degenerate initial triangle, and reports unsupported geometry as an error.
  It is not a general replacement for MATLAB convhull on arbitrary degenerate input.
- Orientation distance requires four matrices and eight or nine outputs. It checks
  dimensions and integer-index bounds, and only allocates the ninth legacy output
  when requested. The eight numerical formulas are preserved.
- The MSRC12 variant selects radial dimensions 2 and 5 (zero-based); the generic
  version selects every third dimension. They are separate build targets.
- ssdesc uses mwSize for the MEX dimension pointer and const strings for errors,
  rejects complex/sparse/oversized images and requires all five outputs. Remaining
  algorithm/API compatibility needs MATLAB testing.

Historical variants under `legacy/` are not added by setup_path and must not override
current algorithms. The recovered Sobel Log-HOG differs from the current version in
gradients, normalization and indexing. sc_distance and distance_ise contain known
bugs; Statisticdtw requires additional Blitz++/hwr dependencies. They are source
archives only, not restored working experiments.

## Included components

- `iid/mbs/src/MelkmanConvexHull.cpp` and generic/MSRC12 orientation distance sources.
- `thirdparty/mexCalcSsdescs`: three source files plus upstream README. Upstream README
  declares MIT; no separate license text was present in the recovered folder.
- `thirdparty/yael_v438/yael`: missing C core and original build configuration. Existing
  MATLAB wrappers and COPYING remain unchanged. Historical -msse4 and BLAS/LAPACK
  settings still need a platform-specific build; they are not validated on ARM.
- `legacy/Mexfunction_C`: Sobel Log-HOG, sc_distance with its original hist_cost linkage
  assets, and distribution-distance experiments.

`build_recovered_mex` builds the standalone new MEX candidates into `build/recovered-mex`;
this directory is not automatically added to the MATLAB path. Yael and historical
experiments are deliberately not included in that helper.
