function load_txt_bat(joints_no,CLASS_SELECTED,BAT_FOLDER)
file_ext = '.txt';
fileprefix='.mat';
samplesfileprefix='samples.mat';
db_i = 0; samples_i = 0;class_i = 0;
joints_num = size(joints_no,2);
joints = zeros(1,joints_num);
for i = 1:joints_num
     joints(1,i) = str2double(joints_no{i});
end
joints_no = joints;
clear joints
%% read random db data from class folder
folder_content = dir(BAT_FOLDER);
class_num=size(folder_content,1);
class_selected_num=size(CLASS_SELECTED,2);

for n = 3:class_num  % 2 class recognition, you can define it arbitrarily  
    flag_class_num=CLASS_SELECTED-ones(1,class_selected_num)*(n-2);
    if all(flag_class_num)==0
        class_i = class_i+1;
        if folder_content(n,1).isdir==1
            class_folder = folder_content(n,1).name;
            data_folder=[BAT_FOLDER class_folder '/'];
            class_folder_content = dir ([data_folder,'*',file_ext]);
            ndata = size (class_folder_content,1);
            
            rand('state',sum(100*clock)); %#ok<RAND>
			randn('state',sum(100*clock)); %#ok<RAND>
			random_db = randperm(ndata,ceil(ndata/2));      
            random_db_length = size(random_db,2);
            
            TRAJDB_temp = cell (2,joints_num*random_db_length);
            TRAJSAMPLES_temp = cell (2,joints_num*(ndata-random_db_length)); 
            
            for k=1:ndata;
                string= [data_folder,class_folder_content(k,1).name]; 
                fprintf ('Loading txt data...%s\n',string);                
               %% read the bvh files
                txt_data = load(string);
                txt_data(:,4:4:80) = [];
                joints_index = (joints_no-1)*3+1;
                %% detect and distinguish the db and samples data.
                flag_samples_num=random_db-ones(1,random_db_length)*k;  

                if all(flag_samples_num)==0
                    db_i = db_i+1;
                else
                    samples_i = samples_i+1;
                end
                TRAJDB_temp_i = (db_i-1)*joints_num;
                TRAJSAMPLES_temp_i = (samples_i-1)*joints_num;
               %% get required txt joint 3D data
                for i = 1:joints_num
                    %% detect and distinguish the db and samples data. 
                    if all(flag_samples_num) == 0
                        TRAJDB_temp{1,TRAJDB_temp_i+i}= string;
                        TRAJDB_temp{2,TRAJDB_temp_i+i} = txt_data(:,joints_index(i):joints_index(i)+2); 
                    else
                        TRAJSAMPLES_temp{1,TRAJSAMPLES_temp_i+i}=string;
                        TRAJSAMPLES_temp{2,TRAJSAMPLES_temp_i+i} = txt_data(:,joints_index(i):joints_index(i)+2); 
                    end
                end
            end
                        

            for i  = 1:joints_num,

                matfilename=[num2str(joints_no(i)) fileprefix];
                if exist(matfilename,'file')
                    load(matfilename);
                else
                    TRAJDB = cell(2,[]);
                end          
                    matfilename=[num2str(joints_no(i)) samplesfileprefix];
                if exist(matfilename,'file'),
                    load(matfilename);
                else
                    TRAJSAMPLES = cell(2,[]);
                end
                TRAJDB(1:2,end+1:end+db_i) = [TRAJDB_temp(1,i:joints_num:end);TRAJDB_temp(2,i:joints_num:end)];   
                TRAJSAMPLES(1:2,end+1:end+samples_i) = [TRAJSAMPLES_temp(1,i:joints_num:end);TRAJSAMPLES_temp(2,i:joints_num:end)];  
                save(num2str(joints_no(i)),'TRAJDB');
                save(matfilename,'TRAJSAMPLES');    
            end
           
            db_i = 0; samples_i = 0;
           
        end
    end
%     closec3d(itf);
end


fclose('all');




