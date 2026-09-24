function [TSSMDB_HOG, TSSMSAMPLES_HOG, trainGID, testGID]= GeneTSSM(TRAJDB, TRAJSAMPLES)
%GENE_TSSM  Legacy hierarchical-SSM experiment (incomplete interface).
%   Intended to combine root and relative descriptors before Log-HOG.
%   The saved declaration accepts only TRAJDB and TRAJSAMPLES, but the caller
%   passes six inputs and the body uses four descriptor arrays not supplied
%   by that declaration. Its declared name also differs from this filename.
%   See REVIEW.md before using this branch.

samples_r = size(TRAJDB, 2);
samples_t = size(TRAJSAMPLES, 2);
trainGID = zeros(samples_r, 1);
testGID = zeros(samples_t, 1);
for i = 1:samples_r
    directory_loca = find(TRAJDB{1, i} == '/');
    TRAJDB{1, i} = TRAJDB{1, i}(1:directory_loca(2)+3);
    trainGID(i) = str2double(TRAJDB{1, i}(end-1:end));
end
for i = 1:samples_t
    directory_loca = find(TRAJSAMPLES{1, i} == '/');
    TRAJSAMPLES{1, i} = TRAJSAMPLES{1, i}(1:directory_loca(2)+3);
    testGID(i) = str2double(TRAJSAMPLES{1, i}(end-1:end));
end
train_num = length(trainGID);
%% Self-similarity descriptor
TSSMDB_HOG = cell (1, train_num);
for i = 1:train_num
    fprintf ('%d of %d ssm descriptor...\n', i, train_num);
    % for multiple trajectories
    des = [TRAJDB_DES{1, i} INTEGRATE_DES{1, i}];
    TSSM = Temporal_SSMofHierarD(des, 0);
    % for single trajectory
    %     des = TRAJDB_DES{1,i};
    %     TSSM = Temporal_SSM(des,3);
    %
    Image_TSSM = TSSM;
    Image_TSSM = floor((Image_TSSM/max(max(Image_TSSM)))*(2^16-1));
    %%%%%%%%%%%%%%%%% HOG of SSM %%%%%%%%%%%%%%%%%
    ssm_des = Log_hogcalculator(Image_TSSM);
    % ssm_des  = LocalSsmcalculatorSameBlock(Image_TSSM);
    %%%%%%%%%%%%%%%%% max(variance) of SSM %%%%%%%%%%%%%%%%%
    % ssm_des  = [marker_des(2+1:end-2,:) LocalSsmcalculator(Image_TSSM)];
    %     ssm_des  = LocalSsmcalculator(Image_TSSM);
    TSSMDB_HOG{1, i} = ssm_des;
end

test_num = length(testGID);
% testdata = zeros(1,dim_root+dim_orien+1,class);
TSSMSAMPLES_HOG = cell (1, test_num);

for i = 1:test_num
    fprintf ('%d of %d samples ssm descriptor...\n', i, test_num);
    % for multiple trajectories
    des = [TRAJSAMPLES_DES{1, i} INTEGRATESAMPLES_DES{1, i}];
    TSSM = Temporal_SSMofHierarD(des, 0);
    % for single trajectory
    %     des = TRAJSAMPLES_DES{1,i};
    %     TSSM = Temporal_SSM(des,3);

    Image_TSSM = TSSM;
    Image_TSSM = floor((Image_TSSM/max(max(Image_TSSM)))*(2^16-1));
    %%%%%%%%%%%%%%%%% HOG of SSM %%%%%%%%%%%%%%%%%
    ssm_des = Log_hogcalculator(Image_TSSM);
    % ssm_des  = LocalSsmcalculatorSameBlock(Image_TSSM);
    %%%%%%%%%%%%%%%%% max(variance) of SSM %%%%%%%%%%%%%%%%%
    % ssm_des  = [marker_des(2+1:end-2,:) LocalSsmcalculator(Image_TSSM)];
    %     ssm_des  = LocalSsmcalculator(Image_TSSM);
    TSSMSAMPLES_HOG{1, i} = ssm_des;
end

save TSSMDB_HOG TSSMDB_HOG;
save TSSMSAMPLES_HOG TSSMSAMPLES_HOG;
