function [traindata, testdata, sum_BoF_time] = gene_codebook(TRAJDB_DES, TRAJSAMPLES_DES, ntotalbh)

%% collect the visual words
% K = 5000; % the numbers of words
niter = 200;
samples_r = size(TRAJDB_DES, 2);
samples_t = size(TRAJSAMPLES_DES, 2);

row_num = 0;
for i = 1:samples_r
    row_num = size(TRAJDB_DES{1, i}, 1)+row_num;
end
words = zeros(row_num, size(TRAJDB_DES{1, 1}, 2));
K = floor(row_num/10); % set the numbers of words according to the training number

% for spatial BoF
traindata = zeros(samples_r, K*ntotalbh);
testdata = zeros(samples_t, K*ntotalbh);
BoWvec = zeros(K, ntotalbh);

% learning code
k = 0;
for i = 1:samples_r
    k = size(TRAJDB_DES{1, i}, 1)+k;
    words(k-size(TRAJDB_DES{1, i}, 1)+1:k, :) = TRAJDB_DES{1, i};
end
words = words';
Vwords = learnCodebook(words, K, niter);
clear words;

%% for spatial BoF
for i = 1:samples_r
    feats = TRAJDB_DES{1, i};
    m = size(feats, 1);
    xbstep = m/ntotalbh;
    stepunit = round(1:xbstep:m);
    k = 1;
    for j = 1:ntotalbh-1
        BoWvec(:, k) = computeBoV(Vwords, feats(stepunit(j):stepunit(j+1)-1, :)', 1);
        k = k+1;
    end
    BoWvec(:, k) = computeBoV(Vwords, feats(stepunit(end):end, :)', 1);
    BoFvec = reshape(BoWvec, K*ntotalbh, 1);
    traindata(i, :) = BoFvec';
end
tic;
for i = 1:samples_t
    feats = TRAJSAMPLES_DES{1, i};
    m = size(feats, 1);
    xbstep = m/ntotalbh;
    stepunit = round(1:xbstep:m);
    k = 1;
    for j = 1:ntotalbh-1
        BoWvec(:, k) = computeBoV(Vwords, feats(stepunit(j):stepunit(j+1)-1, :)', 1);
        k = k+1;
    end
    BoWvec(:, k) = computeBoV(Vwords, feats(stepunit(end):end, :)', 1);
    BoFvec = reshape(BoWvec, K*ntotalbh, 1);
    testdata(i, :) = BoFvec';
end
sum_BoF_time = toc;
%% collect the hog descriptor
% samples_r = size(TRAJDB_DES,2);
% samples_t = size(TRAJSAMPLES_DES,2);
% for i=1:samples_r
%     feats = TRAJDB_DES{1,i};
%     [m,n] = size(feats);
%     traindata(i,:) = reshape(feats,1,m*n);
% end
%
% for i=1:samples_t
%     feats = TRAJSAMPLES_DES{1,i};
%     [m,n] = size(feats);
%     testdata(i,:) = reshape(feats,1,m*n);
% end
