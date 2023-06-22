%function [hgfSelectROI,hgfROIAmp] = saROIAmplitude(fnTS,TS,DAVersion)
addpath '.\Codes';
addpath 'E:\2021_12AustinVisit\Chip20211215ForJimin\Chip20211215ForJimin\run6';
protoDir = '.\Chip20211215ForJimin\run6\';
load M28D20211215R6TS.mat
fnTS = 'M28D20211215R6TS.mat';

Condition = TS.Header.Conditions;
Num_valid = TS.Header.Index.iValidBLKCond;
%% function [hgfSelectROI,hgfROIAmp] = saROIAmp(fnTS,TS,DAVersion)
%
% Calculate response maps and amplitudes within ROI
%
% Input:
%   - fnTS is the TS.mat filename, including pathname and extention (.mat).
%   - TS is the trial structure.
%   - DAVersion is the DA version.
%
% Output:
%   - hgfSelectROI is the handle of figure for selecting ROI
%   - hgfROIAmp is the handle of figure for amplitude within ROI
%
% Parameters:
%   - BinSize
%   - Crop
%
% For FFT, time lock to start point of rising edge (corresponding to -pi)
% YC, Apr. 8, 2019
%
% YC at ES lab
% Created on Apr. 18, 2014
% Last modified on May. 14, 2019

%% Timer starts
TimerStart = now;
disp('Calculate time course within ROI!');

%% Check inputs and outputs
[PathName,fnRoot] = fileparts(fnTS);
fnRoot = regexprep(fnRoot,'TS','');

hgfSelectROI = [];
hgfROIAmp = [];

[FileName,PathName] = ...
  uigetfile('*FFT*.mat;*Intg*.mat', ...
            'Select an FFT or integration file',PathName);
drawnow;pause(0.1);

if all(~FileName)
  return;
end

if (isempty(strfind(FileName,'FFT'))&& ...
    isempty(strfind(FileName,'Intg')))|| ...
   isempty(strfind(FileName,fnRoot))
  beep;
  disp('Wrong FFT or integration file!');
  return;
end

fnFFTIntg = fullfile(PathName,FileName);
fnData = [fnFFTIntg(1:(end-4)),'ROIAmp.mat'];
fnFig = [fnFFTIntg(1:(end-4)),'ROIAmp'];

if isempty(strfind(fnFFTIntg,'Bin'))
  BinSize = 1;
else
  BinSize = ...
    sscanf(fnFFTIntg(strfind(fnFFTIntg,'Bin'):end),'Bin%d');
end

Answer = ...
  inputdlg({'Bin size','Calculate mean(1) or RMS(2)'}, ...
           'Parameters',1, ...
           {sprintf('%d',BinSize),'1'});
drawnow;pause(0.1);

if isempty(Answer)
  return;
end

tBinSize = str2double(Answer{1});
MethodAmp = str2double(Answer{2});

if isempty(tBinSize)||any(tBinSize<BinSize)||~isscalar(tBinSize) || ...
   isempty(MethodAmp)||~isscalar(MethodAmp)||MethodAmp<1||MethodAmp>2
  beep;
  disp('Wrong parameters, please check!');
  return;
end

%% Parameters
%DefaultValues;

iCondBlank = 1:TS.Header.NumBlankCond;
nCond = TS.Header.NumValidCond;

%% Load FFT or integration file
load(fnFFTIntg,'DataTrial');

if ~isreal(DataTrial)
  DataTrial = -real(DataTrial);
end

DataTrial = BinND(DataTrial,[1,1]*round(tBinSize/BinSize));
BinSize = BinSize*round(tBinSize/BinSize);

[Height,Width,nTrial] = size(DataTrial);

LabelCond = cell(1,nCond);
for i = 1:nCond
  LabelCond{i} = sprintf('Cond %d',i);
end

%% Calculate reaponse and d'
RespCond = zeros(Height,Width,nCond);
DPCond = zeros(Height,Width,nCond);
for i = 1:nCond
  RespCond(:,:,i) = ...
    mean(DataTrial(:,:,TS.Header.Index.iValidBLKCond{i}),3);
  DPCond(:,:,i) = ...
    CalculateDPrime(DataTrial(:,:,TS.Header.Index.iValidBLKCond{i}), ...
                    DataTrial(:,:,cell2mat(TS.Header.Index. ...
                                           iValidBLKCond(iCondBlank))),3);
end
RespCond = ...
  RespCond-repmat(mean(RespCond(:,:,iCondBlank),3),[1,1,nCond]);

