function [ Atb, Ctb ] = A_adj_pca_3d(Fpsf, weights, error, k, padding)
% [ Atb, Ctb ] = A_adj_pca_3d(Fpsf, weights, error, k, pad, crop)
%   Fpsf: 2D Fourier transform of PSFs, size Ny x Nx x Npc x Nz
%       Ny - num pixels in y (after padding)
%       Nx - num pixels in x (after padding)
%       Npc - num of spatially varying PSFs per depth
%       Nz - num of depth planes
%   weights: spatially varying weights, size Ny x Nx x Npc
%   error: Ax-b, size Ny(before padding) x Nx(before padding) x Nz
%   k: number of DCT coefficents (k x k) of background
%   pad: handle to pad function
%   crop: handle to crop function (output should be size of data)
 
 
Atb = gpuArray(single(zeros(size(Fpsf,1), size(Fpsf,2), size(Fpsf,4))));
 
%Ferr = fft2(pad(error));

 py = floor(size(error,1)/padding); px = floor(size(error,2)/padding);          
 error_pad = padarray(error,[py,px],'replicate');
%error_pad = error;

Ferr = fft2(fftshift(error_pad));

for n = 1:size(Fpsf,4)
    for m = 1:size(Fpsf,3)
        Fpsf_conj = conj(gpuArray(Fpsf(:,:,m,n)));
        if m == 1
            Atb(:,:,n) = (weights(:,:,m).*real(fftshift(ifft2(gpuArray(Fpsf_conj.*Ferr)))));
        else
            Atb(:,:,n) = Atb(:,:,n) + (weights(:,:,m).*real(fftshift(ifft2(gpuArray(Fpsf_conj.*Ferr)))));
        end
    end
end
 
Ctb_init = single(dct2(gather(error)));
Ctb = gpuArray(single(zeros(30,30)));
Ctb(1:k, 1:k) = Ctb_init(1:k, 1:k);
 
end
 