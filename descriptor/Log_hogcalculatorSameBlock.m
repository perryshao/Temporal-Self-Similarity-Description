function [F_t, F] = Log_hogcalculatorSameBlock(img, radius, nbins_theta, nbins_r, ...
    nthet, ntotalbh, issigned, normmethod)
% HOGCALCULATOR calculate C-HOG feature vector of an input SSM using the
% procedure presented in Dalal and Triggs's paper in CVPR 2005.
%
% Author:   Perry
% Time:     Dec 22, 2014
%         Dec 12 2014 update.
%
%     this copy of code is written for calculate the HOG descriptor of SSM image, which is an
%     original and inornate realization of [Dalal CVPR2005]'s algorithm
%     without any optimization.

%
% F = Log_hogcalculator(img,radius, nbins_theta, nbins_r,
%     nthet, overlap, isglobalinterpolate, issigned, normmethod)
%
% IMG:
%     IMG is the input image.

% RADIUS
%         RADIUS is the radius of central bin in pixel
% NBINS_THETA, NBINS_R:
%     NBINS_THETA and NBINS_R are the mumber of angular and radial bins
%
% NTHET, ISSIGNED:
%     NTHET is the number of the bins of the histogram of oriented
%     gradient. The histogram of oriented gradient ranges from 0 to pi in
%     'unsigned' condition while to 2*pi in 'signed' condition, which can
%     be specified through setting the value of the variable ISSIGNED by
%     the string 'unsigned' or 'signed'.
%
% OVERLAP:
%     OVERLAP is the overlap proportion of two neighboring block.
%
% NORMMETHOD?
%     NORMMETHOD is the block histogram normalized method which can be
%     set as one of the following strings:
%             'none', which means non-normalization;
%             'l1', which means L1-norm normalization;
%             'l2', which means L2-norm normalization;
%             'l1sqrt', which means L1-sqrt-norm normalization;
%             'l2hys', which means L2-hys-norm normalization.
% F?
%     F is a row vector storing the final histogram of all of the blocks
%     one by one in a top-left to bottom-right image scan manner, the
%     cells histogram are stored in the same manner in each block's
%     section of F.
%
% ntotalbh
% Block numbers along the diagnol of the square matrix
if nargin < 2
    % set default parameters value.
    radius = 30; % default
    % radius = 130;
    % nbins_theta = 5;% default
    nbins_theta = 5;
    nbins_r = 3; % default
    % nbins_r = 2;
    % nthet = 6;% default
    nthet = 8;
    ntotalbh = 12;
    % issigned = 'signed';%(0-2pi)
    issigned = 'unsigned'; % (0-pi) default
    normmethod = 'l2hys'; % default
else
    if nargin < 8
        error('Input parameters are not enough.');
    end
end
% the cell size counted by the number of pixels
celltheta = pi/nbins_theta;
cellro = log(radius)/nbins_r;
% check parameters's validity.
[M, N, K] = size(img);
% construct the indx matrix
indx_matrix = zeros(2, sum(1:M));
n = 0;
for i = 1:M
    for j = i:M
        n = n+1;
        indx_matrix(:, n) = [i;j];
    end
end
% calculate gradient scale matrix.
hx = [-1, 0, 1];
hy = -hx';
gradscalx = imfilter(double(img), hx);
gradscaly = imfilter(double(img), hy);
%
if K > 1
    maxgrad = sqrt(double(gradscalx.*gradscalx + gradscaly.*gradscaly));
    [gradscal, gidx] = max(maxgrad, [], 3);
    gxtemp = zeros(M, N);
    gytemp = gxtemp;
    for kn = 1:K
        ttempx = gradscalx(:, :, kn);
        ttempy = gradscaly(:, :, kn);
        tmpindex = find(gidx==kn);
        gxtemp(tmpindex) = ttempx(tmpindex);
        gytemp(tmpindex) = ttempy(tmpindex);
    end
    gradscalx = gxtemp;
    gradscaly = gytemp;
