function [Indx, dtw_distance] = Query_distance(Qdata, Clusterdata)
%QUERY_DISTANCE  Rank a data set by distance to a query.
%   [INDX, DTW_DISTANCE] = QUERY_DISTANCE(QDATA, CLUSTERDATA) returns the
%   indices of CLUSTERDATA sorted by increasing distance to QDATA.
%
%   NOTE: as last saved every distance line below is commented out, so all
%   distances are 0 and the ranking is the identity.  Enable one of them (or
%   use QUERY_DISTANCE_RANKONE) before running a retrieval test.

num = length(Clusterdata);
dtw_distance = zeros(1, num);
for i = 1:num
    fprintf ('dtw computing %d-%d\n', 1, i);
    %     [dtw_distance(1,i), ~, ~] = dtw_adj_matching(Qdata(:,1:10),Clusterdata{i}(:,1:10),100,3);
    % %     [dtw_distance(1,i), ~, ~] = dtw_adj_orien(Qdata(:,1:10),Clusterdata{i}(:,1:10),...
    % %                                             Qdata(:,11:end),Clusterdata{i}(:,11:end),100);
    % for multiscale distance integral invariants
    %     [dtw_distance(1,i), ~, ~] = dtw_adj_orien([Qdata(:,1) Qdata(:,1)],...
    %                                             [Clusterdata{i}(:,1) Clusterdata{i}(:,1)],...
    %                                             Qdata(:,11:end),Clusterdata{i}(:,11:end),1,100);
end
[~, Indx] = sort(dtw_distance, 2);
