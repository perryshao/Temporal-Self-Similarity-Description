function [subjectID_DB, subjectID_SAMPLES] = shuffle_db(joints_no, shuffle_sort)
%SHUFFLE_DB  Re-split training and test sets by subject.
%   [SUBJECTID_DB, SUBJECTID_SAMPLES] = SHUFFLE_DB(JOINTS_NO, SHUFFLE_SORT)
%   reads the subject number encoded in each file path and, for every joint,
%   rewrites <JOINT>.mat with the samples of the subjects in SHUFFLE_SORT(1,:)
%   and <JOINT>samples.mat with those in SHUFFLE_SORT(2,:).

%% look for the index of whole dataset
load([joints_no{1, 1} '.mat']);
load([joints_no{1, 1} 'samples.mat']);
samples_r = size(TRAJDB, 2);
samples_t = size(TRAJSAMPLES, 2);
r_rows = zeros(1, samples_r);
for i = 1:samples_r
    directory_loca = find(TRAJDB{1, i} == '/');
    TEMP(i, :) = TRAJDB{1, i}(directory_loca(2)+1);
end
subjectID_DB = str2num(TEMP);
tempTRAJDB = cell(2, []);
for i = 1:samples_t
    directory_loca = find(TRAJSAMPLES{1, i} == '/');
    TEMP(i, :) = TRAJSAMPLES{1, i}(directory_loca(2)+1);
end
subjectID_SAMPLES = str2num(TEMP);
joints_num = size(joints_no, 2);
for n = 1:joints_num
    %% load training and sampling mat files of corresponding marker
    tempTRAJDB = cell(2, []);
    tempTRAJSAMPLES = cell(2, []);
    matfilename_db = [joints_no{1, n} '.mat'];
    if exist(matfilename_db, 'file')
        load(matfilename_db);
    else
        fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
    end

    matfilename_samples = [joints_no{1, n} 'samples.mat'];
    if exist(matfilename_samples, 'file')
        load(matfilename_samples);
    else
        fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d_samples() funcition');
    end
    samples_r = size(TRAJDB, 2);
    samples_t = size(TRAJSAMPLES, 2);
    %% COLLECTING TRAINNING
    for i = 1:samples_r
        if any(shuffle_sort(1, :) == subjectID_DB(i))
            tempTRAJDB{1, end+1} = TRAJDB{1, i};
            tempTRAJDB{2, end} = TRAJDB{2, i};
        end
    end

    for i = 1:samples_t
        if any(shuffle_sort(1, :) == subjectID_SAMPLES(i))
            tempTRAJDB{1, end+1} = TRAJSAMPLES{1, i};
            tempTRAJDB{2, end} = TRAJSAMPLES{2, i};
        end
    end

    %% COLLECTING SAMPLES

    for i = 1:samples_r
        if any(shuffle_sort(2, :) == subjectID_DB(i))
            tempTRAJSAMPLES{1, end+1} = TRAJDB{1, i};
            tempTRAJSAMPLES{2, end} = TRAJDB{2, i};
        end
    end

    for i = 1:samples_t
        if any(shuffle_sort(2, :) == subjectID_SAMPLES(i))
            tempTRAJSAMPLES{1, end+1} = TRAJSAMPLES{1, i};
            tempTRAJSAMPLES{2, end} = TRAJSAMPLES{2, i};
        end
    end
    %% save as mat files
    TRAJDB = tempTRAJDB;
    save(matfilename_db, 'TRAJDB');
    TRAJSAMPLES = tempTRAJSAMPLES;
    save(matfilename_samples, 'TRAJSAMPLES');
end
