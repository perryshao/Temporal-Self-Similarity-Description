function theta = trainBinRegression(X, trainGID, lambda, jointNum, modulaNum)
%TRAINBINREGRESSION  Train the group-sparse multi-output linear regressor.
%   THETA = TRAINBINREGRESSION(X, TRAINGID, LAMBDA, JOINTNUM, MODULANUM)
%   minimises COSTFUNCTIONREG with MINIMIZE (Rasmussen's conjugate gradients):
%   50 rounds over two shuffled mini-batches, then a final pass on all of X
%   (D x N) with lambda = [0.5 0.5 0.5].  THETA is D x C.
%
%   See also PREDICTBINREGRESSION.

% Labels and training data
clear traind
numTrain = length(trainGID);
classNum = length(unique(trainGID));
Y = zeros(numTrain, classNum);
for i = 1:classNum
    Y(trainGID == i, i) = 1;
end

%% =========== Regularized Multiple Binary Logistic Regression ============

% % Set Options
% options = optimset('GradObj', 'on', 'MaxIter', 400);
% preTheta = 0;
% D = size(X,1);
% initialTheta = zeros(D, classNum);
% % Optimize
% [theta, J, exit_flag] = ...
%     fminunc(@(t)(costFunctionReg(t, X, Y, lambda, classNum,jointNum, modulaNum,preTheta)), initialTheta, options);

% due to memory limitation, we train the regression model with a set of batch training.
D = size(X, 1);
N = size(X, 2);
% shuffle the training data before minibatch training
shuffleIndx = randperm(N);
Y = Y(shuffleIndx, :);
X = X(:, shuffleIndx);
batchTimes = 2;
iterNum = 50;
batchsize = floor(N/batchTimes);
preTheta = zeros(D*classNum, 1);
initialTheta = zeros(D*classNum, 1); % vec(W)
for iter = 1:iterNum
    for batchtimes = 1:batchTimes-1
        Xbatch = X(:, (batchtimes-1)*batchsize+1:batchtimes*batchsize);
        Ybatch = Y((batchtimes-1)*batchsize+1:batchtimes*batchsize, :);
        fprintf('Iteration %d Batch times %d\n', iter, batchtimes)
        [initialTheta, J, c] = minimize(initialTheta, 'costFunctionReg', 50, Xbatch, Ybatch, lambda, classNum, jointNum, modulaNum, preTheta);
    end
    Xbatch = X(:, batchtimes*batchsize+1:end);
    Ybatch = Y(batchtimes*batchsize+1:end, :);
    fprintf('Iteration %d Batch times %d \n', iter, batchtimes+1)
    [initialTheta, J, c] = minimize(initialTheta, 'costFunctionReg', 50, Xbatch, Ybatch, lambda, classNum, jointNum, modulaNum, preTheta);
end
save initialTheta;
preTheta = initialTheta;
lambda = [0.5 0.5 0.5];
[theta, J, c] = minimize(initialTheta, 'costFunctionReg', 50, X, Y, lambda, classNum, jointNum, modulaNum, preTheta);

theta = reshape(theta, D, classNum);
