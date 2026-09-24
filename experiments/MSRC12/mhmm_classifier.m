function [confusion_matrix, test_loglik, I] = mhmm_classifier(traindata, trainGID, testdata, testGID)
%MHMM_CLASSIFIER  Left-right Gaussian-mixture HMM classifier (HMMs-AII baseline).
%   [CONFUSION_MATRIX, TEST_LOGLIK, I, COMPU_TIME_HMM] = MHMM_CLASSIFIER(
%   TRAINDATA, TRAINGID, TESTDATA, TESTGID) trains one left-right HMM per class
%   with MHMM_EM (Murphy's HMM toolbox) and labels every test sequence by the
%   class of largest log-likelihood.  I holds the predicted labels.
%
%   See also CONSTRUCT_HMMDATA.

O = size(traindata{1}, 1); % Number of coefficients in a vector
% nex = length(traindata);        %Number of sequences
% M = mix_num;          %Number of mixtures
% Q = states_num;          %Number of states
M = 3; % Number of mixtures
Q = 12; % Number of states

cov_type = 'diag';
class_num = length(unique(trainGID));
for i = 1:class_num
    data = traindata(trainGID == i);

    % initial guess of parameters
    prior0 = normalise(rand(Q, 1));
    transmat0 = mk_stochastic(rand(Q, Q));

    [mu0, Sigma0] = mixgauss_init(Q*M, data, cov_type);
    mu0 = reshape(mu0, [O Q M]);
    Sigma0 = reshape(Sigma0, [O O Q M]);
    mixmat0 = mk_stochastic(rand(Q, M));

    [LL{i}, prior{i}, transmat{i}, mu{i}, Sigma{i}, mixmat{i}] = ...
        mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', 100, 'cov_type', cov_type);

    loglik{i} = mhmm_logprob(data, prior{i}, transmat{i}, mu{i}, Sigma{i}, mixmat{i})
end
%% get the loglik with test data
nex = length(testdata);
class_num = length(unique(testGID));
test_loglik = zeros(nex, class_num);
for i = 1:nex
    for j = 1:class_num
        fprintf ('the %d samples/%d class--hmm recognition for integral descriptor...%2.2f%%\n', i, j, (class_num*(i-1)+j)*100/(nex*class_num));
        data = testdata{i};
        test_loglik(i, j) = mhmm_logprob(data, prior{j}, transmat{j}, mu{j}, Sigma{j}, mixmat{j});
    end
end
[~, I] = max(test_loglik, [], 2); % sum up the recognition accurate ratio

for i = 1:class_num
    for j = 1:class_num
        confusion_matrix(i, j) = length(find(testGID == i & I == j));
    end
end
recog_ratio_interg{1, 1} = trace(confusion_matrix)/sum(confusion_matrix(:))
confusion_matrix_interg{1, 1} = confusion_matrix;