else
    gradscal = sqrt(double(gradscalx.*gradscalx + gradscaly.*gradscaly));
end

% calculate gradient orientation matrix.
% plus small number for avoiding dividing zero.
gradscalxplus = gradscalx+ones(size(gradscalx))*0.0001;
gradorient = zeros(M, N);
% unsigned situation: orientation region is 0 to pi.
if strcmp(issigned, 'unsigned') == 1
    gradorient = ...
        atan(gradscaly./gradscalxplus);
    gradorient(gradorient<0) = gradorient(gradorient<0)+pi;
    or = 1;
else
    % signed situation: orientation region is 0 to 2*pi.
    if strcmp(issigned, 'signed') == 1
        idx = find(gradscalx >= 0 & gradscaly >= 0);
        gradorient(idx) = atan(gradscaly(idx)./gradscalxplus(idx));
        idx = find(gradscalx < 0);
        gradorient(idx) = atan(gradscaly(idx)./gradscalxplus(idx)) + pi;
        idx = find(gradscalx >= 0 & gradscaly < 0);
        gradorient(idx) = atan(gradscaly(idx)./gradscalxplus(idx)) + 2*pi;
        or = 2;
    else
        error('Incorrect ISSIGNED parameter.');
    end
end
% calculate block slide step.
% xbstride = uint16(radius)*(1-overlap);
% ybstride = uint16(radius)*(1-overlap);
xbstride = 1;
xbstridend = M;
xbstep = M/(ntotalbh-1);
fslidestep = nbins_r*nbins_theta*nthet; % The length of vector for one block
% ybstridend = M;
% calculate the total blocks number in the window detected, which is
% ntotalbh = M/xbstride;
% generate the matrix hist3dbig for storing the 3-dimensions histogram. the
% matrix covers the whole image in the 'globalinterpolate' condition or
% covers the local block in the 'localinterpolate' condition. The matrix is
% bigger than the area where it covers by adding additional elements
% (corresponding to the cells) to the surround for calculation convenience.

hist3dbig = zeros(nbins_theta+2, nbins_r+2, nthet+2);
F = zeros(1, nbins_theta*nbins_r*nthet);
% generate the matrix for storing histogram of one block;
sF = zeros(1, nbins_theta*nbins_r*nthet);
% vote for histogram. there are two situations according to the interpolate
% condition('global' interpolate or local interpolate). The hist3d which is
% generated from the 'bigger' matrix hist3dbig is the final histogram.
% xbstep = xbstride;
% rotate angle
rot_theta = -pi/4;
stepunit = round(1:xbstep:xbstridend);
if length(stepunit)<M
    stepunit(ntotalbh) = xbstridend;
