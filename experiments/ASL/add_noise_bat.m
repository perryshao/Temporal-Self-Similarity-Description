function add_noise_bat(joints_no, level)
%ADD_NOISE_BAT  Add Gaussian noise to the test trajectories of several joints.
%   ADD_NOISE_BAT(JOINTS_NO, LEVEL) calls ADD_NOISE(JOINT, LEVEL) for every
%   joint name in JOINTS_NO.

%% define the joint name
m_num = length(joints_no);
for j = 1:m_num
    fprintf ('adding noise into the tsd data...%s\n', joints_no{1, j});
    add_noise(joints_no{1, j}, level);
end
