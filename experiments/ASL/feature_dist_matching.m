function d=feature_dist_matching(t,r)

[det_k,det_t,S_k,S_t] = distance_matrix_kt(t,r);
d = (det_k./S_k).*(det_t./S_t);


