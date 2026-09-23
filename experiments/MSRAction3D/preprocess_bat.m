function preprocess_bat(joints_no, inter_flag)
%% preprocess and descriptor computation
joints_no = reshape(joints_no, 1, size(joints_no, 1)*size(joints_no, 2));
m_num = size(joints_no, 2);
for j = 1:m_num
    fprintf ('preprocessing the c3d data...%s\n', joints_no{1, j});
    preprocess(joints_no{1, j}, inter_flag);
end
