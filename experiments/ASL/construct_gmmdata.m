function [traindata, testdata, trainGID, testGID]=construct_gmmdata(TRAJDB, TRAJSAMPLES, ...
                              TRAJDB_DES, TRAJSAMPLES_DES)
%CONSTRUCT_GMMDATA  Arrange descriptors for the per-class GMM baseline.
%   [TRAINDATA, TESTDATA, TRAINGID, TESTGID] = CONSTRUCT_GMMDATA(TRAJDB,
%   TRAJSAMPLES, TRAJDB_DES, TRAJSAMPLES_DES) stacks all training frames of
%   each class into one matrix (TRAINDATA{class}) and keeps one matrix per test
%   trajectory.  Column 1 is the frame index; the two zero-padded frames at
%   each end of a descriptor sequence are dropped.

samples_r = size(TRAJDB, 2);
samples_t = size(TRAJSAMPLES, 2);
r_rows = zeros(1, samples_r);
for i = 1:samples_r
    directory_loca = find(TRAJDB{1, i} == '/');
    TRAJDB{1, i} = TRAJDB{1, i}(1:directory_loca(2));
    r_rows(i) = size(TRAJDB{2, i}, 1);
end
trainGID = grp2idx(TRAJDB(1, :)');
t_rows = zeros(1, samples_t);
for i = 1:samples_t
    directory_loca = find(TRAJSAMPLES{1, i} == '/');
    TRAJSAMPLES{1, i} = TRAJSAMPLES{1, i}(1:directory_loca(2));
    t_rows(i) = size(TRAJSAMPLES{2, i}, 1);
end
testGID = grp2idx(TRAJSAMPLES(1, :)');
dim = size(TRAJDB_DES{1, 1}, 2); % eliminate the zeros
class = length(unique(trainGID));
% traindata = zeros(1,dim_root+dim_orien+1,class);
traindata = cell(1, class);
for lable = 1:class
    for i = find(trainGID == lable)'
        m = size(TRAJDB_DES{1, i}, 1)-4; % eliminate the zeros

        traindata{1, lable}(end+1:end+m, 1) = 1:m;
        traindata{1, lable}(end-m+1:end, 2:2+dim-1) = TRAJDB_DES{1, i}(3:end-2, :);

        % traindata{1,lable}(end+1:end+m,1:dim) = TRAJDB_DES{1,i}(3:end-2,:);
    end
end
test_num = length(testGID);
testdata = cell(1, test_num);

for i = 1:test_num
    m = size(TRAJSAMPLES_DES{1, i}, 1)-4; % eliminate the zeros

    testdata{1, i} = zeros(m, dim+1);
    testdata{1, i}(1:end, 1) = 1:m;
    testdata{1, i}(1:end, 2:end) = TRAJSAMPLES_DES{1, i}(3:end-2, :);

    % testdata{1,i} = zeros(m,dim);
    % testdata{1,i} = TRAJSAMPLES_DES{1,i}(3:end-2,:);
end
