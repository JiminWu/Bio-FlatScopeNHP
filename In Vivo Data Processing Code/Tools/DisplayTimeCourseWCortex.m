function hgfTC = DisplayTimeCourseWCortex(fnRoot,AvgCondDisp,iCondDisp,iCondMinus,lCondDispComb,CORTEX)

%% function hgfTC = DisplayTimeCourseWCortex(fnRoot,AvgCondDisp,iCondDisp,iCondMinus,lCondDispComb,CORTEX)
%
% Display time course
%
% Input:
%   - fnRoot: identifier of the data run
%   - AvgCondDisp: average response from *Avg.mat.
%   - iCondDisp: conditions to display
%   - iCondMinus: blank condition to remove
%   - lCondDispComb: whether to combined conditions
%   - CORTEX: image of the cortex.
%
% Output:
%   - hgfTC is the handle of figure for TC
%
% Parameters:
%   - iCondDisp represents the conditions for display.
%   - iCondMinus represents the conditions for substraction, always combined.
%   - lCondDispComb indicates if combine the display conditions.
%
%
% SC at ES lab
% Created on Apr. 15, 2008
% Last modified on Dec. 20, 2015


%% Timer starts
TCCondDisp = AvgCondDisp(:,:,:,iCondDisp);

if ~isempty(iCondMinus)
  TCCondDisp = ...
    TCCondDisp-repmat(nanmean(AvgCondDisp(:,:,:,iCondMinus),4), ...
                      [1,1,1,length(iCondDisp)]);
end

if lCondDispComb
  TCCondDisp = nanmean(TCCondDisp,4);
end

[nRow,nColumn,nFrames,nCond] = size(TCCondDisp);

%% Remove mean
TCCondDisp = ...
  TCCondDisp-repmat(nanmean(TCCondDisp,3),[1,1,nFrames,1]);

%% Display

hgfTC = figure;
if lCondDispComb
  tStr1 = sprintf('%d+',iCondDisp);
  tStr1(end) = ')';
  tStr1 = ['(',tStr1];
else
  tStr1 = sprintf('%d,',iCondDisp);
  tStr1(end) = ')';
  tStr1 = ['(',tStr1];
end
tStr2 = sprintf('%d+',iCondMinus);
tStr2(end) = ')';
tStr2 = ['(',tStr2];
set(hgfTC,'NumberTitle','off', ...
          'Name',[fnRoot,': ',tStr1,' - ',tStr2]);

% display reference
hgaTC = axes('Position',[0.05 0.05 0.9 0.9]);

if isempty(CORTEX)
  CORTEX = 0;
end

imagesc(CORTEX);
axis off;
cmap = gray(256);
colormap(cmap(128:end,:));
[CH,CW] = size(CORTEX);

% display worms
YMin = nanmin(TCCondDisp(:));
YMax = nanmax(TCCondDisp(:));
YScale = 0.9*CH/nRow / (YMax-YMin);

hold on
hgoTC = zeros(nRow,nColumn,size(TCCondDisp,4));
for m = 1:nRow
  for n = 1:nColumn
    tx = linspace(0,1,size(TCCondDisp,3)) *0.9*CW/(nColumn+1) + (n-0.95)*CW/nColumn + 0.5;
    ty = squeeze(TCCondDisp(m,n,:,:));
    ty = -YScale*bsxfun(@minus,ty,mean(ty,1)) + (m-0.5)*CH/(nRow) + 0.5;
    hgoTC(m,n,:) = plot(hgaTC,tx,ty);
    set(hgoTC(m,n,:),'ButtonDownFcn',@SingleTC);
    udSingleTC.TC = squeeze(TCCondDisp(m,n,:,:));
    udSingleTC.Row = m;
    udSingleTC.Column = n;
    udSingleTC.FileName = fnRoot;
    udSingleTC.iCondDisp = iCondDisp;
    udSingleTC.iCondMinus = iCondMinus;
    udSingleTC.lCondDispComb = lCondDispComb;
    set(hgoTC(m,n,:),'UserData',udSingleTC);
  end
end
hold off