%% Create a ps/pdf file
hgfFig = figure;
annotation('TextBox',[0.05,0.7,0.9,0.1], ...
           'String','Amplitude in ROI', ...
           'HorizontalAlignment','Center', ...
           'FontWeight','bold', ...
           'FontSize',18, ...
           'LineStyle','None');
annotation('TextBox',[0.05,0.5,0.9,0.1], ...
           'String',fnRoot, ...
           'HorizontalAlignment','Center', ...
           'FontWeight','bold', ...
           'FontSize',16, ...
           'LineStyle','None');
annotation('TextBox',[0.05,0.3,0.9,0.1], ...
           'String',TS.Header.Conditions.Description, ...
           'HorizontalAlignment','Center', ...
           'FontWeight','bold', ...
           'FontSize',16, ...
           'LineStyle','None');
annotation('TextBox',[0.05,0.2,0.9,0.1], ...
           'String',date, ...
           'HorizontalAlignment','Center', ...
           'FontWeight','bold', ...
           'FontSize',14, ...
           'LineStyle','None');

hgfFig(end+1) = figure;
annotation('TextBox',[0,0.9,1,0.1], ...
           'String',[fnRoot,'---Condition table'], ...
           'HorizontalAlignment','Center', ...
           'FontName','TimesNewRome', ...
           'FontWeight','bold', ...
           'FontSize',12, ...
           'LineStyle','None');
annotation('TextBox',[0.05,0.05,0.9,0.9], ...
           'String',TS.Header.ConditionTable, ...
           'HorizontalAlignment','Left', ...
           'FontName','TimesNewRome', ...
           'FontWeight','bold', ...
           'FontSize',12, ...
           'LineStyle','None');

%% Select ROI
hgfFig(end+1) = figure;
hgfSelectROI = hgfFig(end);
thTitle = ...
  annotation('TextBox',[0,0.9,1,0.1], ...
             'String', ...
             {FileName, ...
              'Select ROI in response maps'}, ...
             'HorizontalAlignment','Center', ...
             'FontWeight','bold', ...
             'FontSize',12, ...
             'LineStyle','None');
hgaSelectROI = zeros(1,nCond);
[nRow,nCol] = DispRowColumn(nCond);
%nRow = 10;
%nCol = 10;
for i = 1:nCond
  hgaSelectROI(i) = ...
    axes('Position', ...
         [0.05+(mod(i-1,nCol))*0.9/nCol, ...
          0.9-(floor((i-1)/nCol)+1)*0.9/nRow, ...
          0.9/nCol*0.9,0.9/nRow*0.7]);
end
Crop = [1,1,Width,Height];  % [X0,Y0,Width,Height]
CLim = [-0.2,1.2]*max(abs(RespCond(:)));
while true
  for i = 1:nCond
    axes(hgaSelectROI(i));
    imagesc(RespCond(:,:,i),CLim);
    axis image off;
    tCrop = Crop;
    tCrop([3,4]) = tCrop([3,4])-1;
    rectangle('Position',tCrop, ...
              'EdgeColor','r', ...
              'FaceColor','None', ...
              'Curvature',[0,0], ...
              'LineWidth',2);
    title(LabelCond{i}, ...
          'FontWeight','bold', ...
          'FontSize',10);
  end
  Answer = ...
    inputdlg({'Select ROI (pixel, x0,y0,width,height):'}, ...
             'Select ROI, cancle when done',1, ...
             {sprintf('%d,%d,%d,%d',Crop)});
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
    Crop = [1,1,Width,Height];
    beep;
    warndlg(['Some required parameters are wrong!', ...
             ' Please re-input.'],'Warning!','modal');
    drawnow;pause(0.1);
    uiwait;
  end
end
th = colorbar;
tPos = get(th,'Position');
set(th,'Position',[0.952,0.01,tPos(3:4)]);
set(thTitle,'String', ...
            {FileName, ...
             ['Select ROI in response maps---', ...
              sprintf('ROI = [%d,%d,%d,%d], BinSize = %d', ...
                      Crop,BinSize)]});

hgfFig(end+1) = figure;
CLim = [-0.2,1.2]*max(abs(DPCond(:)));
annotation('TextBox',[0,0.9,1,0.1], ...
           'String', ...
           {FileName, ...
            ['d'' maps---', ...
             sprintf('ROI = [%d,%d,%d,%d], BinSize = %d', ...
                     Crop,BinSize)]}, ...
           'HorizontalAlignment','Center', ...
           'FontWeight','bold', ...
           'FontSize',12, ...
           'LineStyle','None');
