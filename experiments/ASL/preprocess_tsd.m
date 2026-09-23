function preprocess_tsd(marker, upsamples, transform_flag)
%% detect whether there are existing required mat files for tsd data
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
    % cut the final dense points from the trajectory
    %     marker_xyz_norm = sqrt(sum((marker_xyz(2:end,:) - marker_xyz(1:end-1,:)).^2,2));
    %     marker_xyz(marker_xyz_norm < 20,:)=[];
    %% initial the Kalman Filter Parameters
    ss = 6; % state size
    os = 3; % observation size
    F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
    H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
    Q = 0.005*eye(ss);
    R = 0.001*eye(os);
    % Q = 0.05*eye(ss);
    % R = 1*eye(os);
    %% wave filter
    % [marker_xyz staindex] = remove_stapoint(marker_xyz);
    % marker_xyz=wav_filter(marker_xyz);

    % marker_xyz = medfilt3(marker_xyz,9);
    % marker_xyz(:,1) = movave(marker_xyz(:,1),3);
    % marker_xyz(:,2) = movave(marker_xyz(:,2),3);
    % marker_xyz(:,3) = movave(marker_xyz(:,3),3);
    % TRAJDB{2,i} = marker_xyz;
    %% kalman filter
    initx = [marker_xyz(1, 1) marker_xyz(1, 2) marker_xyz(1, 3) 0.005 0.005 0.005]';
    initV = 1*eye(ss);
    [marker_smooth, ~, ~, loglik] = kalman_smoother(marker_xyz', F, H, Q, R, initx, initV);
    TRAJDB{2, i} = marker_smooth(1:3, :)';
    %% interpolation
    if upsamples
        marker_xyz = TRAJDB{2, i};
        m = size(marker_xyz, 1);
        F = spline(1:m, marker_xyz');
        step = 0.5;t=1:step:m;
        TRAJDB{2, i} = ppval(F, t)';
        % TRAJDB{2,i} = interpolation(TRAJDB{2,i},size(TRAJDB{2,i},1)*2,0);
    end
    % cut the final dense points from the trajectory
    marker_xyz = TRAJDB{2, i};
    marker_xyz_norm = sqrt(sum((marker_xyz(2:end, :) - marker_xyz(1:end-1, :)).^2, 2));
    marker_xyz(marker_xyz_norm < 20, :) = [];
    TRAJDB{2, i} = marker_xyz;
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
    % cut the final dense points from the trajectory
    %     marker_xyz_norm = sqrt(sum((marker_xyz(2:end,:) - marker_xyz(1:end-1,:)).^2,2));
    %     marker_xyz(marker_xyz_norm < 20,:)=[];
    %% initial the Kalman Filter Parameters
    ss = 6; % state size
    os = 3; % observation size
    F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
    H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
    Q = 0.005*eye(ss);
    R = 0.001*eye(os);
    % Q = 0.05*eye(ss);
    % R = 1*eye(os);
    %% wave filter
    % [marker_xyz staindex] = remove_stapoint(marker_xyz);
    % marker_xyz = wav_filter(marker_xyz);

    % marker_xyz = medfilt3(marker_xyz,5);
    % marker_xyz(:,1) = movave(marker_xyz(:,1),3);
    % marker_xyz(:,2) = movave(marker_xyz(:,2),3);
    % marker_xyz(:,3) = movave(marker_xyz(:,3),3);
    % TRAJSAMPLES{2,i} = marker_xyz;
    %% kalman filter
    initx = [marker_xyz(1, 1) marker_xyz(1, 2) marker_xyz(1, 3) 0.005 0.005 0.005]';
    initV = 1*eye(ss);
    [marker_smooth, ~, ~, loglik] = kalman_smoother(marker_xyz', F, H, Q, R, initx, initV);
    TRAJSAMPLES{2, i} = marker_smooth(1:3, :)';
    if upsamples
        marker_xyz = TRAJSAMPLES{2, i};
        m = size(marker_xyz, 1);
        F = spline(1:m, marker_xyz');
        step = 0.5;t=1:step:m;
        TRAJSAMPLES{2, i} = ppval(F, t)';
        % TRAJSAMPLES{2,i} = interpolation(TRAJSAMPLES{2,i},size(TRAJSAMPLES{2,i},1)*2,0);
    end
    % cut the final dense points from the trajectory
    marker_xyz = TRAJSAMPLES{2, i};
    marker_xyz_norm = sqrt(sum((marker_xyz(2:end, :) - marker_xyz(1:end-1, :)).^2, 2));
    marker_xyz(marker_xyz_norm < 20, :) = [];
    TRAJSAMPLES{2, i} = marker_xyz;
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
save(matfilename, 'TRAJSAMPLES');
