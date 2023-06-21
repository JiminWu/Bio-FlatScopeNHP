function Y = FuncWoNGaussianCirc1D(P,X)

%% function Y = FuncWoNGaussianCirc1D(P,X)
%
% 1-D circular Gausian function WithOut Normalization for orientation tuning
%
% P = [Amp,X0,Base,Sigma] --- parameters
% Y = Amp*exp(-(X-X0)^2/2/Sigma^2)+Base;
%
% Note: X-X0 must be circularly ranged within -90~90 degree
%
% YC at ES lab
% Created on Jan. 22, 2009
% Last modified on Jan. 22, 2009

%% Parameters
Amp   = P(1);
X0    = P(2);
Base  = P(3);
Sigma = P(4);

%% Coordinates
X = (mod(X-X0-90,180)-90)/Sigma;

%% 1-D Gaussian
Y = Amp*exp(-X.*X/2)+Base;


