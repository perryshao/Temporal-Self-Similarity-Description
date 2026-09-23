function [ClusterRawData, ClusterData, ClusterID]= ClusterAllData(TRAJDB, TRAJSAMPLES, ...
                              TRAJDB_DES, TRAJSAMPLES_DES, INTEGRATE_DES, INTEGRATESAMPLES_DES)
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

train_num = length(trainGID);
test_num = length(testGID);
ClusterData = cell(1, train_num+test_num);
ClusterRawData = cell(1, train_num+test_num);
for i = 1:train_num
    ClusterData{1, i} = [TRAJDB_DES{1, i} INTEGRATE_DES{1, i}];
    ClusterRawData{1, i} = TRAJDB{2, i};
end
test_num = length(testGID);
for i = 1:test_num
    ClusterData{1, i+train_num} = [TRAJSAMPLES_DES{1, i} INTEGRATESAMPLES_DES{1, i}];
    ClusterRawData{1, i+train_num} = TRAJSAMPLES{2, i};
end
ClusterID = [trainGID;testGID];
