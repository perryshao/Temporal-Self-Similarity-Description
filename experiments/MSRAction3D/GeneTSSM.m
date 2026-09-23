function [TSSMDB_HOG, TSSMSAMPLES_HOG, trainGID,testGID]= GeneTSSM(joints_no)

%% dbs: ensemble the joints in terms of the joint grouping 
% load([joints_no{1,1} '.mat']);
% samples = size(TRAJDB,2);
% groupNum = size(joints_no,1);
% ENSEMBLE = cell(size(joints_no,2),samples);
% 
% for n = 1:groupNum
%     m_num = length(joints_no(n,:));
%     for j=1:m_num
%         load([joints_no{n,j} '.mat']);
%         eval([strcat('DB_',joints_no{n,j}) '=TRAJDB;']); 
%     end
% 
%     for i=1:samples
%         fprintf ('get the %dth ensemble trajectory %d/%d...\n',n,i,samples);
%         ensemble_curve = 0;
%         for j=1:m_num
%             eval(['relative_curve=' strcat('DB_',joints_no{n,j}) '{2,i};']);
%             ensemble_curve = relative_curve+ensemble_curve;
%         end
%         ENSEMBLE{n,i} = ensemble_curve/m_num;
%     end
% end
% save ENSEMBLE ENSEMBLE;
% 
% %% samples
% load([joints_no{1,1} 'samples.mat']);
% samples = size(TRAJSAMPLES,2);
% ENSEMBLE_SAMPLES = cell(size(joints_no,2),samples);
% 
% for n = 1:groupNum
%     load([joints_no{n,1} 'samples.mat']);
%     m_num = length(joints_no(n,:));
%     for j=1:m_num
%         load([joints_no{n,j} 'samples.mat']);
%         eval([strcat('SAMPLES_',joints_no{n,j}) '=TRAJSAMPLES;']); 
%     end
% 
%     for i=1:samples
%         fprintf ('get the %dth sample ensemble trajectory %d/%d...\n',n,i,samples);
%         ensemble_curve = 0;
%         for j=1:m_num
%             eval(['relative_curve=' strcat('SAMPLES_',joints_no{n,j}) '{2,i};']);
%             ensemble_curve = relative_curve+ensemble_curve;
%         end
%         ENSEMBLE_SAMPLES{n,i} = ensemble_curve/m_num;
%     end
% end
% save ENSEMBLE_SAMPLES ENSEMBLE_SAMPLES;

%% dbs:compare the differences between each joint and its nearest neighboring joint
load([joints_no{1,1} '.mat']);
samples_r = size(TRAJDB,2);
groupNum = size(joints_no,1);
ENSEMBLE = cell(size(joints_no,2),samples_r);

for n = 1:groupNum
    m_num = length(joints_no(n,:));
    for j=1:m_num
        load([joints_no{n,j} '.mat']);
        eval([strcat('DB_',joints_no{n,j}) '=TRAJDB;']); 
    end

    for i=1:samples_r
        fprintf ('get the %dth ensemble trajectory %d/%d...\n',n,i,samples_r);
        ensemble_curve = 0;
        for j=m_num:-1:1
            eval(['relative_curve=' strcat('DB_',joints_no{n,j}) '{2,i};']);
            ensemble_curve = relative_curve-ensemble_curve;
        end
        % position normalization
        rowNorm= pdist2(ensemble_curve,[0 0 0]);
        ENSEMBLE{n,i} = ensemble_curve./repmat(rowNorm,1,size(ensemble_curve,2));
    end
end
save ENSEMBLE ENSEMBLE;

%% samples
load([joints_no{1,1} 'samples.mat']);
samples_t = size(TRAJSAMPLES,2);
ENSEMBLE_SAMPLES = cell(size(joints_no,2),samples_t);

