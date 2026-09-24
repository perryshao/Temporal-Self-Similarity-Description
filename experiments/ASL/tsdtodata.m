% TSDTODATA  Inspect one ASL .tsd file (development script).
% Reads tsd_data_bat/draw/1-draw-1.tsd, computes the relative descriptor of
% the left hand w.r.t. the right hand and plots both trajectories.

clear all
data_folder = 'tsd_data_bat/draw/'; % LOCATION OF C3D FILES
file_ext = '.tsd';
fidin = fopen([data_folder '1-draw-1.tsd']);
i = 1;
while ~feof(fidin)
    tline = fgetl(fidin);
    tline = str2num(tline);
    mk(i, :) = tline;
    i = i+1;
    continue
end
xyz = mk(:, 1:3)*10e3;
xyz1 = mk(:, 12:14)*10e3;
right_curve1 = xyz;
left_curve1 = xyz1;
%% moving average filter
% right_curve1(:,1)=movave(xyz(:,1),5);right_curve1(:,2)=movave(xyz(:,2),5);right_curve1(:,3)=movave(xyz(:,3),5);
% left_curve1(:,1)=movave(xyz1(:,2),5);left_curve1(:,2)=movave(xyz1(:,2),5);left_curve1(:,3)=movave(xyz1(:,3),5);

