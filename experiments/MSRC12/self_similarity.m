function d = self_similarity(des,m_num,descrip_flag)
d = zeros(m_num,m_num);
for i = 1:m_num
    for j = 1:i-1
        switch descrip_flag
            case  2
                d(i,j) = feature_dist_matching(des((i-1)*4+1:i*4),des((j-1)*4+1:j*4));
            case  3
                d(i,j) = feature_dist_matching(des((i-1)*2+1:i*2),des((j-1)*2+1:j*2));
%                 d(i,j) = distance_matrix_norm2(des((i-1)*2+1:i*2),des((j-1)*2+1:j*2));   
            case  4
                d(i,j) = feature_dist_matching(des((i-1)*10+1:i*10),des((j-1)*10+1:j*10));
            case 1
                d(i,j) = distance_matrix_fd(des((i-1)*3+1:i*3),des((j-1)*3+1:j*3));
            case 5
                d(i,j) = distance_matrix_norm2(des(i),des(j));
            case 6
                d(i,j) = distance_matrix_norm2(des((i-1)*3+1:i*3),des((j-1)*3+1:j*3));
            otherwise
                disp('error input descrip_flag')
        end
    end
end
d = d + d.';
        
        







