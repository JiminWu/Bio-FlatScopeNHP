function Z = FuncWoNGaussian2D(P,Coordinates)

%% function Z = FuncWoNGaussian2D(P,Coordinates)
%
% 2-D Gaussian function WithOut Normalization
% Note: to create orientation, the whole coordinate is rotated.
%
% P = [Amp,X0,Y0,Base,Ort,SigmaMinor,SigmaMajor] --- parameters
% Coordinates.X --- X vector
% Coordinates.Y --- Y vector
% Z = Amp*exp(-(X-X0)^2/2/SigmaMajor^2-(Y-Y0)^2/2/SigmaMinor^2)+Base;
%
%
% YC at ES lab
% Created on Dec. 1, 2008
% Last modified on Dec. 1, 2008

%% Parameters
Amp        = P(1);
X0         = P(2);
Y0         = P(3);
Base       = P(4);
Ort        = P(5)/180*pi;  % deg -> arc
SigmaMinor = P(6);
SigmaMajor = P(7);

%% Coordinates
X = repmat(Coordinates.X(:)',[length(Coordinates.Y),1])-X0;
Y = repmat(Coordinates.Y(:),[1,length(Coordinates.X)])-Y0;

%% Rotate coordinates
XX = (X*cos(Ort)+Y*sin(Ort))/SigmaMajor;
YY = (-X*sin(Ort)+Y*cos(Ort))/SigmaMinor;

%% 2-D Gaussian
Z = Amp*exp(-(XX.*XX+YY.*YY)/2)+Base;


