function B = RemovePhaseDiscontinuity(A)

%% Remove phase discontinuity in matrix A from center
% A is a matrix with phase in a range of -pi to pi
% B is a matrix without phase discontinuity
%
%
% YC at ES lab
% Created on Jan. 27, 2020
% Last modified on Jan. 27, 2020

%% Parameters
Width = size(A,2);
Height = size(A,1);

iX = floor((Width+1)/2);
iY = floor((Height+1)/2);

B = A;

%% Remove phase discontinuity for the central row
B(iY,1:iX) = flip(unwrap(flip(B(iY,1:iX),2)),2);
B(iY,iX:end) = unwrap(B(iY,iX:end));

%% Remove phase discontinuity for each column from the center row
for i = 1:Width
  B(1:iY,i) = flip(unwrap(flip(B(1:iY,i),1)),1);
  B(iY:end,i) = unwrap(B(iY:end,i));
end


