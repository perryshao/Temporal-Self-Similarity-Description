% modified to support running in occlusion situation -- modified by perry
clear all
% delete *.mat  % only run when firstly loading data
%% define the experiment times and class numbers
% noise_level = [0.1 0.08 0.06 0.04 0.02 0.01 0];
% noise_level = [0.02 0.016 0.012 0.008 0.004 0];
noise_level = 0;
EXPERIMENT_TIMES=length(noise_level);
CLASS_NUM = 20;% class numbers for classification task
SAMPLES_NUM = 30; % training samples numbers 
%% define the directory of c3d data and corresponding numbers of directories
BAT_FOLDER = 'MSRAction3DSkeletonReal3D/';  %LOCATION OF C3D FILES
file_ext = '.txt';

distance_matrix_interg = cell(1,EXPERIMENT_TIMES);
confusion_matrix_interg = cell(1,EXPERIMENT_TIMES);
distance_matrix_diff = cell(1,EXPERIMENT_TIMES);
confusion_matrix_diff = cell(1,EXPERIMENT_TIMES);
compu_time_svm = zeros(1,EXPERIMENT_TIMES); compu_time_diff = zeros(1,EXPERIMENT_TIMES);
compu_time_bof = zeros(1,EXPERIMENT_TIMES);
recog_ratio_diff = zeros(1,EXPERIMENT_TIMES);
recog_ratio_interg = zeros(1,EXPERIMENT_TIMES);

%%  generate random class samples and random training samples
gamma = 0.5;
m_num = 4;
%% define the joint name
RANK = '16' ;RKNE = '14';LANK = '17';LKNE = '15';
LELB = '9';LWRA = '11';RELB = '8';RWRA = '10';
STRN = '7';HEAD = '20';RSHO = '1';LSHO = '2';
LFWT = '6'; RFWT = '5';C7 ='3';T10 = '4';
RFIN = '12';LFIN = '13';RTOE = '18';LTOE = '19';
ENSEMBLE = 'ENSEMBLE';
%% load targets of joints
% joints_no = {LWRA,RWRA,LANK,RANK,...
%              LELB,RELB,LKNE,RKNE,...
%              LFWT,RFWT,RSHO,LSHO,...
%              HEAD,RFIN,LFIN,C7,...
%              T10,RTOE,LTOE,STRN};
joints_no = {LWRA,RWRA,LANK,RANK,LSHO...
             LELB,RELB,LKNE,RKNE,RSHO,STRN,C7,HEAD};

ROOT = ENSEMBLE;
ensemble_no = {ENSEMBLE};
for experiment_num=1:EXPERIMENT_TIMES  
    %% load data initially for first running    
    load_MSRtxt_bat(joints_no,BAT_FOLDER);
    preprocess_bat(joints_no,1); 
    %% loading the original data
%     fprintf ('copying original data...\n');
%     for i=1:length(joints_no)
%         copymat_file = joints_no{1,i};
%         copyfile(['mat/' copymat_file '*.mat'],'../MSRActionEvaluatingCode/','f');
%     end
    %% add Guassian White Noise to Samples data
%     add_noise_bat(joints_no,noise_level(experiment_num));
%     repreprocess_bat(joints_no);
    %%  get the average of ensemble trajectories
    ensemble_bat(joints_no);
    %%  get relative descriptions of LWRA-LELB for database
    fprintf ('generate the relative descriptor...\n');
    [INTEGRATE_DES,INTEGRATESAMPLES_DES] = relative_descrip_bat(joints_no,ROOT);   
    preprocess_bat(ensemble_no,0);
    %% generate the invariant represenation
    fprintf ('get the database descriptor for root trajectory...\n');
    gene_descriptor_integral(ENSEMBLE);
    fprintf ('get the samples descriptor for root trajectory...\n');
    gene_descriptor_integral_samples(ENSEMBLE);
    load ([ENSEMBLE '_des.mat']);
    load ([ENSEMBLE 'samples_des.mat']);    
    %% construct training and test dataset for SVM Classifier
