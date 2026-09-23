function [C, Ctrs] = SpectralClustering(W, K, Type)
%SPECTRALCLUSTERING Executes spectral clustering algorithm
%   Executes the spectral clustering algorithm defined by
%   Type on the adjacency matrix W and returns the k cluster
%   indicator vectors as columns in C.
%   If L and U are also called, the (normalized) Laplacian and
%   eigenvectors will also be returned.
%
%   'W' - Adjacency matrix, needs to be square
%   'k' - Number of clusters to look for
%   'Type' - Defines the type of spectral clustering algorithm
%            that should be used. Choices are:
%      1 - Unnormalized
%      2 - Normalized according to Shi and Malik (2000)
%      3 - Normalized according to Jordan and Weiss (2002)
%
%   References:
%   - Ulrike von Luxburg, "A Tutorial on Spectral Clustering", 
%     Statistics and Computing 17 (4), 2007
%
%   Author: Ingo Buerk
%   Year  : 2011/2012
%   Bachelor Thesis

% calculate degree matrix
degs = sum(W, 2);
D    = sparse(1:size(W, 1), 1:size(W, 2), degs);

% compute unnormalized Laplacian
L = D - W;

% compute normalized Laplacian if needed
switch Type
    case 2
        % avoid dividing by zero
        degs(degs == 0) = eps;
        % calculate inverse of D
        D = spdiags(1./degs, 0, size(D, 1), size(D, 2));
        
        % calculate normalized Laplacian
        L = D * L;
    case 3
        % avoid dividing by zero
        degs(degs == 0) = eps;
        % calculate D^(-1/2)
        D = spdiags(1./(degs.^0.5), 0, size(D, 1), size(D, 2));
        
        % calculate normalized Laplacian
        L = D * L * D;
end

% compute the eigenvectors corresponding to the k smallest
% eigenvalues
diff   = eps;
[U, ~] = eigs(L, K, diff);

% in case of the Jordan-Weiss algorithm, we need to normalize
% the eigenvectors row-wise
if Type == 3
    U = bsxfun(@rdivide, U, sqrt(sum(U.^2, 2)));
end

% now use the k-means algorithm to cluster U row-wise
% C will be a n-by-1 matrix containing the cluster number for
% each data point

[C,Ctrs] = kmeans(U, K, 'start', 'cluster', ...
                 'EmptyAction', 'singleton');
%% plot figure using kmeans cluster in last step
% figure(10),clf,hold on;
% cVec = 'bgrcmykbgrcmykbgrcmykbgrcmyk';%, cVec = [cVec cVec];
% for k = 1:K
%     plot(x(1,C==k),x(2,C==k),[cVec(k) '.']);
% end
%% using meanshift cluster instead of kmeans in last step of spectral clustering
% bandwidth = 0.75;
% [clustCent,point2cluster,clustMembsCell]  = MeanShiftCluster(U', bandwidth);
%% plot the eigenvalues' figure -- perry added
% numClust = length(clustMembsCell);
% U1=U';
% figure(11),clf,hold on
% cVec = 'bgrcmykbgrcmykbgrcmykbgrcmyk';%, cVec = [cVec cVec];
% for k = 1:min(numClust,length(cVec))
%     myMembers = clustMembsCell{k};
%     myClustCen = clustCent(:,k);
%     plot3(U1(1,myMembers),U1(2,myMembers),U1(3,myMembers),[cVec(k) '.'])
%     plot3(myClustCen(1),myClustCen(2),myClustCen(3),'o','MarkerEdgeColor','k','MarkerFaceColor',cVec(k), 'MarkerSize',10)
% end
% title(['no shifting, numClust:' int2str(numClust)])
% %% plot the eigenvalues' figure -- perry added
% figure(12),clf,hold on
% cVec = 'bgrcmykbgrcmykbgrcmykbgrcmyk';%, cVec = [cVec cVec];
% for k = 1:min(numClust,length(cVec))
%     myMembers = clustMembsCell{k};
%     plot(x(1,myMembers),x(2,myMembers),[cVec(k) '.'])
% end
% title(['no shifting, numClust:' int2str(numClust)])

% now convert C to a n-by-k matrix containing the k indicator
% vectors as columns
C = sparse(1:size(D, 1), C, 1);
end