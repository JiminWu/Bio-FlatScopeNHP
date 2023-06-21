function DPrime = CalculateDPrime(A,B,Dim)

%% function DPrime = CalculateDPrime(A,B,Dim)
% Calculate d' between A and B in the dimention of DIM
%
% A and B must have same sizes in all dimentions but DIM
% DIM refers to the dimention of repetation, default = 3
% DPrime is the returned d'
%
% Note: DPrime = 0  when AMean=BMean and ASTD=BSTD=0
%
%
% YC at ES lab
% Created on Oct. 10, 2004
% Last modified on Apr. 9, 2021


%% Check input and output arguements
if ~exist('A','var') || ~exist('B','var')
  error('Please input A and B!');
end

if ~exist('Dim','var')
  Dim = 3;  % default
end

if size(A,Dim)==1 || size(B,Dim)==1
  DPrime = NaN(size(mean(A,Dim)));
  return;
%   error('The sizes of A and B in the dimention of DIM must be greater than 1!');
end

%% Compute mean and std
AMean = mean(A,Dim);
ASTD = std(A,0,Dim);
BMean = mean(B,Dim);
BSTD = std(B,0,Dim);

if ~all(size(AMean)==size(BMean))
  error('A and B must have same sizes in all dimentions but DIM!');
end

%% Compute d'
DPrime = (AMean-BMean)./sqrt((ASTD.^2+BSTD.^2)/2);
DPrime(AMean==BMean) = 0;