%     fprintf(1,'loading training data...\n');
%     load ([ROOT,'.mat']);load ([ROOT,'samples.mat']);
%     [trainGID,testGID] = construct_ID(TRAJDB,TRAJSAMPLES); %#ok<NASGU,ASGLU>
%     clear TRAJDB TRAJSAMPLES;
    %% clustering and retrieval test
%     fprintf(1,'loading training data...\n');
%     load ([ENSEMBLE,'.mat']);load ([ENSEMBLE,'samples.mat']);
%     [ClusterRawData, ClusterData, ClusterID] = ClusterAllData(TRAJDB,TRAJSAMPLES,...
%         TRAJDB_DES,TRAJSAMPLES_DES,INTEGRATE_DES,INTEGRATESAMPLES_DES);
%     delta = 1;
%     [Clustered_Indx, Ctrs,C_distance] = Spec_Clustering(ClusterData,CLASS_NUM,3,delta);
% %     [Clustered_Indx, Ctrs,C_distance] = Spec_Clustering(ClusterData,CLASS_NUM,3,delta,C_distance);
%     Clustered_accuracy = Get_ClusterAccuracy(Clustered_Indx,ClusterID);
%     Plot_Cluster(ClusterRawData,ClusterID,Clustered_Indx);
%     Q_num = 5; % the number of query data
%     [Qdata, QueryID] = PickupQuery(ClusterData,ClusterID,Q_num); % pick up the query data randomly with required number from dataset
%     Recall = zeros(Q_num,11);% initial value, 0.11-0.22-0.33...0.99,1
%     Precision = zeros(Q_num,11);% initial value, 0.11-0.22-0.33...0.99,1
%     for i = 1:Q_num
%         Recall(i,1) = 1/length(ClusterData(ClusterID==QueryID(i)));
%         [Query_Indx, Q_distance] = Query_distance(Qdata{i},ClusterData);
%         Precision(i,1) = 1;
%         for j = 2:11 % initial value, 0.11-0.22-0.33...0.99,1
%             fprintf('Retrievaling the data....%f%%\n',j/11*100);
%             if j == 11
%                 Recall(i,j) = 1;
%             else
%                 Recall(i,j) = 0.11*(j-1);
%             end
%             [Retrieved_Data, Retrieved_Indx] = Retrieval_data(Query_Indx,QueryID(i),...
%                                                Clustered_Indx,ClusterData,ClusterID,Recall(i,j));
%             Relevant_Indx = find(ClusterID == QueryID(i));
%             Precision(i,j) = length(intersect(Relevant_Indx,Retrieved_Indx))/length(Retrieved_Indx);
%         end
%     end
%     drawPRC(Recall,Precision);
     %% hmm classifier
%      fprintf(1,'loading training data...\n');
%      load ([ROOT,'.mat']);load ([ROOT,'samples.mat']);
%      [traindata, testdata, trainGID,testGID]=construct_hmmdata(TRAJDB,TRAJSAMPLES,...
%                               TRAJDB_DES,TRAJSAMPLES_DES,INTEGRATE_DES,INTEGRATESAMPLES_DES);
%      clear TRAJDB TRAJSAMPLES;
%      [confusion_matrix,test_loglik,I] = mhmm_classifier(traindata,trainGID,testdata,testGID);
%      recog_ratio_interg(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:)); %#ok<SAGROW>
%     
%     recog_ratio_final_interg = mean(recog_ratio_interg) %#ok<NOPTS>
%     confusion_matrix_interg{1,experiment_num} = confusion_matrix;
%     distance_matrix_interg{1,experiment_num} = dtw_distance;
       
   %% dtw training
