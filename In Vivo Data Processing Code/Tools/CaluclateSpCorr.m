function [Corr1D, Dist1D] = CaluclateSpCorr(DataTrial, SizePxl)

%%
%   [Corr1D, Dist1D] = CaluclateSpCorr2D(DataTrial, SizePxl)
%
% Calulates spatial correlation of the supplied DataTrial matrix (HxWxT)
% to pixel size SizePxl. Returns 1D correlation with corespoonding distance.

%% Calculate distance matrix
[Width,Height,~] = size(DataTrial);
X = 1:Width;
Y = 1:Height;
[XX,YY] = meshgrid(X,Y);
XXYY = XX(:)+1i*YY(:);

Dist2D = zeros(Width*Height,Width*Height);
for k = 1:(Width*Height)
  Dist2D(:,k) = abs(XXYY-XXYY(k));
end

Dist2D_ = round(Dist2D(:));
[uDist2D,~,iDist2D] = unique(Dist2D_);

Dist1D = 0:max(uDist2D);
nDist1D = length(Dist1D);

% scale to pixel size
% Dist2D = Dist2D * SizePxl;
Dist1D = Dist1D * SizePxl;


%% Calculate 2D correlations
DataTrial_ = reshape(DataTrial, Width*Height, []);
Corr2D = corrcoef(DataTrial_');

%% Calculate 1D correlation
Corr1D = zeros(1,nDist1D);
for k = 1:nDist1D
  ti = iDist2D == k;
  Corr1D(k) = mean(Corr2D(ti));
end
