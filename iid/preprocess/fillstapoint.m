function smooth_curve=fillstapoint(smooth_curve,staindex)
%% refill the static points with the static index
n = length(staindex);
for i = 1:n,
    smooth_curve = [smooth_curve(1:staindex(i)-1,:);smooth_curve(staindex(i)-1,:);smooth_curve(staindex(i):end,:)];% insert operation
end