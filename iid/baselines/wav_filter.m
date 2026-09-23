function wav_curve=wav_filter(curve)
level = 5;
wname = 'db4'; %db4 wavelet filter
tptr  = 'sqtwolot';
sorh  = 's';   %soft
extmode = 'sym'; %extmode

% Then, set the PCA parameters by retaining all the principal components:
npc_app = 3;
npc_fin = 3;

% Finally, perform multivariate denoising by typing:
wav_curve = wmulden(curve, level, wname,'mode',extmode, npc_app, npc_fin, tptr, sorh);
