function [Ev,Em] = eigMax_A(A,At,maxit,lmbd2,szX,useGPU)

X = 10*randn(szX);
if useGPU ==1
    X = gpuArray(X);
end
for ii = 1:maxit
    Xnew = At*(A*X) + lmbd2*X;
    Em = (Xnew(:)'*X(:))/(X(:)'*X(:));
    X = Xnew/norm(Xnew(:));
end
Ev = X;
end