end
% block slide loop
count = 1;
for btlx = stepunit
    btly = btlx;
    % transform the indx_matrix to transformed matrix with respect to the
    % diagonal pixels
    t_matrix = indx_matrix - repmat(double([btlx;btly]), 1, size(indx_matrix, 2));
    % the pixel indexes of log-polar block
    btpixels = indx_matrix(:, 0 < sqrt(sum(t_matrix.*t_matrix))&...
                                     sqrt(sum(t_matrix.*t_matrix)) <= radius);
    % the pixel indexes of the trasformed log-polar block
    npixels = size(btpixels, 2);
    rt_matrix = [cos(rot_theta) -sin(rot_theta);...
        sin(rot_theta) cos(rot_theta)]*(btpixels-repmat(double([btlx;btly]), 1, npixels));
    % adjust the negative value caused by accuracy of floating-point
    % operations.these value's scale is very small, usually at E-04 magnitude
    rt_matrix(abs(rt_matrix) < 10e-4) = 0;
    r_array = sqrt(sum(rt_matrix.*rt_matrix));
    ro = log(r_array);
    theta_array = atan2(rt_matrix(2, :), rt_matrix(1, :));
    for bi = 1:npixels
        i = btpixels(1, bi);
        j = btpixels(2, bi);
        gs = gradscal(i, j);
        go = gradorient(i, j);
        jorbj = ro(bi);iorbi=theta_array(bi);
        % calculate bin index of hist3dbig
        binx1 = floor((jorbj+cellro/2)/cellro) + 1;
        biny1 = floor((iorbi+celltheta/2)/celltheta) + 1;
        binz1 = floor((go+(or*pi/nthet)/2)/(or*pi/nthet)) + 1;

        if gs < 1E-5
            continue;
        end

        binx2 = binx1 + 1;
        biny2 = biny1 + 1;
        binz2 = binz1 + 1;

        x1 = (binx1-1.5)*cellro; % don't need add 0.5 here
        % x1 = (binx1-1.5)*cellro+0.5;
        y1 = (biny1-1.5)*celltheta;
        z1 = (binz1-1.5)*(or*pi/nthet);

        % trilinear interpolation.
        hist3dbig(biny1, binx1, binz1) = ...
            hist3dbig(biny1, binx1, binz1) + gs*...
             (1-(jorbj-x1)/cellro)*(1-(iorbi-y1)/celltheta)...
            *(1-(go-z1)/(or*pi/nthet));
        hist3dbig(biny1, binx1, binz2) = ...
            hist3dbig(biny1, binx1, binz2) + gs*...
             (1-(jorbj-x1)/cellro)*(1-(iorbi-y1)/celltheta)...
            *((go-z1)/(or*pi/nthet));
        hist3dbig(biny2, binx1, binz1) = ...
            hist3dbig(biny2, binx1, binz1) + gs*...
            (1-(jorbj-x1)/cellro)*((iorbi-y1)/celltheta)...
            *(1-(go-z1)/(or*pi/nthet));
        hist3dbig(biny2, binx1, binz2) = ...
            hist3dbig(biny2, binx1, binz2) + gs*...
            (1-(jorbj-x1)/cellro)*((iorbi-y1)/celltheta)...
            *((go-z1)/(or*pi/nthet));
        hist3dbig(biny1, binx2, binz1) = ...
            hist3dbig(biny1, binx2, binz1) + gs*...
            ((jorbj-x1)/cellro)*(1-(iorbi-y1)/celltheta)...
            *(1-(go-z1)/(or*pi/nthet));
        hist3dbig(biny1, binx2, binz2) = ...
            hist3dbig(biny1, binx2, binz2) + gs*...
            ((jorbj-x1)/cellro)*(1-(iorbi-y1)/celltheta)...
            *((go-z1)/(or*pi/nthet));
        hist3dbig(biny2, binx2, binz1) = ...
            hist3dbig(biny2, binx2, binz1) + gs*...
            ((jorbj-x1)/cellro)*((iorbi-y1)/celltheta)...
            *(1-(go-z1)/(or*pi/nthet));
        hist3dbig(biny2, binx2, binz2) = ...
            hist3dbig(biny2, binx2, binz2) + gs*...
            ((jorbj-x1)/cellro)*((iorbi-y1)/celltheta)...
            *((go-z1)/(or*pi/nthet));
    end

    % In the local interpolate condition. F is generated in this block
    % slide loop. hist3dbig should be cleared in each loop.
    if or == 2
        hist3dbig(:, :, 2) = hist3dbig(:, :, 2)...
            + hist3dbig(:, :, nthet+2);
        hist3dbig(:, :, (nthet+1)) =...
            hist3dbig(:, :, (nthet+1)) + hist3dbig(:, :, 1);
    end
    hist3d = hist3dbig(2:(nbins_theta+1), 2:(nbins_r+1), 2:(nthet+1));
    for ibin = 1:nbins_theta
        for jbin = 1:nbins_r
            idsF = nthet*((ibin-1)*nbins_r+jbin-1)+1;
            idsF = idsF:(idsF+nthet-1);
            sF(idsF) = hist3d(ibin, jbin, :);
        end
    end
    % iblock = ((btlx-1)/xbstride) + 1;
    iblock = count;
    count = count+1;
    idF = (iblock-1)*nbins_theta*nbins_r*nthet+1;
    idF = idF:(idF+nbins_theta*nbins_r*nthet-1);
    F(idF) = sF;
    hist3dbig(:, :, :) = 0;
