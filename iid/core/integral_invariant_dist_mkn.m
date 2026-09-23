function integral = integral_invariant_dist_mkn(Curve_xyz,kpoints)
%% parameter definition
%  Input:
%  Curve_xyz -- input 3d sequence of points
% Curve_xyz = normalization(Curve_xyz); % just for Raidus pattern
[Curve_xyz,staindex] = remove_stapoint(Curve_xyz); % for occlusion
n = size(Curve_xyz,1);
multscale = 5;
integral = zeros(n,multscale);
%% compute the integral invariants
kns_i = fix(kpoints/2);
for i = kns_i+1:(n-kns_i)
     r = max(norm(Curve_xyz(i,:) - Curve_xyz(i-kns_i,:)),norm(Curve_xyz(i+kns_i,:) - Curve_xyz(i,:)));
    for j = 1:multscale
        integral(i,j) = estimate_integral_dist(Curve_xyz,r,i); % Radius of the circumcircle to [CL(i),C(i),CR(i)]
        %     integral(i,:) = estimate_integral_ellipse(Curve_xyz,Curve_xyz(i,:),Curve_xyz(L(i),:),Curve_xyz(R(i),:),Radius,0,i); % Radius of the circumcircle to [CL(i),C(i),CR(i)]
        %     integral(i,:) = estimate_integral_fig(Curve_xyz,Curve_xyz(i,:),Curve_xyz(L(i),:),Curve_xyz(R(i),:),Radius,i);
        kns = fix(kpoints/(2^j));
        r = max(norm(Curve_xyz(i,:) - Curve_xyz(i-kns,:)),norm(Curve_xyz(i+kns,:) - Curve_xyz(i,:)));
    end
end
integral = fillstapoint(integral,staindex);

