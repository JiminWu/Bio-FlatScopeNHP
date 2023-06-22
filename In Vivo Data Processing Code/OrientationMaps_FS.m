
clear;

%%
addpath './Tools';

%%
X = 50:1:500;
Y = 100:1:500;
load('./RawRecon/cond3_recon.mat')
ReconData_condition1 = Xt_Stacku8(Y,X,:);
clearvars Xt_Stacku8
load('./RawRecon/cond4_recon.mat')
ReconData_condition2 = Xt_Stacku8(Y,X,:);
clearvars Xt_Stacku8
load('./RawRecon/cond5_recon.mat')
ReconData_condition3 = Xt_Stacku8(Y,X,:);
clearvars Xt_Stacku8
load('./RawRecon/cond6_recon.mat')
ReconData_condition4 = Xt_Stacku8(Y,X,:);
clearvars Xt_Stacku8
load('./RawRecon/cond7_recon.mat')
ReconData_condition5 = Xt_Stacku8(Y,X,:);
clearvars Xt_Stacku8
load('./RawRecon/cond8_recon.mat')
ReconData_condition6 = Xt_Stacku8(Y,X,:);
clearvars Xt_Stacku8
load('./RawRecon/cond1_recon.mat')
ReconData_heartrate1 = Xt_Stacku8(Y,X,:);
clearvars Xt_Stacku8
load('./RawRecon/cond2_recon.mat')
ReconData_heartrate2 = Xt_Stacku8(Y,X,:); 
clearvars Xt_Stacku8

figure, imshow(ReconData_heartrate2(:,:,1),[]);

%%
TotalTrial = 10;
FramepTrial = 22;
ReconData_heartrate = [];
for i = 1:TotalTrial*FramepTrial
    ReconData_heartrate(:,:,i) = im2uint8(((ReconData_heartrate1(:,:,i))+(ReconData_heartrate2(:,:,i)))./2);
end

%% Parameters
DefaultValues;

nCondStim = 6;%length(iCondStim);

Ort = [0, 30, 60, 90, 120, 150]; %TS.Header.Conditions.GGOrtCond(iCondStim);
nOrt = 6; %nCondStim;

FermiLowCutOff = 0.8;  % cyc/mm
FermiHighCutOff = 2.5;  % cyc/mm

SizePxl = 0.008566;%TS.Header.Imaging.SizePxl;
SigmaRMSPxl = 0.25/SizePxl;  % pixel

LabelStim = cell(1,nCondStim);
for i = 1:nCondStim
  LabelStim{i} = sprintf('%d^o',Ort(i));
end
%% gaFFT
%% Rearrange the data
trail_num = size(ReconData_heartrate,3)/FramepTrial;

for pp = 1:trail_num
    for i = 1:FramepTrial
        % condition0(:,:,i,pp) = (im2double(ReconData_heartrate1(:, :, i+(pp-1)*FramepTrial))+im2double(ReconData_heartrate2(:, :, i+(pp-1)*FramepTrial)))./2;%- avg_multitrail(:,:,i);
        condition0(:,:,i,pp) = im2double(ReconData_heartrate(:, :, i+(pp-1)*FramepTrial));
        condition1(:,:,i,pp) = im2double(ReconData_condition1(:, :, i+(pp-1)*FramepTrial));%- avg_multitrail(:,:,i);
        condition2(:,:,i,pp) = im2double(ReconData_condition2(:, :, i+(pp-1)*FramepTrial));%- avg_multitrail(:,:,i);
        condition3(:,:,i,pp) = im2double(ReconData_condition3(:, :, i+(pp-1)*FramepTrial));
        condition4(:,:,i,pp) = im2double(ReconData_condition4(:, :, i+(pp-1)*FramepTrial));
        condition5(:,:,i,pp) = im2double(ReconData_condition5(:, :, i+(pp-1)*FramepTrial));
        condition6(:,:,i,pp) = im2double(ReconData_condition6(:, :, i+(pp-1)*FramepTrial));
    end
