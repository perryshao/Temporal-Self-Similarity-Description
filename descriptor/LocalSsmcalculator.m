function [F_t, F] = LocalSsmcalculator(img,radius, nbins_theta, nbins_r,...
    nthet)
% LocalSsmcalculator calculate local self-similarity feature vector of an input SSM using the
% procedure presented in Dalal and Triggs's paper in CVPR 2005.
%
% Author:   Perry
% Time:     Feb 05, 2015
%           Feb 08 2015 update.
% IMG:
%       IMG is the input image.

% RADIUS
%        RADIUS is the radius of central bin in pixel 
% NBINS_THETA, NBINS_R:
%       NBINS_THETA and NBINS_R are the mumber of angular and radial bins
%
% NTHET, ISSIGNED:
%       NTHET is the number of the bins of the histogram of oriented
%       gradient. The histogram of oriented gradient ranges from 0 to pi in
%       'unsigned' condition while to 2*pi in 'signed' condition, which can
%       be specified through setting the value of the variable ISSIGNED by
%       the string 'unsigned' or 'signed'.
% NORMMETHOD?
%       NORMMETHOD is the block histogram normalized method which can be
%       set as one of the following strings:
%               'none', which means non-normalization;
%               'l1', which means L1-norm normalization;
%               'l2', which means L2-norm normalization;
%               'l1sqrt', which means L1-sqrt-norm normalization;
%               'l2hys', which means L2-hys-norm normalization.
% F?
%       F is a row vector storing the final histogram of all of the blocks 
%       one by one in a top-left to bottom-right image scan manner, the
%       cells histogram are stored in the same manner in each block's
%       section of F.
%
if nargin < 2
    % set default parameters value.
%     radius = 60;% default
    radius = 20;
%     nbins_theta = 12;% default
    nbins_theta = 8;
%     nbins_r = 4;% default
    nbins_r = 3;
    nthet = 1; % find histogroam or maximum value in SSM
    normmethod = 'l2hys';%default
else
    if nargin < 5
        error('Input parameters are not enough.');
    end
end
% the cell size counted by the number of pixels
celltheta = pi/nbins_theta;
cellro = log(radius)/nbins_r;
% check parameters's validity.
[M, ~, ~] = size(img);
% construct the indx matrix
indx_matrix = zeros(2, sum(1:M));
n=0;
for i = 1:M
    for j = i:M
        n = n+1;
        indx_matrix(:,n) = [i;j];
    end
end
% calculate gradient scale matrix.
gradscal= img; %directly use the raw distances in ssm of image
% calculate block slide step.
% xbstride = uint16(radius)*(1-overlap);
% ybstride = uint16(radius)*(1-overlap);
xbstride = 1;
xbstridend = M;
% ybstridend = M;
% calculate the total blocks number in the window detected, which is
ntotalbh = M/xbstride; 
% generate the matrix hist3dbig for storing the 3-dimensions histogram. the
% matrix covers the whole image in the 'globalinterpolate' condition or
% covers the local block in the 'localinterpolate' condition. The matrix is
% bigger than the area where it covers by adding additional elements
% (corresponding to the cells) to the surround for calculation convenience.

% for historgram(bins(x,y))
% hist2dbig = zeros(nbins_theta+2, nbins_r+2);
% for max(bins(x,y))
hist2dbig = zeros(nbins_theta, nbins_r);
F = zeros(1, ntotalbh*nbins_theta*nbins_r*nthet);
% generate the matrix for storing histogram of one block;
sF = zeros(1, nbins_theta*nbins_r*nthet);
% vote for histogram. there are two situations according to the interpolate
% condition('global' interpolate or local interpolate). The hist3d which is
% generated from the 'bigger' matrix hist3dbig is the final histogram.
xbstep = xbstride;
% rotate angle
rot_theta = -pi/4;
% block slide loop
for btlx = 1:xbstep:xbstridend
    btly = btlx;
    % transform the indx_matrix to transformed matrix with respect to the
    % diagonal pixels 
    t_matrix = indx_matrix - repmat(double([btlx;btly]),1,size(indx_matrix,2));
    %% the pixel indexes of log-polar block
    % for historgram(bins(x,y))
%     btpixels= indx_matrix(:,0 < sqrt(sum(t_matrix.*t_matrix))&...
%                                      sqrt(sum(t_matrix.*t_matrix)) <= radius); 
    % for max(bins(x,y))
    btpixels= indx_matrix(:,0 < sqrt(sum(t_matrix.*t_matrix))&...
                                     sqrt(sum(t_matrix.*t_matrix)) < radius); 
    %% the pixel indexes of the trasformed log-polar block
    npixels= size(btpixels,2);
    rt_matrix = [cos(rot_theta) -sin(rot_theta);...
        sin(rot_theta) cos(rot_theta)]*(btpixels-repmat(double([btlx;btly]),1,npixels)); 
    % adjust the negative value caused by accuracy of floating-point
    % operations.these value's scale is very small, usually at E-04 magnitude
    rt_matrix(abs(rt_matrix) < 10e-4) = 0;
    r_array = sqrt(sum(rt_matrix.*rt_matrix));
    ro = log(r_array);
    theta_array=atan2(rt_matrix(2,:),rt_matrix(1,:));
    for bi = 1:npixels 
        i = btpixels(1,bi);
        j = btpixels(2,bi);
        gs = gradscal(i,j);
        jorbj = ro(bi);iorbi=theta_array(bi);
        %% calculate bin index of hist2dbig
        % for historgram(bins(x,y))
