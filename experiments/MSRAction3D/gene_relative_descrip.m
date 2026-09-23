function [orientation, metric_variation]=gene_relative_descrip(curve1, curve2)
%% relative curve are got by subtracting one from another one
relative_curve = curve2-curve1;
samples = size(relative_curve, 1);
%% get original orientaion angle and metric r
r = sqrt(sum(relative_curve.^2, 2));
r_length = sum(r(~isnan(r)));
% relative_curve = relative_curve - repmat([relative_curve(1,1:2) 0],samples,1);
angle1 = atan2(sqrt(sum(relative_curve(:, 1:2).^2, 2)), relative_curve(:, 3));
angle2 = atan2(relative_curve(:, 2), relative_curve(:, 1));
%% then there need to normalize the r and angle
if ~any(r)
    metric_variation = zeros(samples, 1);
else
    metric_variation = (samples*r)/r_length;
end
%% transform the start direction to z axis of sperical
orientation = [angle1 angle2]-repmat([angle1(1) angle2(1)], samples, 1);
% orientation=[angle1 angle2];
%% limit the value in <pi,-pi> range
[i, j] = find(orientation > pi);
orientation(i, j) = orientation(i, j)-2*pi;
[i, j] = find(orientation < -pi);
orientation(i, j) = orientation(i, j)+2*pi;