end
condition0_valid = condition0(:,:,3:22,:);
condition1_valid = condition1(:,:,3:22,:);
condition2_valid = condition2(:,:,3:22,:);
condition3_valid = condition3(:,:,3:22,:);
condition4_valid = condition4(:,:,3:22,:);
condition5_valid = condition5(:,:,3:22,:);
condition6_valid = condition6(:,:,3:22,:);

clearvars ReconData_heartrate ReconData_heartrate1 ReconData_heartrate2 ReconData_condition1 ReconData_condition2 ReconData_condition3 ReconData_condition4 ReconData_condition5 ReconData_condition6

%% gaFFT
PeakFreq = 4;
nFrames = 20;
FrameDuration = 50;  %ms
iFramesFFT = 3:1:22;
iFramesNmlTrial = 1:1:2;
ShowFig = 1;

iPeakFreq = ...
    round(PeakFreq/1000*nFrames*FrameDuration)+1;
if iPeakFreq==1
    FTT2Amp = 1/nFrames;  % convert to peak to trough, DC component
else
    FTT2Amp = 4/nFrames;  % convert to peak to trough, Non-DC component
end

DataTrial_heart = complex(zeros(size(condition0_valid,1),size(condition0_valid,2), trail_num));
DataTrial_condition1 = complex(zeros(size(condition1_valid,1),size(condition1_valid,2), trail_num));
DataTrial_condition2 = complex(zeros(size(condition2_valid,1),size(condition2_valid,2), trail_num));
DataTrial_condition3 = complex(zeros(size(condition3_valid,1),size(condition3_valid,2), trail_num));
DataTrial_condition4 = complex(zeros(size(condition4_valid,1),size(condition4_valid,2), trail_num));
DataTrial_condition5 = complex(zeros(size(condition5_valid,1),size(condition5_valid,2), trail_num));
DataTrial_condition6 = complex(zeros(size(condition6_valid,1),size(condition6_valid,2), trail_num));

if ShowFig == 1
    Freq = ((1:nFrames)-1)/nFrames/FrameDuration*1000;
    iWidth = round(size(condition1_valid,1)/4);
    iHeight = round(size(condition1_valid,2)/4);
end


