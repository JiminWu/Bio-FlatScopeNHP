function B = RotateMatrix(A,Angle)

%% Rotate the first 2 dimention of A with Angle (deg)
% Origin is the center of the first 2 dimention of A
% Clockwise is positive
%
%
% YC at ES lab
% Created on Jul. 3, 2008
% Last modified on Jul. 15, 2008

%% Parameters
SizeA = size(A);

Width = SizeA(2);
Height = SizeA(1);
nRemain = prod(SizeA)/Width/Height;

Angle = Angle*pi/180;
A = reshape(A,[Height,Width,nRemain]);

%% Coordinates
[X,Y] = meshgrid((1:Width)-(Width+1)/2,(1:Height)-(Height+1)/2);

%% Rotation matrix
RotationMatrix = [cos(Angle),-sin(Angle);sin(Angle),cos(Angle)];

%% Rotate co-ordinates
tRotation = [X(:),Y(:)]*RotationMatrix;

XI = reshape(tRotation(:,1),[Height,Width]);
YI = reshape(tRotation(:,2),[Height,Width]);

%% Rotate matrix by interpolation
B = zeros(size(A));
for k = 1:nRemain
  B(:,:,k) = interp2(X,Y,A(:,:,k),XI,YI);
end
B(isnan(B)) = 0;

B = reshape(B,SizeA);


