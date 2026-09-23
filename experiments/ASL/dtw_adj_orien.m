function [min_distance, d, g] = dtw_adj_orien(A, B, orientation1,orientation2,adjustment_window_size)

r = adjustment_window_size;
A = A(3:end-2,:);B = B(3:end-2,:);% because beginning and ending two features are zero
orientation1 = orientation1(3:end-2,:);orientation2 = orientation2(3:end-2,:);
% get length of speech patterns A and B
I = size(A,1);
J = size(B,1);
d = zeros(I,J);
% local distance matrix
d = feature_dist_orien_matrix(A,B,orientation1,orientation2);
% d = distance_matrix_norm2(A,B); 
% d = distance_matrix_fd(A,B);
% d = feature_dist_sc_matrix(A,B,orientation1,orientation2,flag); % for shape context
NaN_index = isnan(d);
d(NaN_index) = 0;
I = size(d,1);J = size(d,2);
d=double(d);
%% search optimal path using C for acceleratting the computation
[g,steps] = dtwpath(d,r); %#ok<NASGU>
% time normalize global distance matrix
N=I+J;
D=g/N;
% remove additional inf padded row and column from global distance matrix
D=D(2:end,2:end);
% path=traceback_path(steps);
% d_ima = max(max(d))-d;
% imshow(d_ima,[min(min(d)) max(max(d))]); hold on;
% figure(1), plot(path(:,2),path(:,1),'.b-'),hold on;
min_distance = D(end, end);