%         binx1 = floor((jorbj+cellro/2)/cellro) + 1;
%         biny1 = floor((iorbi+celltheta/2)/celltheta) + 1;
        % for max(bins(x,y))
        binx1 = floor(jorbj/cellro) + 1; 
        biny1 = floor(iorbi/celltheta) + 1;
        
        if gs < 1E-5
            continue;
        end
        % for historgram(bins(x,y))
%         binx2 = binx1 + 1;
%         biny2 = biny1 + 1;  
%         x1 = (binx1-1.5)*cellro;% don't need add 0.5 here
% %         x1 = (binx1-1.5)*cellro+0.5;
%         y1 = (biny1-1.5)*celltheta;
        %% compute the descriptors with maxmum or histrogram voting with trilinear interpolation.
        % for max(bins(x,y))
        hist2dbig(biny1,binx1) =...
            max(hist2dbig(biny1,binx1), gs);
        % for histogram(bins(x,y)) -- trilinear interpolation.
%         hist2dbig(biny1,binx1) =...
%             hist2dbig(biny1,binx1) + gs*...
%              (1-(jorbj-x1)/cellro)*(1-(iorbi-y1)/celltheta);
%         hist2dbig(biny2,binx1) =...
%             hist2dbig(biny2,binx1) + gs*...
%             (1-(jorbj-x1)/cellro)*((iorbi-y1)/celltheta);
%         hist2dbig(biny1,binx2) =...
%             hist2dbig(biny1,binx2) + gs*...
%             ((jorbj-x1)/cellro)*(1-(iorbi-y1)/celltheta);
%         hist2dbig(biny2,binx2) =...
%             hist2dbig(biny2,binx2) + gs*...
%             ((jorbj-x1)/cellro)*((iorbi-y1)/celltheta);
    end
    %% extract hist2dbig
    % for histogram(bins(x,y)), shuold extract them with eliminated the
    % first and final bins.
%     hist2d = hist2dbig(2:(nbins_theta+1), 2:(nbins_r+1));
    % for max(bins(x,y))
    hist2d = hist2dbig;

    for ibin = 1:nbins_theta
        for jbin = 1:nbins_r
            idsF = nthet*((ibin-1)*nbins_r+jbin-1)+1;
            idsF = idsF:(idsF+nthet-1);
            sF(idsF) = hist2d(ibin,jbin);
        end
    end
    iblock = ((btlx-1)/xbstride) + 1;
    idF = (iblock-1)*nbins_theta*nbins_r*nthet+1;
    idF = idF:(idF+nbins_theta*nbins_r*nthet-1);
    F(idF) = sF;
    hist2dbig(:,:) = 0;
end
% adjust the negative value caused by accuracy of floating-point
% operations.these value's scale is very small, usually at E-03 magnitude
% while others will be E+02 or E+03 before normalization.
F(F<0) = 0;
% block normalization.
e = 0.001;
l2hysthreshold = 0.6;
% l2hysthreshold = 0.2;
fslidestep = nbins_r*nbins_theta*nthet;
switch normmethod
    case 'none'
    case 'l1'
        for fi = 1:fslidestep:size(F,2)
            div = sum(F(fi:(fi+fslidestep-1)));
            F(fi:(fi+fslidestep-1)) = F(fi:(fi+fslidestep-1))/(div+e);
        end
    case 'l1sqrt'
        for fi = 1:fslidestep:size(F,2)
            div = sum(F(fi:(fi+fslidestep-1)));
            F(fi:(fi+fslidestep-1)) = sqrt(F(fi:(fi+fslidestep-1))/(div+e));
        end
    case 'l2'
        for fi = 1:fslidestep:size(F,2)
            sF = F(fi:(fi+fslidestep-1)).*F(fi:(fi+fslidestep-1));
            div = sqrt(sum(sF)+e*e);
            F(fi:(fi+fslidestep-1)) = F(fi:(fi+fslidestep-1))/div;
        end
    case 'l2hys'
        for fi = 1:fslidestep:size(F,2)
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
F_t = reshape(F,fslidestep,ntotalbh)';
%% relocate the bins since that the center bins will be summed up to one bin
% temp = 0;
% nbins =  nbins_r*nbins_theta-nbins_theta+1;% the sum bins for single center
% F_temp = zeros(ntotalbh,nbins*nthet);
% for i = 1:nbins_r:nbins_r*nbins_theta
%     % for histogram(bins(x,y))
% %     temp = F_t(:,(i-1)*nthet+1:i*nthet)+temp;
%     % for max(bins(x,y))
%     temp = max(F_t(:,(i-1)*nthet+1:i*nthet),temp);
%     F_temp(:,1:nthet) = temp;
% end
% for j = 0:nbins_theta-1
%     for i = 2+j*nbins_r:2+j*nbins_r+(nbins_r-2)
%         F_temp(:,(i-j-1)*nthet+1:(i-j)*nthet) = F_t(:,(i-1)*nthet+1:i*nthet);
%     end
% end
% F_t = F_temp;
% F_t = F_temp./repmat(sum(F_temp,2),1,nbins);


