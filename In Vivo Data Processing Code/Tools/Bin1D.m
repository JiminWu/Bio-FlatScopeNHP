function B = Bin1D(A,Dim,BinSize)

%% Bin A in the dimention of DIM (1---default)
% BinSize must be a positive integer (2---default)
%
%
% YC at ES lab
% Created on Sep. 30, 2005
% Last modified on Apr. 17, 2008

%% Check input/output arguements
if ~exist('Dim','var')
  Dim = 1;  % default
end

if ~exist('BinSize','var') 
  BinSize = 2;  % default
elseif BinSize~=floor(BinSize)||BinSize<1
  error('BinSize must be a positive integer!');
end

nLength = size(A,Dim);
Order = [Dim,setdiff(1:ndims(A),Dim)];
A = permute(A,Order);

%% Bin
SizeA = size(A);
nLengthNew = floor(nLength/BinSize);
if nLengthNew<1
  error('BinSize is larger than the size of A in Dim!');
end
SizeNew = [BinSize,nLengthNew,SizeA(2:length(SizeA))];
SizeB = [nLengthNew,SizeA(2:length(SizeA))];

B = ipermute(reshape(mean(reshape(A(1:(BinSize*nLengthNew),:), ...
                                  SizeNew),1),SizeB),Order);


