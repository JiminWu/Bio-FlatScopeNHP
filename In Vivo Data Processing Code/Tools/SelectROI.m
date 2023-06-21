function [Crop, MethodMask, Thresholds, Mask] = SelectROI(hgaMap, mapLabel, hgaMask)

%% function [Crop, MethodMask, Thresholds, Mask] = SelectROI(hgaMap, mapLabel, hgaMask)
%
% Interactive selection of ROI.
%
% Input:
%   - hgaMap: array of response maps in image handles used ROi selection.
%             typically response map and d-prime map
%   - mapLabel: cell array of strings describing content of each ma
%   - hasMask: axes to draw the threshold mask
%
% Output:
%   - Crop: ROI with Thresholding
%   - MethodMask: Which map used to select the ROI (0 for no thresholding)
%   - Thresholds: Threshold set for each map (whether or not used)
%   - Mask: ROI mask
%
%
% SC at ES lab
% Created on Jan. 31, 2016


%% Check input 

assert(~isempty(hgaMap) && all(ishandle(hgaMap)), 'Invalid map axes handles.');

if exist('hgaMask','var')
  assert(ishandle(hgaMask), 'Invalid map axes handles.');
end

if exist('mapLabel','var')
  assert(numel(hgaMap) == numel(mapLabel), 'Number of map labels need to match the number of maps.');
end


%% Create intial ROI and draw ROI
INPUT_TAG = 'Select a mask. Cancel when done';

xdata = get(hgaMap(1),'XData');
ydata = get(hgaMap(1),'YData');
Crop = [xdata(1) ydata(1) xdata(2)-xdata(1)+1 ydata(2)-ydata(1)+1];
Width = Crop(3);
Height = Crop(4);

hgoRect    = zeros(1,numel(hgaMap));
Thresholds = zeros(1,numel(hgaMap));
cdata      = cell(1,numel(hgaMap));
for mm = 1:numel(hgaMap),
  hgoRect(mm) = ...
    rectangle('Position',Crop, ...
              'EdgeColor','r', ...
              'FaceColor','None', ...
              'Curvature',[0,0], ...
              'LineWidth',2, ...
              'Parent', get(hgaMap(mm),'Parent'));
  cdata{mm} = get(hgaMap(mm), 'CData');
  Thresholds(mm) = max(cdata{mm}(:))/2;
end
          
set(hgaMap,'ButtonDownFcn',{@gMaskUpdate, hgoRect, INPUT_TAG});


%% User input to finte-tune ROI

MethodMask = 2;
if exist('hgaMask','var')

  MaskSelect = cellfun(@(x,y) sprintf('%d. %s, ',x,y), num2cell(1:numel(mapLabel)), mapLabel, 'UniformOutput', false);
  MaskSelect{end} = MaskSelect{end}(1:end-1);
  MaskSelect{2} = [MaskSelect{2}, ' (default)'];
  MaskSelect = ['0. no mask, ', MaskSelect];
  MaskSelect = ['(',cat(2,MaskSelect{:}),'):'];

  ThreshInput = cellfun(@(x) sprintf('Threshold for %s',x), mapLabel, 'UniformOutput', false);

  Mask = cdata{MethodMask} > Thresholds(MethodMask);
else
  Mask = [];
end

