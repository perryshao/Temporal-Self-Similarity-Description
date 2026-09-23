# Third-party code

These toolboxes are **not** covered by this project's GPL-3.0 licence. Each remains under
its own authors' copyright and terms. They are bundled because the pipeline calls into
them directly; each was reduced to the code it needs, with bundled datasets, demos, docs
and VCS metadata stripped. Origins and md5s are in `../tools/provenance.tsv`.

| Toolbox | Needed by | Licence |
|---|---|---|
| `ScSPM` (Jianchao Yang) — `sparse_coding/`, `large_scale_svm/` | `reg_sparse_coding`, `L1QP_FeatureSign_yang` (ScTPM coding); `li2nsvm_multiclass_lbfgs` / `_fwd` (linear SVM) | no licence file; research code, © Jianchao Yang / NEC Labs America in headers |
| `libsvm-3.17` — C core + `matlab/` + `windows/` | `svmtrain` / `svmpredict` with the pyramid-match kernel (KTPM) | `COPYRIGHT` (BSD-3-Clause) |
| `computeBoV` (K. R. Mopuri) | `computeBoV`, `learnCodebook` — BoF / KTPM histograms | `license.txt` (BSD-3-Clause) |
| `yael_v438/matlab` (INRIA) | `yael_kmeans`, via `learnCodebook` | `COPYING` (GPL-3.0) |
| `HMMall` (Kevin Murphy) — 33 of 433 files | `mhmm_em`, `mhmm_logprob`, `mixgauss_init`, … — HMMs-AII baseline; netlab `gmm*` — GMM baseline; `foptions` | netlab: `LICENSE` (BSD-style, © Ian Nabney); HMM/KPM: no licence file |
| `Kalman` (Kevin Murphy) | `kalman_smoother` in `ASL/preprocess_sign.m` | no licence file |
| `histogram_distance` (Boris Schauerte) | `chi_square_statistics_fast` — χ² kernel option in the drivers | `license.txt` (BSD-2-Clause) |
| `sc_demo` (Belongie–Malik shape context) | `dist2`, `sc_compute`, `hist_cost` — 3-D shape-context baseline, `Temporal_SSM` flag 9 | no licence file |
| `mexCalcSsdescs` | Chatfield's implementation of the Shechtman–Irani self-similarity descriptor; binary only, no caller in the code as last saved | no source, no licence |
| `SpectralClustering` | `Spec_Clustering`, `RankOneDecom_Feaures` — clustering / retrieval blocks in the ASL and MSRC-12 drivers | no licence file (copied from IID) |
| `cp3_decomposition` (D. Nion, L. De Lathauwer) | `cp3_alsls`, `cp3_init` — needed by `RankOneDecom_Feaures` | no licence file |
| `C3D` | `closec3d` in `MSRC12/load_txt_bat.m` | no licence file (copied from IID) |

> ⚠️ Eight of these twelve ship without a licence file, so their redistribution terms are
> unclear. That is fine while the project is private; revisit before publishing it.

## Deliberately trimmed

- **HMMall**: pruned to the 33 files the HMM/GMM baselines reach. The dropped files include
  `KPMtools/strsplit.m`, `normalize.m`, `entropy.m`, `chi2inv.m`, `factorial.m` and the
  two `pca.m`, which shadow MATLAB built-ins when on the path. The netlab `gmminit` /
  `ppca` branch for `'ppca'` covariance therefore now calls the Statistics-Toolbox `pca`;
  none of the drivers uses that covariance type.
- **libsvm**: `java/`, `python/`, `svm-toy/`, `tools/` removed; `matlab/K.m` and `Kernel.m`
  removed (not part of LIBSVM; `K` is a variable in every driver).
- **ScSPM**: Caltech-101 images, SIFT features and dictionaries (3.2 GB) not copied; the
  top-level `main.m` / `sc_pooling.m` demo is kept for reference but is not on the path.

## Not bundled

| Toolbox | Why |
|---|---|
| `fast_sc` (Honglak Lee) | superseded by ScSPM's `reg_sparse_coding`; no caller |
| `bnt`, `pmtk3` | only `foptions` / netlab `pca` were resolved from them; `foptions` comes from `HMMall/KPMtools` |
| `svm_v0.56` | no caller |
| `vlfeat-0.9.20`, `PG_Curve-master` | only used by the NTU experiment, which was removed |
| `actionletEnsemble-master`, `spectral_saliency_matlab`, `l1_ls_matlab`, `Stochastic_Bosque` | lived in the skeleton folders, no caller from the SSM drivers |
