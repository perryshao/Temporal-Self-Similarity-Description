function gene_descriptor_fd(marker)
%GENE_DESCRIPTOR_FD  Fourier descriptors of the training set.
%   GENE_DESCRIPTOR_FD(MARKER) takes the FFT of every xyz trajectory,
%   normalises it by the magnitude of the first harmonic and keeps
%   coefficients 2..end (the 1-NN-FD baseline).
%   Reads <MARKER>.mat (TRAJDB) and writes <MARKER>_DES.mat (TRAJDB_DES).
%   Keep in sync with the _samples twin, which must compute the SAME
%   descriptor for the test set; a mismatch gives meaningless accuracies.

TRAJDB_DES = cell (1, []);
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
% TRAJDB = normalization_basewhole(marker,joints_no);
for i = 1:samples
    marker_xyz = double(TRAJDB{2, i});
    fprintf ('%d of %d integral descriptor...\n', i, samples);
    fd = fft(marker_xyz);
    fd = fd./repmat(abs(fd(2, :)), size(fd, 1), 1);
    marker_des = fd(2:end, :);
    TRAJDB_DES{1, end+1} = marker_des;
end
save(matfilename, 'TRAJDB_DES');