while true   
  set(hgoRect,'Position',Crop);
  
  if exist('hgaMask','var')
    
    LabelMask = cellfun(@(x,y) sprintf('Mask (%s>%0.2f)',x,y), mapLabel, num2cell(Thresholds), 'UniformOutput', false);
    LabelMask = ['No mask', LabelMask];
      
    MaskCrop = false(Height,Width);
    MaskCrop(Crop(2)-1+(1:Crop(4)),Crop(1)-1+(1:Crop(3))) = true;
    if (MethodMask == 0)
      Mask = MaskCrop;
    else
      Mask = MaskCrop & cdata{MethodMask} > Thresholds(MethodMask);
    end

    axes(hgaMask);
    imagesc(Mask,[0,1]);
    colorbar;
    axis image off;
    title({LabelMask{MethodMask+1}, ...
           sprintf('ROI = [%d,%d,%d,%d]',Crop)}, ...
          'FontSize',12, ...
          'FontWeight','Bold');

    Answer = ...
      inputdlg([['Select a mask, cancel when done. ', MaskSelect], ...
                ThreshInput(:)', ...
                'Select ROI (pixel, x0,y0,width,height):'], ...
               INPUT_TAG,1, ...
               [sprintf('%g',MethodMask), ...
                arrayfun(@(x) sprintf('%g',x), Thresholds, 'UniformOutput', false), ...
                sprintf('%d,%d,%d,%d',Crop)], ...
                struct('WindowStyle', 'normal'));
    drawnow;pause(0.1);              
    
    if isempty(Answer)
      break;
    end
    
    MethodMask = str2double(Answer{1});
    Thresholds = cellfun(@(x) str2double(x), Answer(2:end-1)');
    Crop = str2num(Answer{4});

    if isempty(MethodMask)||~isscalar(MethodMask)|| ...
       MethodMask<0||MethodMask>numel(hgaMap)|| ...
       any(isempty(Thresholds)) || ...
       any(isnan(Thresholds)) || ...
       isempty(Crop)||length(Crop(:))~=4|| ...
       Crop(1)<1||Crop(1)>Width|| ...
       Crop(2)<1||Crop(2)>Height|| ...
       Crop(3)<1||Crop(3)>Width|| ...
       Crop(4)<1||Crop(4)>Height|| ...
       (Crop(1)+Crop(3)-1)>Width|| ...
       (Crop(2)+Crop(4)-1)>Height
      beep;
      warndlg(['Some required parameters are wrong!', ...
               ' Please re-input.'],'Warning!','modal');
      drawnow;pause(0.1);
      uiwait;
    else
      MaskCrop = false(Height,Width);
      MaskCrop(Crop(2)-1+(1:Crop(4)),Crop(1)-1+(1:Crop(3))) = true;
      if (MethodMask == 0)
        Mask = MaskCrop;
      else
        Mask = MaskCrop & cdata{MethodMask} > Thresholds(MethodMask);
      end
    end 
    
  else
    Answer = ...
      inputdlg({'Select ROI (pixel, x0,y0,width,height):'}, ...
               INPUT_TAG,1, ...
               {sprintf('%d,%d,%d,%d',Crop)}, ...
               struct('WindowStyle', 'normal'));
    drawnow;pause(0.1);
    
    if isempty(Answer)
      break;
    end
    
    Crop = str2num(Answer{1});
    
    if isempty(Crop)||length(Crop(:))~=4|| ...
       Crop(1)<1||Crop(1)>Width|| ...
       Crop(2)<1||Crop(2)>Height|| ...
       Crop(3)<1||Crop(3)>Width|| ...
       Crop(4)<1||Crop(4)>Height|| ...
       (Crop(1)+Crop(3)-1)>Width|| ...
       (Crop(2)+Crop(4)-1)>Height
      beep;
      warndlg(['Required parameters are wrong!', ...
               ' Please re-input.'],'Warning!','modal');
      drawnow;pause(0.1);
      uiwait;

    end 
    
    
  end

end

% unset the buttondown functions to adjust mask window
set(hgaMap,'ButtonDownFcn','');




%%
function gMaskUpdate(src, eventdata, rectH, dlgTag)

    if (isempty(rectH))
        return;
    end

    % get xy coordinate of mouse click
    ax = get(src,'Parent');
    xy = get(ax,'CurrentPoint');
    xy = xy(1,1:2);

    % identify closest edges
    rect = get(rectH(1),'Position');
    rect(3:4) = rect(3:4) + rect(1:2);
    xdiff = diff(abs(rect([1 3]) - xy(1)));
    ydiff = diff(abs(rect([2 4]) - xy(2)));
    
    % move left hand edge
    if (xdiff(1) > 0)
        rect(1) = xy(1);
    % move right hand edge
    else
        rect(3) = xy(1);
    end

    % move bottom edge
    if (ydiff(1) > 0)
        rect(2) = xy(2);
    % move top hand edge
    else
        rect(4) = xy(2);
    end
    
    rect(3:4) = rect(3:4) - rect(1:2);
    rect = round(rect);
    
    % update rectangle
    set(rectH,'Position', rect);
   
    % update inputdlg
    dlgH  = findall(0,'Type','figure','HandleVisibility','callback','Tag',dlgTag);
    editH = findall(dlgH,'Style','edit');
    editStr = get(editH,'String');
    if iscell(editStr)
      editStr = cellfun(@(x) numel(str2num(x)), editStr);
    else
      editStr = numel(str2num(editStr));
    end
    editH   = editH(find(editStr == 4,1));
%     editH = max(editH); %find last one created
    set(editH,'String',sprintf('%d,%d,%d,%d',rect));
    
    
end


end