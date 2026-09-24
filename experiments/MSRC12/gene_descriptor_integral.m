function gene_descriptor_integral(marker)
%GENE_DESCRIPTOR_INTEGRAL  Multiscale area integral invariants (MAII), training set.
%   GENE_DESCRIPTOR_INTEGRAL(MARKER) is a menu of per-frame descriptors; as last
%   saved it computes 0.5 - INTEGRAL_INVARIANT_MS(xyz, 6, 0.2).
%   Reads <MARKER>.mat (TRAJDB) and writes <MARKER>_DES.mat (TRAJDB_DES).
%   Keep in sync with the _samples twin, which must compute the SAME
%   descriptor for the test set; a mismatch gives meaningless accuracies.

fileprefix = '.mat';
matfilename = [marker fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
fileextend = '_DES.mat';
matfilename = [marker fileextend];
%% read joint 3D data with matrix format and get the descriptor
samples = size(TRAJDB, 2);
TRAJDB_DES = cell (1, samples);
for i = 1:samples
    marker_xyz = double(TRAJDB{2, i});
    fprintf ('%d of %d integral descriptor...\n', i, samples);
    %% integral invariants
    % marker_des = integral_invariant(marker_xyz,6,0.05);
    % % marker_des = integral_invariant_kn(marker_xyz,6,5);
    % marker_des = 0.5-marker_des;
    % marker_des= [marker_des(:,1) [0; diff(marker_des(:,1),1,1)]...
    %             marker_des(:,2) [0; diff(marker_des(:,2),1,1)]];
    % % use curvature only
    % % marker_des= [marker_des(:,1) [0; diff(marker_des(:,1),1,1)]];
    %% multiscale integral invariants
    marker_des = integral_invariant_ms(marker_xyz, 6, 0.2);
    marker_des = 0.5-marker_des;
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
    %     marker_des = integral_invariant_dist(marker_xyz,30);

    %% multiscale distance integral invariants
    % marker_des = integral_invariant_dist_ms(marker_xyz,0.4);

    %% fourier descriptor
    % fd = fft(marker_xyz);
    % fd = fd./repmat(abs(fd(2,:)),size(fd,1),1);
    % % marker_des = fd(2:end,:);
    % marker_des = fd(2:31,:);
    %% raw data
    % marker_des = marker_xyz;
    %% Self-similarity descriptor
    % TSSM = Temporal_SSM(marker_des,3,5);
    % % Image_TSSM = TSSM(2+1:end-2,2+1:end-2);
    % Image_TSSM = TSSM;
    % Image_TSSM = floor((Image_TSSM/max(max(Image_TSSM)))*(2^16-1));
    % % Image_TSSM = exp(-Image_TSSM/(1*65536));
    % %%%%%%%%%%%%%%%%% HOG of SSM %%%%%%%%%%%%%%%%%
    % marker_des  =   Log_hogcalculator(Image_TSSM);
    % % marker_des  = LocalSsmcalculatorSameBlock(Image_TSSM);
    % % marker_des  =   global_hogcalculator(Image_TSSM);
    % %%%%%%%%%%%%%%%%% max(variance) of SSM %%%%%%%%%%%%%%%%%
    % % marker_des  = [marker_des(2+1:end-2,:) LocalSsmcalculator(Image_TSSM)];
    % % marker_des  = LocalSsmcalculator(Image_TSSM);
    %% final descriptor
    TRAJDB_DES{1, i} = marker_des;
end
save(matfilename, 'TRAJDB_DES');
