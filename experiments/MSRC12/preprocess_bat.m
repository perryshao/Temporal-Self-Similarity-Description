function preprocess_bat(joints_no, inter_flag, transform_flag)
%PREPROCESS_BAT  Kalman-smooth, upsample and/or transform several joints.
%   PREPROCESS_BAT(JOINTS_NO, INTER_FLAG, TRANSFORM_FLAG) runs
%   PREPROCESS(JOINT, INTER_FLAG, TRANSFORM_FLAG) on every joint in JOINTS_NO.

%% preprocess and descriptor computation
m_num = length(joints_no);
for j = 1:m_num
    fprintf ('preprocessing the c3d data...%s\n', joints_no{1, j});
    preprocess(joints_no{1, j}, inter_flag, transform_flag);
end
