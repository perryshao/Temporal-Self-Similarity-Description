function gene_descriptor_diff_samples(marker)
%GENE_DESCRIPTOR_DIFF_SAMPLES  DI-based windowed SSM Log-HOG descriptors, test set.
%   GENE_DESCRIPTOR_DIFF_SAMPLES(MARKER): DESCRIPTOR_COMP (DI) ->
%   TEMPORAL_SSM(des, 3, 5) -> LOG_HOGCALCULATOR.
%   Reads <MARKER>samples.mat (TRAJSAMPLES) and writes <MARKER>samples_DES.mat
%   (TRAJSAMPLES_DES).  Must compute the same descriptor as the training twin.

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
    fprintf ('%d of %d samples differential descriptor...\n', i, samples);
    %% differential invariants
    % marker_des = integral_invariant_dist_ms(marker_xyz,0.4);
    marker_des = descriptor_comp(marker_xyz);
    %% raw data
    % marker_des = marker_xyz;
    %% Self-similarity descriptor
    TSSM = Temporal_SSM(marker_des, 3, 5);
    % Image_TSSM = TSSM(2+1:end-2,2+1:end-2);
    Image_TSSM = TSSM;
    Image_TSSM = floor((Image_TSSM/max(max(Image_TSSM)))*(2^16-1));
    % Image_TSSM = exp(-Image_TSSM/(1*65536));
    %%%%%%%%%%%%%%%%% HOG of SSM %%%%%%%%%%%%%%%%%
    marker_des = Log_hogcalculator(Image_TSSM);
    % marker_des  = LocalSsmcalculatorSameBlock(Image_TSSM);
    % marker_des  =   global_hogcalculator(Image_TSSM);
    %%%%%%%%%%%%%%%%% max(variance) of SSM %%%%%%%%%%%%%%%%%
    % marker_des  = [marker_des(2+1:end-2,:) LocalSsmcalculator(Image_TSSM)];
    % marker_des  = LocalSsmcalculator(Image_TSSM);
    %% final descriptor
    TRAJSAMPLES_DES{1, i} = marker_des;
end
save(matfilename, 'TRAJSAMPLES_DES');
