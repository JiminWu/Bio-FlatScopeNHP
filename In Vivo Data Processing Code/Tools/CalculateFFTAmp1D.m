function [Amp1D,SF1D] = CalculateFFTAmp1D(A,SizePxl,Intv)

%% function [Amp1D,SF1D] = CalculateFFTAmp1D(A,SizePxl)
% Calculate 1D FFT amplitude
%
% A is an array with at leat 2 dimentions
% SizePxl is the pixel size (mm)
% Intv is the interval in SF1D (cyc/mm)
%
% Amp1D is the 1D amplitude
% SF1D is the 1D spatial frequency
%
%
% YC at ES lab
% Created on Dec. 14, 2014
% Last modified on Jan. 20, 2015

%% Check input/output arguements
SizeA = size(A);
Height = SizeA(1);
Width = SizeA(2);

if ~exist('Intv','var')
  Intv = min(1/(Width-1)/SizePxl,1/(Height-1)/SizePxl);
end

%% Calculate 1D FFT amplitude
SFX = ((1:Width)-floor(Width/2)-1)/(Width-1)/SizePxl;
SFY = ((1:Height)-floor(Height/2)-1)/(Height-1)/SizePxl;
[SFXX,SFYY] = meshgrid(SFX,SFY);
SF2D = abs(SFXX+1i*SFYY);

SF1D = 0:Intv:max(SF2D(:));
nSF1D = length(SF1D);

B = abs(fftshift(fftshift(fft(fft(A,[],1),[],2),1),2));

SizeA([1,2]) = [1,1];
Amp1D = cell(1,nSF1D);
for i = 1:nSF1D
  tMask = abs(SF2D-SF1D(i))<Intv/2;
  Amp1D{i} = sum(sum(B.*repmat(tMask,SizeA),1),2)/sum(tMask(:));
end
Amp1D = cell2mat(Amp1D);


