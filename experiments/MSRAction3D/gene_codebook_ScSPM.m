function [traindata,testdata,sum_ScSPM_time] = gene_codebook_ScSPM(TRAJDB_DES,TRAJSAMPLES_DES,ntotalbh)

%% collect the visual words

samples_r = size(TRAJDB_DES,2);
samples_t = size(TRAJSAMPLES_DES,2);


% dictionary training for sparse coding
nBases = 1024;
nsmp = 10000;
beta = 1e-5;                        % a small regularization for stablizing sparse coding 
num_iters = 50;


% feature pooling parameters
pyramid = 2.^(0:ntotalbh);                % spatial block number on each level of the pyramid
gamma = 0.15;
% knn = 200;
knn = 0;                          % find the k-nearest neighbors for approximate sparse coding
                                  % if set 0, use the standard sparse coding


traindata = zeros(nBases*sum(pyramid),samples_r);
testdata = zeros(nBases*sum(pyramid),samples_t);

%% learning sparse coding dictionary
% features in all the training dataset are used to trained codebook
% k = 0;
% for i=1:samples_r
%     k = size(TRAJDB_DES{1,i},1)+k;
% 	X(k-size(TRAJDB_DES{1,i},1)+1:k,:) = TRAJDB_DES{1,i};
% end
% X = X';

% randomly seleting local training features
X = rand_sampling_ts(TRAJDB_DES, nsmp);
nsmp = size(X,2); % remeausre the nsmp after sampling
batch_size = floor(nsmp/1); % batch size when learning sparse codes

[B, S, stat] = reg_sparse_coding(X, nBases, eye(nBases), beta, gamma, num_iters,batch_size);
clear X;


%% calculate the sparse coding feature

disp('==================================================');
fprintf('Calculating the sparse coding feature...\n');
fprintf('Regularization parameter: %f\n', gamma);
disp('==================================================');


for iter1 = 1:samples_r, 
    fprintf ('computing and pooling sparce codes for training data %d...\n',iter1);
    feats = TRAJDB_DES{1,iter1};
    if knn,
        traindata(:, iter1) = sc_approx_pooling_ts(feats', B, pyramid, gamma, knn);
    else
        traindata(:, iter1) = sc_pooling_ts(feats', B, pyramid, gamma);
    end
end
tic;
for iter2 = 1:samples_t, 
    fprintf ('computing and pooling sparce codes for testing data %d...\n',iter2);
    feats = TRAJSAMPLES_DES{1,iter2};
    if knn,
        testdata(:, iter2) = sc_approx_pooling_ts(feats', B, pyramid, gamma, knn);
    else
        testdata(:, iter2) = sc_pooling_ts(feats', B, pyramid, gamma);
    end
end
sum_ScSPM_time = toc;


