function [orientation, metric_variation]=gene_relative_descrip(curve1, curve2)
%GENE_RELATIVE_DESCRIP  Relative descriptor of one trajectory w.r.t. another.
%   [ORIENTATION, METRIC_VARIATION] = GENE_RELATIVE_DESCRIP(CURVE1, CURVE2)
%   describes CURVE2 - CURVE1 frame by frame by its two spherical angles
%   (polar, azimuth), relative to the first frame and wrapped to [-pi, pi],
%   and by its length normalised by the mean length over the sequence.

%% relative curve are got by subtracting one from another one
relative_curve = curve2-curve1;
samples = size(relative_curve, 1);
%% get original orientation angle and metric r
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
%% transform the start direction to z axis of spherical
orientation = [angle1 angle2]-repmat([angle1(1) angle2(1)], samples, 1);
% orientation=[angle1 angle2];
%% limit the value in <pi,-pi> range
[i, j] = find(orientation > pi);
orientation(i, j) = orientation(i, j)-2*pi;
[i, j] = find(orientation < -pi);
orientation(i, j) = orientation(i, j)+2*pi;
