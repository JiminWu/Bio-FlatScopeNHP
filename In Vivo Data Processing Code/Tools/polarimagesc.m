function im = polarimagesc(varargin)
%% polarimagesc.m
%   im = polarimagesc(polarimg)
%   im = polarimagesc(polarimg, clim)
%   im = polarimagesc(ax, polarimg)
%   im = polarimagesc(ax, polarimg, clim)
% Plots a polar image on the current or specified axes. Polar image is
% represented in the complex (Euler's) form. The angle of the image is
% rendered in HSV colorspace. And the amplitude of the image modulates
% brightness within the specified CLIM range. If CLIM is not supplied, then
% the amplitude axis is scaled from 0 to maximum amplitude value.
%
% Returns the handle to the plotted image.
%
% July 22, 2018
% spencer.chen@utexas.edu

%% Initialize

assert(numel(varargin) >= 1, 'Invalid input');

% set the plotting axis
if isscalar(varargin{1}) && ishandle(varargin{1})
  ax = varargin{1};
  varargin = varargin(2:end);
else
  ax = gca;
end

polarimg = varargin{1};
assert(ndims(polarimg) <= 2, 'Needs 2D image');

% set clim
if (numel(varargin) > 1)
  clim = varargin{2};
  assert(numel(clim) == 2, 'Needs 2 value vector for amplitude range');
  assert(all(clim >= 0), 'Needs positive values for amplitude range');
else
  clim = [0 max(abs(polarimg(:)))];
end


%% Map colors

% HSV on polar angle
cmap = hsv(360);
sz   = size(polarimg);
im   = angle(polarimg) / pi * 180;
im   = mod(round(im)+360, 360);
im   = cmap(im(:)+1,:);
im   = reshape(im, [sz 3]);

% Brightness on amplitude
amp  = abs(polarimg);
amp  = max(amp - clim(1), 0);
amp  = min(amp, clim(2));
amp  = amp / (clim(2)-clim(1));
im   = im .* amp;

im = image(ax, im);



