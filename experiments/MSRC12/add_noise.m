function noise_variance = add_noise(marker, level)
%ADD_NOISE  Add Gaussian noise to the test trajectories of one joint.
%   NOISE_VARIANCE = ADD_NOISE(MARKER, LEVEL) rewrites <MARKER>samples.mat with
%   Gaussian noise of level LEVEL, scaled by the trajectory length, on the test trajectories and returns the
%   noise variance.  Trajectories broken by NaN occlusions are handled segment
%   by segment.  The training set <MARKER>.mat is saved back unchanged.

%% detect whether there are existing required mat files for C3D data
if nargin <= 2
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
        nanflag = isnan(marker_xyz);
        % marker_xyz(nanflag(:,1),:) = [];
        %% initial the Kalman Filter Parameters

        if all(~nanflag)
            % [marker_xyz max_limit min_original] = normalization(marker_xyz);
            % % [Y,NOISE_VARIANCE] = noisegen(marker_xyz,level);
            % Y = awgn(marker_xyz,level);
            % % noise_variance = noise_variance+NOISE_VARIANCE;
            % % Y=filter_kalman(Y,2);
            % Y = verse_normalization(Y,max_limit,min_original);
            % TRAJDB{2,i} = Y;
        else
            % continue; % for NaN data -- Perry 20130820
            position_nan = find(nanflag == 1);
            num_nan = sum(nonzeros(nanflag));
            marker_xyz_seg1 = TRAJDB{2, i}(1:position_nan(1)-1, :);
            % % wave filter
            % marker_xyz_seg1=wav_filter(marker_xyz_seg1);

            marker_xyz_seg2 = TRAJDB{2, i}(position_nan(1)+num_nan/3:end, :);
            % % wave filter
            % marker_xyz_seg2=wav_filter(marker_xyz_seg2);

            %% kalman filter for first segmentation
            if ~isempty(marker_xyz_seg1)

                %%%
            end
            %% kalman filter for second segmentation
            if isempty(marker_xyz_seg2)
                continue;
            end
            %%%
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
        nanflag = isnan(marker_xyz);
        % marker_xyz(nanflag(:,1),:) = [];
        % nanflag = isnan(marker_xyz);
        if all(~nanflag)
            %% wave filter

            mindim = min([max(marker_xyz(:, 1))-min(marker_xyz(:, 1))...
                   max(marker_xyz(:, 2))-min(marker_xyz(:, 2))...
                   max(marker_xyz(:, 3))-min(marker_xyz(:, 3))]);
            noise_inten = level*(size(marker_xyz, 1)/500).^2;
            if mindim < 1
                signal_p = mindim^2;
            else
                signal_p = sqrt(mindim);
            end
            marker_xyz(:, 1) = marker_xyz(:, 1)+(level*randn(1, size(marker_xyz, 1))*signal_p)';
            marker_xyz(:, 2) = marker_xyz(:, 2)+(level*randn(1, size(marker_xyz, 1))*signal_p)';
            marker_xyz(:, 3) = marker_xyz(:, 3)+(level*randn(1, size(marker_xyz, 1))*signal_p)';
            TRAJSAMPLES{2, i} = marker_xyz;
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
                %%%
            end
            %% kalman filter for second segmentation
            if isempty(marker_xyz_seg2)
                continue;
            end
            %%%
        end
    end
    %%

    save(matfilename, 'TRAJSAMPLES');
else
    if exist('tsddb.mat', 'file')
        load tsddb;
    else
        fprintf ('Error, there are not existing database, lack of load_tsd() funcition');
    end
    samples = size(TSDDB, 2);
    for i = 1:samples
        right_xyz = TSDDB{2, i}; % right hand xyz position
        left_xyz = TSDDB{3, i}; % left hand xyz position
        %% wave filter
        % right_xyz=wav_filter(right_xyz);
        % left_xyz=wav_filter(left_xyz);
        %% kalman filter

        ss = 6; % state size
        os = 3; % observation size
        F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
        H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
        Q = 0.05*eye(ss);
        R = 0.1*eye(os);
        initV = 1*eye(ss);
        initx = [right_xyz(1, 1) right_xyz(1, 2) right_xyz(1, 3) 0.05 0.05 0.05]';
        [xsmooth1, ~] = kalman_smoother(right_xyz', F, H, Q, R, initx, initV);

        initV = 1*eye(ss);
        initx = [left_xyz(1, 1) left_xyz(1, 2) left_xyz(1, 3) 0.05 0.05 0.05]';
        [xsmooth2, ~] = kalman_smoother(left_xyz', F, H, Q, R, initx, initV);
        right_xyz(:, 1) = xsmooth1(1, :);
        right_xyz(:, 2) = xsmooth1(2, :);
        right_xyz(:, 3) = xsmooth1(3, :);

        left_xyz(:, 1) = xsmooth2(1, :);
        left_xyz(:, 2) = xsmooth2(2, :);
        left_xyz(:, 3) = xsmooth2(3, :);

        %% return the data after filter
        % TSDDB{2,i}=right_xyz;
        % TSDDB{3,i}=left_xyz;
        TSDDB{2, i} = interpolation(right_xyz, 0);
        TSDDB{3, i} = interpolation(left_xyz, 0);
    end
    save('tsddb.mat', 'TSDDB');

    if exist('tsdsamples.mat', 'file')
        load tsdsamples;
    else
        fprintf ('Error, there are not existing database, lack of load_tsd_samples() funcition');
    end
    samples = size(TSDSAMPLES, 2);
    for i = 1:samples
        right_xyz = TSDSAMPLES{2, i}; % right hand xyz position
        left_xyz = TSDSAMPLES{3, i}; % left hand xyz position
        %% wave filter
        % right_xyz=wav_filter(right_xyz);
        % left_xyz=wav_filter(left_xyz);
        %% kalman filter
        ss = 6; % state size
        os = 3; % observation size
        F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
        H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
        Q = 0.05*eye(ss);
        R = 0.1*eye(os);
        initV = 1*eye(ss);
        initx = [right_xyz(1, 1) right_xyz(1, 2) right_xyz(1, 3) 0.05 0.05 0.05]';
        [xsmooth1, ~] = kalman_smoother(right_xyz', F, H, Q, R, initx, initV);

        initV = 1*eye(ss);
        initx = [left_xyz(1, 1) left_xyz(1, 2) left_xyz(1, 3) 0.05 0.05 0.05]';
        [xsmooth2, ~] = kalman_smoother(left_xyz', F, H, Q, R, initx, initV);
        right_xyz(:, 1:3) = xsmooth1(1:3, :);
        left_xyz(:, 1:3) = xsmooth2(1:3, :);
        %% return the data after filter
        TSDSAMPLES{2, i} = right_xyz;
        TSDSAMPLES{3, i} = left_xyz;
        % TSDSAMPLES{2,i}=interpolation(right_xyz,0);
        % TSDSAMPLES{3,i}=interpolation(left_xyz,0);
    end
    save('tsdsamples.mat', 'TSDSAMPLES');
end
