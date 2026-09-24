function d=feature_dist_matching(t, r)
%FEATURE_DIST_MATCHING  Local distance between two integral-invariant sequences.
%   D = FEATURE_DIST_MATCHING(T, R) returns the size(T,1)-by-size(R,1) matrix
%   (dK./SK).*(dT./ST) of the IID local distance (thesis Eq. 3.3), computed by
%   the DISTANCE_MATRIX_KT mex from the two halves (osculating / rectifying)
%   of each descriptor row.

% m = size(t,1);
% n = size(r,1);
% dim = size(t,2);
% det_k = zeros(m,n);det_t = zeros(m,n);S_k = zeros(m,n);S_t = zeros(m,n);
% for i=1:m
%
%     %%   differential invariants computation
%     det_diff = repmat(t(i,:),n,1)-r;
% %         det_k(i,:) = sqrt(sum(det_diff(:,1:dim).^2,2))'; % for norm-2
%     det_k(i,:) = sum(abs(det_diff(:,1:dim/2)),2)'; % for norm-1
%     det_t(i,:) = sum(abs(det_diff(:,dim/2+1:end)),2)'; % for norm-1
% %                 S_k(i,:) = sum(abs([repmat(t(i,:),n,1) r]),2)';
%     S_k(i,:) = sum(abs([repmat(t(i,1:dim/2),n,1) r(:,1:dim/2)]),2)';
%     S_t(i,:) = sum(abs([repmat(t(i,dim/2+1:end),n,1) r(:,dim/2+1:end)]),2)';
%
% end
[det_k, det_t, S_k, S_t] = distance_matrix_kt(t, r);
d = (det_k./S_k).*(det_t./S_t);
