function repreprocess_bat(joints_no)
%REPREPROCESS_BAT  Re-smooth the test trajectories of several joints.
%   REPREPROCESS_BAT(JOINTS_NO) Kalman-smooths <JOINT>samples.mat again for
%   every joint in JOINTS_NO (e.g. after ADD_NOISE); trajectories broken by NaN
%   occlusions are smoothed segment by segment.

%% preprocess and descriptor computation
m_num = length(joints_no);
for j = 1:m_num
    fprintf ('preprocessing the c3d data...%s\n', joints_no{1, j});
    fileprefix = 'samples.mat';
    matfilename = [joints_no{1, j} fileprefix];
    if exist(matfilename, 'file')
        load(matfilename);
    else
        fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d_samples() funcition');
    end
    %% read required length of joint 3D data with matrix format and filter it
    samples = size(TRAJSAMPLES, 2);
    for i = 1:samples
        marker_xyz = TRAJSAMPLES{2, i};
        nanflag = isnan(marker_xyz);
        %% initial the Kalman Filter Parameters
        ss = 6; % state size
        os = 3; % observation size
        F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
        H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
        Q = 0.1*eye(ss);
        R = 1*eye(os);
        if all(~nanflag)
            %% kalman filter
            initx = [marker_xyz(1, 1) marker_xyz(1, 2) marker_xyz(1, 3) 0.1 0.1 0.1]';
            initV = 1*eye(ss);
            [marker_smooth, ~, ~, loglik] = kalman_smoother(marker_xyz', F, H, Q, R, initx, initV);

            TRAJSAMPLES{2, i} = marker_smooth(1:3, :)';
        else
            % continue; % for NaN data -- Perry 20130820
            position_nan = find(nanflag == 1);
            num_nan = sum(nonzeros(nanflag));
            marker_xyz_seg1 = TRAJSAMPLES{2, i}(1:position_nan(1)-1, :);
            % wave filter
            %         marker_xyz_seg1=wav_filter(marker_xyz_seg1);

            marker_xyz_seg2 = TRAJSAMPLES{2, i}(position_nan(1)+num_nan/3:end, :);
            % wave filter
            %         marker_xyz_seg2=wav_filter(marker_xyz_seg2);

            %% kalman filter for first segmentation
            if ~isempty(marker_xyz_seg1)
                initx = [marker_xyz_seg1(1, 1) marker_xyz_seg1(1, 2) marker_xyz_seg1(1, 3) 0.1 0.1 0.1]';
                initV = 1*eye(ss);
                [marker_smooth, ~, ~, loglik] = kalman_smoother(marker_xyz_seg1', F, H, Q, R, initx, initV);
                loglik;

                TRAJSAMPLES{2, i}(1:position_nan(1)-1, 1:3)=marker_smooth(1:3, :)';
            end
            %% kalman filter for second segmentation
            if isempty(marker_xyz_seg2)
                continue;
            end
            initx = [marker_xyz_seg2(1, 1) marker_xyz_seg2(1, 2) marker_xyz_seg2(1, 3) 0.1 0.1 0.1]';
            initV = 1*eye(ss);
            [marker_smooth, ~, ~, loglik] = kalman_smoother(marker_xyz_seg2', F, H, Q, R, initx, initV);
            loglik;

            TRAJSAMPLES{2, i}(position_nan(1)+num_nan/3:end, 1:3)=marker_smooth(1:3, :)';
        end
    end
    save(matfilename, 'TRAJSAMPLES');
end
