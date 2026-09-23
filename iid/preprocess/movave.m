

% Implements a moving local average filter
%
% Simple and efficient moving-average filter using convolution. Only
% one-dimensional data is accepted. The length of the output is the
% same as the length of the input.
%
% Usage:
%
%       Smoothed Data = movave(Data Vector, Averaging Window Size in Samples)
%
% See also: slidefilter.m, filter

% Hazem Baqaen (Hazem@brown.edu), Simmons lab., Brown University.
% MATLAB 7.
%
% Credit due to Duane Hanselman and Pascal Getreuer for suggestions.
%
% Version 4, Feb. 2006.

function out = movave(data,windowsize)


% Check dimensions of data set
[r,c] = size(data);
if (r~=1) & (c~=1)
    error('Data must be a one-dimensional vector')
elseif (r~=1)
    data = data';
end
clear r,c;


windowsize = round(abs(windowsize));
if windowsize >= length(data)
    windowsize = length(data);
    warning('The window you entered is bigger than or equal to the data length. It has been reduced to match.')
end


a = 1;      % Filter coefficients
b = (1/windowsize)*ones(1,windowsize);

averageddata = filter(b,a,data);

% b = pdf('Normal',-floor(windowsize/2):floor(windowsize/2),0,1);   % gaussian
% averageddata = filter(b,a,data);


out = averageddata;

