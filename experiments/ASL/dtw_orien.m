function dist = dtw_orien(t,r,orientation1,orientation2,flag)
% Compare two model using a efficient DTW
% inputs:
%   test -- test model
%   ref  -- reference model
%   flag -- 0: for tsd database; 1: for hdm05 database
% output:
%   dist -- matching score
t=t(3:end-2,:);r=r(3:end-2,:);% because beginning and ending two features are zero
orientation1=orientation1(3:end-2,:);orientation2=orientation2(3:end-2,:);
n = size(t,1);
m = size(r,1);
% frame match distance matrix

d = zeros(n,m);
d = feature_dist_orien_matrix(t,r,orientation1,orientation2,flag);
% accumulate distance matrix
% D =  ones(n,m) * realmax;
D =  ones(n,m) * 10e5;
D(1,1) = d(1,1);
% dynamic programming
for i = 2:n
for j = 1:m
	D1 = D(i-1,j);

	if j>1
		D2 = D(i-1,j-1);
        D3 = D(i,j-1);
    else
        D2 = 10e5;
        D3 = 10e5;
%         D2 = realmax;
%         D3 = realmax;
    end
	D(i,j) = d(i,j) + min([D1,D2,D3]);
end
end
dist = D(n,m);