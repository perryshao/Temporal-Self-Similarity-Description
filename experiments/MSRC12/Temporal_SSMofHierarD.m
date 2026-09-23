function TSSM = Temporal_SSMofHierarD(des,descrip_flag)
m = size(des,1);% temporal length
n = size(des,2); % dimension
d = zeros(m,m);% Similarity matrix
slide_win = 5; % slide window
path = floor(slide_win/2);% path size
des_matrix = zeros(m-slide_win+1,n*slide_win);
joint_num = 13;

for i = path+1:m-path
    des_matrix(i-path,1:slide_win) = reshape(des(i-path:i+path,1),1,slide_win*1);% consturct the path with size = 5
    des_matrix(i-path,1*slide_win+1:2*slide_win) = reshape(des(i-path:i+path,2),1,slide_win*1);% consturct the path with size = 5
    des_matrix(i-path,2*slide_win+1:end) = reshape(des(i-path:i+path,3:end),1,slide_win*3*joint_num);  
end



switch descrip_flag
    case  {2,3,4}
%         d = feature_dist_matching(des,des);
        d = feature_dist_matching(des_matrix,des_matrix);
    case 1
        d = distance_matrix_fd(des,des);
    case {5,6}
        d = distance_matrix_norm2(des,des);
    case {7,8}
        d = distance_matrix_norm1(des,des);
    case 0
%         d = distance_matrix_norm1(des,des);
        d = feature_dist_orien_matrix(des_matrix(3:end-2,1:2*slide_win),des_matrix(3:end-2,1:2*slide_win),...
                                      des_matrix(3:end-2,2*slide_win+1:end),des_matrix(3:end-2,2*slide_win+1:end));
    otherwise
        disp('error input descrip_flag')
end
TSSM = d;

        
        







