addpath './Tools';


load M28D20221026R0TS.mat

fnTS = 'M28D20221026R0TS.mat';

%% gaFFT
Message = gaFFT(fnTS,TS,DAVersion);

%%
XX = 100:1:360; %select ROI
YY = 150:1:310;


TotalTrial = 10;
FramepTrial = 120;

LowCutOff = 0.8;
HighCutOff = 2.5;
SizePxl = 0.0153; %/mm

DataCond_filtered =  FilterFermi2D(DataCond(Y,X,:),0.8,2.5,TS.Header.Imaging.SizePxl);
DataCondBand = DataCond_filtered-repmat(DataCond_filtered(:,:,1),[1,1,14]);

DataTrial_filtered =  FilterFermi2D(DataTrial(Y,X,:), 0.8,2.5,TS.Header.Imaging.SizePxl); 
DataTrialBand = DataTrial_filtered-repmat(DataCondBand(:,:,1),[1,1,140]);


%%
figure, imagesc(DataCondBand(:,:,3));
colorbar;
figure, imagesc(DataCondBand(:,:,9));
colorbar;
figure, imagesc(DataCondBand(:,:,3)-DataCondBand(:,:,9));
colorbar;

 Maps1 = DataCondBand(:,:,3);
 Maps2 = DataCondBand(:,:,9);
 %%
 Data_filtered1 = Maps1;
 Data_filtered2 = Maps2;
 subtract = Maps1-Maps2;
 R = corrcoef(Maps1, Maps2);
%%
figure, imagesc(DataTrial_filtered(:,:,2));
%%
save('Saved_maps_groundtruth.mat', 'Maps1', 'Maps2', 'subtract','DataTrial','DataTrialBand');

