function run_octave_validation(root, work)
%RUN_OCTAVE_VALIDATION Run original project functions with freshly built MEX.
%   All generated binaries, fixtures and result files stay in WORK.
    oldpath = path; oldpwd = pwd;
    cleanup = onCleanup(@() restore_session(oldpath, oldpwd));
    cd(work);
    pkg load image;
    pkg load statistics;
    pkg load optim;
    support = fileparts(mfilename('fullpath'));
    for name = {'distance_matrix_norm1', 'distance_matrix_norm2'}
        mkoctfile('--mex', ['-I' fullfile(support, 'octave_include')], ...
            fullfile(root, 'iid/matching/src/distance_matrix', [name{1} '.cpp']), '-o', name{1});
    end
    mkoctfile('--mex', fullfile(root, 'iid/matching/src/hist_isect_c.c'), '-o', 'hist_isect_c');
    base = fullfile(root, 'thirdparty/libsvm-3.17');
    for name = {'svmtrain', 'svmpredict'}
        mkoctfile('--mex', fullfile(base, 'matlab', [name{1} '.c']), ...
            fullfile(base, 'matlab/svm_model_matlab.c'), fullfile(base, 'svm.cpp'), '-o', name{1});
    end
    base = fullfile(root, 'thirdparty/yael_v438');
    core = {'vector', 'matrix', 'nn', 'kmeans', 'sorting', 'binheap', 'machinedeps', 'eigs'};
    src = cellfun(@(n) fullfile(base, 'yael', [n '.c']), core, 'UniformOutput', false);
    for name = {'yael_nn', 'yael_kmeans'}
        mkoctfile('--mex', '-DFINTEGER=int', ['-I' base], ...
            fullfile(base, 'matlab', [name{1} '.c']), src{:}, ...
            '-lblas', '-llapack', '-lpthread', '-o', name{1});
    end
    for folder = {'ssm', 'descriptor', 'thirdparty/computeBoV', 'thirdparty/ScSPM/sparse_coding', 'experiments/ASL'}
        addpath(fullfile(root, folder{1}));
    end
    addpath(work, '-begin');
    assert(strcmp(which('svmtrain'), fullfile(work, ['svmtrain.' mexext])));
    fixture = load(fullfile(work, 'fixtures.mat'));
    x = fixture.trajectory;
    raw = Temporal_SSM(x, 5, 1, 0);
    sig = Temporal_SSM(x, 5, 1, 1);
    win = Temporal_SSM(x, 5, 3, 0);
    l1 = Temporal_SSM([x x], 7, 3, 0);
    hog_raw = Log_hogcalculator(raw);
    hog_sig = Log_hogcalculator(sig);
    hog_zero = Log_hogcalculator(zeros(7));
    assert(all(hog_zero(:) == 0));
    local_default = LocalSsmcalculator(raw);
    local_explicit = LocalSsmcalculator(raw, 20, 8, 3, 1);
    assert(isequal(local_default, local_explicit));
    hog_blocks = Log_hogcalculatorSameBlock(raw);
    local_blocks = LocalSsmcalculatorSameBlock(raw);
    assert(all(isfinite([local_default(:); hog_blocks(:); local_blocks(:)])));
    % Test the actual train/test descriptor generators, including their uint16
    % range scaling, file naming and MAT serialization conventions.
    TRAJDB = {1; x}; TRAJSAMPLES = TRAJDB;
    save('-mat7-binary', 'fixture.mat', 'TRAJDB');
    save('-mat7-binary', 'fixturesamples.mat', 'TRAJSAMPLES');
    gene_descriptor_diff('fixture'); gene_descriptor_diff_samples('fixture');
    a = load('fixture_DES.mat'); b = load('fixturesamples_DES.mat');
    generated_raw = a.TRAJDB_DES{1};
    assert(isequal(generated_raw, b.TRAJSAMPLES_DES{1}));
    gene_descriptor_integral('fixture'); gene_descriptor_integral_samples('fixture');
    a = load('fixture_DES.mat'); b = load('fixturesamples_DES.mat');
    generated_sig = a.TRAJDB_DES{1};
    assert(isequal(generated_sig, b.TRAJSAMPLES_DES{1}));
    % Degenerate input regression: the previous uint16 scaling divided by zero.
    TRAJDB = {1; zeros(32, 3)}; TRAJSAMPLES = TRAJDB;
    save('-mat7-binary', 'zero.mat', 'TRAJDB');
    save('-mat7-binary', 'zerosamples.mat', 'TRAJSAMPLES');
    for mode = 0:1
        if mode == 0
            gene_descriptor_diff('zero'); gene_descriptor_diff_samples('zero');
        else
            gene_descriptor_integral('zero'); gene_descriptor_integral_samples('zero');
        end
        a = load('zero_DES.mat'); b = load('zerosamples_DES.mat');
        assert(all(a.TRAJDB_DES{1}(:) == 0));
        assert(isequal(a.TRAJDB_DES{1}, b.TRAJSAMPLES_DES{1}));
    end
    % Actual feature-sign optimizer; Python checks coefficients and KKT.
    B = fixture.dictionary; X = fixture.features;
    A = B'*B + 2e-4*eye(size(B, 2)); Q = -B'*X';
    codes = zeros(size(B, 2), size(X, 1));
    for i = 1:size(X, 1)
        codes(:, i) = L1QP_FeatureSign_yang(.15, A, Q(:, i));
    end
    pools = zeros(3, size(B, 2)*7);
    for dataset = 1:3
        names = {'ASL', 'MSRAction3D', 'MSRC12'};
        folder = fullfile(root, 'experiments', names{dataset});
        addpath(folder, '-begin'); clear sc_pooling_ts;
        assert(strcmp(which('sc_pooling_ts'), fullfile(folder, 'sc_pooling_ts.m')));
        pools(dataset, :) = sc_pooling_ts(X', B, [1 2 4], .15)';
        z = sc_pooling_ts(zeros(size(X, 2), 1), B, [1 2 4], .15);
        assert(all(z == 0));
        if dataset == 2
            clear Temporal_SSM;
            msra_sig = Temporal_SSM(x, 5, 1, .0005, 0);
            assert(max(abs(msra_sig(:)-sig(:))) < 1e-10);
        end
        rmpath(folder);
    end
    addpath(fullfile(root, 'experiments/ASL'), '-begin');
    clear Temporal_SSM sc_pooling_ts;
    % Known-center Yael/VQ and intersection-kernel parity fixtures.
    bov = computeBoV(single(fixture.centers'), single(X'), 1);
    kernel = PyramidMatching(fixture.histograms, fixture.histograms, 2, 2);
    accuracies = zeros(2, 3);
    dictionary_objectives = cell(1, 2);
    dictionary_norms = cell(1, 2);
    for mode = 0:1
        TRAJDB = [num2cell(fixture.train_y'); reshape(fixture.train_x, 1, [])];
        TRAJSAMPLES = [num2cell(fixture.test_y'); reshape(fixture.test_x, 1, [])];
        save('-mat7-binary', 'pipeline.mat', 'TRAJDB');
        save('-mat7-binary', 'pipelinesamples.mat', 'TRAJSAMPLES');
        if mode == 0
            gene_descriptor_diff('pipeline'); gene_descriptor_diff_samples('pipeline');
        else
            gene_descriptor_integral('pipeline'); gene_descriptor_integral_samples('pipeline');
        end
        a = load('pipeline_DES.mat'); b = load('pipelinesamples_DES.mat');
        training = a.TRAJDB_DES; testing = b.TRAJSAMPLES_DES;
        [tr, te, ~, words] = gene_codebook_pyramid(training, testing, 2);
        kt = PyramidMatching(tr, tr, 2, words);
        kv = PyramidMatching(te, tr, 2, words);
        model = svmtrain(fixture.train_y, [(1:rows(kt))' kt], '-t 4 -c 10 -q');
        labels = svmpredict(fixture.test_y, [(1:rows(kv))' kv], model, '-q');
        accuracies(mode+1, 1) = mean(labels == fixture.test_y);
        [tr, te] = gene_codebook(training, testing, 1);
        model = svmtrain(fixture.train_y, tr, '-t 0 -c 10 -q');
        labels = svmpredict(fixture.test_y, te, model, '-q');
        accuracies(mode+1, 2) = mean(labels == fixture.test_y);
        % Original ScSPM dictionary learner, including its constrained dual
        % optimizer, on training descriptors only. Small fixture parameters.
        rand('state', 71); randn('state', 71);
        features = vertcat(training{:})';
        if mode == 0, raw_features = features; end
        % The public initB interface accepts training-derived atoms. Random
        % zero-mean atoms can all be inactive at gamma=.15 on tiny fixtures.
        initB = double(learnCodebook(features, 8, 30));
        initB = initB ./ repmat(sqrt(sum(initB.^2, 1)), rows(initB), 1);
        [learned, ~, stat] = reg_sparse_coding(features, 8, eye(8), ...
            1e-5, .15, 3, size(features, 2), initB, 'dictionary_fixture');
        dictionary_objectives{mode+1} = stat.fobj_avg;
        dictionary_norms{mode+1} = sqrt(sum(learned.^2, 1));
        assert(all(isfinite(learned(:))));
        assert(max(dictionary_norms{mode+1}) < 1.01);
        tr = zeros(numel(training), 56); te = zeros(numel(testing), 56);
        for i = 1:numel(training)
            tr(i, :) = sc_pooling_ts(training{i}', learned, [1 2 4], .15)';
        end
        for i = 1:numel(testing)
            te(i, :) = sc_pooling_ts(testing{i}', learned, [1 2 4], .15)';
        end
        model = svmtrain(fixture.train_y, tr, '-t 0 -c 10 -q');
        labels = svmpredict(fixture.test_y, te, model, '-q');
        accuracies(mode+1, 3) = mean(labels == fixture.test_y);
    end
    assert(all(accuracies(:) >= 8/9));
    % Record the known random-init limitation separately from the supported
    % train-derived initialization path. Do not relax its unit-ball constraint.
    rand('state', 71); randn('state', 71);
    [randomB, ~, ~] = reg_sparse_coding(raw_features, 8, eye(8), ...
        1e-5, .15, 3, columns(raw_features), fixture.init_dictionary, 'random_init_probe');
    random_init_max_norm = max(sqrt(sum(randomB.^2, 1)));

    octave_version = version;
    packages = pkg('list');
    package_versions = cell(numel(packages), 2);
    for i = 1:numel(packages)
        package_versions(i, :) = {packages{i}.name, packages{i}.version};
    end
    save('-mat7-binary', fullfile(work, 'octave_results.mat'), 'raw', 'sig', ...
        'win', 'l1', 'hog_raw', 'hog_sig', 'generated_raw', 'generated_sig', ...
        'codes', 'pools', 'bov', 'kernel', 'accuracies', 'dictionary_objectives', ...
        'dictionary_norms', 'random_init_max_norm', 'octave_version', 'package_versions');
end

function restore_session(oldpath, oldpwd)
    path(oldpath);
    cd(oldpwd);
end
