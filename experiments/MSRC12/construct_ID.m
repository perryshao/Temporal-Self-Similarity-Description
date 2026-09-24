function [trainGID, testGID]=construct_ID(TRAJDB, TRAJSAMPLES)
%CONSTRUCT_ID  Class labels of the training and test trajectories.
%   [TRAINGID, TESTGID] = CONSTRUCT_ID(TRAJDB, TRAJSAMPLES) derives a numeric
%   class label for every trajectory from the class sub-folder in its file
%   path (row 1 of TRAJDB / TRAJSAMPLES), via GRP2IDX.

samples_r = size(TRAJDB, 2);
samples_t = size(TRAJSAMPLES, 2);
trainGID = zeros(samples_r, 1);
for i = 1:samples_r
    directory_loca = find(TRAJDB{1, i} == '/');
    TRAJDB{1, i} = TRAJDB{1, i}(1:directory_loca(2));
    trainGID(i) = str2double(TRAJDB{1, i}(end-2:end-1));
end
testGID = zeros(samples_t, 1);
for i = 1:samples_t
    directory_loca = find(TRAJSAMPLES{1, i} == '/');
    TRAJSAMPLES{1, i} = TRAJSAMPLES{1, i}(1:directory_loca(2));
    testGID(i) = str2double(TRAJSAMPLES{1, i}(end-2:end-1));
end
