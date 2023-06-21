function B = BinND(A,BinSizeVector)

%% Bin A in N dimentions
% BinSizeVector must be a vector with positive integers.
%
%
% YC at ES lab
% Created on Apr. 17, 2008
% Last modified on Apr. 17, 2008

%% Parameters
nBinSizeVector = length(BinSizeVector);

SizeA = size(A);
nSizeA = length(SizeA);

N = min(nBinSizeVector,nSizeA);

if any(BinSizeVector(1:N)>SizeA(1:N))
  error('At least one integer in BinSizeVector is larger than the size of A!');
end

%% Bin
for k = 1:N
  if BinSizeVector(k)>1
    A = Bin1D(A,k,BinSizeVector(k));
  end
end

B = A;


