function [min_distance, d, g] = dtw_adj_matching(A, B, adjustment_window_size, descrip_flag)
switch descrip_flag
    case   {2, 3, 4}
        A = A(3:end-2, :);B = B(3:end-2, :); % because beginning and ending two features are zero
        % get length of speech patterns A and B
        I = size(A, 1);
        J = size(B, 1);
        d = zeros(I, J);
        % local distance matrix
        d = feature_dist_matching(A, B);
    case 1
        % Fourier descriptor distance matrix
        % get length of speech patterns A and B
        I = size(A, 1);
        J = size(B, 1);
        d = zeros(I, J);
        d = distance_matrix_fd(A, B);
        % min_distance = sum(sum(abs(A-B).^2));
        % g = min_distance;
        % return;
    case {5, 6}
        A = A(3:end-2, :);B = B(3:end-2, :); % because beginning and ending two features are zero
        % get length of speech patterns A and B
        I = size(A, 1);
        J = size(B, 1);
        d = zeros(I, J);
        % local distance matrix
        d = distance_matrix_norm2(A, B);
    case {7, 8}
        % get length of speech patterns A and B
        I = size(A, 1);
        J = size(B, 1);
        d = zeros(I, J);
        % local distance matrix
        d = distance_matrix_norm1(A, B);
end

% global distance matrix
NaN_index = isnan(d);
d(NaN_index) = 0;
I = size(d, 1);J = size(d, 2);
d = double(d);
%% search optimal path using C for accelerating the computation
[g, steps] = dtwpath(d, adjustment_window_size); %#ok<NASGU>
% time normalize global distance matrix
N = I+J;
D = g/N;
% remove additional inf padded row and column from global distance matrix
D = D(2:end, 2:end);
% path=traceback_path(steps);
min_distance = D(end, end);
