% USAGE: drawskt(1,3,1,4,1,2) --- show actions 1,2,3 performed by subjects 1,2,3,4 with instances 1 and 2.
function [X Y Z] = readMSRtxt(skeleton_txt)

file = sprintf(skeleton_txt);
fp = fopen(file);
if (fp>0)
    A = fscanf(fp, '%f');
    fclose(fp);
end

l = size(A, 1)/4;
A = reshape(A, 4, l);
A = A';
A = reshape(A, 20, l/20, 4);

X = A(:, :, 1);
Z = 400-A(:, :, 2);
Y = A(:, :, 3)/4;
