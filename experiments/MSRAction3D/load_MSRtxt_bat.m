function load_MSRtxt_bat(joints_no, BAT_FOLDER)
file_ext = '.txt';
fileprefix = '.mat';
samplesfileprefix = 'samples.mat';
db_i = 0; samples_i = 0;class_i = 0;
joints_no = reshape(joints_no, 1, size(joints_no, 1)*size(joints_no, 2));
joints_num = size(joints_no, 2);
joints = zeros(1, joints_num);
for i = 1:joints_num
    joints(1, i) = str2double(joints_no{i});
end
joints_no = joints;
clear joints
%% read random db data from class folder
folder_content = dir(BAT_FOLDER);
directory_num = size(folder_content, 1);
for n = 3:directory_num % 2 class recognition, you can define it arbitrarily
    class_i = class_i+1;
    if folder_content(n, 1).isdir == 1
        class_folder = folder_content(n, 1).name;
        data_folder = [BAT_FOLDER class_folder '/'];
        class_folder_content = dir ([data_folder, '*', file_ext]);
        ndata = size (class_folder_content, 1);

        if strcmp(class_folder, 'db')

            TRAJDB_temp = cell (2, joints_num*ndata);
        else

            TRAJSAMPLES_temp = cell (2, joints_num*ndata);
        end

        for k = 1:ndata;
            string = [data_folder, class_folder_content(k, 1).name];
            fprintf ('Loading txt data...%s\n', string);
            %% read the bvh files
            [X, Y, Z] = readMSRtxt(string);
            %% detect and distinguish the db and samples data.

            if strcmp(class_folder, 'db')
                db_i = db_i+1;
                TRAJDB_temp_i = (db_i-1)*joints_num;
            else
                samples_i = samples_i+1;
                TRAJSAMPLES_temp_i = (samples_i-1)*joints_num;
            end
            %% get required txt joint 3D data
            for i = 1:joints_num
                %% detect and distinguish the db and samples data.
                if strcmp(class_folder, 'db')

                    TRAJDB_temp{1, TRAJDB_temp_i+i} = string;
                    TRAJDB_temp{2, TRAJDB_temp_i+i} = [X(joints_no(i), :)' Y(joints_no(i), :)' Z(joints_no(i), :)'];
                else
                    TRAJSAMPLES_temp{1, TRAJSAMPLES_temp_i+i} = string;
                    TRAJSAMPLES_temp{2, TRAJSAMPLES_temp_i+i} = [X(joints_no(i), :)' Y(joints_no(i), :)' Z(joints_no(i), :)'];
                end
            end
        end
    end
    % closec3d(itf);
end

for i = 1:joints_num

    matfilename = [num2str(joints_no(i)) fileprefix];
    if exist(matfilename, 'file')
        load(matfilename);
    else
        TRAJDB = cell(2, []);
    end
    matfilename = [num2str(joints_no(i)) samplesfileprefix];
    if exist(matfilename, 'file')
        load(matfilename);
    else
        TRAJSAMPLES = cell(2, []);
    end
    TRAJDB(1:2, end+1:end+db_i) = [TRAJDB_temp(1, i:joints_num:end);TRAJDB_temp(2, i:joints_num:end)];
    TRAJSAMPLES(1:2, end+1:end+samples_i) = [TRAJSAMPLES_temp(1, i:joints_num:end);TRAJSAMPLES_temp(2, i:joints_num:end)];
    save(num2str(joints_no(i)), 'TRAJDB');
    save(matfilename, 'TRAJSAMPLES');
end

fclose('all');
