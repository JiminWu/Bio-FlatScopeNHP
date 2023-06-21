function [MapOrt,AmpOrt,TCPROrt,TCPROrtAmp] = CalculateMapTCPROrt(MapResp,Ort,Mask)

%% function [MapOrt,AmpOrt,TCPROrt,TCPROrtAmp] = CalculateMapTCPROrt(MapResp,Ort,Mask)
% Calculate orientation map with a vector summation
%
% Combine CalculateMapOrt.m and CalculateTCPROrt.m
%
% MapResp must be 3D---[Y,X,Ort]
% Ort is a vector of orientation in deg, covering 0~180 deg
% Mask is a logic matrix of [Y,X]
%
% MapOrt is the orientation map of [Y,X], 0~180 deg; -10 deg means NULL
% AmpOrt is the tuning amplitude map of [Y,X]
% TCPROrt is a matrix of [Ort,Ort], each row is the orientation tuning curve
% and each column is the population reponse
% TCPROrtAmp is a matrix of [Ort,Ort,10], expanding TCPROrt based on amplitude
% in step of 10%.
%
% The interval to integrate TC over orietation map is up to 20 deg.
% Remove the normalization by sd
%
%
% YC at ES lab
% Created on Sep. 3, 2009
% Last modified on Jul, 16, 2012

%% Check inputs and/or outputs
[Height,Width,nOrt] = size(MapResp);

if ~exist('Mask','var')
  Mask = ones(Height,Width);
end

%% Pre-process, removing DC and mean
MapResp = ...
  MapResp-repmat(mean(mean(MapResp,1),2),[Height,Width,1]);  % remove DC

MapResp = ...
  MapResp-repmat(mean(MapResp,3),[1,1,nOrt]);  % remove mean

%% Compute orientation map
MapRespSum = ...
  sum(MapResp.*repmat(exp(1i*reshape(Ort*2,[1,1,nOrt])*pi/180), ...
                      [Height,Width,1]),3);

MapOrt = angle(MapRespSum)*180/pi;
MapOrt(MapOrt<0) = MapOrt(MapOrt<0)+360;
MapOrt = MapOrt/2;
AmpOrt = abs(MapRespSum);

MapOrt(~Mask) = -10;
AmpOrt(~Mask) = 0;

%% Compute orientation tuning curve and population response
tOrtIntv = min(mean(setdiff(abs(diff(Ort)),0)),30)/2;
tMapResp = reshape(MapResp,[Height*Width,nOrt]);
tMapOrt = reshape(MapOrt,[Height*Width,1]);
tMask = reshape(Mask,[Height*Width,1]);
tAmpOrt = reshape(AmpOrt,[Height*Width,1])/max(AmpOrt(:));

TCPROrt = zeros(nOrt,nOrt);
TCPROrtAmp = zeros(nOrt,nOrt,10);
for k = 1:nOrt
  TCPROrt(k,:) = ...
    mean(tMapResp((((tMapOrt>=(Ort(k)-tOrtIntv))& ...
                    (tMapOrt<(Ort(k)+tOrtIntv)))| ...
                   ((tMapOrt>=(Ort(k)+180-tOrtIntv))& ...
                    (tMapOrt<(Ort(k)+180+tOrtIntv))))&tMask,:),1);
  for j = 1:10
    TCPROrtAmp(k,:,j) = ...
      mean(tMapResp((((tMapOrt>=(Ort(k)-tOrtIntv))& ...
                      (tMapOrt<(Ort(k)+tOrtIntv)))| ...
                     ((tMapOrt>=(Ort(k)+180-tOrtIntv))& ...
                      (tMapOrt<(Ort(k)+180+tOrtIntv))))& ...
                     (tAmpOrt>=((j-1)*0.1)&tAmpOrt<(j*0.1))&tMask,:),1);
  end
end


