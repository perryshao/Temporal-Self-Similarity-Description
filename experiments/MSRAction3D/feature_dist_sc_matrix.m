function d=feature_dist_sc_matrix(t,r,sc1,sc2,flag)
%   flag1 -- 0: for tsd database; 1: for hdm05 database
%   flag2 -- 0: for integral invariants 1: for differential invariants
%   weight_h=1;
sc1_length = size(sc1,1);
sc2_length = size(sc2,1);
nbins = 60; % nbins of 3d shape context
m_num = 9; % joint numbers
for i = 1:sc1_length/9
    for j = 1:sc2_length/9
        costmat_theta = hist_cost_2(sc1(i*m_num-m_num+1:i*m_num,1:nbins),...
            sc2(j*m_num-m_num+1:j*m_num,1:nbins));
        [a1,b1]=min(costmat_theta,[],1);
        [a2,b2]=min(costmat_theta,[],2);
        sc_cost_theta=max(mean(a1),mean(a2));
        costmat_alpha = hist_cost_2(sc1(i*m_num-m_num+1:i*m_num,nbins+1:end),...
            sc2(j*m_num-m_num+1:j*m_num,nbins+1:end));
        [a1,b1]=min(costmat_alpha,[],1);
        [a2,b2]=min(costmat_alpha,[],2);
        sc_cost_alpha = max(mean(a1),mean(a2));
        det_sc(i,j)=sc_cost_theta+sc_cost_alpha;
    end
end
[det_k1,det_t1,S_k1,S_t1,det_sc1]=distance_matrix_sc(t,r,sc1,sc2);
[det_k,det_t,S_k,S_t] = distance_matrix_kt(t,r);

factor_sc = mean(mean(det_sc./det_sc))/mean(mean((det_k./S_k).*(det_t./S_t)));% for sc descriptor
d=(det_k./S_k).*(det_t./S_t)+factor_sc*(det_sc); % for sc descriptor






