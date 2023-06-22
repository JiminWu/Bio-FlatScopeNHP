clear;
addpath './Tools';

nCond = 8;
FramepTrial = 22;
imageCount = nCond*FramepTrial;
k = 1;
start_x = 60+40*(k-1); 
start_y = 150+15*(k-1); 
X = start_x:1:(start_x+40);
Y = start_y:1:(start_y+40);

%% Load reconstructed Bio-FlatScopeNHP data after FFT

RespCond_org = [];
DataTrial_org = [];

for cond = 1:nCond % total 8 conditions
    fprintf('Cond%03d \n', cond);
    filename = sprintf('recon_Cond%d.mat',cond);
    Xt_Stack = matfile(filename);
    Xt_Stack = im2double(Xt_Stack.Xt_Stack_norm);
    Xt_Stack_down = imresize(Xt_Stack, [300 300], 'bicubic');

    RespCond_org(:,:,cond) = abs(imrotate(mean(Xt_Stack_down,3),9));
    DataTrial_org(:,:,:,cond) = abs(imrotate((Xt_Stack_down),9));   

end

DataTrial_hr = squeeze(DataTrial(:,:,:,1));
DataTrial_hr_org = squeeze(DataTrial_org(:,:,:,1));

%%
for cond = 1:nCond
    DPCond(:,:,cond) = CalculateDPrime(DataTrial(:,:,:,cond),DataTrial_hr,3);
    DPCond_org(:,:,cond) = CalculateDPrime(DataTrial_org(:,:,:,cond),DataTrial_hr_org,3);
end

RespCond = RespCond-repmat(mean(RespCond(:,:,1:2),3),[1,1,nCond]);
RespCond_org = RespCond_org-repmat(mean(RespCond_org(:,:,1:2),3),[1,1,nCond]);

AmpCond = squeeze(mean(mean(RespCond,1),2))';
DPAmpCond = squeeze(mean(mean(DPCond,1),2))';

%% plot overall amp
CLim = [-0.2,1.2]*max(abs(RespCond_org(:)));

figure,
imagesc(RespCond_org(:,:,6),CLim);
hold on
h = rectangle('Position',[X(1),Y(1),length(X),length(Y)]);
h.LineWidth = 3;
h.EdgeColor = [0.4940 0.1840 0.5560];
axis image

figure,
for i = 3:nCond
    subplot(2,3,i-2);
    imagesc(RespCond_org(:,:,i),CLim);
    hold on
    h = rectangle('Position',[X(1),Y(1),length(X),length(Y)]);
    h.LineWidth = 3;
    h.EdgeColor = [0.4940 0.1840 0.5560];
    axis image
end

%%
% %hgfFig(end+1) = figure;
% CLim = [0,1]*max(abs(DPCond_org(:)));
% figure,
% for i = 1:nCond
%     subplot(2,4,i);
%     imagesc(DPCond(:,:,i),CLim);
%     axis image off;
% end
% th = colorbar;
% tPos = get(th,'Position');
% set(th,'Position',[0.952,0.01,tPos(3:4)]);
%%
CLim = [0,1.1]*max(abs(RespCond(:)));
figure,
for i = 3:nCond
    subplot(2,3,i-2);
    imagesc(RespCond(:,:,i),CLim);
  %  axis image off;
end
%%
CLim = [0,1]*max(abs(RespCond_org(:)));
%figure,
%imagesc(RespCond_org(:,:,2),CLim);
%figure,
for i = 3:nCond
    %subplot(2,3,i-2);
    figure,
    I_mid = RespCond_org(:,:,i);
    imagesc(I_mid,CLim);
    axis image;
  %  colorbar;
  %  axis image off;
end

%%

xx = 3:1:8;
yy = abs(AmpCond(3:8));

%Y = FuncWoNGaussian1D(P,X);
f1 = fit(xx', yy', 'gauss1');
mu = f1.b1;
sigma = f1.c1/sqrt(2);
xgrid = linspace(3,8,80)';
pre = f1.a1*exp(-((xgrid-f1.b1)/f1.c1).^2);

figure,
%color1 = []
clearvars ColorCond
ColorCond(1,:) = '#9E2A2B';
ColorCond(2,:) = '#F79256';
ColorCond(3,:) = '#fcca46';
ColorCond(4,:) = '#7dcfb6';
ColorCond(5,:) = '#00b2ca';
ColorCond(6,:) = '#1d4e89';
ColorCond(7,:) = '#928f8b';
%ColorCond = [color1, color2];%hsv(nCond);

%axes('Position',[0.1,0.5,0.27,0.36]);
for i = 1:nCond-2
    plot(i+2,yy(i),'o', ...
        'MarkerEdgeColor',ColorCond(k,:), ...
        'Color',ColorCond(k,:), 'LineWidth',3);
    hold on;
end
plot(xgrid,pre, 'LineWidth', 3, 'Color', ColorCond(k,:));
hold on
% plot(groundtruth(k),max(yy),'p', ...
%         'MarkerEdgeColor',ColorCond(7,:), ...
%         'Color',ColorCond(7,:), 'LineWidth',4);
%     hold on;

% 
hold off;
axis tight;
% % xlabel('Condition', ...
% %     'FontSize',12, ...
% %     'FontWeight','Bold');
% % ylabel('Amplitude', ...
% %     'FontSize',12, ...
% %     'FontWeight','Bold');
% 
xlim([3 8]);
xticks([3 5 7]);
xticklabels({'-0.8', '-1.0', '-1.2'})


xlabel('deg', ...
    'FontSize',12, ...
    'FontWeight','Bold');
ylabel('\Delta F/F', ...
    'FontSize',12, ...
    'FontWeight','Bold');
set(gca, 'FontSize', 12);
set(gcf, 'position', [100, 100, 300, 280]);

