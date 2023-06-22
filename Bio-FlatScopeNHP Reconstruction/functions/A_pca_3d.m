function [ b_out ] = A_pca_3d(Fpsf, weights, x, Size, BG, padding)
% [ b ] = A_pca_3d(Fpsf, weights, x, BG, pad, crop)
%   Fpsf: 2D Fourier transform of PSFs, size Ny x Nx x Npc x Nz
%       Ny - num pixels in y (after padding)
%       Nx - num pixels in x (after padding)
%       Npc - num of spatially varying PSFs per depth
%       Nz - num of depth planes
%   weights: spatially varying weights, size Ny x Nx x Npc
%   x: 3D object, size Ny x Nx x Nz
%   BG: lowest k x k components of the DCT transform of the background
%   pad: handle to pad function
%   crop: handle to crop function (output should be size of data)
 
for n = 1:size(Fpsf,4)
    for m = 1:size(Fpsf,3)
        if m == 1 && n == 1
            B = gpuArray(Fpsf(:,:,m,n)).*fft2(fftshift(gpuArray(weights(:,:,m).* x(:,:,n))));
        else
            B = B + gpuArray(Fpsf(:,:,m,n)).*fft2(fftshift(gpuArray(weights(:,:,m).* x(:,:,n))));
        end
    end
end
 
%b = crop(fftshift(real(ifft2(B))),size(Fpsf,1));
b = real(ifftshift(ifft2(B)));
px = floor(Size(1)/padding);py = floor(Size(2)/padding);
b_out = (b(px+1:end-px, py+1:end-py));
%b_out = b;

BGpad = single(zeros(size(b_out)));
BGpad(1:size(BG,1), 1:size(BG,2)) = gather(BG);
bg = idct2(BGpad);
b_out = b_out+gpuArray(bg);


 
 
end
 