end

% adjust the negative value caused by accuracy of floating-point
% operations.these value's scale is very small, usually at E-03 magnitude
% while others will be E+02 or E+03 before normalization.
F(F<0) = 0;
% block normalization.
e = 0.001;
l2hysthreshold = 0.6;
% l2hysthreshold = 0.2;

switch normmethod
    case 'none'
    case 'l1'
        for fi = 1:fslidestep:size(F, 2)
            div = sum(F(fi:(fi+fslidestep-1)));
            F(fi:(fi+fslidestep-1)) = F(fi:(fi+fslidestep-1))/(div+e);
        end
    case 'l1sqrt'
        for fi = 1:fslidestep:size(F, 2)
            div = sum(F(fi:(fi+fslidestep-1)));
            F(fi:(fi+fslidestep-1)) = sqrt(F(fi:(fi+fslidestep-1))/(div+e));
        end
    case 'l2'
        for fi = 1:fslidestep:size(F, 2)
            sF = F(fi:(fi+fslidestep-1)).*F(fi:(fi+fslidestep-1));
            div = sqrt(sum(sF)+e*e);
            F(fi:(fi+fslidestep-1)) = F(fi:(fi+fslidestep-1))/div;
        end
    case 'l2hys'
        for fi = 1:fslidestep:size(F, 2)
            sF = F(fi:(fi+fslidestep-1)).*F(fi:(fi+fslidestep-1));
            div = sqrt(sum(sF)+e*e);
            sF = F(fi:(fi+fslidestep-1))/div;
            sF(sF>l2hysthreshold) = l2hysthreshold;
            div = sqrt(sum(sF.*sF)+e*e);
            F(fi:(fi+fslidestep-1)) = sF/div;
        end
    otherwise
        error('Incorrect NORMMETHOD parameter.');
end

F_t = reshape(F, fslidestep, ntotalbh)';
temp = 0;
nbins = nbins_r*nbins_theta-nbins_theta+1; % the sum bins for single center
F_temp = zeros(ntotalbh, nbins*nthet);
for i = 1:nbins_r:nbins_r*nbins_theta
    temp = F_t(:, (i-1)*nthet+1:i*nthet)+temp;
    F_temp(:, 1:nthet) = temp;
end
for j = 0:nbins_theta-1
    for i = 2+j*nbins_r:2+j*nbins_r+(nbins_r-2)
        F_temp(:, (i-j-1)*nthet+1:(i-j)*nthet) = F_t(:, (i-1)*nthet+1:i*nthet);
    end
end
F_t = F_temp;

% temp = 0;
% tic
% for i = 1:nbins_r*nbins_theta
%     switch i
%         case {1,4,7,10,13}
%             temp = F_t(:,(i-1)*nthet+1:i*nthet)+temp;
%             F_temp(:,1:nthet) = temp;
%         case {2,3}
%             F_temp(:,(i-1)*nthet+1:i*nthet) = F_t(:,(i-1)*nthet+1:i*nthet);
%         case {5,6}
%             F_temp(:,(i-1-1)*nthet+1:(i-1)*nthet) = F_t(:,(i-1)*nthet+1:i*nthet);
%         case {8,9}
%             F_temp(:,(i-2-1)*nthet+1:(i-2)*nthet) = F_t(:,(i-1)*nthet+1:i*nthet);
%         case {11,12}
%             F_temp(:,(i-3-1)*nthet+1:(i-3)*nthet) = F_t(:,(i-1)*nthet+1:i*nthet);
%         case {14,15}
%             F_temp(:,(i-4-1)*nthet+1:(i-4)*nthet) = F_t(:,(i-1)*nthet+1:i*nthet);
%         otherwise
%             disp('Unknown i')
%     end
% end
% toc
% F_t = F_temp;
