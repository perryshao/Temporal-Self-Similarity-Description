function [Qdata, QueryID] = PickupQuery(clusterdata, clusterID, Q_num)
%PICKUPQUERY  Draw random query samples for a retrieval test.
%   [QDATA, QUERYID] = PICKUPQUERY(CLUSTERDATA, CLUSTERID, Q_NUM) picks Q_NUM
%   samples (with replacement) and returns them with their class labels.

data_num = length(clusterdata);
pick_indx = ceil(rand(1, Q_num)*data_num);
Qdata = clusterdata(pick_indx);
QueryID = clusterID(pick_indx);
