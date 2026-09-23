function ensemble_bat(joints_no)


%% dbs
load([joints_no{1,1} '.mat']);
samples=size(TRAJDB,2);
m_num = length(joints_no);
for j=1:m_num
    load([joints_no{1,j} '.mat']);
    eval([strcat('DB_',joints_no{1,j}) '=TRAJDB;']); % LWRA curve
end
%% average all the joints into one trajectory
TRAJDB = cell(1,samples);
for i=1:samples
	fprintf ('get the ensemble trajectory %d/%d...\n',i,samples);
    ensemble_curve = 0;
    for j=1:m_num
        eval(['relative_curve=' strcat('DB_',joints_no{1,j}) '{2,i};']);
        ensemble_curve = relative_curve+ensemble_curve;
    end
    eval(['TRAJDB{1,i}=' strcat('DB_',joints_no{1,1}) '{1,i};']);
    TRAJDB{2,i} = ensemble_curve/m_num;
end
save ENSEMBLE TRAJDB;

%% concatenate all the joints into one trajectory
% TRAJDB = cell(1,samples);
% for i=1:samples
% 	fprintf ('get the ensemble trajectory %d/%d...\n',i,samples);
%     ensemble_curve = [];
%     for j=1:m_num
%         eval(['relative_curve=' strcat('DB_',joints_no{1,j}) '{2,i};']);
%         ensemble_curve = [ensemble_curve;relative_curve];
%     end
%     eval(['TRAJDB{1,i}=' strcat('DB_',joints_no{1,1}) '{1,i};']);
%     TRAJDB{2,i} = ensemble_curve;
% end
% save ENSEMBLE TRAJDB;

%% samples
load([joints_no{1,1} 'samples.mat']);
samples=size(TRAJSAMPLES,2);
for j=1:m_num
    load([joints_no{1,j} 'samples.mat']);
    eval([strcat('SAMPLES_',joints_no{1,j}) '=TRAJSAMPLES;']); % LWRA curve
end

%% average all the joints into one trajectory
TRAJSAMPLES = cell(1,samples);      
for i=1:samples
	fprintf ('get the sample ensemble trajectory %d/%d...\n',i,samples);
    ensemble_curve = 0;
    for j=1:m_num
        eval(['relative_curve=' strcat('SAMPLES_',joints_no{1,j}) '{2,i};']);
        ensemble_curve = relative_curve+ensemble_curve;
    end
    eval(['TRAJSAMPLES{1,i}=' strcat('SAMPLES_',joints_no{1,1}) '{1,i};']);
    TRAJSAMPLES{2,i} = ensemble_curve/m_num;
end
save ENSEMBLEsamples TRAJSAMPLES;

%% concatenate all the joints into one trajectory
% TRAJSAMPLES = cell(1,samples);      
% for i=1:samples
% 	fprintf ('get the sample ensemble trajectory %d/%d...\n',i,samples);
%     ensemble_curve = [];
%     for j=1:m_num
%         eval(['relative_curve=' strcat('SAMPLES_',joints_no{1,j}) '{2,i};']);
%         ensemble_curve = [ensemble_curve;relative_curve];
%     end
%     eval(['TRAJSAMPLES{1,i}=' strcat('SAMPLES_',joints_no{1,1}) '{1,i};']);
%     TRAJSAMPLES{2,i} = ensemble_curve;
% end
% save ENSEMBLEsamples TRAJSAMPLES;

for j=1:m_num-1
    eval(['clear ' strcat('SAMPLES_',joints_no{1,j})]); % LWRA curve
    eval(['clear ' strcat('DB_',joints_no{1,j})]); % LWRA curve
end

