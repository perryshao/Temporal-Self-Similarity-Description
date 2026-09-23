function [Retrieved_Data, Retrieved_Indx] = Retrieval_data(Query_Indx,QueryID,Clustered_Indx,...
                                            ClusterData,ClusterID,Recall)
num = length(ClusterData);
%% Clustering-based retrieval
% K = length(Clustered_Indx);
% Retrieved_Cluster = zeros(1,num);
% for i = 1:num
%     for j = 1:K
%         if any(ismember(Clustered_Indx{j},Query_Indx(i)))
%             Retrieved_Cluster(i) = j;
%         end
%     end
% end
% Retrieved_Cluster= unique(Retrieved_Cluster,'stable');
% % IndexNum_Cluster = 10;
% % IndexNum_Incluster = 10;
% % Retrieved_Indx = zeros(1,IndexNum_Cluster*IndexNum_Incluster);
% % for i = 1:IndexNum_Cluster
% %     for j = 1:length(Clustered_Indx{Retrieved_Cluster(i)})
% %          temp_indx = Clustered_Indx{Retrieved_Cluster(i)};
% %          dtw_distance(i,j) = dtw_adj_matching(Clusterdata{Query_Indx(i)},Clusterdata{temp_indx(j)},50,0);      
% %     end
% %     [~,Indx] = sort(dtw_distance,2);
% %     Retrieved_Indx((i-1)*IndexNum_Incluster+1:i*IndexNum_Incluster) = Indx(1:IndexNum_Incluster);
% % end
% 
% Relevant_Indx = find(ClusterID == QueryID);
% % for recall_num = 1:IndexNum_Cluster*IndexNum_Incluster
% Retrieved_Indx = [];
% for recall_num = 1:K
%     Retrieved_Indx = [Retrieved_Indx;Clustered_Indx{Retrieved_Cluster(recall_num)}];
% %     recall = length(intersect(Relevant_indx,Retrieved_Indx(1:recall_num)))/length(Relevant_indx);
%     recall = length(intersect(Relevant_Indx,Retrieved_Indx))/length(Relevant_Indx);
%     if recall > Recall || recall == 1
%         break;
%     end
% end
% Retrieved_Data = ClusterData(Retrieved_Indx);
% % Retrieved_Data = ClusterData(Retrieved_Indx(1:recall_num));
% % Retrieved_indx = Retrieved_Indx(1:recall_num);
%% KNN-based retrieval
Relevant_Indx = find(ClusterID == QueryID);
for recall_num = 2:num 
    Retrieved_Indx = Query_Indx(1:recall_num)';
    recall = length(intersect(Relevant_Indx,Retrieved_Indx))/length(Relevant_Indx);
    if recall > Recall || recall == 1
        break;
    end
end
Retrieved_Data = ClusterData(Retrieved_Indx);

