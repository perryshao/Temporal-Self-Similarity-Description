function preprocess(marker, upsamples)
%PREPROCESS  Kalman-smooth (and optionally upsample) one joint's trajectories.
%   PREPROCESS(MARKER, UPSAMPLES) applies a constant-velocity Kalman smoother to
%   every trajectory in <MARKER>.mat and <MARKER>samples.mat, and doubles the
%   frame rate if UPSAMPLES is true.

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
    %% wave filter
    % [marker_xyz staindex] = remove_stapoint(marker_xyz);
    % marker_xyz=wav_filter(marker_xyz);
    % TRAJDB{2,i} = marker_xyz;
    %% Kalman Filter
    ss = 6; % state size
    os = 3; % observation size
    F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
    H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
    Q = 0.005*eye(ss);
    R = 0.01*eye(os);
    % Q = 0.1*eye(ss);
    % R = 1*eye(os);
    initx = [marker_xyz(1, 1) marker_xyz(1, 2) marker_xyz(1, 3) 0.005 0.005 0.005]';
    initV = 1*eye(ss);
    [marker_smooth, ~, ~, loglik] = kalman_smoother(marker_xyz', F, H, Q, R, initx, initV);
    loglik;
    TRAJDB{2, i} = marker_smooth(1:3, :)';
    %% interpolation
    if upsamples
        TRAJDB{2, i} = interpolation(TRAJDB{2, i}, size(TRAJDB{2, i}, 1)*2, 0);
    end

    %% Loess filter
    % X = smooth(TRAJDB{2,i}(:,1),0.2,'loess');
    % Y = smooth(TRAJDB{2,i}(:,2),0.2,'loess');
    % Z = smooth(TRAJDB{2,i}(:,3),0.2,'loess');
    % TRAJDB{2,i} = [X Y Z];
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
    %% wave filter
    % [marker_xyz staindex] = remove_stapoint(marker_xyz);
    % marker_xyz = wav_filter(marker_xyz);
    %
    % TRAJDB{2,i} = marker_xyz;
    %% kalman filter
    ss = 6; % state size
    os = 3; % observation size
    F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
    H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
    Q = 0.005*eye(ss);
    R = 0.01*eye(os);
    % Q = 0.1*eye(ss);
    % R = 1*eye(os);
    initx = [marker_xyz(1, 1) marker_xyz(1, 2) marker_xyz(1, 3) 0.005 0.005 0.005]';
    initV = 1*eye(ss);
    [marker_smooth, ~, ~, loglik] = kalman_smoother(marker_xyz', F, H, Q, R, initx, initV);
    loglik;
    TRAJSAMPLES{2, i} = marker_smooth(1:3, :)';
    %% interpolation
    if upsamples
        TRAJSAMPLES{2, i} = interpolation(TRAJSAMPLES{2, i}, size(TRAJSAMPLES{2, i}, 1)*2, 0);
    end
    %% Loess filter
    % X = smooth(TRAJSAMPLES{2,i}(:,1),0.2,'loess');
    % Y = smooth(TRAJSAMPLES{2,i}(:,2),0.2,'loess');
    % Z = smooth(TRAJSAMPLES{2,i}(:,3),0.2,'loess');
    % TRAJSAMPLES{2,i} = [X Y Z];

end
%%
save(matfilename, 'TRAJSAMPLES');
