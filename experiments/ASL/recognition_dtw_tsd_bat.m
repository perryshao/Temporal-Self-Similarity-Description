clear all
delete *.mat
%% define the experiment times and class numbers
noise_level = [0 0.1 0.2 0.3 0.4];
% noise_level = 0;
% EXPERIMENT_TIMES=length(noise_level);
% EXPERIMENT_TIMES = 50; % thesis Sec. 5.2.1 setting (50 random 16-class splits)
EXPERIMENT_TIMES = 10;% repeated times of experiment
CLASS_NUM = 16;% class numbers for classification task
SAMPLES_NUM = 8; % training samples numbers 
%% define the directory of c3d data and corresponding numbers of directories
BAT_FOLDER = 'tsd_data_bat/';  %LOCATION OF C3D FILES
file_ext = '.tsd';
folder_content = dir(BAT_FOLDER);
class_num = size(folder_content,1);
class_num = class_num-2;
class_array = 1:class_num;
K=randperm(class_num);
CLASS_SELECTED = class_array(K(1:CLASS_NUM));
distance_matrix_interg = cell(1,EXPERIMENT_TIMES);
confusion_matrix_interg = cell(1,EXPERIMENT_TIMES);
distance_matrix_diff = cell(1,EXPERIMENT_TIMES);
confusion_matrix_diff = cell(1,EXPERIMENT_TIMES);
compu_time_svm = zeros(1,EXPERIMENT_TIMES); compu_time_diff = zeros(1,EXPERIMENT_TIMES);
compu_time_bof = zeros(1,EXPERIMENT_TIMES);
recog_ratio_diff = zeros(1,EXPERIMENT_TIMES);
recog_ratio_interg = zeros(1,EXPERIMENT_TIMES);

%% define the joint name
LWRA = 'LWRA';RWRA = 'RWRA';ENSEMBLE = 'ENSEMBLE';
joints_no = {LWRA,RWRA};
esemble_no = {ENSEMBLE};
ROOT = ENSEMBLE;
gamma = 0.5;
%% begin the recognition
for experiment_num=1:EXPERIMENT_TIMES
    %% generate random samples
    random_seed=rand(1,SAMPLES_NUM);
    K=randperm(class_num);
    CLASS_SELECTED = K(1:CLASS_NUM);
    %% load database
    load_tsd_bat(joints_no,random_seed,CLASS_SELECTED,BAT_FOLDER);
%     preprocess_bat(joints_no,0,1,0);% tsd =0 or sing = 1 flag,inter_flag,transform_flag
      %% loading the original data
%       copyfile('mat/*.*','../tsdEvaluatingCode/','f');
%      add_noise_bat(joints_no,noise_level);
    %% shuffling the whole dataset
    fprintf ('shuffling the dataset...\n');
    shuffle_sort = [ 1 3 5 7 9;
                     2 4 6 8 0];
    [subjectID_DB,subjectID_SAMPLES] = shuffle_db(joints_no,shuffle_sort);
    %%  get the average of ensemble trajectories
    ensemble_bat(joints_no);
    %%  get relative descriptions of LWRA-LELB for database
    fprintf ('generate the relative descriptor...\n');
%     [INTEGRATE_DES,INTEGRATESAMPLES_DES] =relative_descrip_bat(joints_no,ROOT);
    preprocess_bat(esemble_no,0,1,0); %joints_no,tsd =0 or sing = 1 flag,inter_flag,transform_flag
    add_noise_bat(esemble_no,noise_level(1));
    %% computing the integral invariants
    fprintf ('get the database descriptor for root trajectory...\n');
    gene_descriptor_integral(ROOT);
    fprintf ('get the samples descriptor for root trajectory...\n');
    gene_descriptor_integral_samples(ROOT);
    load ([ROOT '_des.mat']);
    load ([ROOT 'samples_des.mat']);
    
    
    %% clustering and retrieval test
