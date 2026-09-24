function fused_data = fusion_dtwdata(align_path, align_data_1, align_data_2, w)
%FUSION_DTWDATA  Fuse two DTW-aligned sequences into one weighted average.
%   FUSED = FUSION_DTWDATA(ALIGN_PATH, ALIGN_DATA_1, ALIGN_DATA_2, W) walks the
%   warping path ALIGN_PATH and averages the aligned columns of the two
%   sequences with weights W(1), W(2).  Helper of TRAIN_DTW.

fused_data = [];
align_length = size(align_path, 1);
warp_num_1 = 1;warp_num_2 = 1;
for n = 2:align_length
    path_incre = align_path(n, :) - align_path(n-1, :);
    path_incre = num2str(path_incre);
    switch path_incre
        case '0  1'
            fused_data(:, end+1) = sum([w(1)*2*align_data_1(:, align_path(n, 1)) w(2)*align_data_2(:, align_path(n:-1:n-1, 2))], 2)...
                /((w(1)+w(2))*4);
        case '1  0'
            fused_data(:, end+1) = sum([w(1)*align_data_1(:, align_path(n:-1:n-1, 1)) w(2)*2*align_data_2(:, align_path(n, 2))], 2)...
                /((w(1)+w(2))*4);
        case '1  1'
            fused_data(:, end+1) = sum([w(1)*align_data_1(:, align_path(n, 1)) w(2)*align_data_2(:, align_path(n, 2))], 2)...
                /(w(1)+w(2));
        otherwise
            disp('error');
    end
end

% for n = 2:align_length
%     if align_path(n,1) ~= align_path(n-1,1) &&...
%             align_path(n,2) ~= align_path(n-1,2)
%         if warp_num_2 ~= 1
%             fused_data(:,end+1)=sum([w(1)*warp_num_1*align_data_1(:,align_path(n-1:-1:n-warp_num_2,1)) w(2)*warp_num_2*align_data_2(:,align_path(n-1,2))],2)...
%                 /((w(1)+w(2))*(warp_num_2+warp_num_1-1));
%             warp_num_2 = 1;
%         elseif warp_num_1 ~= 1
%             fused_data(:,end+1)=sum([w(1)*warp_num_1*align_data_1(:,align_path(n-1,1)) w(2)*warp_num_2*align_data_2(:,align_path(n-1:-1:n-warp_num_1,2))],2)...
%                 /((w(1)+w(2))*(warp_num_2+warp_num_1-1));
%             warp_num_1 = 1;
%         end
%     elseif align_path(n,1) == align_path(n-1,1)
%         warp_num_1 = warp_num_1+1;
%     else
%         warp_num_2 = warp_num_2+1;
%     end
% end
