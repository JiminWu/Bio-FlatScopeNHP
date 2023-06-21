function [Index,Value] = FindIndexInArray(A,Flag)

%% Find the index in an array A
% Flag is 1(max), 2(min), ...
%
%
% YC at ES lab
% Created on Sep.09, 2008
% Last modified on Aug. 24, 2012

%% Parameters
SizeA = size(A);
nSizeA = length(SizeA);

%% Find index
switch Flag
  case 1  % max
    [t,ti] = max(A(:));
  case 2  % min
    [t,ti] = min(A(:));
  otherwise
end

Index = zeros(1,nSizeA);
for i = 1:nSizeA
  Index(i) = mod(ti-1,SizeA(i))+1;
  ti = ceil(ti/SizeA(i));
end

Value = t;

