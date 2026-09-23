function preprocess_bat(joints_no, inter_flag, transform_flag)
%% preprocess and descriptor computation
m_num = length(joints_no);
for j = 1:m_num
    fprintf ('preprocessing the c3d data...%s\n', joints_no{1, j});
    preprocess(joints_no{1, j}, inter_flag, transform_flag);
end
