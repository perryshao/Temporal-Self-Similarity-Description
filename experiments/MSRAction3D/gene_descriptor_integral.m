function gene_descriptor_integral(marker)

fileprefix = '.mat';
matfilename = [marker fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
fileextend = '_DES.mat';
matfilename = [marker fileextend];
%% read joint 3D data with matrix format and get the descritor
samples = size(TRAJDB, 2);
TRAJDB_DES = cell (1, samples);
for i = 1:samples
    marker_xyz = double(TRAJDB{2, i});
    % [marker_xyz,stapoint_index] = remove_stapoint(marker_xyz); % cannot eliminate the static points
    fprintf ('%d of %d integral descriptor...\n', i, samples);
    % marker_des = integral_invariant(marker_xyz,6,0.05);
    marker_des = integral_invariant_kn(marker_xyz, 6, 5);
    marker_des = 0.5-marker_des;
    % marker_des= [marker_des(:,1) [0; diff(marker_des(:,1),1,1)]...
    %             marker_des(:,2) [0;diff(marker_des(:,2),1,1)]];

    % marker_des = integral_invariant_ms(marker_xyz,6,0.3);
    % marker_des = 0.5-marker_des;
    TRAJDB_DES{1, i} = marker_des;
end
save(matfilename, 'TRAJDB_DES');