for j = 1:trail_num
    fprintf('FFTing BLK file for trial %03d/%03d ...\n', ...
        j,trail_num);
    tTrial0 =  condition0(:,:,:,j);
    tFFTTrial0 = ... %fft(tTrial(:,:,iFramesFFT),[],3);
        fft(tTrial0(:,:,iFramesFFT)./ ...
        repmat(mean(tTrial0(:,:,iFramesNmlTrial),3), ...
        [1,1,nFrames]),[],3);
    DataTrial_heart(:,:,j) = tFFTTrial0(:,:,iPeakFreq)*FTT2Amp;

    fprintf('FFTing BLK file for trial %03d/%03d ...\n', ...
        j,trail_num);
    tTrial1 =  condition1(:,:,:,j);
    tFFTTrial1 = ... %fft(tTrial(:,:,iFramesFFT),[],3);
        fft(tTrial1(:,:,iFramesFFT)./ ...
        repmat(mean(tTrial1(:,:,iFramesNmlTrial),3), ...
        [1,1,nFrames]),[],3);
    DataTrial_condition1(:,:,j) = tFFTTrial1(:,:,iPeakFreq)*FTT2Amp;

    if ShowFig == 1
        if j==1
            hgfSpectrum = figure;
            set(hgfSpectrum,'NumberTitle','off', ...
                'Name','FFT spectrum');
        else
            set(0,'CurrentFigure',hgfSpectrum);
        end

        tFFTTrialSpectrum = ...
            squeeze(abs(mean(mean(tFFTTrial1(iWidth, iHeight, :),1), 2)))*FTT2Amp;
        tFFTTrialSpectrum(1) = NaN;

        plot(Freq,tFFTTrialSpectrum, ...
            'Color','b', ...
            'LineWidth',2);
        axis tight;
        xlim([0,PeakFreq*4]);
        line([1,1]*Freq(iPeakFreq),ylim, ...
            'Color','r', ...
            'LineStyle','--', ...
            'LineWidth',2);
        xlabel('Freq (Hz)', ...
            'FontWeight','bold', ...
            'FontSize',12);
        ylabel('FFT amp', ...
            'FontWeight','bold', ...
            'FontSize',12);
        title('Spectum on center', ...
            'FontWeight','bold', ...
            'FontSize',12);
    end

    fprintf('FFTing BLK file for trial %03d/%03d ...\n', ...
        j,trail_num);
    tTrial2 =  condition2(:,:,:,j);
    tFFTTrial2 = ... %fft(tTrial(:,:,iFramesFFT),[],3);
        fft(tTrial2(:,:,iFramesFFT)./ ...
        repmat(mean(tTrial2(:,:,iFramesNmlTrial),3), ...
        [1,1,nFrames]),[],3);
    DataTrial_condition2(:,:,j) = tFFTTrial2(:,:,iPeakFreq)*FTT2Amp;

     fprintf('FFTing BLK file for trial %03d/%03d ...\n', ...
        j,trail_num);
    tTrial3 =  condition3(:,:,:,j);
    tFFTTrial3 = ... %fft(tTrial(:,:,iFramesFFT),[],3);
        fft(tTrial3(:,:,iFramesFFT)./ ...
        repmat(mean(tTrial3(:,:,iFramesNmlTrial),3), ...
        [1,1,nFrames]),[],3);
    DataTrial_condition3(:,:,j) = tFFTTrial3(:,:,iPeakFreq)*FTT2Amp;

     fprintf('FFTing BLK file for trial %03d/%03d ...\n', ...
        j,trail_num);
    tTrial4 =  condition4(:,:,:,j);
    tFFTTrial4 = ... %fft(tTrial(:,:,iFramesFFT),[],3);
        fft(tTrial4(:,:,iFramesFFT)./ ...
        repmat(mean(tTrial4(:,:,iFramesNmlTrial),3), ...
        [1,1,nFrames]),[],3);
    DataTrial_condition4(:,:,j) = tFFTTrial4(:,:,iPeakFreq)*FTT2Amp;

     fprintf('FFTing BLK file for trial %03d/%03d ...\n', ...
        j,trail_num);
    tTrial5 =  condition5(:,:,:,j);
    tFFTTrial5 = ... %fft(tTrial(:,:,iFramesFFT),[],3);
        fft(tTrial5(:,:,iFramesFFT)./ ...
        repmat(mean(tTrial5(:,:,iFramesNmlTrial),3), ...
        [1,1,nFrames]),[],3);
    DataTrial_condition5(:,:,j) = tFFTTrial5(:,:,iPeakFreq)*FTT2Amp;

     fprintf('FFTing BLK file for trial %03d/%03d ...\n', ...
        j,trail_num);
    tTrial6 =  condition6(:,:,:,j);
    tFFTTrial6 = ... %fft(tTrial(:,:,iFramesFFT),[],3);
        fft(tTrial6(:,:,iFramesFFT)./ ...
        repmat(mean(tTrial6(:,:,iFramesNmlTrial),3), ...
        [1,1,nFrames]),[],3);
    DataTrial_condition6(:,:,j) = tFFTTrial6(:,:,iPeakFreq)*FTT2Amp;
end

clearvars condition0 condition1 condition2 condition3 condition4 condition5 condition6
clearvars condition0_valid condition1_valid condition2_valid condition3_valid condition4_valid condition5_valid condition6_valid
clearvars tTrial0 tTrial1 tTrial2 tTrial3 tTrial4 tTrial5 tTrial6
clearvars tFFTTrial0 tFFTTrial1 tFFTTrial2 tFFTTrial3 tFFTTrial4 tFFTTrial5 tFFTTrial6
%%

DataTrial_heart(isnan(DataTrial_heart))=0;
DataTrial_condition1(isnan(DataTrial_condition1))=0;
DataTrial_condition2(isnan(DataTrial_condition2))=0;
DataTrial_condition3(isnan(DataTrial_condition3))=0;
DataTrial_condition4(isnan(DataTrial_condition4))=0;
DataTrial_condition5(isnan(DataTrial_condition5))=0;
DataTrial_condition6(isnan(DataTrial_condition6))=0;