%     fprintf(1,'loading training data...\n');
%     load ([ROOT,'.mat']);load ([ROOT,'samples.mat']);
%     descrip_flag = 3;
%     [ClusterRawData, ClusterData, ClusterID] = ClusterTsdData(TRAJDB,TRAJSAMPLES,...
%         TRAJDB_DES,TRAJSAMPLES_DES);
%     
%     delta = 0.1;
%     [Clustered_Indx, Ctrs,C_distance] = Spec_Clustering(ClusterData,CLASS_NUM,3,delta);
%     
%     cluster_num = 50;Average_accuracy = 0;
%     for i = 1:cluster_num
%         [Clustered_Indx, Ctrs,C_distance] = Spec_Clustering(ClusterData,CLASS_NUM,3,delta,C_distance);
%         Clustered_accuracy = Get_ClusterAccuracy(Clustered_Indx,ClusterID);
%         Average_accuracy = Clustered_accuracy + Average_accuracy;
%     end
%     Average_accuracy = Average_accuracy/cluster_num;
%     
%     Plot_Cluster(ClusterRawData,ClusterID,Clustered_Indx);
%     
%     Q_num = 30; % the number of query data
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
% %             Clustered_Indx = 0; %% not important parameter that can be ignore here
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
%      [traindata, testdata, trainGID,testGID] = construct_hmmdata(TRAJDB,TRAJSAMPLES,...
%                               TRAJDB_DES,TRAJSAMPLES_DES);
%      clear TRAJDB TRAJSAMPLES;
%      [confusion_matrix,test_loglik,I,sum_time] = mhmm_classifier(traindata,trainGID,testdata,testGID);
%      recog_ratio_interg(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:)); 
%      compu_time_svm(experiment_num) = sum_time/length(testdata);
%     
%     recog_ratio_final_interg = mean(recog_ratio_interg) %#ok<NOPTS>
%     confusion_matrix_interg{1,experiment_num} = confusion_matrix;
     %% gmm Classifier
     %% construct training and test dataset for gmm Classifier
