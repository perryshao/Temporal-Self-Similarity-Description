function setup_path()
%SETUP_PATH  Add the TSSM project to the MATLAB path.
%
%   Run this once per MATLAB session from the TSSM root:
%       >> setup_path
%   then change into one experiment folder and run its driver, e.g.
%       >> cd experiments/ASL
%       >> recognition_dtw_tsd_bat
%
%   experiments/ is deliberately NOT added to the path.  Each dataset folder
%   carries its own version of helpers that share a name across folders
%   (rand_sampling_ts, sc_pooling_ts, gene_codebook_ScSPM, Temporal_SSM in
%   MSRAction3D, ...) and the versions differ.  MATLAB resolves the current
%   folder first, which is how the original experiments were run; putting all
%   four folders on the path would make the winner depend on path order.
%
%   See README.md for the layout and for which mex targets exist.

root = fileparts(mfilename('fullpath'));

% Project code (recursive).
folders = {'ssm', 'descriptor', 'figures', 'iid'};
for k = 1:numel(folders)
    add_or_warn(fullfile(root, folders{k}), true);
end

% Third-party code: only the folders the pipeline calls into.
tp = fullfile(root, 'thirdparty');
thirdparty = {
    'ScSPM/sparse_coding'           % reg_sparse_coding, feature-sign search
    'ScSPM/large_scale_svm'         % li2nsvm_multiclass_lbfgs / _fwd  (ScTPM linear SVM)
    'computeBoV'                    % BoF histograms (KTPM / BoF-SSM)
    'yael_v438/matlab'              % yael_kmeans, used by computeBoV/learnCodebook
    'HMMall/HMM'                    % HMMs-AII baseline
    'HMMall/KPMstats'
    'HMMall/KPMtools'
    'HMMall/netlab3.3'              % GMM baseline (gmm, gmmem, gmmpost)
    'Kalman'
    'histogram_distance'
    'sc_demo'
    'mexCalcSsdescs'
    'SpectralClustering'
    'cp3_decomposition'
    'C3D'
    };
for k = 1:numel(thirdparty)
    add_or_warn(fullfile(tp, thirdparty{k}), false);
end

% libsvm: 32-bit mex live in matlab/, 64-bit Windows mex in windows/.
add_or_warn(fullfile(tp, 'libsvm-3.17', 'matlab'), false);
if strcmp(computer('arch'), 'win64')
    addpath(fullfile(tp, 'libsvm-3.17', 'windows'), '-begin');
end

arch = computer('arch');

% Compiled binaries go in front of everything else.
addpath(fullfile(root, 'iid', 'mbs', 'bin'), '-begin');
addpath(fullfile(root, 'iid', 'matching', 'bin'), '-begin');
addpath(fullfile(root, 'loghog', 'bin'), '-begin');

fprintf('TSSM path configured (root: %s)\n', root);

missing = check_mex();
if isempty(missing)
    fprintf('All core mex functions are available for %s.\n', arch);
else
    fprintf(2, 'Missing mex for %s: %s\n', arch, strjoin(missing, ', '));
    fprintf(2, 'See the "Building the mex files" section of README.md.\n');
end
end


function add_or_warn(p, recursive)
if exist(p, 'dir')
    if recursive
        addpath(genpath(p));
    else
        addpath(p);
    end
else
    warning('setup_path:missing', 'Folder not found, skipped: %s', p);
end
end


function missing = check_mex()
%CHECK_MEX  Report which compiled helpers cannot be resolved on this platform.
%   LogHog is optional (Log_hogcalculator.m is the MATLAB equivalent);
%   svmtrain is only needed by the KTPM / pyramid-match-kernel path.
required = {'Determine_segment', 'tricircumcenter3d', 'dtwpath', ...
            'distance_matrix_norm2', 'LogHog', 'svmtrain'};
missing = {};
for k = 1:numel(required)
    if isempty(which(required{k}))
        missing{end+1} = required{k}; %#ok<AGROW>
    end
end
end
