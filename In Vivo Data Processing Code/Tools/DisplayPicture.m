function hgfPict = DisplayPicture(fnPict)

%% function hgfPict = DisplayPicture(fnPict)
%
% Display a picture file
%
% Input:
%   - fnPict is the picture filename, incliding pathname.
%       If it doesn't refer to an existing file, a dialog will open.
%
% Output:
%   - hgfPict is the handle of figure for picture
%
%
% YC at ES lab
% Created on Aug. 30, 2012
% Last modified on Aug. 30, 2012

%% Check inputs and outputs
if exist('fnPict','var')~=1
  fnPict = '';
end

if exist(fnPict,'file')~=2  % filename not exist
  [FileName,PathName] = ...
    uigetfile('*.bmp;*.jpg;*.tif;*.png','Select a picture file',fnPict);
  drawnow;pause(0.1);
  if all(~FileName)
    hgfPict = [];
    return;
  end
  fnPict = fullfile(PathName,FileName);
end

%% Load picure
[ImagePict,CMap] = imread(fnPict);

%% Display picure
hgfPict = figure;
imagesc(ImagePict);
colormap(CMap);
axis image off;
title(FileName, ...
      'FontWeight','bold', ...
      'FontSize',12);