DataTrial_heart1 = abs(DataTrial_heart-repmat(mean(DataTrial_heart,3),[1,1,trail_num]));
DataTrial_condition1 = abs(DataTrial_condition1-repmat(mean(DataTrial_heart,3),[1,1,trail_num]));
DataTrial_condition2 = abs(DataTrial_condition2-repmat(mean(DataTrial_heart,3),[1,1,trail_num]));
DataTrial_condition3 = abs(DataTrial_condition3-repmat(mean(DataTrial_heart,3),[1,1,trail_num]));
DataTrial_condition4 = abs(DataTrial_condition4-repmat(mean(DataTrial_heart,3),[1,1,trail_num]));
DataTrial_condition5 = abs(DataTrial_condition5-repmat(mean(DataTrial_heart,3),[1,1,trail_num]));
DataTrial_condition6 = abs(DataTrial_condition6-repmat(mean(DataTrial_heart,3),[1,1,trail_num]));

% DataCond = ...
%   complex(zeros(size(condition1,1),size(condition1,2), trail_num_1));
%% Create a ps/pdf file
hgfFig = figure;
annotation('TextBox',[0.05,0.7,0.9,0.1], ...
           'String','Orientation map', ...
           'HorizontalAlignment','Center', ...
           'FontWeight','bold', ...
           'FontSize',18, ...
           'LineStyle','None');
