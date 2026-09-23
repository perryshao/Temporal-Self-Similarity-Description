function preprocess_bat(joints_no,flag,inter_flag,transform_flag)
%% preprocess and descriptor computation
m_num = length(joints_no);
for j=1:m_num
    if flag == 0
        fprintf ('preprocessing the tsd data...%s\n',joints_no{1,j});
        preprocess_tsd(joints_no{1,j},inter_flag,transform_flag);
    elseif flag == 1
        fprintf ('preprocessing the tsd data...%s\n',joints_no{1,j});
        preprocess_sign(joints_no{1,j},inter_flag);
    end
end

