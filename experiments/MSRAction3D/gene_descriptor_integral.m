function gene_descriptor_integral(marker)
%GENE_DESCRIPTOR_INTEGRAL  Area integral invariants (AII) of the training set.
%   GENE_DESCRIPTOR_INTEGRAL(MARKER) computes 0.5 - INTEGRAL_INVARIANT_KN(xyz,
%   6, 5) for every trajectory.
%   Reads <MARKER>.mat (TRAJDB) and writes <MARKER>_DES.mat (TRAJDB_DES).
%   Keep in sync with the _samples twin, which must compute the SAME
%   descriptor for the test set; a mismatch gives meaningless accuracies.

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
