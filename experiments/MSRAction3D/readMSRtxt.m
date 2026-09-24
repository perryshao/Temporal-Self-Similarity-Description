function [X Y Z] = readMSRtxt(skeleton_txt)
%READMSRTXT  Read one MSR Action3D skeleton file.
%   [X, Y, Z] = READMSRTXT(SKELETON_TXT) returns 20 x frames matrices of joint
%   coordinates, with the axes rearranged (and the depth axis rescaled) as in
%   the data set's DRAWSKT viewer.

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
