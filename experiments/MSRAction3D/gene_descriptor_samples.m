function gene_descriptor_samples(marker)
%GENE_DESCRIPTOR_SAMPLES  Differential-invariant (DI) descriptors of the test set.
%   GENE_DESCRIPTOR_SAMPLES(MARKER) computes DESCRIPTOR_COMP for every trajectory.
%   Reads <MARKER>samples.mat (TRAJSAMPLES) and writes <MARKER>samples_DES.mat
%   (TRAJSAMPLES_DES).  Must compute the same descriptor as the training twin.

if nargin <= 2

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
    TRAJSAMPLES_DES = cell (1, samples);
    for i = 1:samples
        marker_xyz = double(TRAJSAMPLES{2, i});
        % marker_xyz = remove_stapoint(marker_xyz);
        fprintf ('%d of %d samples differential descriptor...\n', i, samples);
        marker_des = descriptor_comp(marker_xyz);
        TRAJSAMPLES_DES{1, i} = marker_des;
    end
    save(matfilename, 'TRAJSAMPLES_DES');
else

    if exist('tsdsamples.mat', 'file')
        load tsdsamples;
    else
        fprintf ('Error, there are not existing database, lack of load_tsd_samples() funcition');
    end
    samples = size(TSDSAMPLES, 2);
    TSDSAMPLES_DES = cell (2, samples);
    for i = 1:samples
        right_xyz = double(TSDSAMPLES{2, i}); % right hand xyz position
        left_xyz = double(TSDSAMPLES{3, i}); % left hand xyz position
        right_xyz = remove_stapoint(right_xyz);
        right_des = descriptor_comp(right_xyz);
        left_xyz = remove_stapoint(left_xyz);
        left_des = descriptor_comp(left_xyz);
        TSDSAMPLES_DES{1, i} = left_des;
        TSDSAMPLES_DES{2, i} = right_des;
    end
    save('tsdsamples_des', 'TSDSAMPLES_DES');
end
