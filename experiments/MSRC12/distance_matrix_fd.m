function d = distance_matrix_fd(t, r)
m = size(t, 1);
n = size(r, 1);
det_k = zeros(m, n);
for i = 1:m
    det_diff = repmat(t(i, :), n, 1)-r;
    det_k(i, :) = sum(abs(det_diff).^2, 2); %
end
d = det_k;
