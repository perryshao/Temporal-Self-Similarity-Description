function integral = integral_invariant_dist(Curve_xyz,kpoints)
%% parameter definition
%  Input:
%  Curve_xyz -- input 3d sequence of points
% Curve_xyz = normalization(Curve_xyz); % for Raidus pattern
[Curve_xyz,~] = remove_stapoint(Curve_xyz); % for occlusion
n = size(Curve_xyz,1);
integral = zeros(n,1);

%% compute the integral invariants
kns = fix(kpoints/2);
for i = kns+1:(n-kns)
    Radius = min(norm(Curve_xyz(i,:) - Curve_xyz(i-kns,:)),norm(Curve_xyz(i+kns,:) - Curve_xyz(i,:)));
    integral(i,1) = estimate_integral_dist(Curve_xyz,Radius,i); % Radius of the circumcircle to [CL(i),C(i),CR(i)]
end


