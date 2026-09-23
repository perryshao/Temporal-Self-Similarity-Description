function preprocess(marker, upsamples, transform_flag)
%% detect whether there are existing required mat files for C3D data
fileprefix = '.mat';
matfilename = [marker fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
%% read required length of joint 3D data with matrix format and filter it
samples = size(TRAJDB, 2);
for i = 1:samples
    % segmentation of NaN occlusion and filter them separately.
    marker_xyz = TRAJDB{2, i};
    %% initial the Kalman Filter Parameters
    ss = 6; % state size
    os = 3; % observation size
    F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
    H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
    Q = 0.1*eye(ss);
    R = 1*eye(os);
    initx = [marker_xyz(1, 1) marker_xyz(1, 2) marker_xyz(1, 3) 0.1 0.1 0.1]';
    initV = 1*eye(ss);
    [marker_smooth, ~, ~, loglik] = kalman_smoother(marker_xyz', F, H, Q, R, initx, initV);
    loglik;
    TRAJDB{2, i} = marker_smooth(1:3, :)';
    if upsamples
        TRAJDB{2, i} = interpolation(TRAJDB{2, i}, size(TRAJDB{2, i}, 1)*2, 0);
    end
end
save(marker, 'TRAJDB');
%% process the samples data
fileprefix = 'samples.mat';
matfilename = [marker fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d_samples() funcition');
end
%% read required length of joint 3D data with matrix format and filter it
samples = size(TRAJSAMPLES, 2);
for i = 1:samples

    marker_xyz = TRAJSAMPLES{2, i};
    %% initial the Kalman Filter Parameters
    ss = 6; % state size
    os = 3; % observation size
    F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
    H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
    Q = 0.1*eye(ss);
    R = 1*eye(os);
    %% kalman filter
    initx = [marker_xyz(1, 1) marker_xyz(1, 2) marker_xyz(1, 3) 0.1 0.1 0.1]';
    initV = 1*eye(ss);
    [marker_smooth, ~, ~, loglik] = kalman_smoother(marker_xyz', F, H, Q, R, initx, initV);
    loglik;

    TRAJSAMPLES{2, i} = marker_smooth(1:3, :)';
    if upsamples
        TRAJSAMPLES{2, i} = interpolation(TRAJSAMPLES{2, i}, size(TRAJSAMPLES{2, i}, 1)*2, 0);
    end
    %% simulate transformation
    if transform_flag
        marker_xyz = TRAJSAMPLES{2, i};
        theta_x = 30;tx = 200; % in degree
        theta_y = 0; ty = 100;
        theta_z = 45;tz = 0;
        s = 0.5 ; % scale factor
        marker_xyz(:, end+1) = 1; % qici matrix
        marker_xyz = marker_xyz';
        marker_xyz = makehgtform('xrotate', (theta_x*pi)/180)*marker_xyz;
        marker_xyz = makehgtform('yrotate', (theta_y*pi)/180)*marker_xyz;
        marker_xyz = makehgtform('zrotate', (theta_z*pi)/180)*marker_xyz;
        marker_xyz = makehgtform('translate', tx, ty, tz)*marker_xyz;
        marker_xyz = makehgtform('scale', s)*marker_xyz;
        marker_xyz = marker_xyz';
        marker_xyz(:, end) = [];

        % occlu_ratio = 0.2;
        % length_trajectory = size(marker_xyz,1);
        % occlu_indx = fix(length_trajectory*rand*(1-occlu_ratio))+1;
        % marker_xyz(occlu_indx:occlu_indx+fix(length_trajectory*occlu_ratio),:) = NaN;
        TRAJSAMPLES{2, i} = marker_xyz;
    end
end
%%
save(matfilename, 'TRAJSAMPLES');
