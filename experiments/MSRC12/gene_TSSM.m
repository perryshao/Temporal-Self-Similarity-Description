function [traindata, testdata, trainGID,testGID]= gene_TSSM(TRAJDB,TRAJSAMPLES,...
                              TRAJDB_DES,TRAJSAMPLES_DES,INTEGRATE_DES,INTEGRATESAMPLES_DES)
samples_r = size(TRAJDB,2);
samples_t = size(TRAJSAMPLES,2); 
trainGID = zeros(samples_r,1);
testGID = zeros(samples_t,1);
for i=1:samples_r   
       directory_loca=find(TRAJDB{1,i}=='/');
       TRAJDB{1,i}=TRAJDB{1,i}(1:directory_loca(2));
       trainGID(i)= str2double(TRAJDB{1,i}(end-2:end-1));
end
for i=1:samples_t   
        directory_loca=find(TRAJSAMPLES{1,i}=='/');
       TRAJSAMPLES{1,i}=TRAJSAMPLES{1,i}(1:directory_loca(2));
       testGID(i)= str2double(TRAJSAMPLES{1,i}(end-2:end-1));
end
train_num = length(trainGID);
traindata = cell(1,train_num);
%% Self-similarity descriptor

for i = 1:train_num
    fprintf ('%d of %d ssm descriptor...\n',i,train_num);
    des = [TRAJDB_DES{1,i} INTEGRATE_DES{1,i}];
    TSSM = Temporal_SSMofHierarD(des,0);
    Image_TSSM = TSSM;
    Image_TSSM = floor((Image_TSSM/max(max(Image_TSSM)))*(2^16-1));
    %%%%%%%%%%%%%%%%% HOG of SSM %%%%%%%%%%%%%%%%%
    ssm_des  =   Log_hogcalculator(Image_TSSM);
    %     ssm_des  = LocalSsmcalculatorSameBlock(Image_TSSM);
    %%%%%%%%%%%%%%%%% max(variance) of SSM %%%%%%%%%%%%%%%%%
    %     ssm_des  = [marker_des(2+1:end-2,:) LocalSsmcalculator(Image_TSSM)];
%         ssm_des  = LocalSsmcalculator(Image_TSSM);
    traindata{1,i} =  ssm_des;
end
test_num=length(testGID);
% testdata = zeros(1,dim_root+dim_orien+1,class);
testdata = cell(1,test_num);

for i= 1:test_num
    fprintf ('%d of %d samples ssm descriptor...\n',i,test_num);
    des = [TRAJSAMPLES_DES{1,i} INTEGRATESAMPLES_DES{1,i}];
    TSSM = Temporal_SSMofHierarD(des,0);
    Image_TSSM = TSSM;
    Image_TSSM = floor((Image_TSSM/max(max(Image_TSSM)))*(2^16-1));
    %%%%%%%%%%%%%%%%% HOG of SSM %%%%%%%%%%%%%%%%%
    ssm_des  =   Log_hogcalculator(Image_TSSM);
    %     ssm_des  = LocalSsmcalculatorSameBlock(Image_TSSM);
    %%%%%%%%%%%%%%%%% max(variance) of SSM %%%%%%%%%%%%%%%%%
    %     ssm_des  = [marker_des(2+1:end-2,:) LocalSsmcalculator(Image_TSSM)];
%         ssm_des  = LocalSsmcalculator(Image_TSSM);
    testdata{1,i} =  ssm_des;
end

       
