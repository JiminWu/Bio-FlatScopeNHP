function [Power2D, SF2D, Power1D, SF1D] = CalculateSpNoiseSpectrum(RespTrial, SizePxl)

%%
%   [Power2D, SF2D, Power1D, SF1D] = CalculateSpNoiseSpectrum(RespTrial, SizePxl)
%
% Calculate the noise power spectrum of the signal (mean subtrated power
% sprctrum), given RespTrial (HxWxT) and pixel size SizePxl. Returns both
% 1D and 2D power spectrums.

%% Frequency coorsinates
[Height,Width,~] = size(RespTrial);

SFX = ((1:Width)-floor(Width/2)-1)/(Width-1) / SizePxl;
SFY = ((1:Height)-floor(Height/2)-1)/(Height-1) / SizePxl;
[SFXX,SFYY] = meshgrid(SFX,SFY);
SF2D = abs(SFXX+1i*SFYY);

SF1D = 0:min(SFX(2)-SFX(1),SFY(2)-SFY(1)): 1/SizePxl/2;
nSF1D = length(SF1D);


%% Power spectrum
MResp = mean(RespTrial,ndims(RespTrial));
SResp = std(RespTrial,[],ndims(RespTrial));
DResp = bsxfun(@minus, RespTrial, MResp);
ZResp = bsxfun(@rdivide, DResp, SResp);
ZResp(isnan(ZResp)) = 0;
Power2D = ...
  fftshift(fftshift( ...
    mean(abs( ...
      fft(fft(ZResp,[],1),[],2) ...
    ).^2,ndims(RespTrial)) ...
  ,1),2);

Power2D_ = reshape(Power2D, Height*Width, []);
Power1D = zeros(1,nSF1D,size(Power2D_,2));
for k = 1:nSF1D
  ti = abs(SF2D-SF1D(k))<(SF1D(2)-SF1D(1))/2;
  Power1D(1,k,:) = mean(Power2D_(ti,:));
end
