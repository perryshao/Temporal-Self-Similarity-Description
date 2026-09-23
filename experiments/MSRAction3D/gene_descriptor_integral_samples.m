function gene_descriptor_integral_samples(marker)


fileprefix='samples.mat';
matfilename=[marker fileprefix];
if exist(matfilename,'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
fileextend='samples_DES.mat';
matfilename=[marker fileextend];
%% read joint 3D data with matrix format and get the descritor
samples=size(TRAJSAMPLES,2);
TRAJSAMPLES_DES = cell (1,samples);
for i=1:samples
    marker_xyz=double(TRAJSAMPLES{2,i});
    fprintf ('%d of %d samples integral descriptor...\n',i,samples);
%     marker_des = integral_invariant(marker_xyz,6,0.05);
    marker_des = integral_invariant_kn(marker_xyz,6,5);
    marker_des = 0.5-marker_des;
%     marker_des= [marker_des(:,1) [0; diff(marker_des(:,1),1,1)]...
%                  marker_des(:,2) [0;diff(marker_des(:,2),1,1)]];
%     
%     marker_des = integral_invariant_ms(marker_xyz,6,0.3);
%     marker_des = 0.5-marker_des;
    TRAJSAMPLES_DES{1,i}=marker_des;
end
save(matfilename, 'TRAJSAMPLES_DES');
