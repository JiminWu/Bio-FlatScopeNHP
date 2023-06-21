%% Default values
%
%
% YC at ES lab
% Created on Nov. 5, 2006
% Last modified on Sep. 4, 2012

%% Options
sOptOptm = ...
  optimset('LargeScale','On', ...
           'TolFun',1e-8,'TolX',1e-8, ...
           'MaxFunEvals',1e4,'MaxIter',1e4);
OptOptm = sOptOptm;
Options = sOptOptm;
OptionsOptimize = sOptOptm;

sOptInputDlg.Resize = 'off';
sOptInputDlg.WindowStyle = 'normal';
sOptInputDlg.Interpreter = 'tex';
OptInputDlg = sOptInputDlg;
OptionsInputDlg = sOptInputDlg;

CrtrOutl = 5;  % x standard deviation
CrtrOutlPct = 1;  % percent of the points exceeding the criterion
CrtrOutlier = CrtrOutl;
CriterionOutlier = CrtrOutl;

%% Display
nHSV = 128;
cHSV = cell(1,nHSV);
cHSV{1} = ...
  [1.00, 0.00, 0.00];
cHSV{2} = ...
  [1.00, 0.00, 0.00
   0.00, 0.00, 1.00];
cHSV{3} = ...
  [1.00, 0.00, 0.00
   0.00, 0.50, 0.00
   0.00, 0.00, 1.00];
cHSV{4} = ...
  [1.00, 0.00, 0.00
   0.00, 0.50, 0.00
   0.00, 0.00, 1.00
   1.00, 0.00, 1.00];
cHSV{5} = ...
  [1.00, 0.00, 0.00
   0.00, 0.50, 0.00
   0.00, 0.00, 1.00
   0.00, 1.00, 1.00
   1.00, 0.00, 1.00];
cHSV{6} = ...
  [1.00, 0.00, 0.00
   1.00, 0.75, 0.00
   0.00, 0.75, 0.25
   0.00, 1.00, 1.00
   0.00, 0.00, 1.00
   1.00, 0.00, 1.00];
cHSV{7} = ...
  [1.00, 0.00, 0.00
   1.00, 0.75, 0.00
   0.00, 0.75, 0.25
   0.00, 1.00, 1.00
   0.00, 0.00, 1.00
   0.75, 0.00, 1.00
   1.00, 0.00, 1.00];
cHSV{8} = ...
  [1.00, 0.00, 0.00
   1.00, 0.75, 0.00
   0.00, 0.75, 0.25
   0.00, 1.00, 1.00
   0.00, 0.75, 1.00
   0.00, 0.00, 1.00
   0.75, 0.00, 1.00
   1.00, 0.00, 1.00];
for k = 9:nHSV
  cHSV{k} = hsv(k);
end
cColorOrderHSV = cHSV;
ColorOrderHSV = cHSV;
ColorOrder = cHSV{8};

cMarkerSymbol = {'^','s','o','d','*','+','x','.','p','v','<','>'};
MarkerSymbol = cMarkerSymbol;

cLineStyle = {'-','--',':','-.'};
LineStyle = cLineStyle;

%% Clear temporal variables
clear k;


