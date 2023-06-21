function B = FilterFermi2D(A,LowCutOff,HighCutOff,SizePxl)

%% Filter A with 2D Fermi filter
% A is an array with at leat 2 dimentions
% LowCutOff and HighCutOff are the low an high cut-off frequency (cyc/mm)
% SizePxl is the pixel size (mm)
%
% B is an array with same size as A
%
%
% YC at ES lab
% Created on Apr. 24, 2013
% Last modified on Apr. 24, 2013

%% Check input/output arguements
SizeA = size(A);
Height = SizeA(1);
Width = SizeA(2);

%% Fermi filter
ParmFermiLowPass = [1,HighCutOff,0,HighCutOff*0.05];
ParmFermiHighPass = [1,LowCutOff,0,LowCutOff*0.05];

SFX = ((1:Width)-floor(Width/2)-1)/Width/SizePxl;
SFY = ((1:Height)-floor(Height/2)-1)/Height/SizePxl;
[SFXX,SFYY] = meshgrid(SFX,SFY);
SF2D = abs(SFXX+1i*SFYY);
if HighCutOff==inf
  FiltFermiLowPass = zeros(Height,Width);
else
  FiltFermiLowPass = FuncWoNFermi(ParmFermiLowPass,SF2D);
end
if LowCutOff==0
  FiltFermiHighPass = ones(Height,Width);
else
  FiltFermiHighPass = FuncWoNFermi(ParmFermiHighPass,SF2D);
end 
FiltFermi = FiltFermiHighPass-FiltFermiLowPass;

%% Show Fermi filter
thgf = figure;
ti = floor(Height/2)+1;
plot(SFX,FiltFermi(ti,:),'LineWidth',2);
axis tight;
axis([0,10,-0.1,1.1]);
line([1,1]*HighCutOff,ylim, ...
     'Color','r', ...
     'LineStyle','--', ...
     'LineWidth',2);
line([1,1]*LowCutOff,ylim, ...
     'Color','r', ...
     'LineStyle','--', ...
     'LineWidth',2);
xlabel('Spatial frequency (cycle/mm)', ...
       'FontWeight','bold', ...
       'FontSize',12);
ylabel('Amplitude', ...
       'FontWeight','bold', ...
       'FontSize',12);
title('Fermi filter (1D-slice)', ...
      'FontWeight','bold', ...
      'FontSize',12);
drawnow;pause(0.1);

%% Filter A
SizeA([1,2]) = 1;
B = ...
  ifft(ifft(ifftshift(ifftshift( ...
    fftshift(fftshift(fft(fft(A,[],1),[],2),1),2).* ...
    repmat(FiltFermi,SizeA),1),2),[],1),[],2);

if isreal(A)
  B = real(B);
end

%% Close figure
close(thgf);


