function [Indx, dtw_distance] = Query_distance(Qdata, Clusterdata)
%QUERY_DISTANCE  Rank a data set by DTW distance to a query.
%   [INDX, DTW_DISTANCE] = QUERY_DISTANCE(QDATA, CLUSTERDATA) computes the DTW
%   distance (DTW_ADJ_MATCHING, window 50) from QDATA to every element of
%   CLUSTERDATA and returns the indices sorted by increasing distance.

num = length(Clusterdata);
dtw_distance = zeros(1, num);
for i = 1:num
    fprintf ('dtw computing %d-%d\n', 1, i);
    [dtw_distance(1, i), ~, ~] = dtw_adj_matching(Qdata, Clusterdata{i}, 50, 3);
end
[~, Indx] = sort(dtw_distance, 2);
