% Reconstruction using spatially varying PSFs
% PSFs after registeration and FFT are used here
% Spatially varing weights are used here
% Reconstruction for a single plane

%%
reload = 0; % Set to 1 if continue previous iterations

if reload ==0
    clear;
    useGPU = 1;
    
    if useGPU
       gpuDevice(1),
    else
       gpuDevice([]);
    end
    tic,
    reload = 0;
    start_point = 1;
    addpath('./functions/');
     
    % Load Fpsfs and weights
    load FPSFs.mat
    load weights.mat;

    capture = imread('cap_0.20mm.tiff');
    capture = capture(:,513:2560);

    Fpsf = single(Fpsf);
    Nx = size(capture,1);
    Ny = size(capture,2);

    toc
    %
    padding = padding_parm;
    
    px = floor(Nx/padding); py = floor(Ny/padding);
 
    Y = single(capture);
    figure, imshow(Y,[]);

    Nx = size(Y,1);
    Ny = size(Y,2);
    
    showFigs = 1;
    maxItr = 1500;
    gamma = 10; % param for L2
    lmbd1 = 0;  % param for L1
    padding = padding_parm;
    tol = 1e-7;

    center = size(Fpsf,1)/2;
    inter = 300;
    xx = (center-inter):1:(center+inter);
    yy = (center-inter):1:(center+inter);

    %% Step size
    disp('Calculating step size..');
    tic,
    for i = 1:size(Fpsf,3)
        HadjH_max(i) = abs(max(max(conj(Fpsf(:,:,i)).*Fpsf(:,:,i))));
    end
    Em = max(HadjH_max);
    L = Em;
    invL = 1/(2*L);
    toc
    %invL = 0.0000001;
    %%
    
    
    %% Initialization
    disp('Intializing..');
    X_prv = single(zeros(size(Fpsf,1),size(Fpsf,2)));
    G_prv = single(zeros(30,30));
    BG_k = 5;
%    G_prv(1:BG_k,1:BG_k) = BG(1:BG_k,1:BG_k);

    if useGPU == 1
        X_prv = gpuArray(X_prv);
        weights = gpuArray(weights);
        %Fpsf = gpuArray(Fpsf);
        Y = gpuArray(Y);
        G_prv = gpuArray(G_prv);
    end

    V_prv = X_prv;  
    t_prv = 1;
    tp = invL*lmbd1;
    
    fidAcc = [];
    kAcc = [];
    
    %% Reconstruction
    disp('Reconstructing..');
    %fidFn_nxt = sum(reshape(Y_hat_prv - Y,[],1).^2) + lmbd2*sum(X_prv(:).^2);
    
    if showFigs == 1
        fh1 = figure;
        fh2 = figure;
    end
else
    maxItr = 2500;
%    X_prv = X_nxt;
 %   G_prv = G_nxt;
     tol = 1e-10;
    start_point = i-1;
    fh1 = figure;
    fh2 = figure;
end

fidFn_prv = 0;

for i = start_point:maxItr

    tic,
    % calculate Y_hat & error
    Y_hat = A_pca_3d(Fpsf, weights, V_prv, [Nx,Ny], G_prv, padding);
    Y_hat(isnan(Y_hat))=0;

    error = Y_hat - Y;
    
    % gradiant
    [ Atb, Ctb ] = A_adj_pca_3d(Fpsf, weights, error, BG_k, padding);

    gradFn = 2*Atb + gamma*V_prv;
    gradGn = Ctb;
    
    % update x
    fidFn_nxt = sum(reshape(Y_hat - Y,[],1).^2) + gamma*sum(X_prv(:).^2) + lmbd1*norm(X_prv(:),1);
    
    X_nxt = V_prv - invL * gradFn;
    X_nxt(isnan(X_nxt)) = 0;
  %  X_nxt(X_nxt<0)=0;
    
    if lmbd1>0
        X_nxt = max(abs(X_nxt)-tp,0).*sign(X_nxt);
    end
    
    G_nxt = G_prv - invL * gradGn;

    % Neterov's
    t_nxt = 0.5*(1+sqrt(1+4*t_prv^2));
    V_nxt = X_nxt + (t_prv-1)*(X_nxt-X_prv)/t_nxt;
   % GV_nxt = G_nxt + (t_prv-1)*(G_nxt-G_prv)/t_nxt;
    
    if fidFn_nxt > fidFn_prv
        t_prv = 1;
    else
        t_prv = t_nxt;
    end
      
   
    X_prv = X_nxt;
    V_prv = V_nxt;
    G_prv = G_nxt;
    
    % visualization
    fidAcc = [fidAcc fidFn_nxt];
    kAcc = [kAcc i];
    frames = 10; %iterations befpre figure update
    if mod(i,frames) == 0 && showFigs == 1
        fprintf('Iter: %d \n',i);
        X_out = gather(max(X_prv(yy, xx),[],3));
        scaleX = max(X_out(:)); %Scaling
        X_out = X_out/scaleX; %Scaling
        figure(fh1), imshow(X_out), title('Max proj Recon'); drawnow;
        figure(fh2), semilogy(kAcc, fidAcc), title('Error'); drawnow;
    end
    
    if i~=1
        relErr = abs(fidFn_nxt-fidFn_prv)/fidFn_prv;
        if relErr < tol, break; end
    end
    fidFn_prv = fidFn_nxt;
    toc
end
%% Show final results
X_est = X_prv;
% xx = (center-inter):1:(center+inter);
% yy = (center-inter):1:(center+inter);

X_final = gather(X_est);
X_final = X_final./max(X_final(:));
X_final_crop = X_final(yy, xx);
X_final_crop = X_final_crop./max(X_final_crop(:));
%imwrite(X_final_crop,'USAF_recon_LCM_down.png');
figure,imshow(X_final_crop);