% annotation('TextBox',[0.05,0.5,0.9,0.1], ...
%            'String',fnRoot, ...
%            'HorizontalAlignment','Center', ...
%            'FontWeight','bold', ...
%            'FontSize',16, ...
%            'LineStyle','None');
annotation('TextBox',[0.05,0.3,0.9,0.1], ...
           'String','', ...
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

%% Load files
%load(fnFFT,'DataTrial');

DataTrial = zeros(size(DataTrial_condition1,1),size(DataTrial_condition1,2),70);
DataTrial(:,:,1:10) = DataTrial_heart;
DataTrial(:,:,11:20) = DataTrial_condition1;
DataTrial(:,:,21:30) = DataTrial_condition2;
DataTrial(:,:,31:40) = DataTrial_condition3;
DataTrial(:,:,41:50) = DataTrial_condition4;
DataTrial(:,:,51:60) = DataTrial_condition5;
DataTrial(:,:,61:70) = DataTrial_condition6;

if ~isreal(DataTrial)
  DataTrial = abs(DataTrial);
end

[Height,Width,nTrial] = size(DataTrial);

clearvars DataTrial_heart DataTrial_condition1 DataTrial_condition2 DataTrial_condition3 DataTrial_condition4 DataTrial_condition5 DataTrial_condition6
%% Low-pass filtration
DataTrial = FilterFermi2D(DataTrial,0,FermiHighCutOff,SizePxl);

%% Average
RespCond = zeros(Height,Width,nCondStim);
DPCond = zeros(Height,Width,nCondStim);
for i = 1:nCondStim
  RespCond(:,:,i) = ...
    mean(DataTrial(:,:,i*10+1:(i+1)*10),3);
  DPCond(:,:,i) = ...
    CalculateDPrime( ...
      DataTrial(:,:,i*10+1:(i+1)*10), ...
      DataTrial(:,:,1:10),3);
end
RespCond = ...
  RespCond- ...
  repmat(mean(DataTrial(:,:,i*10+1:(i+1)*10),3),[1,1,nCondStim]);

DisplayMap(RespCond,LabelStim, ...
           sprintf(['Response map with low-pass filtration ', ...
                    '(%1.1f cyc/mm)'], ...
                   FermiHighCutOff));
DisplayMap(DPCond,LabelStim, ...
           sprintf('d'' map with low-pass filtration (%1.1f cyc/mm)', ...
                   FermiHighCutOff));

RespCondSave = RespCond./0.01;
% for i = 1:6
%     imwrite((RespCondSave(:,:,i)),sprintf('ResultFigures/FS_RespCond_%02d.png',i));
% end

%% High-pass filtration
[Spct1D,SF1D] = ...
  CalculateFFTAmp1D(RespCond-repmat(mean(RespCond,3), ...
                                    [1,1,nCondStim]),SizePxl);
Spct1D = mean(Spct1D,3);
Spct1D = Spct1D/max(Spct1D(2:end));
nSF1D = length(SF1D);

RespCondFilt = FilterFermi2D(RespCond,FermiLowCutOff,inf,SizePxl);

%% Remove the mean response map
RespCondFilt = RespCondFilt-repmat(mean(RespCondFilt,3),[1,1,nCondStim]);

hgfFig(end+1) = ...
  DisplayMap(RespCondFilt,LabelStim, ...
             sprintf(['d'' map with band-pass filtration ', ...
                      '(%1.1f~%1.1f cyc/mm)'], ...
                     FermiLowCutOff,FermiHighCutOff));
colormap gray;

%% PCA for orientation data
nPCAComp = 2;
[PCACoef,PCAScore,~,~,PCAExpl] = ...
  pca(reshape(RespCondFilt,[Height*Width,nOrt]));

PCAComp = reshape(PCAScore,[Height,Width,nOrt]);

RespCondPCA = ...
  reshape(PCAScore(:,1:nPCAComp)*PCACoef(:,1:nPCAComp)', ...
          [Height,Width,nOrt]);

CorrResp = zeros(1,nOrt);
for i = 1:nOrt
  tCorr = corrcoef(RespCondPCA(:,:,i),RespCondFilt(:,:,i));
  CorrResp(i) = tCorr(1,2);
end

LabelPCA = cell(1,nCondStim);
for i = 1:nCondStim
  LabelPCA{i} = sprintf('PCA%d---%0.1f%%',i,PCAExpl(i));
end
hgfFig(end+1) = ...
  DisplayMap(PCAComp,LabelPCA,'PCA');
colormap gray;

%% Mask the area with poor signals
RespRMS = sqrt(mean(RespCondFilt.^2,3));
% RespRMS = ...
%   sqrt((RespRMS.^2+imag(hilbert(imag(hilbert(RespRMS))'))'.^2)/2);
tCood.X = -round(3*SigmaRMSPxl):round(3*SigmaRMSPxl);
tCood.Y = tCood.X;
GssRMS = ...
  FuncWoNGaussian2D([1,0,0,0,0,SigmaRMSPxl,SigmaRMSPxl],tCood);
GssRMS = GssRMS/sum(GssRMS(:));
RespRMS = CalculateConv2D(RespRMS,GssRMS);

MethodMask = 3;  % define valid area: 0-no mask, 1-response, 2-d', 3-RMS, 4-all
ThsdResp = max(RespCond(:))/3;  % define valid area based on response
ThsdDP = 8;  % define valid area based on d'
ThsdRMS = max(RespRMS(:))/2;  % define valid area based on RMS 2.5

if MethodMask == 2
    Mask = mean(DPCond,3)>ThsdDP;
elseif MethodMask == 3
    Mask = mean(RespRMS,3)>ThsdRMS;
else
end

Crop = [1,1,Width,Height];  % [X0,Y0,Width,Height]

CLimResp = [0,max(RespCond(:))];
CLimDP = [0,10];
CLimRMS = [0,max(RespRMS(:))];

hgfFig(end+1) = figure;
orient landscape;
% annotation('TextBox',[0,0.9,1,0.1], ...
%            'String', ...
%            sprintf('%s---Select a mask',fnRoot), ...
%            'HorizontalAlignment','Center', ...
%            'FontWeight','bold', ...
%            'FontSize',12, ...
%            'LineStyle','None');
axes('Position',[0.1,0.45,0.36,0.48]);
imagesc(mean(RespCond,3)*100,CLimResp*100);
colorbar;
axis image off;
hgoRect1 = ...
  rectangle('Position',Crop, ...
            'EdgeColor','r', ...
            'FaceColor','None', ...
            'Curvature',[0,0], ...
            'LineWidth',2);
title('1. Response (%)', ...
      'FontSize',12, ...
      'FontWeight','Bold');
axes('Position',[0.1,0,0.36,0.48]);
imagesc(mean(DPCond,3),CLimDP);
colorbar;
axis image off;
hgoRect2 = ...
  rectangle('Position',Crop, ...
            'EdgeColor','r', ...
            'FaceColor','None', ...
            'Curvature',[0,0], ...
            'LineWidth',2);
title('2. d''', ...
      'FontSize',12, ...
      'FontWeight','Bold');
axes('Position',[0.6,0.45,0.36,0.48]);
imagesc(RespRMS*100,CLimRMS*100);
colorbar;
axis image off;
hgoRect3 = ...
  rectangle('Position',Crop, ...
            'EdgeColor','r', ...
            'FaceColor','None', ...
            'Curvature',[0,0], ...
            'LineWidth',2);
title('3. RMS (%)', ...
      'FontSize',12, ...
      'FontWeight','Bold');
hgaMask = axes('Position',[0.6,0,0.36,0.48]);

% while true
  LabelMask = ...
    {'No mask', ...
     sprintf('Mask (Resp>%0.2f%%)',ThsdResp*100), ...
     sprintf('Mask (d''>%g)',ThsdDP), ...
     sprintf('Mask (RMS>%0.2f%%)',ThsdRMS*100), ...
     sprintf('Mask (Resp>%0.2f%%,d''>%g,RMS>%0.2f%%)', ...
             ThsdResp*100,ThsdDP,ThsdRMS*100)};
  set(hgoRect1,'Position',Crop);
  set(hgoRect2,'Position',Crop);
  set(hgoRect3,'Position',Crop);
  axes(hgaMask);
  imagesc(Mask,[0,1]);
  colorbar;
  axis image off;
  title({LabelMask{MethodMask+1}, ...
         sprintf('ROI = [%d,%d,%d,%d]',Crop)}, ...
        'FontSize',12, ...
        'FontWeight','Bold');

%% Calculate cross correlation
CorrOrt = zeros(nCondStim,nCondStim);
for i = 1:nCondStim
  tRespCondFilt1 = RespCondFilt(:,:,i);
  for j = 1:nCondStim
    tRespCondFilt2 = RespCondFilt(:,:,j);
    tCorr = corrcoef(tRespCondFilt1(Mask),tRespCondFilt2(Mask));
    CorrOrt(i,j) = tCorr(1,2);
  end
end

[Ort1,Ort2] = meshgrid(mod(Ort,180),mod(Ort,180));
OrtDiff = 90-abs(mod(Ort1-Ort2,180)-90);
OrtDiff1D = unique(OrtDiff(:))';
CorrOrt1D = zeros(1,length(OrtDiff1D));  % convert to 1D
for k = 1:length(OrtDiff1D)
  CorrOrt1D(k) = mean(CorrOrt(OrtDiff==OrtDiff1D(k)));
end

hgfFig(end+1) = figure;
% annotation('TextBox',[0,0.9,1,0.1], ...
%            'String',[fnRoot,'---Spectrum and correlation'], ...
%            'HorizontalAlignment','Center', ...
%            'FontWeight','bold', ...
%            'FontSize',12, ...
%            'LineStyle','None');
axes('Position',[0.1,0.3,0.36,0.48]);
plot(SF1D,Spct1D,'-k','LineWidth',2);
axis square;
axis([0,3,0,1]);
xlabel('SF (cyc/mm)', ...
       'FontSize',12, ...
       'FontWeight','Bold');
ylabel('Normalized amplitude', ...
       'FontSize',12, ...
       'FontWeight','Bold');
title('1D spectrum', ...
      'FontSize',12, ...
      'FontWeight','Bold');
axes('Position',[0.6,0.3,0.36,0.48]);
plot(OrtDiff1D,CorrOrt1D,'-k','LineWidth',2);
axis square;
axis([0,90,-1,1]);
line(xlim,[1,1]*0,'Color','k','LineStyle','--');
set(gca,'XTick',0:45:90);
xlabel('Orientation difference (deg)', ...
       'FontSize',12, ...
       'FontWeight','Bold');
ylabel('Cross-correlation', ...
       'FontSize',12, ...
       'FontWeight','Bold');
title('Correlation', ...
      'FontSize',12, ...
      'FontWeight','Bold');
box on;

% Calculate orientation map
[MapOrt,AmpOrt,TCOrt] = CalculateMapTCPROrt(RespCondFilt,mod(Ort,180),Mask);

OrtUniq = unique(mod(Ort,180));
nOrtUniq = length(OrtUniq);
TCOrtUniq = zeros(nOrtUniq,nOrtUniq);
for i = 1:nOrtUniq
  ti = (mod(Ort,180)==OrtUniq(i));
  for j = 1:nOrtUniq
    tj = (mod(Ort,180)==OrtUniq(j));
    TCOrtUniq(i,j) = mean(mean(TCOrt(ti,tj),1),2);
  end
end

OrtComb = circshift(OrtUniq,[0,floor(nOrtUniq/2)]);
OrtComb(OrtComb>=90) = OrtComb(OrtComb>=90)-180;
OrtComb = [OrtComb,180+OrtComb(1)];
for i = 1:nOrtUniq
  TCOrtUniq(i,:) = circshift(TCOrtUniq(i,:),[0,floor(nOrtUniq/2)+1-i]);
end

DCMean = mean(RespCond(repmat(Mask,[1,1,nCondStim])));  % DC component

TCOrtUniq = [TCOrtUniq,TCOrtUniq(:,1)]+DCMean;
TCOrtUniq = TCOrtUniq/max(TCOrtUniq(:));
TCOrtComb = mean(TCOrtUniq,1);
TCOrtComb = TCOrtComb/max(TCOrtComb(:));

PI = [0.1,0,0.8,30];
PLB = [0,-1e-5,0,1];
PUB = [1,1e-5,1,90];
PFGssOrt = ...
  lsqcurvefit('FuncWoNGaussianCirc1D',PI, ...
              OrtComb,TCOrtComb, ...
              PLB,PUB,sOptOptm);
TCOrtCombFit = FuncWoNGaussianCirc1D(PFGssOrt,OrtComb);

t = corrcoef(TCOrtCombFit,TCOrtComb);
RSQTCOrtComb = t(1,2)^2;

ColorMap = [0.5,0.5,0.5;hsv(18)];
ColorAmp = repmat(0:0.01:1,[3,1])';

tMapOrt = repmat(MapOrt,[1,1,3]);
MapAmpOrt = NaN(Height,Width,3);
for j = 1:size(ColorMap,1)
  tiMapAmpOrt = (tMapOrt>=(j-2)*10&tMapOrt<=(j-1)*10);
  tColor = repmat(reshape(ColorMap(j,:),[1,1,3]),[Height,Width,1]);
  MapAmpOrt(tiMapAmpOrt) = tColor(tiMapAmpOrt);
end
tAmpOrt = AmpOrt/max(AmpOrt(:))*3;
tAmpOrt(tAmpOrt>1) = 1;
tAmpOrt(MapOrt==-10) = 1;
MapAmpOrt = MapAmpOrt.*repmat(tAmpOrt,[1,1,3]);

hgfFig(end+1) = figure;
hgfMapOrt = hgfFig(end);
% annotation('TextBox',[0,0.9,1,0.1], ...
%            'String',[fnRoot,'---Orientation map and tuning curve'], ...
%            'HorizontalAlignment','Center', ...
%            'FontWeight','bold', ...
%            'FontSize',12, ...
%            'LineStyle','None');
axes('Position',[0.2,0.5,0.3,0.4]);
imagesc(MapAmpOrt);
axis image;
set(gca,'XAxisLocation','Top','XTick',[],'YTick',[]);
xlabel(sprintf('%0.1fmm',TS.Header.Imaging.Width), ...
       'FontSize',10, ...
       'FontWeight','Bold');
ylabel(sprintf('%0.1fmm',TS.Header.Imaging.Height), ...
       'FontSize',10, ...
       'FontWeight','Bold');
annotation('Line',[0.5-0.3/TS.Header.Imaging.Width*2,0.5],[0.48,0.48], ...
           'LineWidth',4);
annotation('TextBox',[0.4,0.42,0.1,0.06], ...
           'String','2 mm', ...
           'HorizontalAlignment','Right', ...
           'FontWeight','bold', ...
           'FontSize',12, ...
           'LineStyle','None');
axes('Position',[0.55,0.5,0.01,0.3]);
imagesc(permute(flipdim(ColorMap,1),[1,3,2]));
set(gca,'YAxisLocation','Right', ...
        'XTick',[], ...
        'YTick',[1,9.5,18], ...
        'YTickLabel',{'180','90','0'});
ylabel('Orientation ^o', ...
       'FontSize',10, ...
       'FontWeight','Bold');
box on;
axes('Position',[0.7,0.5,0.01,0.3]);
imagesc(permute(flipdim(ColorAmp,1),[1,3,2]));
set(gca,'YAxisLocation','Right', ...
        'XTick',[], ...
        'YTick',[1,101], ...
        'YTickLabel',{sprintf('%0.3f%%',max(AmpOrt(:))/3*100),'0'});
ylabel('Amplitude', ...
       'FontSize',10, ...
       'FontWeight','Bold');
box on;
axes('Position',[0.2,0.1,0.24,0.32]);
hold on;
plot(OrtComb,TCOrtComb,'bo');
plot(OrtComb,TCOrtCombFit,'-r', ...
     'LineWidth',2);
hold off;
axis square tight;
axis([-90,90,0,1.1]);
set(gca,'XTick',-90:45:90)
xlabel('Orientation difference (deg)', ...
       'FontSize',12, ...
       'FontWeight','Bold');
ylabel('Normalized amp', ...
       'FontSize',12, ...
       'FontWeight','Bold');
text(0,0.2,sprintf('\\sigma=%4.1f^o',PFGssOrt(4)), ...
     'FontSize',10, ...
     'FontWeight','Bold');
box on;

%save('Amp_Orient0720run7.mat','SF1D','Spct1D','OrtDiff1D','CorrOrt1D','CorrOrt','OrtDiff');

%saveas(hgfFig(end),[fnFig,'.fig'],'fig');
%saveas(hgfFig(end),[fnFig,'.jpg'],'jpeg');
%system(['chgrp eslab ',fnFig,'.fig']);
%system(['chgrp eslab ',fnFig,'.jpg']);

% %% Convert ps to pdf
% SavePDF(hgfFig,[fnFig,'.pdf']);
% system(['chgrp eslab ',fnFig,'.pdf']);
% 
% %% Save files
% save(fnData, ...
%      'iCondBlank','iCondStim','nCondStim','DAVersion', ...
%      'Ort','nOrt','Height','Width', ...
%      'FermiLowCutOff','FermiHighCutOff','SizePxl','LabelStim', ...
%      'RespCond','DPCond','RespCondFilt','RespRMS', ...
%      'SF1D','Spct1D','nSF1D','Crop', ...
%      'MethodMask','ThsdResp','ThsdDP','Mask', ...
%      'CorrOrt','OrtDiff','OrtDiff1D','CorrOrt1D', ...
%      'MapOrt','AmpOrt','TCOrt','', ...
%      'OrtComb','TCOrtComb','DCMean','', ...
%      'OrtUniq','nOrtUniq','TCOrtUniq','', ...
%      'PFGssOrt','TCOrtCombFit','RSQTCOrtComb','', ...
%      'MapAmpOrt','ColorMap','ColorAmp','', ...
%      'nPCAComp','PCACoef','PCAScore','PCAExpl', ...
%      'PCAComp','RespCondPCA','CorrResp','', ...
%      '','','','', ...
%      '','','','', ...
%      '');
% system(['chgrp eslab ',fnData]);
% 
% %% Timer ends
% TimerEnd = now;
% disp(['Session started at ',datestr(TimerStart)]);
% disp(['Session ended at ',datestr(TimerEnd)]);