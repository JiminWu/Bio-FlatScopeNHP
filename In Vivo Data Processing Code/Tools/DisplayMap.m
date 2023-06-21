function hgfMap = DisplayMap(A,Title,Name)

%% Display map
% A must be either an 3D array (MxNxK) or
%     an cell vector (length K) with each cell of a 2D array
% Title is a string cell vector, matching A with same length K
% Name is a string for the name of figure
%
%
% YC at ES lab
% Created on May 28, 2008
% Last modified on Jun. 5, 2008

%% Parameters
if iscell(A)
  nMaps = length(A);
  YMin = inf;
  YMax = -inf;
  for k = 1:nMaps
    YMin = min(YMin,min(A{k}(:)));
    YMax = max(YMax,max(A{k}(:)));
  end
else
  nMaps = size(A,3);
  YMin = min(A(:));
  YMax = max(A(:));
end
YMax = 2*YMax;
YMin = 2*YMin;
YMid = (YMin+YMax)/2;
YScale = 1;

nRow = round(sqrt(nMaps/12)*3);
nCol = round(sqrt(nMaps/12)*4);
nCol = nCol+(nRow.*nCol<nMaps);

%% Display
hgfMap = figure;
set(hgfMap,'NumberTitle','off','Name',Name);
hgaMap = zeros(1,nMaps);
for k = 1:nMaps
  m = floor((k-1)/nCol)+1;
  n = mod(k-1,nCol)+1;
  hgaMap(k) = ...
    axes('Position',[(n-1+0.1)*0.9/nCol,1-m/nRow,0.9/nCol*0.9,1/nRow*0.9]);
  if iscell(A)
    thgo = imagesc(A{k},[YMin,YMax]);
  else
    thgo = imagesc(A(:,:,k),[YMin,YMax]);
  end
  axis equal tight off;
  title(Title{k}, ...
        'FontWeight','bold', ...
        'FontSize',12);
  set(thgo,'ButtonDownFcn',@SingleMap);
  if iscell(A)
    udSingleMap.Map = A{k};
  else
    udSingleMap.Map = A(:,:,k);
  end
  udSingleMap.Title = Title{k};
  udSingleMap.Name = Name;
  udSingleMap.CLims = [YMin,YMax];
  set(thgo,'UserData',udSingleMap);
end

% Add colorbar
hgaColorbar = axes('Position',[0.91,0.1,0.01,0.3]);
imagesc(1,-1:0.1:1,(1:-0.1:-1)',[-1,1]);
axis tight;
set(gca,'XTick',[]);
set(gca,'YTick',[-1,0,1], ...
        'YTickLabel',{sprintf('%5.2g',YMax), ...
                      sprintf('%5.2g',YMid), ...
                      sprintf('%5.2g',YMin)}, ...
        'YAxisLocation','Right');
box on;

% Add two scale sliders
hgoScale = ...
  uicontrol('Style','slider','TooltipString','Change Scale',...
            'Units','normalized','Position',[0.95,0.5,0.03,0.2], ...
            'Min',1,'Max',10,'Value',1, ...
            'Callback',@Scale_Callback);
hgoMove = ...
  uicontrol('Style','slider','TooltipString','Move up/down',...
            'Units','normalized','Position',[0.95,0.75,0.03,0.2], ...
            'Min',-YMax,'Max',-YMin,'Value',-YMid, ...
            'Callback',@Move_Callback);

% Set user data
udMap.hgaMap = hgaMap;
udMap.hgaColorbar = hgaColorbar;
udMap.hgoScale = hgoScale;
udMap.hgoMove = hgoMove;
udMap.YMin = YMin;
udMap.YMax = YMax;
udMap.YMid = -YMid;
udMap.YScale = YScale;

udMap.tMin = YMin;
udMap.tMax = YMax;

set(hgfMap,'UserData',udMap);

%% Scale_Callback
function Scale_Callback(hObject, eventdata, handles)

udMap = get(get(hObject,'Parent'),'UserData');
udMap.YScale = get(hObject,'Value');
set(get(hObject,'Parent'),'UserData',udMap);

tMin = (udMap.YMin-udMap.YMax)/2/udMap.YScale-udMap.YMid;
tMax = (udMap.YMax-udMap.YMin)/2/udMap.YScale-udMap.YMid;
set(udMap.hgaMap(:),'CLim',[tMin,tMax]);
set(udMap.hgaColorbar, ...
    'YTick',[-1,0,1], ...
    'YTickLabel',{sprintf('%7.2g',tMax), ...
                  sprintf('%7.2g',-udMap.YMid), ...
                  sprintf('%7.2g',tMin)}, ...
    'YAxisLocation','Right');

%% Move_Callback
function Move_Callback(hObject, eventdata, handles)

udMap = get(get(hObject,'Parent'),'UserData');
udMap.YMid = get(hObject,'Value');
set(get(hObject,'Parent'),'UserData',udMap);

tMin = (udMap.YMin-udMap.YMax)/2/udMap.YScale-udMap.YMid;
tMax = (udMap.YMax-udMap.YMin)/2/udMap.YScale-udMap.YMid;
set(udMap.hgaMap(:),'CLim',[tMin,tMax]);
set(udMap.hgaColorbar, ...
    'YTick',[-1,0,1], ...
    'YTickLabel',{sprintf('%7.2g',tMax), ...
                  sprintf('%7.2g',-udMap.YMid), ...
                  sprintf('%7.2g',tMin)}, ...
    'YAxisLocation','Right');

  
%% SingleMap
function SingleMap(hObject, eventdata, handles)

udSingleMap = get(hObject,'UserData');

figure;
set(gcf,'NumberTitle','off','Name',udSingleMap.Name);
imagesc(udSingleMap.Map,udSingleMap.CLims);
axis equal tight off;
title(udSingleMap.Title, ...
      'FontWeight','bold', ...
      'FontSize',12);

colorbar;


