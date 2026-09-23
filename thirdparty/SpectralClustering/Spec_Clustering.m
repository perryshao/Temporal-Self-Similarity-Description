function [Clustered_indx, Ctrs,dtw_distance] = Spec_Clustering(traindata, K, Type,delta,dtw_distance)
num=length(traindata);
if nargin <5
    dtw_distance = zeros(num,num);
    for i=1:num
        for j=1:i-1
    		fprintf ('dtw computing %d-%d\n',i,j);
                [dtw_distance(i,j), ~, ~] = dtw_adj_matching(traindata{i},traindata{j},100,3); 
%                 [dtw_distance(i,j), ~, ~] = dtw_adj_orien(traindata{i}(:,1:2),traindata{j}(:,1:2),...
%                                             traindata{i}(:,3:end),traindata{j}(:,3:end),1,100);
        end   
    end
    dtw_distance = dtw_distance + dtw_distance.';
end
W = exp(-dtw_distance.^2/delta^2);
W = W - eye(num);
[C, Ctrs] = SpectralClustering(W, K, Type);
C = full(C);
Clustered_indx = cell(1,K);
for i  = 1:K
    Clustered_indx{1,i} = find(C(:,i) == 1);
end