for i = 1:nCond
  axes('Position', ...
       [0.05+(mod(i-1,nCol))*0.9/nCol, ...
        0.9-(floor((i-1)/nCol)+1)*0.9/nRow, ...
        0.9/nCol*0.9,0.9/nRow*0.7]);
  imagesc(DPCond(:,:,i),CLim);
  axis image off;
  tCrop = Crop;
  tCrop([3,4]) = tCrop([3,4])-1;
  rectangle('Position',tCrop, ...
            'EdgeColor','r', ...
            'FaceColor','None', ...
            'Curvature',[0,0], ...
            'LineWidth',2);
  title(LabelCond{i}, ...
        'FontWeight','bold', ...
        'FontSize',10);
end
th = colorbar;
tPos = get(th,'Position');
set(th,'Position',[0.952,0.01,tPos(3:4)]);
% 
%% Calculate amplitude and d' in ROI
switch MethodAmp
  case 1  % mean, default
    AmpCond = ...
      squeeze(mean(mean(RespCond(Crop(2)-1+(1:Crop(4)), ...
                                 Crop(1)-1+(1:Crop(3)),:),1),2))';
    DPAmpCond = ...
      squeeze(mean(mean(DPCond(Crop(2)-1+(1:Crop(4)), ...
                               Crop(1)-1+(1:Crop(3)),:),1),2))';
  case 2  % RMS
    AmpCond = ...
      squeeze(mean(mean(RespCond(Crop(2)-1+(1:Crop(4)), ...
                                 Crop(1)-1+(1:Crop(3)),:).^2,1),2))';
    DPAmpCond = ...
      squeeze(mean(mean(DPCond(Crop(2)-1+(1:Crop(4)), ...
                               Crop(1)-1+(1:Crop(3)),:).^2,1),2))';
    AmpCond = sqrt(AmpCond);
    DPAmpCond = sqrt(DPAmpCond);
end
% 
hgfFig(end+1) = figure;
hgfROIAmp = hgfFig(end);
ColorCond = hsv(nCond);
annotation('TextBox',[0,0.9,1,0.1], ...
           'String', ...
           {FileName, ...
            sprintf('Response at ROI (%0.1fmmx%0.1fmm)', ...
                    Crop([3,4])*BinSize*TS.Header.Imaging.SizePxl)}, ...
           'HorizontalAlignment','Center', ...
           'FontWeight','bold', ...
           'FontSize',12, ...
           'LineStyle','None');
axes('Position',[0.1,0.5,0.27,0.36]);
for i = 1:nCond
  plot(i,AmpCond(i),'o', ...
       'MarkerFaceColor',ColorCond(i,:), ...
       'Color',ColorCond(i,:));
  hold on;
end
hold off;
axis tight;
xlabel('Condition', ...
       'FontSize',12, ...
       'FontWeight','Bold');
ylabel('Amplitude', ...
       'FontSize',12, ...
       'FontWeight','Bold');
axes('Position',[0.5,0.5,0.27,0.36]);
for i = 1:nCond
  plot(i,DPAmpCond(i),'o', ...
       'MarkerFaceColor',ColorCond(i,:), ...
       'Color',ColorCond(i,:));
  hold on;
end
hold off;
axis tight;
xlabel('Condition', ...
       'FontSize',12, ...
       'FontWeight','Bold');
ylabel('d''', ...
       'FontSize',12, ...
       'FontWeight','Bold');
th = legend(LabelCond);
tPos = get(th,'Position');
set(th,'Position',[0.8,0.86-tPos(4),tPos(3:4)]);

%% Convert ps to pdf
%SavePDF(hgfFig,[fnFig,'.pdf']);
% system(['chgrp eslab ',fnFig,'.pdf']);
% 
% %% Save files
% save(fnData, ...
%      'BinSize','iCondBlank','nCond','', ...
%      'Height','Width','nTrial','LabelCond', ...
%      'RespCond','DPCond','Crop','', ...
%      'AmpCond','DPAmpCond','','', ...
%      '','','','', ...
%      '','','','', ...
%      '');
% system(['chgrp eslab ',fnData]);
% 
% %% Timer ends
% TimerEnd = now;
% disp(['Session started at ',datestr(TimerStart)]);
% disp(['Session ended at ',datestr(TimerEnd)]);

