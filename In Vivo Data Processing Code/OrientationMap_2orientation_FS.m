% Load data
clear;
addpath './Tools'

X = 100:1:450; % selected ROI
Y = 100:1:450;

% 0 degree trails
load('./RawRecon/cond3_recon.mat')
ReconData_condition1 = Xt_Stacku8(Y,X,:);
clearvars Xt_Stacku8
% 90 degree trails
load('./RawRecon/cond6_recon.mat')
ReconData_condition2 = Xt_Stacku8(Y,X,:);
clearvars Xt_Stacku8

% blank trails
load('./RawRecon/cond1_recon.mat')
ReconData_heartrate1 = Xt_Stacku8(Y,X,:);
clearvars Xt_Stacku8
load('./RawRecon/cond2_recon.mat')
ReconData_heartrate2 = Xt_Stacku8(Y,X,:); 
clearvars Xt_Stacku8

TotalTrial = 10;
FramepTrial = 22;
ReconData_heartrate = [];
for i = 1:TotalTrial*FramepTrial
    ReconData_heartrate(:,:,i) = ((ReconData_heartrate1(:,:,i))+(ReconData_heartrate2(:,:,i)))./2;
end

ReconData_heartrate = zeros(size(ReconData_condition2));%ReconData_heartrate2;
figure, imshow(ReconData_condition2(:,:,1),[]);

%% Rearrange the data
trail_num = size(ReconData_heartrate,3)/FramepTrial;

for pp = 1:trail_num
    for i = 1:FramepTrial
        condition0(:,:,i,pp) = im2double(ReconData_heartrate(:, :, i+(pp-1)*FramepTrial));
        condition1(:,:,i,pp) = im2double(ReconData_condition1(:, :, i+(pp-1)*FramepTrial));%- avg_multitrail(:,:,i);
        condition2(:,:,i,pp) = im2double(ReconData_condition2(:, :, i+(pp-1)*FramepTrial));%- avg_multitrail(:,:,i);
    end
end
condition0_valid = condition0(:,:,3:22,:);
condition1_valid = condition1(:,:,3:22,:);
condition2_valid = condition2(:,:,3:22,:);

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
DataTrial_condition1 = complex(zeros(size(condition1_valid,1),size(condition1_valid,2), trail_num));
DataTrial_condition2 = complex(zeros(size(condition2_valid,1),size(condition2_valid,2), trail_num));
DataTrial_heart = complex(zeros(size(condition0_valid,1),size(condition0_valid,2), trail_num));


if ShowFig == 1
    Freq = ((1:nFrames)-1)/nFrames/FrameDuration*1000;
    iWidth = round(size(condition1,1)/4);
    iHeight = round(size(condition1,2)/4);
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
end


for j = 1:trail_num
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

end
%close(hgfSpectrum);

for j = 1:trail_num
    fprintf('FFTing BLK file for trial %03d/%03d ...\n', ...
        j,trail_num);
    tTrial2 =  condition2(:,:,:,j);
    tFFTTrial2 = ... %fft(tTrial(:,:,iFramesFFT),[],3);
        fft(tTrial2(:,:,iFramesFFT)./ ...
        repmat(mean(tTrial2(:,:,iFramesNmlTrial),3), ...
        [1,1,nFrames]),[],3);
    DataTrial_condition2(:,:,j) = tFFTTrial2(:,:,iPeakFreq)*FTT2Amp;
end
%%
DataTrial_heart(isnan(DataTrial_heart))=0;
DataTrial_condition1(isnan(DataTrial_condition1))=0;
DataTrial_condition2(isnan(DataTrial_condition2))=0;

DataTrial_heart1 = abs(DataTrial_heart-repmat(mean(DataTrial_heart,3),[1,1,trail_num]));
DataTrial_condition1 = abs(DataTrial_condition1-repmat(mean(DataTrial_heart,3),[1,1,trail_num]));
DataTrial_condition2 = abs(DataTrial_condition2-repmat(mean(DataTrial_heart,3),[1,1,trail_num]));


% DataCond = ...
%   complex(zeros(size(condition1,1),size(condition1,2), trail_num_1));

%% Filter each trial
LowCutOff = 0.8;
HighCutOff = 2.5;
SizePxl = 0.006566; %mm 
Datatrial_filtered0 = FilterFermi2D(DataTrial_heart,LowCutOff,HighCutOff,SizePxl);
Datatrial_filtered1 = FilterFermi2D(DataTrial_condition1,LowCutOff,HighCutOff,SizePxl);
Datatrial_filtered2 = FilterFermi2D(DataTrial_condition2,LowCutOff,HighCutOff,SizePxl);
Datatrial_filtered1 = Datatrial_filtered1 - repmat(mean(Datatrial_filtered0,3),[1,1,trail_num]);
Datatrial_filtered2 = Datatrial_filtered2 - repmat(mean(Datatrial_filtered0,3),[1,1,trail_num]);

%% Average
DataCond_heart = mean(DataTrial_heart1,3);
DataCond_condition1 = mean(DataTrial_condition1,3);
DataCond_condition2 = mean(DataTrial_condition2,3);


%% Filter
LowCutOff = 0.8; 
HighCutOff = 2.5; 
SizePxl = 0.006566; %mm 
DataCond_filtered0 = FilterFermi2D(DataCond_heart,LowCutOff,HighCutOff,SizePxl);
DataCond_filtered1 = FilterFermi2D(DataCond_condition1,LowCutOff,HighCutOff,SizePxl);
DataCond_filtered2 = FilterFermi2D(DataCond_condition2,LowCutOff,HighCutOff,SizePxl);

%%

Maps1 = DataCond_filtered1 - DataCond_filtered0;
Maps2 = DataCond_filtered2 - DataCond_filtered0;
subtract = Maps1-Maps2;

%%
figure, imagesc(Maps1);
colorbar
figure, imagesc(Maps2);
colorbar
figure, imagesc(Maps1-Maps2);
colorbar
%R = corrcoef(Maps1, Maps2);
%%
save('.\Saved_maps_flatscope.mat', 'Maps1', 'Maps2', 'subtract','Datatrial_filtered1', 'Datatrial_filtered2');