for n = 1:groupNum
    load([joints_no{n,1} 'samples.mat']);
    m_num = length(joints_no(n,:));
    for j=1:m_num
        load([joints_no{n,j} 'samples.mat']);
        eval([strcat('SAMPLES_',joints_no{n,j}) '=TRAJSAMPLES;']); 
    end

    for i=1:samples_t
        fprintf ('get the %dth sample ensemble trajectory %d/%d...\n',n,i,samples_t);
        ensemble_curve = 0;
        for j=m_num:-1:1
            eval(['relative_curve=' strcat('SAMPLES_',joints_no{n,j}) '{2,i};']);
            ensemble_curve = relative_curve-ensemble_curve;
        end
        % position normalization
        rowNorm= pdist2(ensemble_curve,[0 0 0]);
        ENSEMBLE_SAMPLES{n,i} = ensemble_curve./repmat(rowNorm,1,size(ensemble_curve,2));
    end
end
save ENSEMBLE_SAMPLES ENSEMBLE_SAMPLES;

%% Self-similarity descriptor
TSSMDB_HOG = cell (1,samples_r);
for i = 1:samples_r
    fprintf ('%d of %d SSM descriptor...\n',i,samples_r);
    rows = size(ENSEMBLE{1,i},1);
    tempHog = zeros(rows*groupNum,150);
    tempSkeleton = zeros(rows*groupNum,3);
    for n = 1:groupNum
        trajectory = ENSEMBLE{n,i};
        desMatrix = trajectory;
        Image_TSSM = Temporal_SSM(desMatrix,5,1,1,0.25); %trajectory,descrip_flag,kernel,belta,c
        Image_TSSM(Image_TSSM <=0) = 0;
%         Image_TSSM = floor(Image_TSSM*(2^16-1));
        Image_TSSM = floor((Image_TSSM/max(max(Image_TSSM)))*(2^16-1));
        Image_TSSM(isnan(Image_TSSM)) = 0;
        ssmDes = Log_hogcalculator(Image_TSSM);
        tempHog((n-1)*rows+1:n*rows,:) =  ssmDes;
        tempSkeleton((n-1)*rows+1:n*rows,:) = trajectory;
%         tempHog((n-1)*rows+1:n*rows,:) =  [ssmDes ENSEMBLE{n,i}];
    end
    TSSMDB_HOG{1,i} =  tempHog ; 
    TSSMDB_SKELETON{1,i} =  tempSkeleton; 
end
save TSSMDB_HOG TSSMDB_HOG;
save TSSMDB_SKELETON TSSMDB_SKELETON;

TSSMSAMPLES_HOG = cell (1,samples_t);
for i= 1:samples_t
    fprintf ('%d of %d samples SSM descriptor...\n',i,samples_t);
    rows = size(ENSEMBLE_SAMPLES{1,i},1);
    tempHog = zeros(rows*groupNum,150);
    tempSkeleton = zeros(rows*groupNum,3);
    for n = 1:groupNum
        trajectory = ENSEMBLE_SAMPLES{n,i};
        desMatrix = trajectory;
        Image_TSSM = Temporal_SSM(desMatrix,5,1,1,0.25); 
        Image_TSSM(Image_TSSM <=0) = 0;
%          Image_TSSM = floor(Image_TSSM*(2^16-1));
        Image_TSSM = floor((Image_TSSM/max(max(Image_TSSM)))*(2^16-1));
        Image_TSSM(isnan(Image_TSSM)) = 0;
        ssmDes = Log_hogcalculator(Image_TSSM);
        tempHog((n-1)*rows+1:n*rows,:) =  ssmDes;
        tempSkeleton((n-1)*rows+1:n*rows,:) = trajectory;
%         tempHog((n-1)*rows+1:n*rows,:) =  [ssmDes ENSEMBLE_SAMPLES{n,i}];
    end
    TSSMSAMPLES_HOG{1,i} =  tempHog; 
    TSSMSAMPLES_SKELETON{1,i} =  tempSkeleton; 
end
save TSSMSAMPLES_HOG TSSMSAMPLES_HOG;
save TSSMSAMPLES_SKELETON TSSMSAMPLES_SKELETON;

       
