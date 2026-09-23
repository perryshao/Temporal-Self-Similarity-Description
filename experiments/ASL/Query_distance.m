function [Indx, dtw_distance] = Query_distance(Qdata,Clusterdata)
num=length(Clusterdata);
dtw_distance = zeros(1,num);
for i=1:num
    fprintf ('dtw computing %d-%d\n',1,i);
    [dtw_distance(1,i), ~, ~] = dtw_adj_matching(Qdata,Clusterdata{i},50,3);
end
[~,Indx] = sort(dtw_distance,2);