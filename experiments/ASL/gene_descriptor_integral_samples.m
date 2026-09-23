function gene_descriptor_integral_samples(marker)
fileprefix = 'samples.mat';
matfilename = [marker fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
fileextend = 'samples_DES.mat';
matfilename = [marker fileextend];
%% read joint 3D data with matrix format and get the descriptor
samples = size(TRAJSAMPLES, 2);
TRAJSAMPLES_DES = cell (1, samples);
for i = 1:samples
    marker_xyz = double(TRAJSAMPLES{2, i});
    fprintf ('%d of %d samples integral descriptor...\n', i, samples);
    %% integral invariants
    % %     marker_des = integral_invariant(marker_xyz,20,0.01);% in presence of noise
    %     marker_des = integral_invariant(marker_xyz,6,0.005);
    % %     marker_des = integral_invariant_kn(marker_xyz,6,5);
    %     marker_des = 0.5-marker_des;
    %     marker_des= [marker_des(:,1) [0; diff(marker_des(:,1),1,1)]...
    %                 marker_des(:,2) [0; diff(marker_des(:,2),1,1)]];
    % % use curvature only
    % %     marker_des= [marker_des(:,1) [0; diff(marker_des(:,1),1,1)]];
    %% multiscale integral invariants
    %     marker_des = integral_invariant_ms(marker_xyz,6,0.1);
    %     marker_des = 0.5-marker_des;
    %     marker_des= [marker_des(:,1) [0; diff(marker_des(:,1),1,1)]...
    %                 marker_des(:,2) [0; diff(marker_des(:,2),1,1)]...
    %                 marker_des(:,3) [0; diff(marker_des(:,3),1,1)]...
    %                 marker_des(:,4) [0; diff(marker_des(:,4),1,1)]...
    %                 marker_des(:,5) [0; diff(marker_des(:,5),1,1)]...
    %                 marker_des(:,6) [0; diff(marker_des(:,6),1,1)]...
    %                 marker_des(:,7) [0; diff(marker_des(:,7),1,1)]...
    %                 marker_des(:,8) [0; diff(marker_des(:,8),1,1)]...
    %                 marker_des(:,9) [0; diff(marker_des(:,9),1,1)]...
    %                 marker_des(:,10) [0; diff(marker_des(:,10),1,1)]];
    % use curvatures only
    %     marker_des= [marker_des(:,1) marker_des(:,2)...
    %                 marker_des(:,3) marker_des(:,4)...
    %                 marker_des(:,5)...
    %                 [0; diff(marker_des(:,1),1,1)]...
    %                 [0; diff(marker_des(:,2),1,1)]...
    %                 [0; diff(marker_des(:,3),1,1)]...
    %                 [0; diff(marker_des(:,4),1,1)]...
    %                 [0; diff(marker_des(:,5),1,1)]...
    %                 ];

    %% distance integral invariants
    % marker_des = integral_invariant_dist(marker_xyz,30);

    %% multiscale distance integral invariants
    % marker_des = integral_invariant_dist_ms(marker_xyz,0.4);

    %% fourier descriptor
    %     fd = fft(marker_xyz);
    %     fd = fd./repmat(abs(fd(2,:)),size(fd,1),1);
    % %     marker_des = fd(2:end,:);
    %     marker_des = fd(2:31,:);
    %% 3dShapeContext descriptor
    % Parameters for computing shape context
    %     mean_dist_global=[]; % use [] to estimate scale from the data
    %     nbins_theta=18;
    %     nbins_alpha=9;
    %     nbins_r=10;
    %     ndum1=0;
    %     eps_dum=0.15;
    %     r_inner=0.1;
    %     r_outer=2.5;
    %
    % %     run 3dsc computing
    %     nsamp1=size(marker_xyz,1);
    % %     outliers on each iteration
    %     out_vec_1=zeros(1,nsamp1-4); % beging and ending elements are excluded
    % %     Frenet Frames
    %     FrenetVector = Estimate_Frenet(marker_xyz,8);
    %     FVector = FrenetVector(3:end-2,:);
    % %     compute shape contexts for (transformed) model
    %     Bsamp = marker_xyz(3:end-2,:);
    %     [BH_theta,BH_alpha,mean_dist_1] = sc3d_compute(Bsamp',FVector',mean_dist_global,nbins_theta,nbins_alpha,nbins_r,r_inner,r_outer,out_vec_1);
    %     marker_des = cat(2,BH_theta, BH_alpha);
    %% raw data
    marker_des = marker_xyz;
    %% Self-similarity descriptor
    TSSM = Temporal_SSM(marker_des, 5, 1, 1);
    % Image_TSSM = TSSM(2+1:end-2,2+1:end-2);
    Image_TSSM = TSSM;
    Image_TSSM = floor((Image_TSSM/max(max(Image_TSSM)))*(2^16-1)); % for raw data
    % Image_TSSM = floor(Image_TSSM*(2^16-1));% for sigmoid distance
    % Image_TSSM = exp(-Image_TSSM/(1*65536));
    %%%%%%%%%%%%%%%%% HOG of SSM %%%%%%%%%%%%%%%%%
    marker_des = Log_hogcalculator(Image_TSSM);
    % marker_des  = LocalSsmcalculatorSameBlock(Image_TSSM);
    % marker_des  =   global_hogcalculator(Image_TSSM);
    %%%%%%%%%%%%%%%%% max(variance) of SSM %%%%%%%%%%%%%%%%%
    % marker_des  = [marker_des(2+1:end-2,:) LocalSsmcalculator(Image_TSSM)];
    % marker_des  = LocalSsmcalculator(Image_TSSM);
    %% final results
    TRAJSAMPLES_DES{1, i} = marker_des;
end
save(matfilename, 'TRAJSAMPLES_DES');
