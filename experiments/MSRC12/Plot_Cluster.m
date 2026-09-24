function Plot_Cluster(ClusterRawData, ClusterID, Clustered_Indx)
%PLOT_CLUSTER  Plot the raw trajectories of each class in its own figure.
%   PLOT_CLUSTER(CLUSTERRAWDATA, CLUSTERID, CLUSTERED_INDX) draws, in figure k,
%   the xyz trajectories whose true class is k (one colour per trajectory).

% K = length(Clustered_Indx);
K = length(unique(ClusterID));
num = length(ClusterRawData);
for i = 1:K
    figure(i), clf, hold on;
    temp_indx = Clustered_Indx{i};
    % temp_indx = find(ClusterID == i);
    cVec = 'bgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmykbgrcmyk'; % , cVec = [cVec cVec];
    for j = 1:length(temp_indx)
        plot3d(ClusterRawData{temp_indx(j)}(:, 1:3), cVec(j));
        % plot(ClusterRawData{temp_indx(j)}(:,1:5),['-.' cVec(j)]);
        % plot(ClusterRawData{temp_indx(j)}(:,6:10),['-*' cVec(j)]);
    end
end
