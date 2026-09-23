function [curvegrid,grid] = curve_grid(curve_xyz,width)
%% discretize the curve into the number of width grids
n = size(curve_xyz,1);
curve_limit = max(curve_xyz,[],1)-min(curve_xyz,[],1);
max_limit = max(curve_limit);
grid = max_limit/width;
curvegrid = (curve_xyz-repmat(min(curve_xyz,[],1),n,1))./grid;
curvegrid = round(curvegrid);