%% kalman filter
% ss = 6; % state size
% os = 3; % observation size
% F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
% H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
% Q = 0.001*eye(ss);
% R = 0.0001*eye(os);
% initV = xyz(1,1)*eye(ss);
% initx = [xyz(1,1) xyz(1,2) xyz(1,3) 0.001 0.001 0.001]';
% [xsmooth1, Vsmooth1] = kalman_smoother(xyz', F, H, Q, R, initx, initV);
%
% initV = xyz1(1,1)*eye(ss);
% initx = [xyz1(1,1) xyz1(1,2) xyz1(1,3) 0.001 0.001 0.001]';
% [xsmooth2, Vsmooth2] = kalman_smoother(xyz1', F, H, Q, R, initx, initV);
% right_curve1(:,1)=xsmooth1(1,:);
% right_curve1(:,2)=xsmooth1(2,:);
% right_curve1(:,3)=xsmooth1(3,:);
%
% left_curve1(:,1)=xsmooth2(1,:);
% left_curve1(:,2)=xsmooth2(2,:);
% left_curve1(:,3)=xsmooth2(3,:);

%% db4 wavelet filter
% right_curve1=wav_filter(xyz);
% left_curve1=wav_filter(xyz1);
%% interpolation
% right_curve1=interpolation(right_curve1,0);hold on;
% left_curve1=interpolation(left_curve1,0);
%% generate relative trajectory
[orientation1, r1] = gene_relative_descrip(right_curve1, left_curve1);
save variable1 orientation1 r1
%% plot the curve
figure(1);
plot3(right_curve1(1, 1), right_curve1(1, 2), right_curve1(1, 3), '--ro');
hold on;
subplot(2, 1, 1), plot3(right_curve1(:, 1), right_curve1(:, 2), right_curve1(:, 3), '--b*');grid on;
hold on;
subplot(2, 1, 2), plot3(left_curve1(1, 1), left_curve1(1, 2), left_curve1(1, 3), '--ro');
plot3(left_curve1(:, 1), left_curve1(:, 2), left_curve1(:, 3), '--r*'); grid on;
%% plot the orientation and r

fidin = fopen([data_folder '1-draw-1.tsd']);
i = 1;
while ~feof(fidin)
    tline = fgetl(fidin);
    tline = str2num(tline);
    mk(i, :) = tline;
    i = i+1;
    continue
end
xyz = mk(:, 1:3)*10e3;
xyz1 = mk(:, 12:14)*10e3;
right_curve2 = xyz;
left_curve2 = xyz1;
%% moving average filter
% right_curve2(:,1)=movave(xyz(:,1),5);right_curve2(:,2)=movave(xyz(:,2),5);right_curve2(:,3)=movave(xyz(:,3),5);
% left_curve2(:,1)=movave(xyz1(:,2),5);left_curve2(:,2)=movave(xyz1(:,2),5);left_curve2(:,3)=movave(xyz1(:,3),5);
%% db4 wavelet filter
right_curve2 = wav_filter(xyz);
left_curve2 = wav_filter(xyz1);
%% kalman filter

% ss = 6; % state size
% os = 3; % observation size
% F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
% H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
% Q = 0.001*eye(ss);
% R = 0.005*eye(os);
% initV = 1*eye(ss);
% initx = [xyz(1,1) xyz(1,2) xyz(1,3) 0.001 0.001 0.001]';
% [xsmooth1, ~,~,loglik] = kalman_smoother(xyz', F, H, Q, R, initx, initV);
% loglik
%
% initV = 1*eye(ss);
% initx = [xyz1(1,1) xyz1(1,2) xyz1(1,3) 0.001 0.001 0.001]';
% [xsmooth2,~,~,loglik] = kalman_smoother(xyz1', F, H, Q, R, initx, initV);
% loglik
% right_curve2(:,1)=xsmooth1(1,:);
% right_curve2(:,2)=xsmooth1(2,:);
% right_curve2(:,3)=xsmooth1(3,:);
%
% left_curve2(:,1)=xsmooth2(1,:);
% left_curve2(:,2)=xsmooth2(2,:);
% left_curve2(:,3)=xsmooth2(3,:);

%% interpolation
% right_curve2=interpolation(right_curve2,0);hold on;
% left_curve2=interpolation(left_curve2,0);
%% generate relative trajectory
[orientation2, r2] = gene_relative_descrip(right_curve2, left_curve2);
save variable2 orientation2 r2
%% plot the curve
figure(2);
plot3(right_curve2(1, 1), right_curve2(1, 2), right_curve2(1, 3), '--ro');
hold on;
subplot(2, 1, 1), plot3(right_curve2(:, 1), right_curve2(:, 2), right_curve2(:, 3), '--b*');grid on;
hold on;
subplot(2, 1, 2), plot3(left_curve2(1, 1), left_curve2(1, 2), left_curve2(1, 3), '--ro');
plot3(left_curve2(:, 1), left_curve2(:, 2), left_curve2(:, 3), '--r*'); grid on;
%% plot the orientation and r

fidin = fopen([data_folder '1-draw-1.tsd']);
i = 1;
while ~feof(fidin)
    tline = fgetl(fidin);
    tline = str2num(tline);
    mk(i, :) = tline;
    i = i+1;
    continue
end
xyz = mk(:, 1:3)*10e3;
xyz1 = mk(:, 12:14)*10e3;
right_curve3 = xyz;
left_curve3 = xyz1;
%% moving average filter
% right_curve3(:,1)=movave(xyz(:,1),5);right_curve3(:,2)=movave(xyz(:,2),5);right_curve3(:,3)=movave(xyz(:,3),5);
% left_curve3(:,1)=movave(xyz1(:,2),5);left_curve3(:,2)=movave(xyz1(:,2),5);left_curve3(:,3)=movave(xyz1(:,3),5);

%% kalman filter
ss = 6; % state size
os = 3; % observation size
F = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 0 0 0 1 0 0;0 0 0 0 1 0;0 0 0 0 0 1];
H = [1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0];
Q = 0.05*eye(ss);
R = 0.1*eye(os);
initV = 1*eye(ss);
initx = [xyz(1, 1) xyz(1, 2) xyz(1, 3) 0.05 0.05 0.05]';
[xsmooth1, ~, ~, loglik] = kalman_smoother(xyz', F, H, Q, R, initx, initV);
loglik

initV = 1*eye(ss);
initx = [xyz1(1, 1) xyz1(1, 2) xyz1(1, 3) 0.05 0.05 0.05]';
[xsmooth2, ~, ~, loglik] = kalman_smoother(xyz1', F, H, Q, R, initx, initV);
loglik
right_curve3(:, 1) = xsmooth1(1, :);
right_curve3(:, 2) = xsmooth1(2, :);
right_curve3(:, 3) = xsmooth1(3, :);

left_curve3(:, 1) = xsmooth2(1, :);
left_curve3(:, 2) = xsmooth2(2, :);
left_curve3(:, 3) = xsmooth2(3, :);
%% db4 wavelet filter
% right_curve3=wav_filter(xyz);
% left_curve3=wav_filter(xyz1);
%% interpolation
% right_curve3=interpolation(right_curve3,0);hold on;
% left_curve3=interpolation(left_curve3,0);
%% generate relative trajectory
[orientation3, r3] = gene_relative_descrip(right_curve3, left_curve3);
save variable3 orientation3 r3
%% plot the curve
figure(3);
subplot(2, 1, 1), plot3(right_curve3(1, 1), right_curve3(1, 2), right_curve3(1, 3), '--ro');
hold on;
subplot(2, 1, 1), plot3(right_curve3(:, 1), right_curve3(:, 2), right_curve3(:, 3), '--b*');grid on;
hold on;
subplot(2, 1, 2), plot3(left_curve3(1, 1), left_curve3(1, 2), left_curve3(1, 3), '--ro');
subplot(2, 1, 2), plot3(left_curve3(:, 1), left_curve3(:, 2), left_curve3(:, 3), '--r*'); grid on;
%% plot the orientation and r
figure(4);
subplot(3, 1, 1), plot(orientation1);subplot(3, 1, 2), plot(orientation2);subplot(3, 1, 3), plot(orientation3);
figure(5);
subplot(3, 1, 1), plot(r1);subplot(3, 1, 2), plot(r2);subplot(3, 1, 3), plot(r3);
fclose('all');
