function YesOrNo = FileExistsOverwrite(fn)

%% File exists. Overwrite?
%
%
% YC at ES lab
% Created on Apr. 25, 2008
% Last modified on Apr. 25, 2008

if exist(fn,'file')
  Answer = ...
    questdlg(sprintf('%s has already existed! Overwrite?',fn),'Overwrite?');
  drawnow;
  switch Answer
    case 'Yes'
      YesOrNo = true;
    otherwise
      YesOrNo = false;
  end
else
  YesOrNo = true;
end


