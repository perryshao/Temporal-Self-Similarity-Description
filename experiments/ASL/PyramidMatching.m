function Kernel_pyramid = PyramidMatching(x1, x2,ntotalbh,num_words)

n = size(x1,1);
m = size(x2,1);
K = num_words;
I = cell(1,ntotalbh);
nblocks = 2.^(0:ntotalbh);


for py_n = 1:ntotalbh+1
    I{py_n}=hist_isect_c(x1(:,sum(nblocks(1:py_n-1))*K+1:sum(nblocks(1:py_n))*K),...
        x2(:,sum(nblocks(1:py_n-1))*K+1:sum(nblocks(1:py_n))*K));
end
temp_I = 0;
for l = 0:ntotalbh-1
    temp_I = temp_I + (I{l+1}-I{l+1+1})./repmat(2^(ntotalbh-l),n,m);
end
Kernel_pyramid = I{ntotalbh+1}+temp_I;


