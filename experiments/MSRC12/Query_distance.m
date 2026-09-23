function [Indx, dtw_distance] = Query_distance(Qdata,Clusterdata)
num=length(Clusterdata);
dtw_distance = zeros(1,num);
for i=1:num
    fprintf ('dtw computing %d-%d\n',1,i);
%     [dtw_distance(1,i), ~, ~] = dtw_adj_matching(Qdata(:,1:10),Clusterdata{i}(:,1:10),100,3);
% %     [dtw_distance(1,i), ~, ~] = dtw_adj_orien(Qdata(:,1:10),Clusterdata{i}(:,1:10),...
% %                                             Qdata(:,11:end),Clusterdata{i}(:,11:end),100);
    % for multiscale distance integral invariants
%     [dtw_distance(1,i), ~, ~] = dtw_adj_orien([Qdata(:,1) Qdata(:,1)],...
%                                               [Clusterdata{i}(:,1) Clusterdata{i}(:,1)],...
%                                             Qdata(:,11:end),Clusterdata{i}(:,11:end),1,100);
end
[~,Indx] = sort(dtw_distance,2);