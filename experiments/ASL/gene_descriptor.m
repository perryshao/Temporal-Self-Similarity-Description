function gene_descriptor(marker, level, descrip_flag, occlu_ratio, ssm_flag)
if occlu_ratio == 0
    occlu_flag = 0;
else
    occlu_flag = 1;
end

%% set the parameters for transformation
theta_x = 30;tx = 200; % in degree
theta_y = 0; ty = 100;
theta_z = 45;tz = 0;
s = 0.5 ; % scale factor

fileprefix = '.mat';
matfilename = [marker fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
fileextend = '_DES.mat';
matfilename = [marker fileextend];
%% read joint 3D data with matrix format and get the descritor
samples = size(TRAJDB, 2);
TRAJDB_DES = cell (1, samples);
for i = 1:samples
    marker_xyz = double(TRAJDB{2, i});
    %% run transforamtions on trajectory
    mindim = min([max(marker_xyz(:, 1))-min(marker_xyz(:, 1))...
            max(marker_xyz(:, 2))-min(marker_xyz(:, 2))...
            max(marker_xyz(:, 3))-min(marker_xyz(:, 3))]);
    maxdim = max([max(marker_xyz(:, 1))-min(marker_xyz(:, 1))...
            max(marker_xyz(:, 2))-min(marker_xyz(:, 2))...
            max(marker_xyz(:, 3))-min(marker_xyz(:, 3))]);
    noise_f(i) = sqrt(mindim)/sqrt(maxdim);
    marker_xyz(:, 1) = marker_xyz(:, 1)+(level*randn(1, size(marker_xyz, 1))*sqrt(mindim))';
    marker_xyz(:, 2) = marker_xyz(:, 2)+(level*randn(1, size(marker_xyz, 1))*sqrt(mindim))';
    marker_xyz(:, 3) = marker_xyz(:, 3)+(level*randn(1, size(marker_xyz, 1))*sqrt(mindim))';

    marker_xyz(:, end+1) = 1; % qici matrix
    marker_xyz = marker_xyz';
    marker_xyz = makehgtform('xrotate', (theta_x*pi)/180)*marker_xyz;
    marker_xyz = makehgtform('yrotate', (theta_y*pi)/180)*marker_xyz;
    marker_xyz = makehgtform('zrotate', (theta_z*pi)/180)*marker_xyz;
    marker_xyz = makehgtform('xrotate', (theta_x*pi)/180)*marker_xyz;
    marker_xyz = makehgtform('yrotate', (theta_y*pi)/180)*marker_xyz;
    marker_xyz = makehgtform('zrotate', (theta_z*pi)/180)*marker_xyz;
    marker_xyz = makehgtform('translate', tx, ty, tz)*marker_xyz;
    marker_xyz = makehgtform('scale', s)*marker_xyz;
    marker_xyz = marker_xyz';
    marker_xyz(:, end) = [];

    if occlu_flag == 1
        length_trajectory = size(noise_trajectory{i}, 1);
        occlu_indx = fix(length_trajectory*rand*(1-occlu_ratio))+1;
        noise_trajectory{i}(occlu_indx:occlu_indx+fix(length_trajectory*occlu_ratio), :) = NaN;
    end

    fprintf ('%d of %d %dth descriptor...\n', i, samples, descrip_flag);
    switch descrip_flag

        case 2
            marker_des = descriptor_comp(marker_xyz);
        case 3
            % integral invaraints
            %     marker_des = integral_invariant(marker_xyz,20,0.01);% in presence of noise
            marker_des = integral_invariant_kn(marker_xyz, 6, 5);
        marker_des = 0.5-marker_des;
        marker_des = [marker_des(:, 1) [0; diff(marker_des(:, 1), 1, 1)]...
                 marker_des(:, 2) [0; diff(marker_des(:, 2), 1, 1)]];
        case 4
            % multiscale integral invaraints
            marker_des = integral_invariant_ms(marker_xyz, 6, 0.1);
        marker_des = 0.5-marker_des;
        marker_des = [marker_des(:, 1) [0; diff(marker_des(:, 1), 1, 1)]...
            marker_des(:, 2) [0; diff(marker_des(:, 2), 1, 1)]...
            marker_des(:, 3) [0; diff(marker_des(:, 3), 1, 1)]...
            marker_des(:, 4) [0; diff(marker_des(:, 4), 1, 1)]...
            marker_des(:, 5) [0; diff(marker_des(:, 5), 1, 1)]...
            marker_des(:, 6) [0; diff(marker_des(:, 6), 1, 1)]...
            marker_des(:, 7) [0; diff(marker_des(:, 7), 1, 1)]...
            marker_des(:, 8) [0; diff(marker_des(:, 8), 1, 1)]...
            marker_des(:, 9) [0; diff(marker_des(:, 9), 1, 1)]...
            marker_des(:, 10) [0; diff(marker_des(:, 10), 1, 1)]];
        case 5
            marker_des = integral_invariant_dist(marker_xyz, 20);
        case 6
            marker_des = integral_invariant_dist_mkn(marker_xyz, 60);
        case 7
            marker_des = marker_xyz;
        otherwise
            disp('error input descrip_flag')
    end
    if ssm_flag = 1
        %% Self-similarity descriptor
        TSSM = Temporal_SSM(marker_des, descrip_flag);
        Image_TSSM = TSSM(2+1:end-2, 2+1:end-2);
        Image_TSSM = floor((Image_TSSM/max(max(Image_TSSM)))*(2^16-1));
        % marker_des  = Log_hogcalculator(Image_TSSM);
        % marker_des  = LocalSsmcalculatorSameBlock(Image_TSSM);
        marker_des = LocalSsmcalculator(Image_TSSM);
    end
    %% final descriptor
    TRAJDB_DES{1, i} = marker_des;
end
save(matfilename, 'TRAJDB_DES');
