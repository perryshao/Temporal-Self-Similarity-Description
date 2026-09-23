function gene_descriptor(marker)
if nargin == 1

    fileprefix = '.mat';
    matfilename = [marker fileprefix];
    if exist(matfilename, 'file')
        load(matfilename);
    else
        fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
    end
    fileextend = '_DES.mat';
    matfilename = [marker fileextend];
    %% read joint 3D data with matrix format and get the descriptor
    samples = size(TRAJDB, 2);
    TRAJDB_DES = cell (1, samples);
    for i = 1:samples
        marker_xyz = double(TRAJDB{2, i});
        % [marker_xyz,stapoint_index] = remove_stapoint(marker_xyz); % cannot eliminate the static points
        fprintf ('%d of %d differential descriptor...\n', i, samples);
        marker_des = descriptor_comp(marker_xyz);
        TRAJDB_DES{1, i} = marker_des;
    end
    save(matfilename, 'TRAJDB_DES');
else

    if exist('tsddb.mat', 'file')
        load tsddb;
    else
        fprintf ('Error, there are not existing database, lack of load_tsd() funcition');
    end
    samples = size(TSDDB, 2);
    TSDDB_DES = cell (2, samples);
    for i = 1:samples
        right_xyz = double(TSDDB{2, i}); % right hand xyz position
        left_xyz = double(TSDDB{3, i}); % left hand xyz position
        right_xyz = remove_stapoint(right_xyz);
        right_des = descriptor_comp(right_xyz);
        left_xyz = remove_stapoint(left_xyz);
        left_des = descriptor_comp(left_xyz);
        TSDDB_DES{1, i} = left_des;
        TSDDB_DES{2, i} = right_des;
    end
    save('tsddb_des', 'TSDDB_DES');
end
