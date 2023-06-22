addpath './Tools';
load M28D20220720R11TS.mat
fnTS = 'M28D20220720R11TS.mat';
load 'M28D20220720R11FFTAmpS026E100PF0400.mat';

Condition = TS.Header.Conditions;
Num_valid = TS.Header.Index.iValidBLKCond;

%% Parameters
DefaultValues;

iCondBlank = 1:TS.Header.NumBlankCond;
nCond = TS.Header.NumValidCond;

BinSize = 1;
tBinSize = 1;
MethodAmp = 1;
nCol = 3;
nRow = 2;

X = 91:1:415; % select ROI
Y = 96:1:420;
%% Load FFT or integration file
%load(fnFFTIntg,'DataTrial');
DataTrial = DataTrial(Y,X,:);

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

%%
%Crop = [90, 100, 350, 350]; % horizontal vertical 
k = 1;
start_x = 60+40*(k-1); 
start_y = 150+15*(k-1); 

Crop = [start_x, start_y, 40, 40];
CLim = [0,1.2]*max(abs(RespCond(:)));

%figure, imshow(RespCond(Crop(2)-1+(1:Crop(4)),Crop(1)-1+(1:Crop(3)),4),CLim);
figure,
for i = 3:nCond
  axes('Position', ...
       [0.05+(mod(i-3,nCol))*0.9/nCol, ...
        0.9-(floor((i-3)/nCol)+1)*0.9/nRow, ...
        0.9/nCol*0.9,0.9/nRow*0.7]);
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
%%
% CLim = [0,1]*max(abs(RespCond(:)));
% for i = 3:nCond
% figure,
%   imagesc(RespCond(:,:,i),CLim);
%   axis image;
%     filename = sprintf('./0720_run4_AvgCond/processed/GT_RespCond%d.pdf',i);
%    % imwrite(im2uint8)
%     saveas(gcf,filename);
% end
%%
% for i = 3:nCond
%     subplot(2,3,i-2);
% %     I_mid = medfilt2(RespCond_org(:,:,i), [7 7]);
% %     imagesc(I_mid,CLim);
% %     %  axis image off;
%     imagesc(RespCond(:,:,i),CLim);
%     hold on
%     h = rectangle('Position',[X(1),Y(1),length(X),length(Y)]);
%     h.LineWidth = 3;
%     h.EdgeColor = [0.4940 0.1840 0.5560];
%     axis image
%  %     tCrop = Crop;
%  % tCrop([3,4]) = tCrop([3,4])-1;
% %   rectangle('Position',tCrop, ...
% %             'EdgeColor','r', ...
% %             'FaceColor','None', ...
% %             'Curvature',[0,0], ...
% %             'LineWidth',2);
% end


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

%%
xx = 3:1:8;
yy = AmpCond(3:8);
f1 = fit(xx', yy', 'gauss1');
mu = f1.b1;
sigma = f1.c1/sqrt(2);
xgrid = linspace(3,8,80)';
pre = f1.a1*exp(-((xgrid-f1.b1)/f1.c1).^2);

figure,
clearvars ColorCond
ColorCond(1,:) = '#9E2A2B';
ColorCond(2,:) = '#F79256';
ColorCond(3,:) = '#fcca46';
ColorCond(4,:) = '#7dcfb6';
ColorCond(5,:) = '#00b2ca';
ColorCond(6,:) = '#1d4e89';
ColorCond(7,:) = '#928f8b';
%k = 1;

for i = 1:nCond-2
  plot(i+2,yy(i),'o', ...
       'MarkerEdgeColor',ColorCond(k,:), ...
       'Color',ColorCond(k,:),'LineWidth',3);
  hold on;
end
plot(xgrid,pre, 'LineWidth', 3, 'Color', ColorCond(k,:));
hold off;
axis tight;

xlim([3 8]);
xticks([3 5 7]);
xticklabels({'-0.8', '-1.0', '-1.2'})
ylim([min(yy) 0.035]);
%ylim([0 max(yy)+0.001]);

xlabel('deg', ...
    'FontSize',12, ...
    'FontWeight','Bold');
ylabel('\Delta F/F', ...
    'FontSize',12, ...
    'FontWeight','Bold');
set(gca, 'FontSize', 12);
set(gcf, 'position', [100, 100, 300, 280]);

%% Convert ps to pdf
%SavePDF(hgfFig,[fnFig,'.pdf']);
%system(['chgrp eslab ',fnFig,'.pdf']);

%% Save files
% save(fnData, ...
%      'BinSize','iCondBlank','nCond','', ...
%      'Height','Width','nTrial','LabelCond', ...
%      'RespCond','DPCond','Crop','', ...
%      'AmpCond','DPAmpCond','','', ...
%      '','','','', ...
%      '','','','', ...
%      '');
% system(['chgrp eslab ',fnData]);
