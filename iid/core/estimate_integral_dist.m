function average_dist = estimate_integral_dist(Curve_xyz,Radius,pos)
dist = [];k=0;
Curve_length = size(Curve_xyz,1);
%% get the left points in Radius
r = 0;l_k = pos;
while (r <= Radius && l_k > 1)
    k = k+1;
    dist(k) = norm((Curve_xyz(l_k,:)-Curve_xyz(pos,:)));
    l_k = l_k-1;
    r = norm((Curve_xyz(l_k,:)-Curve_xyz(pos,:)));
end
%% get the right points in Radius
r = 0;r_k = pos;
while (r <= Radius && r_k < Curve_length)
    k = k+1;
    dist(k) = norm((Curve_xyz(r_k,:)-Curve_xyz(pos,:)));
    r_k = r_k+1;
    r = norm((Curve_xyz(r_k,:)-Curve_xyz(pos,:)));
end
%% pos-processing
if isempty(dist)
    average_dist = NaN;
elseif length(dist) == 1
    average_dist = dist;
else
    if ~any(dist)
        average_dist = 0;
    else
        average_dist = mean(dist)/(max(dist)-min(dist));%normalize the distance
    end
end
end
