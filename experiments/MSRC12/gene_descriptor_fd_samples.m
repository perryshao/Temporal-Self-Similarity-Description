function gene_descriptor_fd_samples(marker)
%GENE_DESCRIPTOR_FD_SAMPLES  Fourier descriptors of the test set.
%   GENE_DESCRIPTOR_FD_SAMPLES(MARKER): see GENE_DESCRIPTOR_FD.
%   Reads <MARKER>samples.mat (TRAJSAMPLES) and writes <MARKER>samples_DES.mat
%   (TRAJSAMPLES_DES).  Must compute the same descriptor as the training twin.

TRAJSAMPLES_DES = cell (1, []);
fileprefix = 'samples.mat';
matfilename = [marker fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
fileextend = 'samples_DES.mat';
matfilename = [marker fileextend];
%% read joint 3D data with matrix format and get the descriptor
samples = size(TRAJSAMPLES, 2);
for i = 1:samples
    marker_xyz = double(TRAJSAMPLES{2, i});
    fprintf ('%d of %d samples integral descriptor...\n', i, samples);
    fd = fft(marker_xyz);
    fd = fd./repmat(abs(fd(2, :)), size(fd, 1), 1);
    marker_des = fd(2:end, :);
    TRAJSAMPLES_DES{1, end+1} = marker_des;
end
save(matfilename, 'TRAJSAMPLES_DES');
