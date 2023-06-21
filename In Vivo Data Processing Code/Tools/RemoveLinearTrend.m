function [B,Slope,Intercept] = RemoveLinearTrend(A,Dim,X)

%% Remove linear trend in A at the dimention of DIM
% B = A-SLOPE*X-INTERCEPT
% X is a vector along DIM for linear fitting
% B is the residual after removing the linear trend
%
%
% YC at ES lab
% Created on Oct. 13, 2005
% Last modified on May 7, 2008

%% Remove linear trend
nLength = size(A,Dim);
if length(X)~=nLength
  error('The length of X must be equal to the size of A in DIM!');
end

tSize1 = ones(1,ndims(A));
tSize1(Dim) = nLength;
tSize2 = size(A);
tSize2(Dim) = 1;

tX = reshape(X,tSize1);
tXMean = mean(tX);
tXSquareMean = mean(tX.*tX);
tXX = repmat(tX,tSize2);

tAMean = mean(A,Dim);

Slope = (mean(tXX.*A,Dim)-tXMean*tAMean)./(tXSquareMean-tXMean*tXMean);
Intercept = tAMean-Slope*tXMean;

B = A-repmat(Slope,tSize1).*tXX-repmat(Intercept,tSize1);


