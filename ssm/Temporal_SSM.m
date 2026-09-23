function TSSM = Temporal_SSM(des, descrip_flag, slide_win, kernel, belta, c)
%TEMPORAL_SSM  Temporal self-similarity matrix (SSM) of a descriptor sequence.
%   TSSM = TEMPORAL_SSM(DES, DESCRIP_FLAG, SLIDE_WIN, KERNEL, BELTA, C) returns
%   the matrix of distances between all pairs of frame windows of the
%   per-frame descriptor sequence DES (M frames x N dimensions).  Each window
%   stacks SLIDE_WIN consecutive frames (thesis Eq. 3.1-3.2, omega = SLIDE_WIN),
%   so TSSM is (M-SLIDE_WIN+1)-by-(M-SLIDE_WIN+1).
%
%   DESCRIP_FLAG selects the distance between two windows:
%     1      Fourier descriptors            distance_matrix_fd      (*)
%     2-4    DI / AII / MAII local distance feature_dist_matching   (*)
%     5, 6   L2 (raw xyz, DII, ...);  with KERNEL = 1 the sigmoid distance
%            tanh(BELTA*||a-b|| - C) of the conference paper
%     7, 8   L1                             distance_matrix_norm1
%     9      chi-square histogram cost      hist_cost_2 (tanh'ed if KERNEL = 1)
%   (*) resolved from the calling experiment folder.  For every flag except
%   5 and 6, DES is split into two column halves (e.g. osculating / rectifying
%   invariants) that are windowed separately.
%
%   Defaults: SLIDE_WIN = 1, KERNEL = 0, BELTA = 0.5e-3, C = 0 -- the ASL values
%   of the sigmoid distance.  They keep the older short call forms working,
%   e.g. TEMPORAL_SSM(DES, FLAG) and TEMPORAL_SSM(DES, 5, 1, 1).
%
%   See also LOG_HOGCALCULATOR.
if nargin < 3, slide_win = 1; end
if nargin < 4, kernel = 0; end
if nargin < 5, belta = 0.5e-3; end
if nargin < 6, c = 0; end
m = size(des, 1); % temporal length
n = size(des, 2); % dimension
d = zeros(m, m); % Similarity matrix
%% direct computing a SSM
patch = floor(slide_win/2); % patch size
des_matrix = zeros(m-slide_win+1, n*slide_win);
if descrip_flag == 5 || descrip_flag == 6
    for i = patch+1:m-patch
        des_matrix(i-patch, 1:n*slide_win) = reshape(des(i-patch:i+patch, :), 1, slide_win*n); % construct the patch with size = 5
    end
else
    for i = patch+1:m-patch
        des_matrix(i-patch, 1:(n*slide_win)/2) = reshape(des(i-patch:i+patch, 1:n/2), 1, slide_win*(n/2)); % construct the patch with size = 5
        des_matrix(i-patch, (n*slide_win)/2+1:end) = reshape(des(i-patch:i+patch, n/2+1:end), 1, slide_win*(n/2));
    end
end

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
            % belta = 0.5e-3; % for asl dataset
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
