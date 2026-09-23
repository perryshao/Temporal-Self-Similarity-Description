function [trainGID, testGID]=construct_ID(TRAJDB, TRAJSAMPLES)
%%  build the labels for training and testing
samples_r = size(TRAJDB, 2);
samples_t = size(TRAJSAMPLES, 2);
trainGID = zeros(samples_r, 1);
testGID = zeros(samples_t, 1);
for i = 1:samples_r
    directory_loca = find(TRAJDB{1, i} == '/');
    TRAJDB{1, i} = TRAJDB{1, i}(1:directory_loca(2)+3);
    trainGID(i) = str2double(TRAJDB{1, i}(end-1:end));
end
for i = 1:samples_t
    directory_loca = find(TRAJSAMPLES{1, i} == '/');
    TRAJSAMPLES{1, i} = TRAJSAMPLES{1, i}(1:directory_loca(2)+3);
    testGID(i) = str2double(TRAJSAMPLES{1, i}(end-1:end));
end
train_num = length(trainGID);
