function [X] = rand_sampling_ts(TRAJDB_DES, num_smp)
%RAND_SAMPLING_TS  Randomly sample descriptors for dictionary learning.
%   X = RAND_SAMPLING_TS(TRAJDB_DES, NUM_SMP) draws about NUM_SMP descriptors
%   (columns of X), the same number from every training sequence.
%   Sequences shorter than their share are sampled with repetition.
%

num_training = length(TRAJDB_DES); % num of images
num_per_training = round(num_smp/num_training);
num_smp = num_per_training*num_training;
dimFea = size(TRAJDB_DES{1, 1}, 2);

X = zeros(dimFea, num_smp);
cnt = 0;

for ii = 1:num_training
    num_fea = size(TRAJDB_DES{1, ii}, 1);
    rndidx = randperm(num_fea);
    if num_per_training > max(rndidx)
        rndidx = [rndidx rndidx(1:num_per_training - max(rndidx))];
    end
    X(:, cnt+1:cnt+num_per_training) = TRAJDB_DES{1, ii}(rndidx(1:num_per_training), :)';
    cnt = cnt+num_per_training;
end;