% Add two scale sliders
hgoScale = ...
  uicontrol('Style','slider','TooltipString','Change Scale',...
            'Units','Normalized','Position',[0.95,0.5,0.03,0.2], ...
            'Min',0.1*YScale,'Max',10*YScale,'Value',YScale, ...
            'Callback',@Scale_Callback);
hgoMove = ...
  uicontrol('Style','slider','TooltipString','Move up/down',...
            'Units','Normalized','Position',[0.95,0.75,0.03,0.2], ...
            'Min',-.5*CH/nRow,'Max',.5*CH/nRow,'Value',0, ...
            'Callback',@Move_Callback);

% Set user data
udTC.hgoTC = hgoTC;
udTC.hgoScale = hgoScale;
udTC.hgoMove = hgoMove;
udTC.YMid = 0;
udTC.YScale = YScale;

set(hgfTC,'UserData',udTC);


annotation(hgfTC, ...
           'TextBox',[0,0.9,1,0.1], ...
           'String', [fnRoot,': ',tStr1,' - ',tStr2], ...
           'HorizontalAlignment','Center', ...
           'FontWeight','bold', ...
           'FontSize',12, ...
           'LineStyle','None');
       
     


function Scale_Callback(hObject, eventdata, handles)
%% Scale_Callback
newYScale = get(hObject,'Value');
udTC = get(get(hObject,'Parent'),'UserData');
ydata = get(udTC.hgoTC, 'YData'); 
ydata = cellfun(@(x) (x-mean(x))*newYScale/udTC.YScale + mean(x), ydata, 'UniformOutput', false);
set(udTC.hgoTC, {'YData'}, ydata);
udTC.YScale = newYScale;
set(get(hObject,'Parent'),'UserData',udTC);



function Move_Callback(hObject, eventdata, handles)
%% Move_Callback
newYMid = get(hObject,'Value');
udTC = get(get(hObject,'Parent'),'UserData');
ydata = get(udTC.hgoTC, 'YData'); 
ydata = cellfun(@(x) x-udTC.YMid - newYMid, ydata, 'UniformOutput', false);
set(udTC.hgoTC, {'YData'}, ydata);
udTC.YMid = -newYMid;
set(get(hObject,'Parent'),'UserData',udTC);


function SingleTC(hObject, eventdata, handles)
%% SingleTC
udSingleTC = get(hObject,'UserData');

tStr2 = sprintf('%d+',udSingleTC.iCondMinus);
tStr2(end) = ')';
tStr2 = ['(',tStr2];
if udSingleTC.lCondDispComb
  tStr1 = sprintf('%d+',udSingleTC.iCondDisp);
  tStr1(end) = ')';
  tStr1 = ['(',tStr1];
  StrTitle = ...
    [sprintf('%s (X%d,Y%d): ', ...
             udSingleTC.FileName,udSingleTC.Column,udSingleTC.Row), ...
     tStr1,' - ',tStr2];
else
  tStr1 = sprintf('%d,',udSingleTC.iCondDisp);
  tStr1(end) = ')';
  tStr1 = ['(',tStr1];
  StrTitle = ...
    [sprintf('%s (X%d,Y%d): ', ...
             udSingleTC.FileName,udSingleTC.Column,udSingleTC.Row), ...
     tStr1,' - ',tStr2];
end

figure;
set(gcf,'NumberTitle','off', ...
        'Name',sprintf('%s: (X%d,Y%d)', ...
                       udSingleTC.FileName, ...
                       udSingleTC.Column,udSingleTC.Row));
plot(udSingleTC.TC*100);
axis tight;
grid on;
xlabel('Frame #', ...
       'FontWeight','bold', ...
       'FontSize',12);
ylabel('\DeltaF/F (%)', ...
       'FontWeight','bold', ...
       'FontSize',12);
title(StrTitle, ...
      'FontWeight','bold', ...
      'FontSize',12);

if ~udSingleTC.lCondDispComb
  StrLegend = cell(1,length(udSingleTC.iCondDisp));
  for i = 1:length(udSingleTC.iCondDisp)
    StrLegend{i} = sprintf('Cond %d',udSingleTC.iCondDisp(i));
  end
  legend(StrLegend);
  legend boxoff;
end


