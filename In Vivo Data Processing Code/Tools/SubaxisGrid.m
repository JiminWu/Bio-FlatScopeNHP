classdef SubaxisGrid < handle

%% SUBAXISGRID
%     gx = SubaxisGrid(nrows, ncols, ...)
% Creates figure with a nrows x ncols grid of plots. Spacing and margin
% are specified uses the subaxis() syntax.
%
% Additional methods are provided for figure, row, and column titles.

  properties (SetAccess = protected)

    % Handles
    hFig;
    hAx;
    hFigTitle;
    hRowTitles;
    hColTitles;
    hFigTitle_ax;
    hRowTitles_ax;
    hColTitles_ax;
    hLegend;
    hColorbar;
    hColorbar2;
    
    % Component margin and position
    MarginFigTitle   = 0.12;
    MarginColTitles  = 0.12;
    MarginRowTitles  = 0.1;
    MarginLegend     = 0.1;
    MarginColorbar   = 0.1;
    PositionLegend   = 'MarginTop'
    PositionColorbar = 'MarginBottom'

    MarginColorbar2   = 0.1;
    PositionColorbar2 = 'MarginBottom'
    
    % subaxis() margin and spacing properties
    MarginTop     = 0.12;
    MarginBottom  = 0.1;
    MarginLeft    = 0.1;
    MarginRight   = 0.07;
    SpacingHoriz  = 0.05;
    SpacingVert   = 0.05;
