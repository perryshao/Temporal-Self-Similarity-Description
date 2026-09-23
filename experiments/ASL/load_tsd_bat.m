function load_tsd_bat(markers, random_seed, CLASS_SELECTED, BAT_FOLDER)

file_ext = '.tsd';
fileprefix = '.mat';
samplesfileprefix = 'samples.mat';
db_i = 0; samples_i = 0;
marker_num = size(markers, 2);
%% read random db data from class folder
folder_content = dir(BAT_FOLDER);
class_num = size(folder_content, 1);
class_selected_num = size(CLASS_SELECTED, 2);
for n = 3:class_num % 2 class recognition, you can define it arbitrarily
    flag_class_num = CLASS_SELECTED-ones(1, class_selected_num)*(n-2);
    if all(flag_class_num)==0
        if folder_content(n, 1).isdir==1
            class_folder = folder_content(n, 1).name %#ok<NOPRT>
            data_folder = [BAT_FOLDER class_folder '/'];
            class_folder_content = dir ([data_folder, '*', file_ext]);
            ndata = size (class_folder_content, 1);

            rand('state', sum(100*clock)); %#ok<RAND>
            randn('state', sum(100*clock)); %#ok<RAND>
            random_db = randperm(ndata, ceil(ndata/2));
            % random_db=round(random_seed*ndata);
            % random_db(find(random_db==0))=1; %#ok<FNDSB>
            % random_db(find(random_db>ndata))=ndata; %#ok<FNDSB>
            random_db_length = size(random_db, 2);

            TRAJDB_temp = cell (2, marker_num*random_db_length);
            TRAJSAMPLES_temp = cell (2, marker_num*(ndata-random_db_length));
            for k = 1:ndata;

                string = [data_folder, class_folder_content(k, 1).name];
                fprintf ('Loading tsd data...\n');
                %%  Begin reading loop for tsd files
                fid = fopen(string);
                i = 1;
                mk = []; % casue high accuracy in recognition
                while ~feof(fid)
                    tline = fgetl(fid);
                    tline = str2num(tline);
                    mk(i, :) = tline;
                    i = i+1;
                end
                fclose(fid);
                %% detect and distinguish the db and samples data.
                flag_samples_num = unique(random_db)-ones(1, random_db_length)*k;

                if all(flag_samples_num)==0
                    db_i = db_i+1;
                else
                    samples_i = samples_i+1;
                end
                TRAJDB_temp_i = (db_i-1)*marker_num;
                TRAJSAMPLES_temp_i = (samples_i-1)*marker_num;

                %% get required hand 3D data
                for i = 1:marker_num
                    %% detect and distinguish the db and samples data.
                    if all(flag_samples_num)==0
                        TRAJDB_temp{1, TRAJDB_temp_i+i} = string;
                        if i == 1
                            TRAJDB_temp{2, TRAJDB_temp_i+i} = mk(:, 1:3)*10e3; % right hand position
                        elseif i == 2
                            TRAJDB_temp{2, TRAJDB_temp_i+i} = mk(:, 12:14)*10e3; % left hand position
                        end
                    else
                        TRAJSAMPLES_temp{1, TRAJSAMPLES_temp_i+i} = string;
                        if i == 1
                            TRAJSAMPLES_temp{2, TRAJSAMPLES_temp_i+i} = mk(:, 1:3)*10e3; % right hand position
                        elseif i == 2
                            TRAJSAMPLES_temp{2, TRAJSAMPLES_temp_i+i} = mk(:, 12:14)*10e3; % left hand position
                        end
                    end
                end
            end

            for i = 1:marker_num
                matfilename = [markers{i} fileprefix];
                if exist(matfilename, 'file')
                    load(matfilename);
                else
                    TRAJDB = cell (2, []);
                end
                %% identify whether there have a mat file in samples
                matfilename = [markers{i} samplesfileprefix];
                if exist(matfilename, 'file')
                    load(matfilename);
                else
                    TRAJSAMPLES = cell (2, []);
                end
                TRAJDB(1:2, end+1:end+db_i) = [TRAJDB_temp(1, i:marker_num:end);TRAJDB_temp(2, i:marker_num:end)];
                TRAJSAMPLES(1:2, end+1:end+samples_i) = [TRAJSAMPLES_temp(1, i:marker_num:end);TRAJSAMPLES_temp(2, i:marker_num:end)];
                save(markers{i}, 'TRAJDB');
                save(matfilename, 'TRAJSAMPLES');
            end

            db_i = 0; samples_i = 0;
        end
    end
end
fclose('all');
