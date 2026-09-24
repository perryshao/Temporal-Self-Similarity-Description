function [traindata, testdata, trainGID, testGID]= construct_hmmdata(TRAJDB, TRAJSAMPLES, ...
                              TRAJDB_DES, TRAJSAMPLES_DES)
%CONSTRUCT_HMMDATA  Arrange descriptors as observation sequences for the HMM baseline.
%   [TRAINDATA, TESTDATA, TRAINGID, TESTGID] = CONSTRUCT_HMMDATA(TRAJDB,
%   TRAJSAMPLES, TRAJDB_DES, TRAJSAMPLES_DES) returns one (dims x frames)
%   sequence per trajectory, without the two zero-padded frames at each end,
%   and the class labels (HMMs-AII in thesis Table 5.1).
%
%   See also MHMM_CLASSIFIER.

samples_r = size(TRAJDB, 2);
samples_t = size(TRAJSAMPLES, 2);
for i = 1:samples_r
    directory_loca = find(TRAJDB{1, i} == '/');
    TRAJDB{1, i} = TRAJDB{1, i}(1:directory_loca(2));
end
trainGID = grp2idx(TRAJDB(1, :)');
for i = 1:samples_t
    directory_loca = find(TRAJSAMPLES{1, i} == '/');
    TRAJSAMPLES{1, i} = TRAJSAMPLES{1, i}(1:directory_loca(2));
end
testGID = grp2idx(TRAJSAMPLES(1, :)');

train_num = length(trainGID);
traindata = cell(1, train_num);
for i = 1:train_num
    % traindata{1,i} = [TRAJDB_DES{1,i} INTEGRATE_DES{1,i}]';
    % traindata{1,i} = INTEGRATE_DES{1,i}(3:end-2,:)';
    traindata{1, i} = TRAJDB_DES{1, i}(3:end-2, :)';

end
test_num = length(testGID);
% testdata = zeros(1,dim_root+dim_orien+1,class);
testdata = cell(1, test_num);

for i = 1:test_num
    % testdata{1,i} = [TRAJSAMPLES_DES{1,i} INTEGRATESAMPLES_DES{1,i}]';
    % testdata{1,i} = INTEGRATESAMPLES_DES{1,i}(3:end-2,:)';
    testdata{1, i} = TRAJSAMPLES_DES{1, i}(3:end-2, :)';
end
