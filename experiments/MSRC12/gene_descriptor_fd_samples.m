function gene_descriptor_fd_samples(marker)
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
