function [ClusterData, ClusterID]= ClusterAllData_JointFeatures(joints_no, descrip_flag)
m_num = length(joints_no);
for j = 1:m_num
    load([joints_no{1, j} '.mat']);
    eval([strcat('DB_', joints_no{1, j}) '=TRAJDB;']); % LWRA curve
end
samples = size(TRAJDB, 2);
FEATURES = cell(1, samples);

for i = 1:samples
    fprintf ('get joint features %d/%d...\n', i, samples);
    for j = 1:m_num
        eval(['marker_xyz=' strcat('DB_', joints_no{1, j}) '{2,i};']);
        switch descrip_flag
            case 1
                fd = fft(marker_xyz);
                fd = fd./repmat(abs(fd(2, :)), size(fd, 1), 1);
                % FEATURES{1,i}(:,end+1:end+29) = abs(fd(2:30,:));
                FEATURES{1, i}(:, end+1:end+3) = fd(2:30, :);
            case 2
                FEATURES{1, i}(:, end+1:end+4) = descriptor_comp(marker_xyz);
            case 3
                % marker_des = integral_invariant(marker_xyz,8,0.05);
                marker_des = integral_invariant_kn(marker_xyz, 8, 20);
                FEATURES{1, i}(:, end+1:end+2) = 0.5-marker_des;
            case 4
                marker_des = integral_invariant_ms(marker_xyz, 8, 0.3);
                FEATURES{1, i}(:, end+1:end+10) = 0.5-marker_des;
            case 5
                FEATURES{1, i}(:, end+1) = integral_invariant_dist(marker_xyz, 20);
            case 6
                FEATURES{1, i}(:, end+1:end+3) = marker_xyz;
            otherwise
                disp('error input descrip_flag')
        end

    end
end

for j = 1:m_num
    load([joints_no{1, j} 'samples.mat']);
    eval([strcat('SAMPLES_', joints_no{1, j}) '=TRAJSAMPLES;']);
end
samples = size(TRAJSAMPLES, 2);
FEATURESAMPLES = cell(1, samples);

for i = 1:samples
    fprintf ('get sample joint features %d/%d...\n', i, samples);
    for j = 1:m_num
        eval(['marker_xyz=' strcat('SAMPLES_', joints_no{1, j}) '{2,i};']);
        switch descrip_flag
            case 1
                fd = fft(marker_xyz);
                fd = fd./repmat(abs(fd(2, :)), size(fd, 1), 1);
                % FEATURES{1,i}(:,end+1:end+29) = abs(fd(2:30,:));
                FEATURESAMPLES{1, i}(:, end+1:end+3) = fd(2:30, :);
            case 2
                FEATURESAMPLES{1, i}(:, end+1:end+4) = descriptor_comp(marker_xyz);
            case 3
                % marker_des = integral_invariant(marker_xyz,8,0.05);
                marker_des = integral_invariant_kn(marker_xyz, 8, 20);
                FEATURESAMPLES{1, i}(:, end+1:end+2) = 0.5-marker_des;
            case 4
                marker_des = integral_invariant_ms(marker_xyz, 8, 0.3);
                FEATURESAMPLES{1, i}(:, end+1:end+10) = 0.5-marker_des;
            case 5
                FEATURESAMPLES{1, i}(:, end+1) = integral_invariant_dist(marker_xyz, 20);
            case 6
                FEATURESAMPLES{1, i}(:, end+1:end+3) = marker_xyz;
            otherwise
                disp('error input descrip_flag')
        end

    end
end
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
test_num = length(testGID);
ClusterData = cell(1, train_num+test_num);
ClusterRawData = cell(1, train_num+test_num);
for i = 1:train_num
    ClusterData{1, i} = FEATURES{1, i};
end
test_num = length(testGID);
for i = 1:test_num
    ClusterData{1, i+train_num} = FEATURESAMPLES{1, i};
end
ClusterID = [trainGID;testGID];