%      fprintf(1,'loading training data...\n');
%      load ([ROOT,'.mat']);load ([ROOT,'samples.mat']);
%      [traindata, testdata, trainGID,testGID]=construct_gmmdata(TRAJDB,TRAJSAMPLES,...
%                               TRAJDB_DES,TRAJSAMPLES_DES);
%      clear TRAJDB TRAJSAMPLES;
%      
%      dim = 3; ncentres = 20; covar_type = 'diag';max_iter = 100;
%      options = foptions; options(1) = 1; % >0 be displayed % <0 be quiet!
%      options(14) = max_iter;
%      mix = cell(1,CLASS_NUM);
%       % train the gmm model
%      for i = 1:CLASS_NUM
%          mix{i} = gmm(dim, ncentres, covar_type);
%          mix{i} = gmminit(mix{i}, traindata{1,i},options);
%         [mix{i}, options, errlog] = gmmem(mix{i}, traindata{1,i}, options);
%          while isnan(mix{i}.covars)
%              [mix{i}, options, errlog] = gmmem(mix{i}, traindata{1,i}, options);
%          end
%      end
%       % test the gmm model
%       tic
%       test_len=length(testGID);
%       post = cell(test_len,CLASS_NUM);
%       for i = 1:test_len
%           for j = 1:CLASS_NUM
%               [post{i,j}, a] = gmmpost(mix{j}, testdata{1,i});
%           end
%       end
%       
%       for i = 1:test_len
%           for j = 1:CLASS_NUM
% %               prob(j)=sum(sum(post{i,j}));
%               prob(j) = sum(max(post{i,j},[],2));
%           end
%           [~,indx]=max(prob);
%           test_class(i) = indx;
%       end
%       
%       for i = 1:CLASS_NUM
%           for j = 1:CLASS_NUM
%               confusion_matrix(i,j) = length(find(testGID == i & test_class' == j));
%           end
%       end
%       sum_time_diff = toc;
%       compu_time_diff(experiment_num) = sum_time_diff/length(testdata);
% 
%       recog_ratio_diff(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:));
%       recog_ratio_final_diff = mean(recog_ratio_diff) %#ok<NOPTS>
%       confusion_matrix_diff{1,experiment_num} = confusion_matrix;

    %% SVM using BoF of SSM   
	load ([ROOT,'.mat']);load ([ROOT,'samples.mat']);
    [trainGID,testGID]=construct_ID(TRAJDB,TRAJSAMPLES);
    numTrain = length(trainGID);numTest = length(testGID);
    ntotalbh = 2; % l = 0,1,2,3 (L=3) blocks are 2^(l)
    

   
    % temporal pyramid matching based on intersection Histograms
%     ntotalbh = 5;
% 	[traindata,testdata,sum_BoF_time] = gene_codebook(TRAJDB_DES,TRAJSAMPLES_DES,ntotalbh);
%     compu_time_bof(experiment_num) =sum_BoF_time/size(testdata,1);

    % temporal pyramid matching kernels
    [traindata,testdata,sum_BoF_time,num_words] = gene_codebook_pyramid(TRAJDB_DES,TRAJSAMPLES_DES,ntotalbh);
    compu_time_bof(experiment_num) =sum_BoF_time/size(testdata,1);

    % temporal pyramid baded on spooling sparce coding
%     [traindata,testdata,sum_ScSPM_time] = gene_codebook_ScSPM(TRAJDB_DES,TRAJSAMPLES_DES,ntotalbh);
%     compu_time_bof(experiment_num) =sum_ScSPM_time/size(testdata,1);
    
    %%%%%%%%%%% using predefined kernels%%%%%%%%%%%%%%%%%%%%%
   
    
    % norm1 distance
%     Svm_kernel = @(X,Y)distance_matrix_norm1(X,Y);
%     K =  [ (1:numTrain)' , Svm_kernel(traindata,traindata) ];
%     KK = [ (1:numTest)'  , Svm_kernel(testdata,traindata)  ];

    % chi-square statistic
%     dist_func=@chi_square_statistics_fast; 
%     K =  [ (1:numTrain)' , pdist2(traindata,traindata,dist_func) ];
%     model = svmtrain(trainGID,K,'-t 4 -b 1');
%     tic;
%     KK = [ (1:numTest)'  , pdist2(testdata,traindata,dist_func)  ];
%     [predict_label, accuracy, dec_values] = svmpredict(testGID,KK, model,'-b 1');
%     sum_time_svm = toc;
%     compu_time_svm(experiment_num) =sum_time_svm/size(testdata,1);

    % cityblock, norm1
%     K =  [ (1:numTrain)' , pdist2(traindata,traindata,'cityblock') ];
%     KK = [ (1:numTest)'  , pdist2(testdata,traindata,'cityblock')  ];
    
    % Pyramid Matching kernel
    
    Pyramid_kernel = @(X,Y)PyramidMatching(X,Y,ntotalbh,num_words);
    K =  [ (1:numTrain)' , Pyramid_kernel(traindata,traindata) ];
    model = svmtrain(trainGID,K,'-t 4 -b 1');
    
    tic;
    KK = [ (1:numTest)'  , Pyramid_kernel(testdata,traindata)  ];
	[predict_label, accuracy, dec_values] = svmpredict(testGID,KK, model,'-b 1');
    sum_time_svm = toc;
    compu_time_svm(experiment_num) =sum_time_svm/size(testdata,1);
    
    %%%%%%%%%%% using linear kernels based on ScSPM%%%%%%%%%%%%%%%%%%%%%
    
%     lambda = 0.1;     % regularization parameter for w
%     [w, b, class_name] = li2nsvm_multiclass_lbfgs(traindata',trainGID, lambda);
%     
%     tic;
%     [predict_label, ~] = li2nsvm_multiclass_fwd(testdata', w, b, class_name);
%     sum_time_svm = toc;
%     compu_time_svm(experiment_num) =sum_time_svm/size(testdata,1);


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
    %% implement recognition using Integral invariant
%     load ([ROOT,'.mat']);load ([ROOT,'samples.mat']);
%     [trainGID,testGID]=construct_ID(TRAJDB,TRAJSAMPLES);
%     samples_r=size(TRAJDB,2);
%     samples_t=size(TRAJSAMPLES,2);
%     dtw_distance = zeros(samples_t,samples_r);
%     tic;
%     for i=1:samples_t
%         for j=1:samples_r
%             fprintf ('the %d/%d--%d recognition for integral descriptor...%2.2f%%\n',i,j,samples_r*samples_t,(samples_r*(i-1)+j)*100/(samples_r*samples_t));
%             [dtw_distance(i,j), ~, ~]=dtw_adj_matching(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},50,3);
%         end   
%     end
%     [~,I] = min(dtw_distance,[],2); % sum up the recognition accurate ratio
%     confusion_matrix = zeros(CLASS_NUM,CLASS_NUM);
%     for i = 1:CLASS_NUM
%         for j = 1:CLASS_NUM
%             confusion_matrix(i,j) = length(find(testGID == i & trainGID(I) == j));
%         end
%     end
%     sum_time_svm = toc;
%     compu_time_svm(experiment_num) = sum_time_svm/samples_t;
% 
%     recog_ratio_interg(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:))   %#ok<NOPTS>
%     recog_ratio_final_interg = mean(recog_ratio_interg) %#ok<NOPTS>
%     confusion_matrix_interg{1,experiment_num} = confusion_matrix;
%     distance_matrix_interg{1,experiment_num} = dtw_distance; 
    %% implement recognition using differential invariants
%     fprintf ('get the database descriptor for root trajectory...\n');
%     gene_descriptor_diff(ROOT);
%     fprintf ('get the samples descriptor for root trajectory...\n');
%     gene_descriptor_diff_samples(ROOT);
%     load ([ROOT '_des.mat']);
%     load ([ROOT 'samples_des.mat']);
%     samples_r=size(TRAJDB,2);
%     samples_t=size(TRAJSAMPLES,2);
%     dtw_distance = zeros(samples_t,samples_r);
%     tic;
%     for i=1:samples_t
%         for j=1:samples_r
%             fprintf ('the %d/%d--%d recognition for differential descriptor...%2.2f%%\n',i,j,samples_r*samples_t,(samples_r*(i-1)+j)*100/(samples_r*samples_t));
%             [dtw_distance(i,j), ~, ~]=dtw_adj_matching(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},50,3);
% %             [dtw_distance(i,j), ~, ~]=dtw_adj_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},80); 
%         end   
%     end
%     dtw_distance = exp(-gamma*dtw_distance); %% tranform to Likelihood of dtw distance -- Perry 28/05/2013
%     dtw_distance = dtw_distance./repmat(sum(dtw_distance,2),1, samples_r);%% softmax of dtw distance -- Perry 28/05/2013
%     [~,I]=max(dtw_distance,[],2); % sum up the recognition accurate ratio
%     
%     confusion_matrix = zeros(CLASS_NUM,CLASS_NUM);
%     for i = 1:CLASS_NUM
%         for j = 1:CLASS_NUM
%             confusion_matrix(i,j) = length(find(testGID == i & trainGID(I) == j));
%         end
%     end
%     sum_time_diff = toc;
%     compu_time_diff(experiment_num) = sum_time_diff/samples_t;
%     
%     recog_ratio_diff(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:));
%     recog_ratio_final_diff = mean(recog_ratio_diff) %#ok<NOPTS>
%     confusion_matrix_diff{1,experiment_num} = confusion_matrix;
%     distance_matrix_diff{1,experiment_num} = dtw_distance;
    
    %% SVM-BoF using DI 
    fprintf ('get the database descriptor for root trajectory...\n');
    gene_descriptor_diff(ROOT);
    fprintf ('get the samples descriptor for root trajectory...\n');
    gene_descriptor_diff_samples(ROOT);
    load ([ROOT '_des.mat']);
    load ([ROOT 'samples_des.mat']);
%     
    load ([ROOT,'.mat']);load ([ROOT,'samples.mat']);
    [trainGID,testGID]=construct_ID(TRAJDB,TRAJSAMPLES);
    numTrain = length(trainGID);numTest = length(testGID);
    ntotalbh = 2; % l = 0,1,2,3 (L=3) blocks are 2^(l) 


	% temporal pyramid matching based on intersection Histograms
%     ntotalbh = 5; % BoF when ntotalbh = 1;
% 	[traindata,testdata,sum_BoF_time] = gene_codebook(TRAJDB_DES,TRAJSAMPLES_DES,ntotalbh);
%     compu_time_bof(experiment_num) =sum_BoF_time/size(testdata,1);
    
    
    % temporal pyramid matching kernels
    [traindata,testdata,sum_BoF_time,num_words] = gene_codebook_pyramid(TRAJDB_DES,TRAJSAMPLES_DES,ntotalbh);
    compu_time_bof(experiment_num) =sum_BoF_time/size(testdata,1);
    
    % temporal pyramid baded on spooling sparce coding
%     [traindata,testdata,sum_ScSPM_time] = gene_codebook_ScSPM(TRAJDB_DES,TRAJSAMPLES_DES,ntotalbh);
%     compu_time_bof(experiment_num) =sum_ScSPM_time/size(testdata,1);
    
    %%%%%%%%%%% using predefined kernels%%%%%%%%%%%%%%%%%%%%%
    
    % norm1 distance
%     Svm_kernel = @(X,Y)distance_matrix_norm1(X,Y);
%     K =  [ (1:numTrain)' , Svm_kernel(traindata,traindata) ];
%     KK = [ (1:numTest)'  , Svm_kernel(testdata,traindata)  ];

    % chi-square statistic
%     dist_func=@chi_square_statistics_fast; 
%     K =  [ (1:numTrain)' , pdist2(traindata,traindata,dist_func) ];
%     model = svmtrain(trainGID,K,'-t 4 -b 1');
%     tic;
%     KK = [ (1:numTest)'  , pdist2(testdata,traindata,dist_func)  ];
%     [predict_label, accuracy, dec_values] = svmpredict(testGID,KK, model,'-b 1');
%     sum_time_svm = toc;
%     compu_time_svm(experiment_num) =sum_time_svm/size(testdata,1);

    % cityblock, norm1
%     K =  [ (1:numTrain)' , pdist2(traindata,traindata,'cityblock') ];
%     KK = [ (1:numTest)'  , pdist2(testdata,traindata,'cityblock')  ];
     
    
    % Pyramid Matching kernel
    
    Pyramid_kernel = @(X,Y)PyramidMatching(X,Y,ntotalbh,num_words);
    K =  [ (1:numTrain)' , Pyramid_kernel(traindata,traindata) ];
    model = svmtrain(trainGID,K,'-t 4 -b 1');
    
    tic;
    KK = [ (1:numTest)'  , Pyramid_kernel(testdata,traindata)  ];
	[predict_label, accuracy, dec_values] = svmpredict(testGID,KK, model,'-b 1');
    sum_time_svm = toc;
    compu_time_svm(experiment_num) =sum_time_svm/size(testdata,1);
    
    %%%%%%%%%%% using linear kernels based on ScSPM%%%%%%%%%%%%%%%%%%%%%
    
%     lambda = 0.1;     % regularization parameter for w
%     [w, b, class_name] = li2nsvm_multiclass_lbfgs(traindata',trainGID, lambda);
%     
%     tic;
%     [predict_label, ~] = li2nsvm_multiclass_fwd(testdata', w, b, class_name);
%     sum_time_svm = toc;
%     compu_time_svm(experiment_num) =sum_time_svm/size(testdata,1);


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
%     
    recog_ratio_diff(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:));
    recog_ratio_final_diff = mean(recog_ratio_diff) %#ok<NOPTS>
    confusion_matrix_diff{1,experiment_num} = confusion_matrix;
    %% save the results
%     if recog_ratio_diff(experiment_num) - recog_ratio_interg(experiment_num) >0.08
%         pause
%     end
    delete *.mat;
    save  RECOGNITION_TALBLE_INTERG distance_matrix_diff distance_matrix_interg;
    save  RECOGNITION_RATIO confusion_matrix_diff confusion_matrix_interg recog_ratio_interg...
          recog_ratio_diff compu_time_svm compu_time_diff compu_time_bof;%recog_ratio_svm;
    clearvars -except class_num BAT_FOLDER EXPERIMENT_PARA experiment_num EXPERIMENT_TIMES...
              gamma CLASS_SELECTED SAMPLES_NUM CLASS_NUM noise_level joints_no esemble_no ROOT;
    load RECOGNITION_RATIO; load RECOGNITION_TALBLE_INTERG;
end
% close(h);
fprintf('Recognition task has completed!\n');
fclose('all');
clear all;


