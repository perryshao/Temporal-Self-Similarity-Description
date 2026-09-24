function Kernel_pyramid = PyramidMatching(x1, x2, ntotalbh, num_words)
%PYRAMIDMATCHING  Temporal pyramid match kernel between two sets of histograms.
%   K = PYRAMIDMATCHING(X1, X2, NTOTALBH, NUM_WORDS) returns the
%   size(X1,1)-by-size(X2,1) kernel matrix for rows that concatenate BoF
%   histograms (NUM_WORDS bins each) over pyramid levels 0..NTOTALBH with 2^l
%   temporal blocks per level (GENE_CODEBOOK_PYRAMID):
%       K = I_L + sum_{l=0}^{L-1} (I_l - I_{l+1}) / 2^(L-l),
%   where I_l is the histogram intersection at level l (Lazebnik et al. 2006).
%   Used as a precomputed kernel for LIBSVM (svmtrain -t 4): the KTPM method.

n = size(x1, 1);
m = size(x2, 1);
K = num_words;
I = cell(1, ntotalbh);
nblocks = 2.^(0:ntotalbh);

for py_n = 1:ntotalbh+1
    I{py_n} = hist_isect_c(x1(:, sum(nblocks(1:py_n-1))*K+1:sum(nblocks(1:py_n))*K), ...
        x2(:, sum(nblocks(1:py_n-1))*K+1:sum(nblocks(1:py_n))*K));
end
temp_I = 0;
for l = 0:ntotalbh-1
    temp_I = temp_I + (I{l+1}-I{l+1+1})./repmat(2^(ntotalbh-l), n, m);
end
Kernel_pyramid = I{ntotalbh+1}+temp_I;
