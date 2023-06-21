function [DPrime, DMean, STD, dpSignal, dpNoise] = CalculateDPrimes(Signal,Noise,Dim)

%% function DPrime = CalculateDPrimes(A,B,Dim)
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
%
% Spencer
% Last modified on Jan. 3, 2016

DPrime = [];
DMean = [];
STD = [];
dpSignal = [];
dpNoise = [];

if (isempty(Signal) || isempty(Noise))
  return;
end

%% Check input and output arguements
if ~exist('Signal','var') || ~exist('Signal','var')
  error('Please input Signal and Noise!');
end

if ~exist('Dim','var')
  Dim = 3;  % default
end

if (~iscell(Signal))
  Signal = {Signal};
  signal_decell = 1;
else
  signal_decell = 0;
end

if (~iscell(Noise))
  Noise = {Noise};
  noise_decell = 1;
else
  noise_decell = 0;
end

if (numel(Noise) ~= 1 && numel(Noise) ~= numel(Signal))
  error('Noise and Signal pairing error!');
end

dimSignal = cellfun(@(x) size(x,Dim), Signal);
dimNoise  = cellfun(@(x) size(x,Dim), Noise);

if any(dimNoise<1) || any(dimSignal<1)
  error('The sizes of Noise and Signal in the dimension of DIM must be greater than 1!');
end

%% Compute mean and std
MNoise = cellfun(@(x) mean(x,Dim), Noise, 'UniformOutput', false);
DNoise = cellfun(@(s,m) bsxfun(@minus, s, m), Noise, MNoise, ...
    'UniformOutput', false);

MSignal = cellfun(@(x) mean(x,Dim), Signal, 'UniformOutput', false);
DSignal = cellfun(@(s,m) bsxfun(@minus, s, m), Signal, MSignal, ...
    'UniformOutput', false);

% check size
sz  = cellfun(@(x) all(size(MNoise{1})==size(x)), MSignal);
sz2 = cellfun(@(x) all(size(MSignal{1})==size(x)), MNoise);
  
if ~all(sz) || ~all(sz2)
  error('Noise and Signal must have same sizes in all dimensions but DIM!');
end

% combine data to estimate STD
AllData = cat(Dim, DNoise{:}, DSignal{:});
STD = std(AllData, 0, Dim);


%% Compute d'a
DPrime = cell(numel(MSignal),1);
for ii = 1:numel(MSignal),
  if (numel(MNoise)==1)
    mn = MNoise{1};
  else
    mn = MNoise{ii};
  end
  DMean  = MSignal{ii} - mn;
  DPrime{ii} = DMean ./ STD;
  DPrime{ii}(DMean==0) = 0;
end

if (signal_decell)
  DPrime = DPrime{1};
end
% elseif (isempty(DPrime))
%   DPrime = nan(size(MNoise));
% end


%% compute d-prime for each noise and signal data point
if (nargout > 3)
  dpNoise = cellfun(@(x) bsxfun(@rdivide, x, STD), DNoise, 'UniformOutput', false);
  if (numel(MNoise) == 1)
    dpSignal = cellfun(@(x) bsxfun(@rdivide, bsxfun(@minus, x, MNoise{1}), STD), ...
        Signal, 'UniformOutput', false);
  else
    dpSignal = cellfun(@(x,y) bsxfun(@rdivide, bsxfun(@minus, x, y), STD), ...
        Signal, MNoise, 'UniformOutput', false);
  end
%   if (isempty(dpSignal))
%     sz = size(MNoise);
%     dpSignal = nan([sz(1:end-1) 0]);
%   end
end


