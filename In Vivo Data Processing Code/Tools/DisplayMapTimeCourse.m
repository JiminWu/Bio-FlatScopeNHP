function hgfFig = DisplayMapTimeCourse(TimeCourse, cfg)

%% DisplayMapTimeCourse.m
%
%     hgfFig = DisplayMapTimeCourse(TimeCourse, cfg)
%
% Plots response maps time course and ouputs the figure handle.
%
% Input TimeCourse requires the following fields:
%     (dCond): one field for each specified by cfg.dConds. 
%         Each is an HxWxT matrix of response map.
%
% Input cfg requires the following fields:
%     frange:   frame index to plot
%     trange:   corresponding time range
%     crange:   color axis range
%     dConds:   data fields of DVTimeCourse to plot
%     dCondNames: labels for data fields
%     clabel:   color axis label
%     figTitle: title of the plot
%
% spencer.chen@utexas.edu


%%

hgfFig = figure;

nFrames = numel(cfg.frange);

% Each comparison pair in its own row
for dd = 1:numel(cfg.dConds),

  % Frame by frame response map
  for ii = 1:nFrames,
    
    ff = cfg.frange(ii);
    
    subaxis(numel(cfg.dConds)+1, nFrames, ii+nFrames*(dd-1), ...
      'sh', 0.01, 'mt', 0.23, 'ml', 0.05, 'mr', 0.05)
    
    [Height, Width, ~] = size(TimeCourse.(cfg.dConds{dd}));
    
    % plot map
    imagesc(TimeCourse.(cfg.dConds{dd})(:,:,ff),cfg.crange);
    axis equal tight
    set(gca,'XTick',[],'YTick',[]);
    
    % frame the timestamp labels
    if (dd == 1)
      if (ii == 1)
        title({['F',num2str(ff)], ['t=',num2str(cfg.trange(ii)),' ms'],' '},'FontSize',8);
      else
        title({['F',num2str(ff)], num2str(cfg.trange(ii)),' '},'FontSize',8);
      end
    end
    
    % comparison group labels
    if (ii == ceil(nFrames/2))
        text(Width/2,1.7*Height,cfg.dCondNames{dd},'HorizontalAlignment','center','FontSize',12);
    end
    
  end
end

% colobar legends
subaxis(numel(cfg.dConds)+1, nFrames, floor(nFrames/2), numel(cfg.dConds)+1, 3, 1)
xx = linspace(cfg.crange(1),cfg.crange(2),100);
imagesc(xx,(cfg.crange(2)-cfg.crange(1))*(1:5)/200,repmat(xx,5,1), cfg.crange);

if (cfg.crange(1) < 0)
  set(gca,'YTick',[],'XTick',[cfg.crange(1) 0 cfg.crange(2)]);
else
  set(gca,'YTick',[],'XTick',[cfg.crange(1) cfg.crange(2)]);
end

axis equal tight
xlabel(cfg.clabel);
set(gca,'YTick',[]);


annotation(hgfFig, ...
           'TextBox',[0,0.9,1,0.1], ...
           'String', cfg.figTitle, ...
           'HorizontalAlignment','Center', ...
           'FontWeight','bold', ...
           'FontSize',12, ...
           'LineStyle','None');

         