%     PaddingTop    = 0;
%     PaddingBottom = 0;
%     PaddingLeft   = 0;
%     PaddingRight  = 0;

  end        

  
  methods
    
    function this = SubaxisGrid(rows, cols, varargin)
    %% Subaxis grid constructor
    %     gx = SubaxisGrid(nrows, ncols, ...)
    % Creates figure with a nrows x ncols grid of plots. Spacing and margin
    % are specified uses the subaxis() syntax.
      
      % Check input
      assert(rows >= 1 && mod(rows,1) == 0, 'Row count most be a positive integer');
      assert(cols >= 1 && mod(cols,1) == 0, 'Column count most be a positive integer');

      % Update spacing
      this.config(varargin{:});
                   
      % Create new figure
      this.hFig = figure('Units','normalized');
      
      % Create axis
      this.hAx = zeros(rows,cols);
      for ii = 1:rows*cols
        this.hAx(ii) = axes(this.hFig,'Visible','off');
      end
      this.updateAxisPositions();
      set(this.hAx,'Visible','on')
                  
    end
    

    %%
    function config(this, varargin)
      %% Reset grid spacing and margins
      %   this.config(prop, val, ...)
      % Resets the spacing and margins of the subaxis without replotting.
      % Use subaxis() prop/val values.
      
      props = varargin(1:2:end);
      pvals = varargin(2:2:end);
      assert(numel(props) == numel(pvals), 'Mismatched Property/Value pairs');
      assert(iscellstr(props), 'Invalid Property input');      
      assert(all(cellfun(@(v) isnumeric(v) && isscalar(v) && v >= 0 && v < 1, pvals)), ...
                'Invalid Value input');

      % re-interpret shorthands
      props_ = {};
      pvals_ = {};
      for pp = 1:numel(props)        
        switch (lower(props{pp}))
          
          case {'margintop','mt'}
            props_{end+1} = 'MarginTop';
            pvals_{end+1} = pvals{pp};
            
          case {'marginbottom','mb'}
            props_{end+1} = 'MarginBottom';
            pvals_{end+1} = pvals{pp};
            
          case {'marginleft','ml'}
            props_{end+1} = 'MarginLeft';
            pvals_{end+1} = pvals{pp};
            
          case {'marginright','mr'}
            props_{end+1} = 'MarginRight';
            pvals_{end+1} = pvals{pp};
            
          case {'spacinghoriz','sh'}
            props_{end+1} = 'SpacingHoriz';
            pvals_{end+1} = pvals{pp};
            
          case {'spacingvert','sv'}
            props_{end+1} = 'SpacingVert';
            pvals_{end+1} = pvals{pp};
            
          case {'margin','m'}
            props_{end+1} = 'MarginTop';
            pvals_{end+1} = pvals{pp};
            props_{end+1} = 'MarginBottom';
            pvals_{end+1} = pvals{pp};
            props_{end+1} = 'MarginLeft';
            pvals_{end+1} = pvals{pp};
            props_{end+1} = 'Marginright';
            pvals_{end+1} = pvals{pp};
            
          case {'spacing','s'}
            props_{end+1} = 'SpacingHoriz';
            pvals_{end+1} = pvals{pp};
            props_{end+1} = 'SpacingVert';
            pvals_{end+1} = pvals{pp};
            
        end
      end
              
      % Update values input
      this.updateSpacing(props_, pvals_);

      % Update axis
      if (~isempty(this.hAx))
        this.updateAxisPositions();
      end
      
    end

    
    %%
    function figtitle(this, varargin)
      %% Sets global figure title
      %   this.figtitle(titlestr, ...)
      %   this.figtitle(margin, titlestr, ...)
      % Use the 'margin' input to specify the position of the "bottom" of
      % the title text. Additonal prop/val paris can be used to configure
      % the title text.
      
      % Sets up title space as margin from figure top
      if (isnumeric(varargin{1}))
        margin = varargin{1};
        assert(isscalar(margin) && margin > 0 && margin <= 1, 'Invalid margin');
        if numel(varargin) > 1
          titlestr = varargin{2};
          varargin = varargin(3:end);
        else
          titlestr = 0;
        end
      else
        margin   = this.MarginTop;
        titlestr = varargin{1};
        varargin = varargin(2:end);
      end
      
      % Create axis if necessary
      if (isempty(this.hFigTitle_ax))
        this.hFigTitle_ax = axes(this.hFig,'Visible','off','XLim',[-1 1],'YLim',[-1 1]);
        this.hFigTitle    = text(0,0,'',...
            'Parent',this.hFigTitle_ax,...
            'FontWeight','bold','FontSize',12,...
            'HorizontalAlignment','center','VerticalAlignment','bottom');
      end
      
      % Update position
      set(this.hFigTitle_ax, 'Position', [0 1-margin 1 margin]);
      this.MarginFigTitle = margin;
      
      % Update title text
      if (ischar(titlestr) || iscellstr(titlestr))        
        set(this.hFigTitle, 'String', titlestr, varargin{:});
      end
      
    end
    
    %%
    function coltitles(this, varargin)
      %% Sets the column titles of the subaxis grid
      %   this.coltitles(titlestr, ...)
      %   this.coltitles(margin, titlestr, ...)
      % Input 'titlestr' is a cell array of column titles.
      % Use the 'margin' input to specify the position of the "top" of
      % the column title text. Additonal prop/val paris can be used to
      % configure the title text.
      
      % Sets up column title space as margin from figure top
      if (isnumeric(varargin{1}))
        margin = varargin{1};
        assert(isscalar(margin) && margin > 0 && margin <= 1, 'Invalid margin');
        if numel(varargin) > 1
          titlestr = varargin{2};
          varargin = varargin(3:end);
        else
          titlestr = 0;
        end
      else
        margin   = this.MarginTop;
        titlestr = varargin{1};
        varargin = varargin(2:end);
      end
      
      % Create axis if necessary
      if (isempty(this.hColTitles_ax))
        for cc = 1:size(this.hAx,2)
          this.hColTitles_ax(cc) = axes(this.hFig,'Visible','off','XLim',[-1 1],'YLim',[-1 1]);
          this.hColTitles(cc)    = text(0,-1,'',...
              'Parent',this.hColTitles_ax(cc),...
              'FontSize',10,...
              'HorizontalAlignment','center','VerticalAlignment','bottom');
        end
      end
      
      % Update
      this.MarginColTitles = margin;
      for cc = 1:size(this.hAx,2)
        
        axpos = get(this.hAx(1,cc), 'Position');
        set(this.hColTitles_ax(cc), 'Position', [axpos(1) 1-margin axpos(3) margin]);
        
        if (iscell(titlestr))
          if (numel(titlestr) >= cc && (ischar(titlestr{cc}) || iscellstr(titlestr{cc})))
            set(this.hColTitles(cc), 'String', titlestr{cc}, varargin{:});
          else
            set(this.hColTitles(cc), 'String', '', varargin{:});
          end
        end
        
      end
            
    end

    
    %%
    function rowtitles(this, varargin)
      %% Sets the row titles of the subaxis grid
      %   this.rowtitles(titlestr, ...)
      %   this.rowtitles(margin, titlestr, ...)
      % Input 'titlestr' is a cell array of row titles.
      % Use the 'margin' input to specify the position of the "right" of
      % the row title text. All row titles are right-aligned. Additonal
      % prop/val paris can be used to configure the title text.
      
      % Sets up row title space as margin from figure top
      if (isnumeric(varargin{1}))
        margin = varargin{1};
        assert(isscalar(margin) && margin > 0 && margin <= 1, 'Invalid margin');
        if numel(varargin) > 1
          titlestr = varargin{2};
          varargin = varargin(3:end);
        else
          titlestr = 0;
        end
      else
        margin   = this.MarginLeft;
        titlestr = varargin{1};
        varargin = varargin(2:end);
      end
      
      % Create axis if necessary
      if (isempty(this.hRowTitles_ax))
        for rr = 1:size(this.hAx,1)
          this.hRowTitles_ax(rr) = axes(this.hFig,'Visible','off','XLim',[-1 1],'YLim',[-1 1]);
          this.hRowTitles(rr)    = text(-1,0,'',...
              'Parent',this.hRowTitles_ax(rr),...
              'FontSize',10,...
              'HorizontalAlignment','right','VerticalAlignment','middle');
        end
      end
      
      % Update
      this.MarginRowTitles = margin;
      for rr = 1:size(this.hAx,1)
        
        axpos = get(this.hAx(rr,1), 'Position');
        set(this.hRowTitles_ax(rr), 'Position', [margin axpos(2) margin axpos(4)]);
        
        if (iscell(titlestr))
          if (numel(titlestr) >= rr && (ischar(titlestr{rr}) || iscellstr(titlestr{rr})))
            set(this.hRowTitles(rr), 'String', titlestr{rr}, varargin{:});
          else
            set(this.hRowTitles(rr), 'String', '');
          end
        end
        
      end
            
    end    
    
    
    %%
    function legend(this, varargin)
      %% Configures plot legend
      %   this.legend(legstr, linespecs, ...)
      % Creates a phatom plot legend axis, create plots using the specified
      % linespecs, then create an associated legend text. Additional
      % prop/val pairs can be used to configure the legend text.
      %
      % Inputs:
      %   legstr    - cell array of legend strings
      %   linespecs - cell array of cells, each subcell contains prop/val
      %               pairs specifying the line style of each plot. e.g.
      %               { {'Color', 'b', 'LineWidth', 3}, ...
      %                 {'Color', 'r', 'LineWidth', 3}, ...
      %                 {'Color', 'b', 'LineWidth', 2, 'LineStyle', ':'} }
            
      % input modes
      if (isnumeric(varargin{1}))
        legendid  = varargin{1};
        legstr    = varargin{2};
        linespecs = varargin{3};
        varargin  = varargin(4:end);
      else
        legendid  = 1;
        legstr    = varargin{1};
        linespecs = varargin{2};
        varargin  = varargin(3:end);
      end
      
      % Create axes if necessary
      if (numel(this.hLegend) < legendid || isempty(this.hLegend{legendid}))
        this.hLegend{legendid} = axes(this.hFig,'Position',[0 0 1 1],...
                            'Visible','off','XLim',[-1 1],'YLim',[-1 1]);        
        legendpos(this, 'mt', this.MarginTop)
      end
      
      % Clear axis and create dummy lines
      cla(this.hLegend{legendid});
      hold(this.hLegend{legendid},'on');
      h = zeros(numel(linespecs),1);
      for ll = 1:numel(linespecs)
        h(ll) = plot(this.hLegend{legendid},nan(2,1),nan(2,1),linespecs{ll}{:});
      end
      hold(this.hLegend{legendid},'off');
      
      % Create legend
      legend(h, legstr, varargin{:});
      
    end
    
    function legendpos(this, varargin)
      %% Sets plot legend position
      %   this.legendpos(mode, val)
      % Sets the position of the colorbar on the figure. Available modes
      % are:
      %   {'MarginTop','mt'}
      %         - Put the legend (horizontal) above all plots.
      %           Use val input to specify margin from top.
      %   {'MarginBottom','mb'}
      %         - Put the legend (horizontal) beneath all plots.
      %           Use val input to specify margin from bottom.
      %   {'MarginRight','mr'}
      %         - Put the legend (vertical) on the right of all plots.
      %           Use val input to specify margin from right.
      %   {'GridAx','g'}
      %         - Put the legend at a specific subaxis position
      %           Use val input to specify [row col] of subaxis.

      % input modes
      if (isnumeric(varargin{1}))
        legendid  = varargin{1};
        mode      = varargin{2};
        val       = varargin{3};
      else
        legendid  = 1;
        mode      = varargin{1};
        val       = varargin{2};
      end
      
      if (numel(this.hLegend) < legendid || isempty(this.hLegend{legendid}))
        return;
      end
      
      switch (mode)
        case {'MarginTop','mt'}
          assert(isscalar(val) && val > 0 && val <= 1, 'Invalid margin');
          this.PositionLegend = 'MarginTop';
          this.MarginLegend   = val;
          set(this.hLegend{legendid}, 'Position', [0 1-val 1 val]);

        case {'MarginBottom','mb'}
          assert(isscalar(val) && val > 0 && val <= 1, 'Invalid margin');
          this.PositionLegend = 'MarginBottom';
          this.MarginLegend   = val;
          set(this.hLegend{legendid}, 'Position', [0 0 1 val]);
          
        case {'MarginRight','mr'}
          assert(isscalar(val) && val > 0 && val <= 1, 'Invalid margin');
          this.PositionLegend = 'MarginRight';
          this.MarginLegend   = val;
          axpos = get(this.hAx(end,end), 'Position');
          set(this.hLegend{legendid}, 'Position', [1-val axpos(2) val 1-(this.MarginTop+this.MarginBottom)]);
          
        case {'GridAx','g'}
          assert(numel(val) == 2 && all(mod(val,1)==0) && ...
                 val(1) >= 1 && val(1) <= size(this.hAx,1) && ...
                 val(2) >= 1 && val(2) <= size(this.hAx,2), ...
                 'Invalid margin');
          this.PositionLegend = 'GridAx';
          this.MarginLegend   = val;
          axpos = get(this.hAx(val(1),val(2)));
          set(this.hLegend{legendid}, 'Position', axpos);
          this.hAx(val(1),val(2)) = this.hLegend{legendid};          
      end     
      
    end
    
    
    %%
    function colorbar(this, cbtitle, clim, varargin)
      %% Configures colorbar
      %   this.colorbar(cbtitle, clim, ...)
      % Creates a colorbar axis with axis label (implemented as xlabel) and
      % the color scal clim. Additional prop/val pairs can be used to
      % configure the colorbar axis.
      
      assert(ischar(cbtitle), 'Colorbar label must be a char array');
      assert(isnumeric(clim) && numel(clim)== 2, 'Invalid caxis limits');
      
      % Create axes if necessary
      if (isempty(this.hColorbar))
        this.hColorbar = axes(this.hFig,'Position',[0 0 1 1],...
                            'Visible','on','XLim',[-1 1],'YLim',[-1 1]);
      end
      
      % colobar data
      cb = linspace(clim(1),clim(2),256);
      cb = [cb; cb; cb];
      set(this.hColorbar, 'Userdata',  cb, varargin{:});
      xlabel(this.hColorbar, cbtitle);

      % posotion colorbar
      this.colorbarpos(this.PositionColorbar, this.MarginColorbar);
            
    end
    
    
    function colorbarpos(this, mode, val)
      %% Sets colorbar position
      %   this.colorbarpos(mode, val)
      % Sets the position of the colorbar on the figure. Available modes
      % are:
      %   {'MarginRight','mr'}
      %         - Put the colorbar (vertical) on the right of all plots.
      %           Use val input to specify margin from right.
      %   {'MarginBottom','mb'}
      %         - Put the colorbar (horizontal) beneath all plots.
      %           Use val input to specify margin from bottom.
      
      if (isempty(this.hColorbar))
        return;
      end
      
      cb = get(this.hColorbar, 'UserData');
      clim = [min(cb(:)) max(cb(:))];
      
      % position
      switch (mode)
        case {'MarginRight','mr'}
          assert(isscalar(val) && val > 0 && val <= 1, 'Invalid margin');
          this.PositionColorbar = 'MarginRight';
          this.MarginColorbar   = val;
          cla(this.hColorbar);
          imagesc(this.hColorbar,'XData',1:3,'YData',cb(1,:),'CData',cb',clim);
          axpos = get(this.hAx(end,end),'Position');
          h   = 0.02;
          pos = [1-val axpos(2) h 1-(this.MarginTop+this.MarginBottom)];
          set(this.hColorbar, 'Position', pos, ...
              'XTick', [], 'YAxisLocation', 'right', 'YTickMode', 'auto');
          axis(this.hColorbar,'tight');
          
        case {'MarginBottom','mb'}
          assert(isscalar(val) && val > 0 && val <= 1, 'Invalid margin');
          this.PositionColorbar = 'MarginBottom';
          this.MarginColorbar   = val;
          cla(this.hColorbar);
          imagesc(this.hColorbar,'XData',cb(1,:),'YData',1:3,'CData',cb,clim);
          h   = 0.02;
          pos = [this.MarginLeft val-h 1-(this.MarginLeft+this.MarginRight) h];
          set(this.hColorbar, 'Position', pos, 'YTick', [], 'XTickMode', 'auto');          
          axis(this.hColorbar,'tight');
          
        case {'GridAx','g'}
          assert(numel(val) == 2 && all(mod(val,1)==0) && ...
                 val(1) >= 1 && val(1) <= size(this.hAx,1) && ...
                 val(2) >= 1 && val(2) <= size(this.hAx,2), ...
                 'Invalid margin');
          this.PositionColorbar = 'GridAx';
          this.MarginColorbar   = val;
          cla(this.hColorbar);
          imagesc(this.hColorbar,'XData',1:3,'YData',cb(1,:),'CData',cb',clim);
          axpos = get(this.hAx(val(1),val(2)), 'Position');
          axpos(3) = 0.02;
          set(this.hColorbar, 'Position', axpos, ...
            'XTick', [], 'YAxisLocation', 'right', 'YTickMode', 'auto', 'Box', 'on');
          axis(this.hColorbar,'tight');
          
      end
      
    end
    
    
    %%
    function colorbar2(this, cbtitle, clim, varargin)
      
      assert(ischar(cbtitle), 'Colorbar label must be a char array');
      assert(isnumeric(clim) && numel(clim)== 2, 'Invalid caxis limits');
      
      % Create axes if necessary
      if (isempty(this.hColorbar2))
        this.hColorbar2 = axes(this.hFig,'Position',[0 0 1 1],...
                            'Visible','on','XLim',[-1 1],'YLim',[-1 1]);
      end
      
      % colobar data
      cb = linspace(clim(1),clim(2),256);
      cb = [cb; cb; cb];
      set(this.hColorbar2, 'Userdata',  cb, varargin{:});
      xlabel(this.hColorbar2, cbtitle);

      % posotion colorbar
      this.colorbar2pos(this.PositionColorbar, this.MarginColorbar);
            
    end
    
    
    function colorbar2pos(this, mode, val)
      
      if (isempty(this.hColorbar2))
        return;
      end
      
      cb = get(this.hColorbar2, 'UserData');
      clim = [min(cb(:)) max(cb(:))];
      
      % position
      switch (mode)
        case {'MarginRight','mr'}
          assert(isscalar(val) && val > 0 && val <= 1, 'Invalid margin');
          this.PositionColorbar2 = 'MarginRight';
          this.MarginColorbar2   = val;
          cla(this.hColorbar2);
          imagesc(this.hColorbar2,'XData',1:3,'YData',cb(1,:),'CData',cb',clim);
          axpos = get(this.hAx(end,end),'Position');
          h   = 0.02;
          pos = [1-val axpos(2) h 1-(this.MarginTop+this.MarginBottom)];
          set(this.hColorbar2, 'Position', pos, ...
              'XTick', [], 'YAxisLocation', 'right', 'YTickMode', 'auto');
          axis(this.hColorbar2,'tight');
          
        case {'MarginBottom','mb'}
          assert(isscalar(val) && val > 0 && val <= 1, 'Invalid margin');
          this.PositionColorbar2 = 'MarginBottom';
          this.MarginColorbar2   = val;
          cla(this.hColorbar2);
          imagesc(this.hColorbar2,'XData',cb(1,:),'YData',1:3,'CData',cb,clim);
          h   = 0.02;
          pos = [this.MarginLeft val-h 1-(this.MarginLeft+this.MarginRight) h];
          set(this.hColorbar2, 'Position', pos, 'YTick', [], 'XTickMode', 'auto');          
          axis(this.hColorbar2,'tight');
      
        case {'GridAx','g'}
          assert(numel(val) == 2 && all(mod(val,1)==0) && ...
                 val(1) >= 1 && val(1) <= size(this.hAx,1) && ...
                 val(2) >= 1 && val(2) <= size(this.hAx,2), ...
                 'Invalid margin');
          this.PositionColorbar2 = 'GridAx';
          this.MarginColorbar2   = val;
          cla(this.hColorbar2);
          imagesc(this.hColorbar2,'XData',1:3,'YData',cb(1,:),'CData',cb',clim);
          axpos = get(this.hAx(val(1),val(2)), 'Position');
          axpos(3) = 0.02;
          set(this.hColorbar2, 'Position', axpos, ...
            'XTick', [], 'YAxisLocation', 'right', 'YTickMode', 'auto', 'Box', 'on');
          axis(this.hColorbar2,'tight');
          
      end
      
    end
    
    
    %%
    function caxis(this, clim, ax)
      %% Sets the color-axis
      %   this.caxis(clim)
      %   this.caxis(clim, axs)
      
      if ~exist('ax','var')
        ax = this.hAx;
      end
      
      for ii = 1:numel(ax)
        caxis(ax(ii), clim);
      end
      
    end

    
    %%
    function xlabel(this, xstr, tickmode, varargin)
      %% Sets x-axis labels
      %   this.xlabel(labelstr)
      %   this.xlabel(labelstr, tickmode)
      %   this.xlabel(labelstr, tickmode, axprop, axval, ...)
      % Label the bottom-left axis with x-axis labelstr. 
      %
      % Optional 'tickmode' determines which axis will retain the tick
      % labels. Unlabelled axis still has ticks marks. Available modes are:
      %   'all'        - label all axis (default)
      %   'lastrow'    - label just the lat row 
      %
      % Optional axis property/value pairs can be used to set XTick, XLim, 
      % etc; in which case, all axis are set to the same settings.
      
      if (~exist('tickmode','var'))
        tickmode = 'all';
      end      
      
      lax = [];
      switch (tickmode)
        case 'all'
          lax = this.hAx;
          
        case 'lastrow'
          lax = this.hAx(end,:);
          set(this.hAx(1:end-1,:), 'XTickLabel', []);
          
      end
      set(lax, 'XTickLabelMode', 'auto');      
      xlabel(this.hAx(end,1), xstr);
      
      if (~isempty(varargin))
        set(this.hAx, varargin{:});
      end
      
      
    end

    function ylabel(this, ystr, tickmode, varargin)
      %% Sets y-axis labels
      %   this.ylabel(labelstr)
      %   this.ylabel(labelstr, tickmode)
      %   this.ylabel(labelstr, tickmode, axprop, axval, ...)
      % Label the bottom-left axis with y-axis labelstr. 
      %
      % Optional 'tickmode' determines which axis will retain the tick
      % labels. Unlabelled axis still has ticks marks. Available modes are:
      %   'all'        - label all axis (default)
      %   'firstcol'   - label just the first column 
      %
      % Optional axis property/value pairs can be used to set YTick, YLim, 
      % etc; in which case, all axis are set to the same settings.

      if (~exist('tickmode','var'))
        tickmode = 'all';
      end      

      lax = [];
      switch (tickmode)
        case 'firstcol'
          lax = this.hAx(:,1);
          set(this.hAx(:,2:end), 'YTickLabel', []);
          
        case 'bottomleft'
          lax = this.hAx(end,1);
          set(this.hAx(:,2:end), 'YTickLabel', []);
          set(this.hAx(1:end-1,1), 'YTickLabel', []);
          
        case 'topleft'
          lax = this.hAx(1,1);
          set(this.hAx(:,2:end), 'YTickLabel', []);
          set(this.hAx(2:end,1), 'YTickLabel', []);
          
        otherwise %case 'all'
          lax = this.hAx;          
          
      end   
      set(lax, 'YTickLabelMode', 'auto');      
      ylabel(this.hAx(end,1), ystr);
      
      if (~isempty(varargin))
        set(this.hAx, varargin{:});
      end
        
    end
    
    
    function ax = subaxis(this, row, col)
      %% Set the current plotting axis (gca)to specified axis
      %   ax = this.subaxis(index)
      %   ax = this.subaxis(row, col)
      
      if (~exist('col','var'))
         col = mod(row - 1, size(this.hAx,2)) + 1;
         row = ceil(row / size(this.hAx,2));
      end
      
      assert(row >= 1 && row <= size(this.hAx,1) && ...
             col >= 1 && col <= size(this.hAx,2), ...
             'Invalid row and column index.');
      ax = this.hAx(row,col);
      axes(ax);
    end
    
    function hide(this, row, col)
      %% Hide specified axis
      %   this.hide(row, col)
      
      if (~exist('col','var'))
         col = mod(row - 1, size(this.hAx,2)) + 1;
         row = ceil(row / size(this.hAx,2));
      end
      
      assert(row >= 1 && row <= size(this.hAx,1) && ...
             col >= 1 && col <= size(this.hAx,2), ...
             'Invalid row and column index.');
      set(this.hAx(row,col),'Visible','off');
    end
    
    function gridlines(this, on_off, varargin)
      %% Turn gridlines on/off
      %   this.gridlines('on')
      %   this.gridlines('off')
      for ii = 1:numel(this.hAx)
        grid(this.hAx(ii), on_off);
        if numel(varargin)
          set(this.hAx(ii), varargin{:});
        end
      end
    end

    function box(this, on_off)
      %% Turn bounding box on/off
      %   this.box('on')
      %   this.box('off')
      for ii = 1:numel(this.hAx)
        box(this.hAx(ii), on_off);
      end
    end
    
    function xlim(this, xl)
      %% Sets xlim for all axes
      %     this.xlim([start end]);
      arrayfun(@(ax) xlim(ax,xl), this.hAx);
    end

    function ylim(this, yl)
      %% Sets ylim for all axes
      %     this.ylim([start end]);
      arrayfun(@(ax) ylim(ax,yl), this.hAx);
    end
    
  end
  
  
  methods (Access=private)
    
    function updateSpacing(this, props, pvals)
      %% Private: Updates spacing and margin settings for subaxis grids.
      %     this.updateSpacing(props, pvals)
      % Use props/pvals pairs as in subaxis function.

      % Assign new values to a copy of this obj
      warning off
      tmp = struct(this);      
      warning on
      for pp = 1:numel(props)
        if (isfield(tmp,props{pp}))
          tmp.(props{pp}) = pvals{pp};
        else
          warning('Unknown Property "%s" is ignored', props{pp});
        end
      end
      
      % Check that the new settings work
      [r,c] = size(tmp.hAx);
      y = tmp.MarginTop  + tmp.MarginBottom + (r-1)*tmp.SpacingVert;
      x = tmp.MarginLeft + tmp.MarginRight  + (c-1)*tmp.SpacingHoriz;
      assert(y < 1 && x < 1, 'Specified spacing is large to work.');
      
      % If all works, then override this object
      for pp = 1:numel(props)
        this.(props{pp}) = pvals{pp};
      end      
      
    end
    
    
    %%
    function updateAxisPositions(this)
      %% Private: Updates subaxis positions base on new spacing settings
      %     this.updateAxisPositions()

      [rows,cols] = size(this.hAx);
      width = this.MarginLeft + this.MarginRight  + (cols-1)*this.SpacingHoriz;
      width = (1-width) / cols;

      height = this.MarginTop + this.MarginBottom + (rows-1)*this.SpacingVert;
      height = (1-height) / rows;
      
      left   = this.MarginLeft   + (0:cols-1)*(this.SpacingHoriz+width);
      bottom = this.MarginBottom + (0:rows-1)*(this.SpacingVert+height);
      bottom = fliplr(bottom);
      
      % Update plots
      for rr = 1:rows
        for cc = 1:cols
          set(this.hAx(rr,cc), 'Position', [left(cc) bottom(rr) width, height]);
        end
      end

      % Update column titles
      if (~isempty(this.hColTitles_ax))
        for cc = 1:size(this.hAx,2)
          axpos = get(this.hColTitles_ax(cc), 'Position');
          set(this.hColTitles_ax(cc), 'Position', [left(cc) axpos(2) width axpos(4)]);
        end
      end

      % Update row titles
      if (~isempty(this.hRowTitles_ax))
        for rr = 1:size(this.hAx,1)
          axpos = get(this.hRowTitles_ax(rr), 'Position');
          set(this.hRowTitles_ax(rr), 'Position', [axpos(1) bottom(rr) axpos(3) height]);
        end
      end
      
      % Update legend axis
      this.legendpos(this.PositionLegend, this.MarginLegend)
      
      % Update colorbar axis
      this.colorbarpos(this.PositionColorbar, this.MarginColorbar)
      
      
    end    
    
  end
  
  
end