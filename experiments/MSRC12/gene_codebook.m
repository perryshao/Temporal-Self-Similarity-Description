function [traindata,testdata,sum_BoF_time] = gene_codebook(TRAJDB_DES,TRAJSAMPLES_DES)

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

% for normal BoF
% traindata = zeros(samples_r,K);
% testdata = zeros(samples_t,K);

% for spatial BoF
ntotalbh = 5;
traindata = zeros(samples_r,K*ntotalbh);
testdata = zeros(samples_t,K*ntotalbh);
BoWvec = zeros(K,ntotalbh);

% learning code
k = 0;
for i=1:samples_r
    k = size(TRAJDB_DES{1,i},1)+k;
	words(k-size(TRAJDB_DES{1,i},1)+1:k,:) = TRAJDB_DES{1,i};
end
words = words';
Vwords = learnCodebook(words,K,niter);
clear words;

%% for normal BoF
% for i=1:samples_r
% 	feats = TRAJDB_DES{1,i};
%     BoWvec = computeBoV(Vwords,feats',1);
% 	traindata(i,:) = BoWvec';
% end
% 
% for i=1:samples_t   
% 	feats = TRAJSAMPLES_DES{1,i};
% 	BoWvec = computeBoV(Vwords,feats',1);
% 	testdata(i,:) = BoWvec';
% end

%% for spatial BoF
for i=1:samples_r
	feats = TRAJDB_DES{1,i};
    m = size(feats,1);
    xbstep = m/ntotalbh;
    stepunit = round(1:xbstep:m);
    k = 1;
    for j = 1:ntotalbh-1
       BoWvec(:,k) = computeBoV(Vwords,feats(stepunit(j):stepunit(j+1)-1,:)',1);
       k = k+1;
    end
    BoWvec(:,k) = computeBoV(Vwords,feats(stepunit(end):end,:)',1);
    BoFvec  = reshape(BoWvec,K*ntotalbh,1);
	traindata(i,:) = BoFvec';
end
tic;
for i=1:samples_t 
    feats = TRAJSAMPLES_DES{1,i};
	m = size(feats,1);
    xbstep = m/ntotalbh;
    stepunit = round(1:xbstep:m);
    k = 1; 
    for j = 1:ntotalbh-1
       BoWvec(:,k) = computeBoV(Vwords,feats(stepunit(j):stepunit(j+1)-1,:)',1);
       k = k+1;
    end  
    BoWvec(:,k) = computeBoV(Vwords,feats(stepunit(end):end,:)',1); 
    BoFvec  = reshape(BoWvec,K*ntotalbh,1);
	testdata(i,:) = BoFvec';
end
sum_BoF_time = toc;
