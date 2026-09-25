# TSSM — Temporal Self-Similarity Description for Trajectory Recognition

MATLAB/C++ implementation of **temporal self-similarity matrices (SSMs)** of 3-D motion
trajectories, the **log-polar HOG** self-similarity descriptor extracted along the SSM
diagonal, and the encoders and classifiers used to recognise trajectories from those
descriptors: **bag of features / vector quantisation (VQ)**, **sparse coding (SC)**,
**temporal pyramid matching (TPM)** with max pooling, and **linear / kernel SVMs** —
together with the baselines and later skeleton-action extensions built on the same
pipeline.

This directory is a consolidated, **code-only** reconstruction of a project that was
previously spread across a networked MATLAB workspace and several local folders.
Intermediate results (`.mat`), figures and raw datasets are deliberately **not**
included — see [Provenance](#provenance) and [Datasets](#datasets).

---

## Papers

| # | Work | Venue |
|---|------|-------|
| 1 | *Temporal Self-Similarity Description for Trajectory Recognition* — Chapter 3 (method) and §5.2 (experiments) | Z. Shao, PhD thesis, City University of Hong Kong |
| 2 | *Motion Trajectory Recognition Using Local Temporal Self-Similarities* | Z. Shao, Y. F. Li — conference paper |

Both evaluate on the **ASL (Auslan) sign dataset** only. Everything under
`experiments/MSRAction3D` and `experiments/MSRC12` is later work that
reuses the same pipeline on skeleton data and is **not** part of either paper — see
[Skeleton-action extensions](#skeleton-action-extensions).

## Licence

GPL-3.0 — see [`LICENSE`](LICENSE), the same licence as the companion `IID` project.
The toolboxes under `thirdparty/` keep their own licences; see
[`thirdparty/README.md`](thirdparty/README.md).

---

## Method at a glance

```
  3-D trajectory γ(t) = {x(t), y(t), z(t)},  t = 1..N
        │
        ├─ iid/            per-frame descriptor: raw xyz, AII / DII (integral invariants),
        │                  DI (differential invariants), FD …     (copied from IID)
        │
        ├─ ssm/            Temporal_SSM: N×N matrix of distances between frame windows
        │                  of size ω (thesis: ω = 5), under one of several metrics:
        │                    Euclidean (SSM-raw)          sigmoid tanh(β‖·‖ − c) (paper 2)
        │                    AII local L1 distance (thesis, Eq. 3.2–3.3)
        │
        ├─ descriptor/     Log_hogcalculator: at every diagonal element, a log-polar patch
        │  loghog/         (r = 30, 8 angular × 4 radial bins, centre cells merged → 25 cells)
        │                  × 6 unsigned orientation bins, L2-Hys  →  150-D descriptor/frame
        │                  (LogHog.mex is the C++/OpenCV port of the same routine)
        │
        ├─ experiments/    encode the N descriptors of one trajectory:
        │   gene_codebook          BoF histogram (VQ, k-means codebook)          BoF-SSM
        │   gene_codebook_pyramid  VQ histograms over a temporal pyramid 2^0..2^L  KTPM
        │   gene_codebook_ScSPM    sparse codes, max-pooled over the pyramid       ScTPM
        │
        └─ classify        KTPM:  PyramidMatching kernel + LIBSVM (svmtrain -t 4)
                           ScTPM: linear multiclass SVM, li2nsvm_multiclass_lbfgs
                           baselines: 1-NN + DTW, HMM (mhmm_classifier), GMM
```

## Paper variant → code

The drivers are *menus*: every variant in the tables of both papers is a commented block
in `experiments/ASL/recognition_dtw_tsd_bat.m` and the two descriptor generators it calls
(`gene_descriptor_integral` / `gene_descriptor_diff`, each with a `_samples` twin that must
be kept identical). Pick a variant by uncommenting its block.

**As last saved**, the driver runs the conference paper's head-to-head:
`gene_descriptor_integral` = raw xyz → **sigmoid** SSM, `gene_descriptor_diff` = raw xyz →
**Euclidean** SSM, both → Log-HOG → **KTPM** (`gene_codebook_pyramid` + `PyramidMatching`
+ LIBSVM), temporal pyramid `ntotalbh = 2` (levels 2⁰–2²).

| Variant (thesis Table 5.1 / paper) | Per-frame descriptor | `Temporal_SSM(des, flag, ω, kernel)` | Encoding | Classifier |
|---|---|---|---|---|
| **ScTPM** (thesis, 94.48 %) | AII: `integral_invariant(xyz,6,0.005)` + diffs | `(des, 3, 5)` | `gene_codebook_ScSPM` | `li2nsvm_multiclass_lbfgs` |
| ScTPM (ω = 1) | AII | `(des, 3, 1)` | ScSPM | linear SVM |
| ScTPM-SSM-raw | raw xyz | `(des, 5, 5, 0)` | ScSPM | linear SVM |
| ScTPM-SSM-DI | `descriptor_comp` (DI) | `(des, 2, 5)` | ScSPM | linear SVM |
| ScTPM-AII / -DI | AII / DI, **no SSM** (skip `Temporal_SSM` + Log-HOG) | — | ScSPM | linear SVM |
| **KTPM** | as ScTPM | `(des, 3, 5)` | `gene_codebook_pyramid` | `PyramidMatching` + `svmtrain -t 4` |
| KTPM-AII / -DI | AII / DI, no SSM | — | pyramid | pyramid-match SVM |
| BoF-SSM | as ScTPM | `(des, 3, 5)` | `gene_codebook` with `ntotalbh = 1` | SVM |
| HMMs-AII | AII | — | — | `construct_hmmdata` + `mhmm_classifier` |
| 1-NN-AII / MAII / DI / FD | AII / MAII / DI / FD | — | — | DTW block (`dtw_adj_matching`) |
| **SSM-sig-TPM** (paper 2) | raw xyz | `(des, 5, 1, 1)`, β = 0.5e-3, c = 0 | `gene_codebook_pyramid` | pyramid-match SVM |
| SSM-raw-TPM (paper 2) | raw xyz | `(des, 5, 1, 0)` | pyramid | pyramid-match SVM |
| SSM-sig-BoF (paper 2) | raw xyz | `(des, 5, 1, 1)` | `gene_codebook` | SVM |

`Temporal_SSM` flags: 1 FD (`distance_matrix_fd`), 2–4 DI / AII / MAII
(`feature_dist_matching`, the IID local distance), 5–6 L2 on the window (Euclidean, or
sigmoid when `kernel = 1`), 7–8 L1, 9 χ² histogram cost. Flags 1–4 call helpers that
live in each **experiment folder**, which is why drivers must run from there.

Two parameters differ from the thesis. Both values are kept, in the usual menu style — the
value as last saved is live, the thesis value is the commented line directly above it:

| Setting | Live (as last saved) | Commented (thesis §5.2.1) |
|---|---|---|
| `nsmp` in `ASL/gene_codebook_ScSPM.m` — descriptors sampled for dictionary learning | 6000 | 10000 |
| `EXPERIMENT_TIMES` in `ASL/recognition_dtw_tsd_bat.m` — random 16-class splits | 10 | 50 |

It is not known which setting produced the published numbers.

The ASL folder also carries C++ ports of the two hot loops of ScTPM,
`libsc_pooling_ts.cpp` and `libli2nsvm_multiclass_fwd.cpp` (+ Windows DLLs), which is
presumably what the per-query timing in thesis Table 5.2 measured.

---

## Directory layout

```
Temporal-Self-Similarity-Description/
├── ssm/           Temporal_SSM — the SSM itself
├── descriptor/    Log_hogcalculator (+ SameBlock), LocalSsmcalculator (+ SameBlock),
│                  global_hogcalculator, hogcalculator — SSM image descriptors
├── loghog/        LogHog.mex: C++/OpenCV port of Log_hogcalculator
│   ├── src/         LogHog.cpp, log_hogcalculator.cpp/.h, VS2012 project
│   └── bin/         LogHog.mexw32, LogHog.mexw64
├── figures/       plot_bases_sparse — the 1024 learned bases as 6×25 tiles (thesis Fig. 3.1e)
├── iid/           Integral invariants, MBS, DTW and baselines, copied from the IID project
│   ├── core/  mbs/  matching/  preprocess/  baselines/  utils/  figures/
├── experiments/
│   ├── ASL/           the two papers
│   ├── MSRAction3D/   2015 extension — joint-group SSMs + ScTPM / cost-sensitive regression
│   └── MSRC12/        2015 extension — AII/DI windowed SSMs on MSRC-12 gestures
├── thirdparty/    code-only subsets of the toolboxes the pipeline calls
├── tools/         provenance.tsv — origin and md5 of every file; cleanup_originals.sh
└── setup_path.m
```

`iid/` is a verbatim copy of the files this pipeline needs from the companion **IID**
project (`github.com/perryshao/Integral-Invariants`), so that this project runs on its
own. Treat IID as the upstream for those files.

## Running

```matlab
cd Temporal-Self-Similarity-Description
setup_path                 % adds ssm/, descriptor/, iid/, figures/ and the third-party code
cd experiments/ASL
recognition_dtw_tsd_bat    % expects the ASL .tsd files under tsd_data_bat/
```

`experiments/` is intentionally **not** on the path: the four dataset folders contain
different versions of same-named helpers (`rand_sampling_ts`, `sc_pooling_ts`,
`gene_codebook_ScSPM`, `construct_ID`, …) and MATLAB's current-folder-first rule is how
the originals were run. Note also that **MSRAction3D carries its own
`Temporal_SSM`** with the older 5-argument signature `(des, flag, kernel, belta, c)` and
no frame window; `GeneTSSM` depends on it.

Drivers `delete *.mat` and write intermediate `.mat` files into the current folder.

---

## Datasets

Not bundled. Obtain them from the original sources and point the `load_*` scripts at them.

| Folder | Dataset | Loader |
|---|---|---|
| `experiments/ASL` | Australian Sign Language signs (High Quality), UCI KDD archive — 95 signs × 27 | `load_tsd_bat` (`tsd_data_bat/`) |
| `experiments/MSRAction3D` | MSR Action3D skeletons | `load_MSRtxt_bat` |
| `experiments/MSRC12` | MSRC-12 Kinect Gesture | `load_txt_bat` |

---

## Skeleton-action extensions

Not part of either paper. They apply the same SSM → Log-HOG → coding pipeline to
groups of skeleton joints.

- **MSRAction3D** (Aug–Sep 2015) — `recognition_ssm_MSRA_bat.m`: `GeneTSSM` builds one SSM
  per joint group — on the mean trajectory of the group — (sigmoid, `Temporal_SSM(des,5,1,1,0.25)`), `GeneScCodeJointPyramid`
  sparse-codes and pools per joint, then either the linear SVM or a multiple binary
  regression (`trainBinRegression` / `costFunctionReg` / `minimize`).
  `recognition_dtw_MSRA_bat.m` is the older single-SSM version (`gene_TSSM` +
  `Temporal_SSMofHierarD` + ScSPM). The MSRAction3D driver originally resolved seven
  helpers (`PyramidMatching`, `gene_codebook_pyramid`, `drawPRC`, …) from the ASL folder;
  copies of the ASL versions were placed alongside it.
- **MSRC12** (Feb–Apr 2015) — `recognition_dtw_MR_txt.m`; `gene_descriptor_diff` computes
  the thesis-style DI windowed SSM (`Temporal_SSM(des,3,5)`); `gene_TSSM` +
  `Temporal_SSMofHierarD` build hierarchical SSMs. These two files were removed from IID
  and handed over here.
- **NTU** (Sep 2017) — `recognition_ssm_NTUA_bat.m` was **removed**: 11 of the functions
  it calls (`GeneTSSMofParisD`, `GeneTSSMofRrvD`, `GetModalityData`, `fv_pooling_ts`, …)
  exist in none of the source locations, so it could not run. The originals remain in
  `Projects/Work/NTU3DActionEvaluatingCode` until the source cleanup.

The 2016–18 drivers in the IP, UCF-Kinect, UT-Kinect, MSR-DailyActivity folders, the
2018 MSRC-12 `run.m` and NTU `run.m` use a **different** method (3-D shape context +
RRV + Fisher vectors + cost-sensitive regression, no SSM) and were left out; several of
their helpers are also missing (`load_IPtxt_bat`, `load_UCFske_bat`, `CS_DataCollect`).

---

## Changes made during consolidation

All edits are listed with the original md5 in `tools/provenance.tsv` (status `modified`).

- **`ssm/Temporal_SSM.m` could not run the ASL sigmoid SSM.** It had been refactored to
  take `belta, c` as arguments, but the ASL generators still call
  `Temporal_SSM(des,5,1,1)`, so the sigmoid branch hit an undefined variable. Its old
  hard-coded ASL value survived only as a comment (`belta = 0.5e-3; % for asl dataset`).
  Defaults were added: `slide_win = 1`, `kernel = 0`, `belta = 0.5e-3`, `c = 0` (the
  values in paper 2). This also revives the 2-argument form `Temporal_SSM(des,flag)` used
  by `ASL/gene_descriptor.m`, which otherwise failed on `slide_win`.
- **`Log_hogcalculator` and `LocalSsmcalculatorSameBlock` rejected explicit parameters.**
  Both take 7 parameters but tested `nargin < 8`, so any call that passed them raised
  *Input parameters are not enough*; only the all-defaults form worked. Now `nargin < 7`.
  Every existing caller uses the defaults, so results are unchanged.
- **`clear all` removed from the end of 24 function files** (`gene_descriptor_*`,
  `preprocess*`, `load_*_bat`). There it only unloads every MEX from memory; in driver
  scripts it is the reset idiom and was kept.
- **Encoding**: `descriptor/hogcalculator.m`, `global_hogcalculator.m` (Windows-1252) and
  `loghog/src/stdafx.*`, `targetver.h` (GBK) converted to UTF-8.
- **HMMall pruned to the 33 files the HMM/GMM baselines reach** (from 433). Beyond size,
  this removes `KPMtools/strsplit.m`, `normalize.m`, `entropy.m`, `chi2inv.m`,
  `factorial.m` and two `pca.m`, which shadow MATLAB built-ins on the path — `strsplit`
  is used by MATLAB internals.
- `libsvm-3.17/matlab/K.m` and `Kernel.m` were dropped: not part of LIBSVM, and `K` is a
  variable name in every driver.

Not changed, but worth knowing:

- `LogHog.mex` and `Log_hogcalculator.m` are meant to compute the same descriptor; they
  have **not** been compared numerically here (no MATLAB/OpenCV build available during
  consolidation). `LogHog.mexw64` is byte-identical to the copies that were deployed in
  the old NTU and UCF folders, so `loghog/src` is the source of the binary actually used.
- `ssm/Temporal_SSM.m` expects `feature_dist_matching` / `distance_matrix_fd` from the
  calling experiment folder (flags 1–4). For flag 9, `hist_cost_2` comes from the folder if
  it has one, otherwise from `thirdparty/sc_demo` (a different version).

## Building the mex files

| Binary | Source | Prebuilt for |
|---|---|---|
| `LogHog` | `loghog/src` — needs OpenCV 2.4 (`core`, `imgproc`) | w32, w64 |
| `Determine_segment`, `tricircumcenter3d`, `dtwpath`, `dpcore`, `distance_matrix_*`, `hist_isect_c` | `iid/mbs/src`, `iid/matching/src` | see `iid/*/bin` |
| `libsc_pooling_ts`, `libli2nsvm_multiclass_fwd` | `experiments/ASL/*.cpp` | Windows DLL |
| `hist_cost` | `experiments/MSRAction3D/hist_cost.c` | Windows DLL |
| `svmtrain` / `svmpredict` | `thirdparty/libsvm-3.17/matlab` (`make.m`) | w32, w64 |
| `yael_kmeans` | `thirdparty/yael_v438/matlab` (`Make.m`) | a64, w32 |
| `mexCalcSsdescs` (Chatfield/Shechtman self-similarity) | `thirdparty/mexCalcSsdescs` (recovered source) | w32, w64 |
| `MelkmanConvexHull` | `iid/mbs/src/MelkmanConvexHull.cpp` (recovered source) | w32, w64 |

```matlab
cd loghog/src
mex -I<opencv>/include LogHog.cpp log_hogcalculator.cpp -L<opencv>/lib -lopencv_core -lopencv_imgproc
```

---

## Provenance

Every file's origin and original md5 is in [`tools/provenance.tsv`](tools/provenance.tsv).
Sources were three overlapping copies of the old workspace — the SMB share
`MatlabProjects/work` (also mounted as `work`), a second share `9592df65…/work`, and
local `~/Documents/Projects/Work` — plus the IID repository. No file existed in two
locations with different contents; where helpers of the same name differed between
dataset folders, each folder kept its own.

The C++ source of `LogHog.mex` was recovered from `Projects/Work/Log_Hog/Log_Hog.zip`
(Sept 2015); the unzipped copy next to it had lost the source files.

Excluded as not code: ScSPM's Caltech-101 images and SIFT features (3.2 GB), and
`ScSPM/Results/reg_sc_b1024_20150402T092740.mat`, which appears to be a 1024-atom
dictionary learned in April 2015.

## Recovered source and retired workspaces

See [MEX recovery](docs/MEX_RECOVERY.md) for restored sources, separate build targets, and validation limits. Old workspace sources/data are preserved by SHA-256 under `~/Documents/Projects/LegacyResearchAssets`; consult its README and manifest before using historical paths above.

## Validation without MATLAB

Validation now combines Python numerical oracles, C++ AddressSanitizer/UndefinedBehaviorSanitizer,
and actual MATLAB-source execution through Octave with seven rebuilt MEX modules.
Six synthetic raw/sigmoid SSM → Log-HOG → BoF/VQ/ScSPM → SVM paths pass with
training-derived sparse initialization; a separate random-initialization failure
is recorded. See [Octave validation and reproducibility](docs/OCTAVE_VALIDATION.md),
[recorded results](docs/OCTAVE_VALIDATION.json), and the
[Python reference layer](docs/VALIDATION.md). This does not certify MATLAB ABI
compatibility or reproduce published dataset scores.