%    trained_data = train_dtw(traindata,trainGID);
%    
%    samples_r=length(traindata);
%    samples_t=length(testdata);
%    dtw_distance = zeros(samples_t,samples_r);
%    for i=1:samples_t
%        for j=1:samples_r
%            fprintf ('the %d/%d--%d recognition for integral descriptor...%2.2f%%\n',i,j,samples_r*samples_t,(samples_r*(i-1)+j)*100/(samples_r*samples_t));
%            [dtw_distance(i,j), ~, ~]=dtw(testdata{i}',traindata{j}',50);
% %            [dtw_distance(i,j), ~, ~]=dtw_adj_matching(testdata{i}(1:10,:)',traindata{j}(1:10,:)',50,0);
%        end
%    end
%    [~,I]=min(dtw_distance,[],2); % sum up the recognition accurate ratio
%    
%    for i = 1:CLASS_NUM
%        for j = 1:CLASS_NUM
%            confusion_matrix(i,j) = length(find(testGID == i & trainGID(I) == j));
%        end
%    end
%    recog_ratio_interg(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:))
%    confusion_matrix_interg{1,experiment_num} = confusion_matrix;
   %% SSM based classifier
    fprintf(1,'loading training data...\n');
    load ([ROOT,'.mat']);load ([ROOT,'samples.mat']);
    [TSSMDB_HOG, TSSMSAMPLES_HOG, trainGID,testGID] = gene_TSSM(TRAJDB,TRAJSAMPLES,...
                              TRAJDB_DES,TRAJSAMPLES_DES,INTEGRATE_DES,INTEGRATESAMPLES_DES);
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)  
    % temporal pyramid matching kernels
%     [traindata,testdata,sum_BoF_time,num_words] = gene_codebook_pyramid(TRAJDB_DES,TRAJSAMPLES_DES,ntotalbh);
%     compu_time_bof(experiment_num) =sum_BoF_time/size(testdata,1);
    % temporal pyramid baded on spooling sparce coding
    [traindata,testdata,sum_ScSPM_time] = gene_codebook_ScSPM(TSSMDB_HOG,TSSMSAMPLES_HOG,ntotalbh);
    compu_time_bof(experiment_num) =sum_ScSPM_time/size(testdata,1);
    
    %%%%%%%%%%% using predefined kernels%%%%%%%%%%%%%%%%%%%%%
%     numTrain = length(trainGID);numTest = length(testGID);
    
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
    
