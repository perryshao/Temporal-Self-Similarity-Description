function [ClusterRawData, ClusterData, ClusterID]= ClusterAllData(TRAJDB, TRAJSAMPLES, ...
                              TRAJDB_DES, TRAJSAMPLES_DES, INTEGRATE_DES, INTEGRATESAMPLES_DES)
%CLUSTERALLDATA  Pool training and test sets for clustering / retrieval.
%   [CLUSTERRAWDATA, CLUSTERDATA, CLUSTERID] = CLUSTERALLDATA(TRAJDB,
%   TRAJSAMPLES, TRAJDB_DES, TRAJSAMPLES_DES, INTEGRATE_DES,
%   INTEGRATESAMPLES_DES) concatenates both sets: raw xyz trajectories, their
%   descriptors (root descriptor followed by the relative descriptors) and
%   their class labels.

samples_r = size(TRAJDB, 2);
samples_t = size(TRAJSAMPLES, 2);
for i = 1:samples_r
    directory_loca = find(TRAJDB{1, i} == '/');
    TRAJDB{1, i} = TRAJDB{1, i}(1:directory_loca(2)+3);
end
trainGID = grp2idx(TRAJDB(1, :)');
for i = 1:samples_t
    directory_loca = find(TRAJSAMPLES{1, i} == '/');
    TRAJSAMPLES{1, i} = TRAJSAMPLES{1, i}(1:directory_loca(2)+3);
end
testGID = grp2idx(TRAJSAMPLES(1, :)');
train_num = length(trainGID);
test_num = length(testGID);
ClusterData = cell(1, train_num+test_num);
ClusterRawData = cell(1, train_num+test_num);
for i = 1:train_num
    % traindata{1,i} = [TRAJDB_DES{1,i} INTEGRATE_DES{1,i}]';
    % ClusterData{1,i} = [TRAJDB_DES{1,i} INTEGRATE_DES{1,i}];
    ClusterData{1, i} = TRAJDB_DES{1, i};
    ClusterRawData{1, i} = TRAJDB{2, i};
end
test_num = length(testGID);
for i = 1:test_num
    % clusterdata{1,i+train_num} = [TRAJSAMPLES_DES{1,i} INTEGRATESAMPLES_DES{1,i}]';
    % ClusterData{1,i+train_num} = [TRAJSAMPLES_DES{1,i} INTEGRATESAMPLES_DES{1,i}];
    ClusterData{1, i+train_num} = TRAJSAMPLES_DES{1, i};
    ClusterRawData{1, i+train_num} = TRAJSAMPLES{2, i};
end
ClusterID = [trainGID;testGID];
