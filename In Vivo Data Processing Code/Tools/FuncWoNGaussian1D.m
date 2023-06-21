function Y = FuncWoNGaussian1D(P,X)

%% function Y = FuncWoNGaussian1D(P,X)
%
% 1-D Gausian function WithOut Normalization
%
% P = [Amp,X0,Base,Sigma] --- parameters
% Y = Amp*exp(-(X-X0)^2/2/Sigma^2)+Base;
%
%
% YC at ES lab
% Created on Dec. 1, 2008
% Last modified on Dec. 1, 2008

%% Parameters
Amp   = P(1);
X0    = P(2);
Base  = P(3);
Sigma = P(4);

%% Coordinates
X = (X-X0)/Sigma;

%% 1-D Gaussian
Y = Amp*exp(-X.*X/2)+Base;


