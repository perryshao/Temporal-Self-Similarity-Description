% modified to support running in occlusion situation -- modified by perry
clear all
% delete *.mat  % only run when firstly loading data
%% define the experiment times and class numbers
% noise_level = [0.1 0.08 0.06 0.04 0.02 0.01 0];
% noise_level = [0.02 0.016 0.012 0.008 0.004 0];
noise_level = 0;
EXPERIMENT_TIMES = length(noise_level);
CLASS_NUM = 20; % class numbers for classification task
SAMPLES_NUM = 30; % training samples numbers
%% define the directory of c3d data and corresponding numbers of directories
BAT_FOLDER = 'MSRAction3DSkeletonReal3D/'; % LOCATION OF C3D FILES
file_ext = '.txt';

distance_matrix_ssm = cell(1, EXPERIMENT_TIMES);
confusion_matrix_ssm = cell(1, EXPERIMENT_TIMES);
distance_matrix_diff = cell(1, EXPERIMENT_TIMES);
confusion_matrix_diff = cell(1, EXPERIMENT_TIMES);
compu_time_svm = zeros(1, EXPERIMENT_TIMES); compu_time_diff = zeros(1, EXPERIMENT_TIMES);
compu_time_bof = zeros(1, EXPERIMENT_TIMES);
recog_ratio_diff = zeros(1, EXPERIMENT_TIMES);
recog_ratio_ssm = zeros(1, EXPERIMENT_TIMES);
%% define the joint name
RANK = '16' ;RKNE = '14';LANK = '17';LKNE = '15';
LELB = '9';LWRA = '11';RELB = '8';RWRA = '10';
STRN = '7';HEAD = '20';RSHO = '1';LSHO = '2';
LFWT = '6'; RFWT = '5';C7 ='3';T10 = '4';
RFIN = '12';LFIN = '13';RTOE = '18';LTOE = '19';
ENSEMBLE = 'ENSEMBLE';
%% load targets of joints
% partition joints into 4 groups
% joints_no = {RFIN RWRA,RELB,RSHO;...
%             LFIN LWRA,LELB,LSHO;...
%             RFWT,RKNE,RANK,RTOE;...
%             LFWT,LKNE,LANK,LTOE;};
% partition joints into 20 groups

joints_no = {HEAD;...
             C7;...
             RFIN;...
             RWRA;...
             RELB;...
             RSHO;...
             LFIN;...
             LWRA;...
             LELB;...
             LSHO;...
             T10;...
             STRN;...
             RFWT;...
             RKNE;...
             RANK;...
             RTOE;...
             LFWT;...
             LKNE;...
             LANK;...
             LTOE;...
             };
% jointNum = length(joints_no);

% compare joints between themself with the nearest neighborhood
% pairJoints = { HEAD T10;...
%                 C7 T10;...
%                 RFIN RWRA;...
%                 RWRA RELB;...
%                 RELB RSHO;...
%                 RSHO C7;...
%                 LFIN LWRA;...
%                 LWRA LELB;...
%                 LELB LSHO;...
%                 LSHO C7;...
%                 STRN T10;...
%                 RFWT STRN;...
%                 RKNE RFWT;...
%                 RANK RKNE;...
%                 RTOE RANK;...
%                 LFWT STRN;...
%                 LKNE LFWT;...
%                 LANK LKNE;...
%                 LTOE LANK;...
%             };
% jointNum = length(pairJoints);

% compare joints between themself with the hip-center joint and include the scale normalization
pairJoints = { HEAD STRN;...
               C7 STRN;...
               RFIN STRN;...
               RWRA STRN;...
               RELB STRN;...
               RSHO STRN;...
               LFIN STRN;...
               LWRA STRN;...
               LELB STRN;...
               LSHO STRN;...
               T10 STRN;...
               RFWT STRN;...
               RKNE STRN;...
               RANK STRN;...
               RTOE STRN;...
               LFWT STRN;...
               LKNE STRN;...
               LANK STRN;...
               LTOE STRN;...
             };
jointNum = length(pairJoints);

