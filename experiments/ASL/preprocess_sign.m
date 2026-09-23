function preprocess_sign(marker,upsamples)
%% detect whether there are existing required mat files for tsd data
fileprefix='.mat';
matfilename=[marker fileprefix];
if exist(matfilename,'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
%% read required length of joint 3D data with matrix format and filter it
samples=size(TRAJDB,2);
for i=1:samples
    % segmentation of NaN occlusion and filter them seperately.
    marker_xyz=TRAJDB{2,i};
    %% initial the Kalman Filter Parameters
    ss = 6; % state size
    os = 3; % observation size
    F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
    H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
    Q = 0.001*eye(ss);
    R = 0.005*eye(os);  
    %% wave filter
%     [marker_xyz staindex] = remove_stapoint(marker_xyz);
%     marker_xyz=wav_filter(marker_xyz);
%     TRAJDB{2,i} = marker_xyz;
    marker_xyz(:,1) = movave(marker_xyz(:,1),20);
    marker_xyz(:,2) = movave(marker_xyz(:,2),20);
    marker_xyz(:,3) = movave(marker_xyz(:,3),20);
%     marker_xyz(:,1) = anisodiff1D(marker_xyz(:,1), 10, 0.2, 40, 2);
%     marker_xyz(:,2) = anisodiff1D(marker_xyz(:,2), 10, 0.2, 40, 2);
%     marker_xyz(:,3) = anisodiff1D(marker_xyz(:,3), 10, 0.2, 40, 2);
%     TRAJDB{2,i} = marker_xyz;
    % kalman filter
    initx = [marker_xyz(1,1) marker_xyz(1,2) marker_xyz(1,3) 0.001 0.001 0.001]';
    initV = 1*eye(ss);
    [marker_smooth, ~,~,loglik] = kalman_smoother(marker_xyz', F, H, Q, R, initx, initV);
    TRAJDB{2,i} = marker_smooth(1:3,:)';
    %% interpolation
    if upsamples
        TRAJDB{2,i} = interpolation(TRAJDB{2,i},size(TRAJDB{2,i},1)*2,0);
    end
end
save(marker,'TRAJDB');
%% process the samples data
fileprefix='samples.mat';
matfilename=[marker fileprefix];
if exist(matfilename,'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d_samples() funcition');
end
%% read required length of joint 3D data with matrix format and filter it
samples=size(TRAJSAMPLES,2);
for i=1:samples
    marker_xyz = TRAJSAMPLES{2,i};
    %% initial the Kalman Filter Parameters
    ss = 6; % state size
    os = 3; % observation size
    F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
    H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
    Q = 0.001*eye(ss);
    R = 0.005*eye(os);  
    %% wave filter
%     [marker_xyz staindex] = remove_stapoint(marker_xyz);
%     marker_xyz=wav_filter(marker_xyz);
%     TRAJSAMPLES{2,i} = marker_xyz;
    marker_xyz(:,1) = movave(marker_xyz(:,1),20);
    marker_xyz(:,2) = movave(marker_xyz(:,2),20);
    marker_xyz(:,3) = movave(marker_xyz(:,3),20);
%     marker_xyz(:,1) = anisodiff1D(marker_xyz(:,1), 10, 0.2, 40, 2);
%     marker_xyz(:,2) = anisodiff1D(marker_xyz(:,2), 10, 0.2, 40, 2);
%     marker_xyz(:,3) = anisodiff1D(marker_xyz(:,3), 10, 0.2, 40, 2);
%     TRAJSAMPLES{2,i} = marker_xyz;
    %% kalman filter
    initx = [marker_xyz(1,1) marker_xyz(1,2) marker_xyz(1,3) 0.001 0.001 0.001]';
    initV = 1*eye(ss);
    [marker_smooth, ~,~,loglik] = kalman_smoother(marker_xyz', F, H, Q, R, initx, initV);
    TRAJSAMPLES{2,i}= marker_smooth(1:3,:)';
    if upsamples
        TRAJSAMPLES{2,i} = interpolation(TRAJSAMPLES{2,i},size(TRAJSAMPLES{2,i},1)*2,0);
    end
end
save(matfilename,'TRAJSAMPLES');
