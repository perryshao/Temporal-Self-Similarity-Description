function [Qdata,QueryID] = PickupQuery(clusterdata,clusterID, Q_num)
data_num = length(clusterdata);
pick_indx = ceil(rand(1,Q_num)*data_num);
Qdata= clusterdata(pick_indx);
QueryID = clusterID(pick_indx);