for experiment_num = 1:EXPERIMENT_TIMES
    %% load data initially for first running
    load_MSRtxt_bat(joints_no, BAT_FOLDER);
    preprocess_bat(joints_no, 1);
    %% loading the original data
    % fprintf ('copying original data...\n');
    % for i=1:length(joints_no)
    %     copymat_file = joints_no{1,i};
    %     copyfile(['mat/' copymat_file '*.mat'],'../MSRActionEvaluatingCode/','f');
    % end
    %% add Guassian White Noise to Samples data
    % add_noise_bat(joints_no,noise_level(experiment_num));
    %% generate the self-similarity descriptors for represenation
    [TSSMDB_HOG, TSSMSAMPLES_HOG] = GeneTSSM(pairJoints);
    [trainGID, testGID] = getLabels(joints_no);
    %% SSM based sparse coding
    load TSSMDB_HOG.mat;load TSSMSAMPLES_HOG.mat;
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)
    % temporal pyramid baded on spooling sparce coding
    [traindata, testdata, sum_ScSPM_time] = GeneScCodeJointPyramid(TSSMDB_HOG, TSSMSAMPLES_HOG, jointNum, ntotalbh);
    compu_time_bof(experiment_num) = sum_ScSPM_time/length(testGID);
    save traindata traindata; save testdata testdata; clear traindata testdata; % avoid Out of Memory
    clear TSSMDB_HOG TSSMSAMPLES_HOG; % to avoid Out of Memory
    %% SSM and skeleton based sparse coding
    load TSSMDB_HOG.mat;load TSSMSAMPLES_HOG.mat;load TSSMDB_SKELETON.mat;load TSSMSAMPLES_SKELETON.mat;
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)
    % pyramid baded on spooling sparce coding based on
    % self-similarity descriptor and skeleton features
    [traindataOfssm, testdataOfssm, ~] = GeneScCodeJointPyramid(TSSMDB_HOG, TSSMSAMPLES_HOG, jointNum, ntotalbh);
    [traindataOfskel, testdataOfskel, ~] = GeneScCodeJointPyramid(TSSMDB_SKELETON, TSSMSAMPLES_SKELETON, jointNum, ntotalbh);
    traindata = [traindataOfssm;traindataOfskel];testdata = [testdataOfssm;testdataOfskel];
    save traindata traindata; save testdata testdata; clear traindata testdata ; % avoid Out of Memory
    clear traindataOfssm testdataOfssm traindataOfskel testdataOfskel;
    clear TSSMDB_HOG TSSMSAMPLES_HOG TSSMDB_SKELETON TSSMSAMPLES_SKELETON; % to avoid Out of Memory

    %%%%%%%%%%% using predefined kernels%%%%%%%%%%%%%%%%%%%%%
    % numTrain = length(trainGID);numTest = length(testGID);

    % norm1 distance
    %     Svm_kernel = @(X,Y)distance_matrix_norm1(X,Y);
    %     K =  [ (1:numTrain)' , Svm_kernel(traindata,traindata) ];
    %     KK = [ (1:numTest)'  , Svm_kernel(testdata,traindata)  ];

    % chi-square statistic
    %     dist_func=@chi_square_statistics_fast;
    %     K =  [ (1:numTrain)' , pdist2(traindata,traindata,dist_func) ];
    %     KK = [ (1:numTest)'  , pdist2(testdata,traindata,dist_func)  ];

    % cityblock, norm1
    %     K =  [ (1:numTrain)' , pdist2(traindata,traindata,'cityblock') ];
    %     KK = [ (1:numTest)'  , pdist2(testdata,traindata,'cityblock')  ];

    % Pyramid Matching kernel

    % Pyramid_kernel = @(X,Y)PyramidMatching(X,Y,ntotalbh,num_words);
    % K =  [ (1:numTrain)' , Pyramid_kernel(traindata,traindata) ];
    % model = svmtrain(trainGID,K,'-t 4 -b 1');
    %
    % tic;
    % KK = [ (1:numTest)'  , Pyramid_kernel(testdata,traindata)  ];
    % [predict_label, accuracy, dec_values] = svmpredict(testGID,KK, model,'-b 1');
    % sum_time_svm = toc;
    % compu_time_svm(experiment_num) =sum_time_svm/size(testdata,1);

    %%%%%%%%%%% using linear kernels based on ScSPM%%%%%%%%%%%%%%%%%%%%%

    % Sparse Coding Pyramid Matching Linear SVM

    lambda = 0.1; % regularization parameter for w
    load traindata.mat;[w, b, class_name] = li2nsvm_multiclass_lbfgs(traindata', trainGID, lambda);clear traindata;

    tic;
    load testdata.mat;[predict_label, ~] = li2nsvm_multiclass_fwd(testdata', w, b, class_name);clear testdata;
    sum_time_svm = toc;
    compu_time_ssm(experiment_num) = sum_time_svm/length(predict_label);

    %%%%%%%%%%%%%%%%% using stardard kernels  %%%%%%%%%%%%%%%%%%%%%%%%
    % model = svmtrain(trainGID,traindata,'-t 2 -b 0');
    % tic;
    % [predict_label1, accuracy1, dec_values1] = svmpredict(testGID,testdata, model,'-b 0');
    % sum_time_svm = toc;
    % compu_time_svm(experiment_num) =sum_time_svm/length(predict_label1);
    %%%%%%%%%%%%%%%%%%% using multiple binary regression %%%%%%%%%%%%%%%%%%%
    numTrain = length(trainGID);numTest = length(testGID);
    lambda = [0.1, 10, 0];modulaNum = 1;
    load traindata.mat;theta = trainBinRegression(traindata, trainGID, lambda, jointNum, modulaNum);clear traindata;
    predict_label = predictBinRegression(testdata, theta);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    confusion_matrix = zeros(CLASS_NUM, CLASS_NUM);
    for i = 1:CLASS_NUM
        for j = 1:CLASS_NUM
            confusion_matrix(i, j) = length(find(testGID == i & predict_label == j));
        end
    end

    recog_ratio_ssm(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:));
    recog_ratio_final_ssm = mean(recog_ratio_ssm) %#ok<NOPTS>
    confusion_matrix_ssm{1, experiment_num} = confusion_matrix;

    %% implement recognition using integral invariant
    % samples_r=size(INTEGRATE_DES,2);
    % samples_t=size(INTEGRATESAMPLES_DES,2);
    % dtw_distance = zeros(samples_t,samples_r);
    % for i=1:samples_t
    %     for j=1:samples_r
    %         fprintf ('the %d/%d--%d recognition for integral descriptor...%2.2f%%\n',i,j,samples_r*samples_t,(samples_r*(i-1)+j)*100/(samples_r*samples_t));
    %         [dtw_distance(i,j), ~, path]=dtw_adj_matching(testdata{1,i},traindata{1,j},50,7);
    % %         [dtw_distance(i,j), ~, ~]=dtw_adj_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},50);
    %     end
    % end
    % [~,I]=min(dtw_distance,[],2); % sum up the recognition accurate ratio
    %
    %
    % for i = 1:CLASS_NUM
    %     for j = 1:CLASS_NUM
    %         confusion_matrix(i,j) = length(find(testGID == i & trainGID(I) == j));
    %     end
    % end
    % recog_ratio_interg(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:)); %#ok<SAGROW>
    %
    % recog_ratio_final_interg = mean(recog_ratio_interg) %#ok<NOPTS>
    % confusion_matrix_interg{1,experiment_num} = confusion_matrix;
    % distance_matrix_interg{1,experiment_num} = dtw_distance;

    %% save and delete data
    delete *.mat;
    save  RECOGNITION_TALBLE_INTERG distance_matrix_ssm distance_matrix_interg;
    save  RECOGNITION_RATIO confusion_matrix_ssm confusion_matrix_interg...
         recog_ratio_interg recog_ratio_ssm compu_time_svm compu_time_ssm compu_time_bof; %recog_ratio_svm;
    clearvars -except BAT_FOLDER EXPERIMENT_PARA experiment_num EXPERIMENT_TIMES  CLASS_SELECTED SAMPLES_NUM CLASS_NUM noise_level;
    load RECOGNITION_RATIO; load RECOGNITION_TALBLE_INTERG;
end
% close(h);
fprintf('Recognition task has completed!\n');
fclose('all');
clear all;
