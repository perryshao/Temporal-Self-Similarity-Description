function [theta, trained_data] = train_dtw(traindata, trainGID, testdata, testGID)
%TRAIN_DTW  Build one DTW-averaged template per class (exploratory).
%   [THETA, TRAINED_DATA] = TRAIN_DTW(TRAINDATA, TRAINGID, TESTDATA, TESTGID)
%   computes all pairwise DTW alignments inside each class and repeatedly
%   merges the closest pair with FUSION_DTWDATA until one template per class
%   remains.  THETA is all ones (no weights are learned).

num = length(traindata);
dtw_distance = zeros(num, num);
dtw_path = cell(num, num);
for i = 1:num
    for j = 1:i-1
        fprintf ('dtw computing %d-%d\n', i, j);
        [dtw_distance(i, j), ~, dtw_path{i, j}] = dtw(traindata{i}', traindata{j}', 50);
    end
end
for i = 1:num
    for j = 1:i-1
        dtw_path{j, i} = dtw_path{i, j}(:, 2:-1:1);
    end
end
dtw_distance = dtw_distance + dtw_distance.';

dimen = size(traindata{1}, 1);
class_num = length(unique(trainGID));
theta = ones(dimen, class_num);
trained_data = cell(1, class_num);
for i = 1:class_num
    distance = dtw_distance(trainGID == i, trainGID == i);
    path = dtw_path(trainGID == i, trainGID == i);
    data = traindata(trainGID == i);
    while ~isempty(data)
        for n = 1:length(data)
            [distance(end, n), ~, path{end, n}] = dtw(data{end}', data{n}', 50);
        end
        distance(:, end) = distance(end, :);
        for n = 1:length(data)
            path{n, end} = path{end, n}(:, 2:-1:1);
        end
        d_av = mean(distance, 2);
        alpha = 1/mean(d_av);
        w = alpha*exp(-alpha*d_av);
        [~, indx] = sort(d_av, 'ascend');
        align_path = path{indx(1), indx(2)};
        align_data_1 = w(indx(1))*data{indx(1)}(:, align_path(:, 1));
        align_data_2 = w(indx(2))*data{indx(2)}(:, align_path(:, 2));
        [~, average_indx] = max(max(align_path));
        align_data{1} = data{average_indx};
        align_data{2} = (align_data_1+align_data_2)/(w(indx(1))+ w(indx(1)));
        trained_data{i} = dba(align_data);
        % w(1) = w(indx(1));w(2) = w(indx(2));
        % trained_data{i} = fusion_dtwdata(align_path,align_data_1,align_data_2,w);

        % align_data{1} = w(indx(1))*data{indx(1)};align_data{2} = w(indx(2))*data{indx(2)};
        % trained_data{i} = dba(align_data);

        data(indx(1:2)) = [];path(indx(1:2), :) = [];path(:, indx(1:2)) = [];
        distance(indx(1:2), :) = [];distance(:, indx(1:2)) = [];
        data{end+1} = trained_data{i};path(end+1, end+1) = cell(1);distance(end+1, end+1) = 0;
        if length(data) == 1
            break;
        end
    end
    % threshold = [repmat(0.2,2,1);repmat(0.1,32,1)];
    threshold = [repmat(0.2, 8, 1)];
    theta_logic(:, i) = max(trained_data{i}, [], 2)-min(trained_data{i}, [], 2) > threshold;
end
theta(theta_logic) = 1;
theta(~theta_logic) = 0.1;

class = 7;feature = 3;
plot(trained_data{class}(feature, :), '.b-');hold on;
data = traindata(trainGID == class);
for i = 1:length(data)
    plot(data{i}(feature, :), '-k.');hold on;
end

nex = length(testdata);
class_num = length(unique(testGID));
test_loglik = zeros(nex, class_num);
d_av = zeros(dimen, class_num);
for i = 1:nex
    for p = 1:class_num
        fprintf ('the %d samples/%d class--hmm recognition for integral descriptor...%2.2f%%\n', i, p, (class_num*(i-1)+p)*100/(nex*class_num));
        data = testdata{i};
        for j = 1:dimen;
            d_av(j, p) = dtw(data(j, :)', trained_data{p}(j, :)', 50);
        end
    end
    alpha = 1./mean(d_av, 1);alpha = repmat(alpha, dimen, 1);
    P = alpha.*exp(-alpha.*d_av);
    test_loglik(i, :) = sum(theta.*log(P), 1);
end
[~, I] = max(test_loglik, [], 2);

nex = length(testdata);
class_num = length(unique(testGID));
test_loglik = zeros(nex, class_num);
d_av = zeros(nex, class_num);
for i = 1:nex
    for p = 1:class_num
        fprintf ('the %d samples/%d class--hmm recognition for integral descriptor...%2.2f%%\n', i, p, (class_num*(i-1)+p)*100/(nex*class_num));
        data = testdata{i};
        d_av(i, p) = dtw(data', trained_data{p}', 50);
    end
end
[~, I] = min(d_av, [], 2);

for i = 1:class_num
    for j = 1:class_num
        confusion_matrix(i, j) = length(find(testGID == i & I == j));
    end
end
recog_ratio_interg{1, 1} = trace(confusion_matrix)/sum(confusion_matrix(:))
confusion_matrix_interg{1, 1} = confusion_matrix;
