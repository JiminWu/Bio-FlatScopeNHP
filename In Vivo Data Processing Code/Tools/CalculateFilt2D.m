function C = CalculateFilt2D(A,B)

%% function C = CalculateFilt2D(A,B)
% Calculate 2D filtration of A by B
%
% Use fft2, so much faster than filter2 in matlab
% A and B must be 2D
% C has same size as A
%
%
% YC at ES lab
% Created on Sep. 29, 2009
% Last modified on Oct. 1, 2009

%% Check inputs and/or outputs

%% Filtration
B = flipdim(flipdim(B,1),2);

C = CalculateConv2D(A,B);


