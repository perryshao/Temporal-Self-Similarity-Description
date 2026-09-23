function Clustered_accuracy = Get_ClusterAccuracy(Clustered_Indx, clusterID)
K = length(Clustered_Indx);
intersect_indx = cell(K, K);
interscet_num = zeros(K, K);
temp = 0;
for i = 1:K
    for j = 1:K
        intersect_indx{i, j} = intersect(Clustered_Indx{i}, find(clusterID == j));
        interscet_num(i, j) = length(intersect_indx{i, j});
    end
    [matched_num, indx] = max(interscet_num(i, :));
    temp = matched_num/length(find(clusterID == indx)) + temp;
    % temp = max(interscet_num(i,:))/length(Clustered_Indx{i}) + temp;
end
Clustered_accuracy = temp/K;
