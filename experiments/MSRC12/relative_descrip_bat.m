function [INTEGRATE_DES, INTEGRATESAMPLES_DES] = relative_descrip_bat(joints_no, marker)

%% dbs
load([marker '.mat']);
ROOTDB = TRAJDB; % HEAD curve as root trajectory here
samples = size(ROOTDB, 2);
INTEGRATE_DES = cell(1, samples);
m_num = length(joints_no);
for j = 1:m_num
    load([joints_no{1, j} '.mat']);
    eval([strcat('DB_', joints_no{1, j}) '=TRAJDB;']); % LWRA curve
end

for i = 1:samples
    fprintf ('get the relative descriptor %d/%d...\n', i, samples);
    root_curve = ROOTDB{2, i};
    for j = 1:m_num
        eval(['relative_curve=' strcat('DB_', joints_no{1, j}) '{2,i};']);
        [orientation, r] = gene_relative_descrip(root_curve, relative_curve); % get relative curve description
        INTEGRATE_DES{1, i}(:, end+1:end+3) = [orientation, r];
        % if j<=4
        %     INTEGRATE_DES{1,i}(:,end+1:end+2) = orientation;
        % else
        %     INTEGRATE_DES{1,i}(:,end+1:end+3) = [orientation,r];
        % end
        %
        % INTEGRATE_DES{1,i}(:,end+1:end+4) = [sin(orientation(:,1)).*cos(orientation(:,2))...
        %     sin(orientation(:,1)).*sin(orientation(:,2)) cos(orientation(:,1)) r];
    end
end

%% samples
load([marker 'samples.mat']);
ROOTSAMPLES = TRAJSAMPLES;
samples = size(ROOTSAMPLES, 2);
INTEGRATESAMPLES_DES = cell(1, samples);
for j = 1:m_num
    load([joints_no{1, j} 'samples.mat']);
    eval([strcat('SAMPLES_', joints_no{1, j}) '=TRAJSAMPLES;']); % LWRA curve
end

for i = 1:samples
    fprintf ('get the samples relative descriptor %d/%d...\n', i, samples);
    root_curve = ROOTSAMPLES{2, i};
    for j = 1:m_num
        eval(['relative_curve=' strcat('SAMPLES_', joints_no{1, j}) '{2,i};']);
        [orientation, r] = gene_relative_descrip(root_curve, relative_curve); % get relative curve description
        INTEGRATESAMPLES_DES{1, i}(:, end+1:end+3) = [orientation, r];
        % if j<=4
        %     INTEGRATESAMPLES_DES{1,i}(:,end+1:end+2) = orientation;
        % else
        %     INTEGRATESAMPLES_DES{1,i}(:,end+1:end+3) = [orientation,r];
        % end

        % INTEGRATESAMPLES_DES{1,i}(:,end+1:end+4) = [sin(orientation(:,1)).*cos(orientation(:,2))...
        %     sin(orientation(:,1)).*sin(orientation(:,2)) cos(orientation(:,1)) r];

    end
end
for j = 1:m_num
    eval(['clear ' strcat('SAMPLES_', joints_no{1, j})]); % LWRA curve
    eval(['clear ' strcat('DB_', joints_no{1, j})]); % LWRA curve
end
