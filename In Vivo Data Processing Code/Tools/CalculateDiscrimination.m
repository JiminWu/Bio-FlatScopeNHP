function [DP,DPBSSE,Weight,vA,vB] = CalculateDiscrimination(A,B,sParm)

%% function [DP,DPBSSE,Weight,vA,vB] = CalculateDiscrimination(A,B,sParm)
% Calculate discrimination of A and B
% Inputs:
%   A and B must be 3D arrays with [Height,Width,nTrial]
%   Height and Width must be the same in A and B, but nTrial can be different
%   sParm.nBS define the number of bootstrap
%   sParm.Mask define the mask, true/false
%   sParm.Method define the model
%     1. weighted d'
%     2. input sParm.Weight
%     3. logistic, similar to weighted d', but worse in jackknife (20210720YC)
%
% Outputs:
%   DP is the d' between vA and vB
%   DPBSSE is the standard error of d' with bootstrape
%   vA and vB are the decision vector with Jack-knife
%
%
% YC at ES lab
% Created on Mar. 12, 2014
% Last modified on Jul. 20, 2021

%% Check inputs and/or outputs
[nYA,nXA,nTA] = size(A);
[nYB,nXB,nTB] = size(B);

if nYA~=nYB || nXA~=nXB || min(nTA,nTB)<=1
  error('A and B must be 3D arrays with [Height,Width,nTrial]!');
end

if ~exist('sParm','var')
  Method = 1;  % default
  nBS = 1000;  % default
  Mask = true(nYA,nXA);
else
  if ~isfield(sParm,'Method')
    Method = 1;  % default
  else
    Method = sParm.Method;
  end
  if ~isfield(sParm,'nBS')
    nBS = 1000;  % default
  else
    nBS = sParm.nBS;
  end
  if ~isfield(sParm,'Mask')
    Mask = true(nYA,nXA);  % default
  else
    Mask = sParm.Mask;
  end
end

%% Discrimination
switch Method
  case 1  % weighted d'
    vA = zeros(1,nTA);
    for i = 1:nTA
      Weight = CalculateDPrime(A(:,:,setdiff(1:nTA,i)),B,3);
      Weight(~Mask) = NaN;
      vA(i) = nanmean(nanmean(A(:,:,i).*Weight,1),2);
    end
    vB = zeros(1,nTB);
    for i = 1:nTB
      Weight = CalculateDPrime(A,B(:,:,setdiff(1:nTB,i)),3);
      Weight(~Mask) = NaN;
      vB(i) = nanmean(nanmean(B(:,:,i).*Weight,1),2);
    end
    Weight = CalculateDPrime(A,B,3);
  case 2  % input sParm.Weight
    if ~isfield(sParm,'Weight')
      error('Input weight for method 2!');
    end
    Weight = sParm.Weight;
    Weight(~Mask) = NaN;
    vA = squeeze(nanmean(nanmean(A.*repmat(Weight,[1,1,nTA]),1),2))';
    vB = squeeze(nanmean(nanmean(B.*repmat(Weight,[1,1,nTB]),1),2))';
  case 3  % logistic
    vA = zeros(1,nTA);
    tB = B./repmat(std(B,[],3),[1,1,nTB]);  % z-score
    for i = 1:nTA
      ti = setdiff(1:nTA,i);
      tAstd = std(A(:,:,ti),[],3);
      tA = A(:,:,ti)./repmat(tAstd,[1,1,nTA-1]);  % z-score
      Weight = mean(tA,3)-mean(tB,3);
      Weight(~Mask) = NaN;
      vA(i) = nanmean(nanmean(A(:,:,i)./tAstd.*Weight,1),2);
    end
    vB = zeros(1,nTB);
    tA = A./repmat(std(A,[],3),[1,1,nTA]);  % z-score
    for i = 1:nTB
      ti = setdiff(1:nTB,i);
      tBstd = std(B(:,:,ti),[],3);
      tB = B(:,:,ti)./repmat(tBstd,[1,1,nTB-1]);  % z-score
      Weight = mean(tA,3)-mean(tB,3);
      Weight(~Mask) = NaN;
      vB(i) = nanmean(nanmean(B(:,:,i)./tBstd.*Weight,1),2);
    end
    Weight = mean(A,3)./std(A,[],3)-mean(B,3)./std(B,[],3);
  otherwise
    error('Wrong method!');
end

DP = CalculateDPrime(vA,vB,2);

DPBSSE = ...
  std(CalculateDPrime(vA(randi(nTA,[nBS,nTA])), ...
                      vB(randi(nTB,[nBS,nTB])),2),[],1);


