function d=feature_dist_matching(t, r)
%FEATURE_DIST_MATCHING  Local distance between two integral-invariant sequences.
%   D = FEATURE_DIST_MATCHING(T, R) returns the size(T,1)-by-size(R,1) matrix
%   (dK./SK).*(dT./ST) of the IID local distance (thesis Eq. 3.3), computed by
%   the DISTANCE_MATRIX_KT mex from the two halves (osculating / rectifying)
%   of each descriptor row.

[det_k, det_t, S_k, S_t] = distance_matrix_kt(t, r);
d = (det_k./S_k).*(det_t./S_t);
