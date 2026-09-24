function add_noise(marker, level)
%ADD_NOISE  Add white Gaussian noise to the test trajectories of one joint.
%   ADD_NOISE(MARKER, LEVEL) rewrites <MARKER>samples.mat with i.i.d. Gaussian
%   noise on x, y and z, whose standard deviation is LEVEL times a signal
%   scale derived from the trajectory's smallest extent (the "normalised
%   standard deviation" of the conference paper's noise test).  The training
%   set <MARKER>.mat is saved back unchanged.

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

    % mindim = min([max(marker_xyz(:,1))-min(marker_xyz(:,1))...
    %     max(marker_xyz(:,2))-min(marker_xyz(:,2))...
    %     max(marker_xyz(:,3))-min(marker_xyz(:,3))]);
    % if mindim < 1
    %     signal_p = mindim^2;
    % else
    %     signal_p = sqrt(mindim);
    % end
    % marker_xyz(:,1) = marker_xyz(:,1)+(level*randn(1,size(marker_xyz,1))*signal_p)';
    % marker_xyz(:,2) = marker_xyz(:,2)+(level*randn(1,size(marker_xyz,1))*signal_p)';
    % marker_xyz(:,3) = marker_xyz(:,3)+(level*randn(1,size(marker_xyz,1))*signal_p)';

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

    mindim = min([max(marker_xyz(:, 1))-min(marker_xyz(:, 1))...
        max(marker_xyz(:, 2))-min(marker_xyz(:, 2))...
        max(marker_xyz(:, 3))-min(marker_xyz(:, 3))]);
    % noise_inten = level*(size(marker_xyz,1)/500).^2;
    if mindim < 1
        signal_p = mindim^2;
    else
        signal_p = sqrt(mindim);
    end
    marker_xyz(:, 1) = marker_xyz(:, 1)+(level*randn(1, size(marker_xyz, 1))*signal_p)';
    marker_xyz(:, 2) = marker_xyz(:, 2)+(level*randn(1, size(marker_xyz, 1))*signal_p)';
    marker_xyz(:, 3) = marker_xyz(:, 3)+(level*randn(1, size(marker_xyz, 1))*signal_p)';
    TRAJSAMPLES{2, i} = marker_xyz;
end
%%
save(matfilename, 'TRAJSAMPLES');
