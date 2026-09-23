function [regular_xyz,stapoint_index] = remove_stapoint(curve_xyz)
%% remove static point in curve so that the curve can be computable for curvation and torsion.
% remove NaN data in sequence
NaN_index = isnan(curve_xyz);
curve_xyz(NaN_index(:,1)==1,:) = [];
double(curve_xyz);
samples = size(curve_xyz,1);
regular_xyz = [];
regular_xyz(end+1,:) = curve_xyz(1,:);
stapoint_index = [];
for i=2:samples
    velocity = norm((curve_xyz(i,:)-curve_xyz(i-1,:)));
    if velocity > 0
        regular_xyz(end+1,:) = curve_xyz(i,:); %#ok<AGROW>
    else
        stapoint_index(end+1) = i; %#ok<AGROW>
    end
end
