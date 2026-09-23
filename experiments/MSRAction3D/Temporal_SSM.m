function TSSM = Temporal_SSM(des_matrix, descrip_flag, kernel, belta, c)
m = size(des_matrix, 1); % temporal length
n = size(des_matrix, 2); % dimension
d = zeros(m, m); % Similarity matrix
%% direct computing a SSM
switch descrip_flag
    case  {2, 3, 4}
        d = feature_dist_matching(des_matrix, des_matrix);
    case 1
        d = distance_matrix_fd(des_matrix, des_matrix);
    case {5, 6}
        if kernel == 0
            d = distance_matrix_norm2(des_matrix, des_matrix);
        elseif kernel == 1
            % the new metric
            %             belta = 1e-8;
            %             d = pdist2(des_matrix,des_matrix).^2;
            %             d = 1-exp(-belta*d);
            %             d = d - mean(mean(d));
            %             belta =sum(sum((d.^2)))/(m^2);

            % tanh function
            %             belta = 0.8e-7;%default
            %             belta = 0.9e-7;
            %             tanh_matrix = belta*(des_matrix*des_matrix');
            %             d = tanh(tanh_matrix);

            % tanh function of norm2
            distNorm = pdist2(des_matrix, des_matrix);
            tanh_matrix = belta*distNorm-c;
            d = tanh(tanh_matrix);

            % % for debug
            % if min(min(tanh_matrix))<-1 || max(max(tanh_matrix))>1
            %     d;
            % end
        end
    case {7, 8}
        d = distance_matrix_norm1(des_matrix, des_matrix);
    case 9
        if kernel == 0
            d = hist_cost_2(des_matrix, des_matrix);
            % d = pdist2(des_matrix,des_matrix);
        elseif kernel == 1
            tanh_matrix = hist_cost_2(des_matrix, des_matrix);
            d = tanh(tanh_matrix);

            % % for debug
            % if min(min(0.8e-7*(des_matrix*des_matrix')))<-1 || max(max(0.8e-7*(des_matrix*des_matrix')))>1
            %     d;
            % end
        end
    otherwise
        disp('error input descrip_flag')
end
TSSM = d;
%% first computing a SSM between individual elements and then perform image filtering
% des_matrix = des;
% switch descrip_flag
%     case  {2,3,4}
%         d = feature_dist_matching(des_matrix,des_matrix);
%     case 1
%         d = distance_matrix_fd(des_matrix,des_matrix);
%     case {5,6}
%         d = distance_matrix_norm2(des_matrix,des_matrix);
%     case {7,8}
%         d = distance_matrix_norm1(des_matrix,des_matrix);
%     otherwise
%         disp('error input descrip_flag')
% end
% % H = fspecial('gaussian',slide_win,slide_win);%gaussian filter
% H = eye(slide_win);% sum filter
% TSSM = imfilter(d,H);
