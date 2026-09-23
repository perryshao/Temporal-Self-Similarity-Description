function [min_distance, steps, path] = dtw(testdata, traindata, adjustment_window_size)
% Minimal time normalized dtw distance between speech patterns A and B.

% References:
%
% [SakoeChiba1978] SAKOE, Hiroki; CHIBA, Seibi: Dynamic Programming
%     Algorithm Optimization for Spoken Word Recognition,
%     http://citeseer.ist.psu.edu/viewdoc/download?doi=10.1.1.114.3782&rep=rep1&type=pdf
%
% [Paliwal1982] PALIWAL, K.K. et al.: A Modification over Sakoe and Chiba's
%     Dynamic Time Warping Algorithm for Isolated Word Recognition,
%     http://maxwell.me.gu.edu.au/spl/publications/papers/sigpro82_kkp_dtw.pdf
%
% [Ellis2003] ELLIS, D.: Dynamic Time Warp (DTW) in Matlab,
%     http://www.ee.columbia.edu/~dpwe/resources/matlab/dtw/

r = adjustment_window_size;
% get length of speech patterns A and B
I = size(traindata, 1);
J = size(testdata, 1);
d = zeros(I, J);
% local distance matrix
d = distance_matrix_norm2(testdata, traindata);
% d = feature_dist_sc_matrix(A,B,orientation1,orientation2,flag); % for shape context
NaN_index = isnan(d);
d(NaN_index) = 0;
I = size(d, 1);J = size(d, 2);
d = double(d);
%% search optimal path using C for accelerating the computation
[g, steps] = dtwpath(d, r);
% time normalize global distance matrix
N = I+J;
D = g/N;
% remove additional inf padded row and column from global distance matrix
D = D(2:end, 2:end);
path = traceback_path(steps);
% d_ima = max(max(d))-d;
% imshow(d_ima,[min(min(d)) max(max(d))]); hold on;
% figure(1), plot(path(:,2),path(:,1),'.b-'),hold on;
min_distance = D(end, end);
