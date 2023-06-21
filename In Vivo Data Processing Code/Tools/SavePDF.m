function SavePDF(hgfFig,fnPDF,Orientation)

%% SavePDF(hgfFig,fnPDF,Orient)
% save figures into a pdf file
%
% hgfFig is a vector of figure handles
% fnPDF is the file name of pdf file including path name
% Orient is the orientation of page
%
%
% YC at ES lab
% Created on Jun. 7, 2018
% Last modified on Jun. 10, 2018

%% Check inputs and/or outputs
if ~exist('Orient','var')
  Orientation = 'landscape';
end

[pn,fn] = fileparts(fnPDF);

fnPS = [fullfile(pn,fn),'.ps'];
if exist(fnPS,'file')
  delete(fnPS);
end

hgfFig = hgfFig(:);

VerMatlabYear = sscanf(version('-release'),'%d');

%% Save figures to ps file
drawnow;pause(0.1);
for k = 1:length(hgfFig)
  set(hgfFig(k), ...
      'PaperOrientation',Orientation, ...
      'PaperType','usletter');
  if VerMatlabYear<2018
    print(hgfFig(k),fnPS,'-dpsc','-append');
  else
    print(hgfFig(k),fnPS,'-dpsc','-append','-fillpage');
  end
end

%% Convert ps to pdf
system(['ps2pdf ',fnPS,' ',fnPDF]);
delete(fnPS);


