function [beta] = sc_approx_pooling_ts(feaSet, B, pyramid, gamma, knn)
% ================================================
%
% Usage:
% Compute the linear spatial pyramid feature of temporal sequences using sparse coding.
%
% Inputss:

% feaSet         local feature array extracted from the
%                 temporal sequences, column-wise

% B             -sparse dictionary, column-wise
% pyramid       -defines structure of pyramid
% gamma         -sparsity regularization parameter
% knn           -k nearest neighbors selected for sparse coding
%
% Output:
% beta          -multiscale max pooling feature
%
% Written by Jianchao Yang @ NEC Research Lab America (Cupertino)
% Mentor: Kai Yu
% July 2008
%
% Revised May. 2010
% ===============================================

dSize = size(B, 2);
nSmp = size(feaSet, 2);
sc_codes = zeros(dSize, nSmp);

% compute the local feature for each local feature
D = feaSet'*B;
IDX = zeros(nSmp, knn);
for ii = 1:nSmp
    d = D(ii, :);
    [~, idx] = sort(d, 'descend');
    IDX(ii, :) = idx(1:knn);
end

for ii = 1:nSmp
    y = feaSet(:, ii);
    idx = IDX(ii, :);
    BB = B(:, idx);
    sc_codes(idx, ii) = feature_sign(BB, y, 2*gamma);
end

sc_codes = abs(sc_codes);

% spatial levels
pLevels = length(pyramid);
% total spatial bins
tBins = sum(pyramid);

beta = zeros(dSize, tBins);
bId = 0;

for iter1 = 1:pLevels
    Unit = nSmp / pyramid(iter1);
    % find to which spatial bin each local descriptor belongs
    idxBin = ceil((1:nSmp)/Unit);

    for iter2 = 1: pyramid(iter1)
        bId = bId + 1;
        sidxBin = find(idxBin == iter2);
        if isempty(sidxBin)
            continue;
        end
        beta(:, bId) = max(sc_codes(:, sidxBin), [], 2);
    end
end

if bId ~= tBins
    error('Index number error!');
end

beta = beta(:);
beta = beta./sqrt(sum(beta.^2));
