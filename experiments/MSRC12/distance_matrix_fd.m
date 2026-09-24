function d = distance_matrix_fd(t, r)
%DISTANCE_MATRIX_FD  Pairwise squared Euclidean distances of Fourier descriptors.
%   D = DISTANCE_MATRIX_FD(T, R) returns the size(T,1)-by-size(R,1) matrix of
%   sum(|T(i,:)-R(j,:)|.^2).

m = size(t, 1);
n = size(r, 1);
det_k = zeros(m, n);
for i = 1:m
    det_diff = repmat(t(i, :), n, 1)-r;
    det_k(i, :) = sum(abs(det_diff).^2, 2); %
end
d = det_k;