%     Pyramid_kernel = @(X,Y)PyramidMatching(X,Y,ntotalbh,num_words);
%     K =  [ (1:numTrain)' , Pyramid_kernel(traindata,traindata) ];
%     model = svmtrain(trainGID,K,'-t 4 -b 1');
%     
%     tic;
%     KK = [ (1:numTest)'  , Pyramid_kernel(testdata,traindata)  ];
% 	[predict_label, accuracy, dec_values] = svmpredict(testGID,KK, model,'-b 1');
%     sum_time_svm = toc;
%     compu_time_svm(experiment_num) =sum_time_svm/size(testdata,1);
    
    %%%%%%%%%%% using linear kernels based on ScSPM%%%%%%%%%%%%%%%%%%%%%
    
    % Sparse Coding Pyramid Matching Linear SVM
    lambda = 0.1;     % regularization parameter for w
    [w, b, class_name] = li2nsvm_multiclass_lbfgs(traindata',trainGID, lambda);
    
    tic;
    [predict_label, ~] = li2nsvm_multiclass_fwd(testdata', w, b, class_name);
    sum_time_svm = toc;
    compu_time_svm(experiment_num) =sum_time_svm/size(testdata,1);


    %%%%%%%%%%%%%%%%% using stardard kernels  %%%%%%%%%%%%%%%%%%%%%%%%
%     model = svmtrain(trainGID,traindata,'-t 2 -b 0');
%     tic;
%     [predict_label1, accuracy1, dec_values1] = svmpredict(testGID,testdata, model,'-b 0');
%     sum_time_svm = toc;
%     compu_time_svm(experiment_num) =sum_time_svm/size(testdata,1);

    confusion_matrix = zeros(CLASS_NUM,CLASS_NUM);
    for i = 1:CLASS_NUM
        for j = 1:CLASS_NUM
            confusion_matrix(i,j) = length(find(testGID == i & predict_label == j));
        end
    end
    
    recog_ratio_interg(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:));  
    recog_ratio_final_interg = mean(recog_ratio_interg) %#ok<NOPTS>
    confusion_matrix_interg{1,experiment_num} = confusion_matrix;
                          
    %% implement recognition using integral invariant
%     samples_r=size(INTEGRATE_DES,2);
%     samples_t=size(INTEGRATESAMPLES_DES,2);
%     dtw_distance = zeros(samples_t,samples_r);
%     for i=1:samples_t
%         for j=1:samples_r
%             fprintf ('the %d/%d--%d recognition for integral descriptor...%2.2f%%\n',i,j,samples_r*samples_t,(samples_r*(i-1)+j)*100/(samples_r*samples_t));
%             [dtw_distance(i,j), ~, path]=dtw_adj_matching(testdata{1,i},traindata{1,j},50,7);
% %             [dtw_distance(i,j), ~, ~]=dtw_adj_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},50); 
%         end   
%     end
%     [~,I]=min(dtw_distance,[],2); % sum up the recognition accurate ratio
%     
% 
%     for i = 1:CLASS_NUM
%         for j = 1:CLASS_NUM
%             confusion_matrix(i,j) = length(find(testGID == i & trainGID(I) == j)); 
%         end
%     end
%     recog_ratio_interg(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:)); %#ok<SAGROW>
%     
%     recog_ratio_final_interg = mean(recog_ratio_interg) %#ok<NOPTS>
%     confusion_matrix_interg{1,experiment_num} = confusion_matrix;
%     distance_matrix_interg{1,experiment_num} = dtw_distance;    
    %% implement recognition using differential invariants
    fprintf ('get the database descriptor for root trajectory...\n');
    gene_descriptor(LWRA);
    fprintf ('get the samples descriptor for root trajectory...\n');
    gene_descriptor_samples(LWRA);
    load ([LWRA '_des.mat']);
    load ([LWRA 'samples_des.mat']);

    for i=1:samples_t
        for j=1:samples_r
            fprintf ('the %d/%d--%d recognition for differential descriptor...%2.2f%%\n',i,j,samples_r*samples_t,(samples_r*(i-1)+j)*100/(samples_r*samples_t));
    %         dtw_distance(i,j)=dtw_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},1);
            [dtw_distance(i,j), ~, ~]=dtw_adj_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},1,50); 
        end   
    end
    dtw_distance = exp(-gamma*dtw_distance); %% tranform to Likelihood of dtw distance -- Perry 28/05/2013
    dtw_distance = dtw_distance./repmat(sum(dtw_distance,2),1, samples_r);%% softmax of dtw distance -- Perry 28/05/2013
    
    dtw_distance(:,77)=[];dtw_distance(:,77)=[];dtw_distance(:,243)=[]; % for eliminate the failure of LWAR differential invariant 
    
    [~,I]=max(dtw_distance,[],2); % sum up the recognition accurate ratio
    
    
    for i = 1:CLASS_NUM
        for j = 1:CLASS_NUM
            confusion_matrix(i,j) = length(find(testGID == i & trainGID(I) == j));
        end
    end
    recog_ratio_diff(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:));
    
    recog_ratio_final_diff = mean(recog_ratio_diff) %#ok<NOPTS>
    confusion_matrix_diff{1,experiment_num} = confusion_matrix;
    distance_matrix_diff{1,experiment_num} = dtw_distance;
    %% save and delete data
    delete *.mat;
    % save  RECOGNITION_TALBLE_SINGLE dtw_distance;
    save  RECOGNITION_TALBLE_INTERG distance_matrix_diff distance_matrix_interg;
    save  RECOGNITION_RATIO confusion_matrix_diff confusion_matrix_interg...
         recog_ratio_interg recog_ratio_diff compu_time_svm compu_time_diff compu_time_bof; %recog_ratio_svm;
%     save RECOGNITION_RATIO_SINGLE recog_ratio_single
    clearvars -except BAT_FOLDER EXPERIMENT_PARA experiment_num EXPERIMENT_TIMES  CLASS_SELECTED SAMPLES_NUM CLASS_NUM noise_level;
    load RECOGNITION_RATIO; load RECOGNITION_TALBLE_INTERG;
end
% close(h);
fprintf('Recognition task has completed!\n');
fclose('all');
clear all;

