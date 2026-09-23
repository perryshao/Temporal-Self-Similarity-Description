function add_noise_bat(joints_no,level)
%% define the joint name
m_num = length(joints_no);
for j=1:m_num
    fprintf ('adding noise into the tsd data...%s\n',joints_no{1,j});
    add_noise(joints_no{1,j},level);
end

