function Y = FuncWoNFermi(P,X)

%% function Y = FuncWoNFermi(P,X)
%
% Fermi function WithOut Normalization
%
% P = [Amp,X0,Base,Tao] --- parameters
% Y = Amp./(1+exp(-(abs(X)-X0)/Tao))+Base;
%
%
% YC at ES lab
% Created on Jan. 13, 2012
% Last modified on Jan. 18, 2012

%% Parameters
Amp  = P(1);
X0   = P(2);
Base = P(3);
Tao = P(4);

%% Fermi
Y = Amp./(1+exp(-(X-X0)/Tao))+Base;


