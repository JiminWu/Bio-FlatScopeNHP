function C = CalculateConv2D(A,B,nB)

%% function C = CalculateConv2D(A,B)
% Calculate 2D convolution of A and B
%
% Use fft2, so much faster than conv2 in matlab
% A and B must be 2D
% C has same size as A
%
%
% YC at ES lab
% Created on Sep. 29, 2009
% Last modified on Jan. 1, 201

if (~exist('nB','var'))
  nB = 1;
end

%% Check inputs and/or outputs
[nYA,nXA] = size(A);
[nYB,nXB] = size(B);

%% Convolution
tFFTA = zeros(nYA+nYB-1,nXA+nXB-1);
tFFTB = zeros(nYA+nYB-1,nXA+nXB-1);

tFFTA(1:nYA,1:nXA) = A;
tFFTB(1:nYB,1:nXB) = B;

% shift center to pixel (1,1) to avoid any shifting in image from multiple
% FFT multiplications
tFFTA = circshift(tFFTA, -floor([nYA,nXA]/2));
tFFTB = circshift(tFFTB, -floor([nYB,nXB]/2));

FFTC = fft2(tFFTA,nYA+nYB-1,nXA+nXB-1);
FFTB = fft2(tFFTB,nYA+nYB-1,nXA+nXB-1);

for ii = 1:nB,
  FFTC = FFTC .* FFTB;
end
tConv = ifft2(FFTC);

% reverse shifting from earlier
tConv = circshift(tConv, floor([nYA,nXA]/2));

C = tConv(1:nYA,1:nXA);




