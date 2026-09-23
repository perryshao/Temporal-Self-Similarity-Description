function [beta] = sc_pooling_ts(feaSet, B, pyramid, gamma)
%================================================
% 
% Usage:
% Compute the linear spatial pyramid feature using sparse coding. 
%
% Inputss:
% feaSet        local feature array extracted from the
%               temporal sequences, column-wise

% B             -sparse dictionary, column-wise
% gamma         -sparsity regularization parameter
% pyramid       -defines structure of pyramid 
% 
% Output:
% beta          -multiscale max pooling feature
%
% Written by Jianchao Yang @ NEC Research Lab America (Cupertino)
% Mentor: Kai Yu
% July 2008
%
% Revised May. 2010
%===============================================

dSize = size(B, 2);
nSmp = size(feaSet, 2);
sc_codes = zeros(dSize, nSmp);


% compute the local feature for each local feature
beta = 1e-4;
A = B'*B + 2*beta*eye(dSize);
Q = -B'*feaSet;

for iter1 = 1:nSmp,
    sc_codes(:, iter1) = L1QP_FeatureSign_yang(gamma, A, Q(:, iter1));
end

sc_codes = abs(sc_codes);

% spatial levels
pLevels = length(pyramid);
% total spatial bins
tBins = sum(pyramid);

beta = zeros(dSize, tBins);
bId = 0;

for iter1 = 1:pLevels,    
    Unit = nSmp / pyramid(iter1);  
    % find to which spatial bin each local descriptor belongs
    idxBin = ceil((1:nSmp)/Unit);
    
    for iter2 = 1: pyramid(iter1),     
        bId = bId + 1;
        sidxBin = find(idxBin == iter2);
        if isempty(sidxBin),
            continue;
        end      
        beta(:, bId) = max(sc_codes(:, sidxBin), [], 2);
    end
end

if bId ~= tBins,
    error('Index number error!');
end

beta = beta(:);
beta = beta./sqrt(sum(beta.^2));
