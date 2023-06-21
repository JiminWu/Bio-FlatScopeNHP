function C = CalculateCrossCorr2D(A,B)

%% function C = CalculateCrossCorr2D(A,B)
% Calculate 2D cross-correlation of A and B
%
% A and B must be 2D
% C has same size as A
%
% Note (Aus. 24, 2012): remove mean before calculating cross-correlation
%
%
% YC at ES lab
% Created on Sep. 29, 2009
% Last modified on Aus. 24, 2012

%% Check inputs and/or outputs

%% Filtration
A = A-mean(A(:));
B = B-mean(B(:));

C = CalculateFilt2D(A,B)/sqrt(sum(sum(A.*A)))/sqrt(sum(sum(B.*B)));


