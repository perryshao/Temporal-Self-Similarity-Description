function [traindata,testdata,sum_BoF_time,num_words] = gene_codebook_pyramid(TRAJDB_DES,TRAJSAMPLES_DES,ntotalbh)

%% collect the visual words
% K = 10000; % the numbers of words
niter = 200;
samples_r = size(TRAJDB_DES,2);
samples_t = size(TRAJSAMPLES_DES,2);


row_num = 0;
for i=1:samples_r
	row_num = size(TRAJDB_DES{1,i},1)+row_num;
end
words = zeros(row_num,size(TRAJDB_DES{1,1},2));
K = floor(row_num/10); % set the numbers of words according to the training number
num_words = K;


nblocks = 2.^(0:ntotalbh);
traindata = zeros(samples_r,K*sum(nblocks));
testdata = zeros(samples_t,K*sum(nblocks));

%% learning vocabulary words
% features in all the training dataset are used to trained codebook
k = 0;
for i=1:samples_r
    k = size(TRAJDB_DES{1,i},1)+k;
	words(k-size(TRAJDB_DES{1,i},1)+1:k,:) = TRAJDB_DES{1,i};
end
words = words';
Vwords = learnCodebook(words,K,niter);
clear words;

%% quantize the descriptors
for i=1:samples_r
	feats = TRAJDB_DES{1,i};
    m = size(feats,1);
    for py_n = 1:ntotalbh+1
        BoWvec = zeros(K,nblocks(py_n)); 
        xbstep = m/nblocks(py_n);
        stepunit = round(1:xbstep:m);
        k = 1;
        for j = 1:nblocks(py_n)-1
            BoWvec(:,k) = computeBoV(Vwords,feats(stepunit(j):stepunit(j+1)-1,:)',1);
            k = k+1;
        end
        BoWvec(:,k) = computeBoV(Vwords,feats(stepunit(end):end,:)',1);
        BoFvec  = reshape(BoWvec,K*nblocks(py_n),1);
        traindata(i,sum(nblocks(1:py_n-1))*K+1:sum(nblocks(1:py_n))*K) = BoFvec';
    end
end
tic;
for i=1:samples_t 
    feats = TRAJSAMPLES_DES{1,i};
    m = size(feats,1);
    for py_n = 1:ntotalbh+1
        BoWvec = zeros(K,nblocks(py_n)); 
        xbstep = m/nblocks(py_n);
        stepunit = round(1:xbstep:m);
        k = 1;
        for j = 1:nblocks(py_n)-1
            BoWvec(:,k) = computeBoV(Vwords,feats(stepunit(j):stepunit(j+1)-1,:)',1);
            k = k+1;
        end
        BoWvec(:,k) = computeBoV(Vwords,feats(stepunit(end):end,:)',1);
        BoFvec  = reshape(BoWvec,K*nblocks(py_n),1);
        testdata(i,sum(nblocks(1:py_n-1))*K+1:sum(nblocks(1:py_n))*K) = BoFvec';
    end
end
sum_BoF_time = toc;
