% read in captured PSFs at a single depth
% Calibration should be done in 'S' shape
% the point position moves opposite as PSF pattern
% the gap between each PSF capture is 1 mm

clear;

%% Read in psfs at each row
n = 1;
downsample = 1;

for folder_num = 1
    foldername = ['Z',num2str(folder_num)];
    path = ['.\',foldername,'\'];
    files = dir(strcat(path,'*.mat'));
    file_len = size(files,1);
    num_row = 9;
    
    for k = 1:1:num_row
        psfNum_eachrow = 9;
        if mod(k,2) ~= 0
            for file_num = (k-1)*psfNum_eachrow+1:1:(k-1)*psfNum_eachrow+psfNum_eachrow
                psfName = [path, ['psf_',num2str(file_num,'%.04d'),'mm.mat']];
                %        psf = im2double(imread(psfName));
                fprintf('PSF_ %d \n',file_num);
                psf = load(psfName);
                psf = psf.avgCap;
                % Smooth the boundary of psf
                w_psfCut = 100; %10
                kg = fspecial('gaussian',w_psfCut*[1,1],w_psfCut/10); %2);
                crpSmth = zeros(size(psf));
                crpSmth(w_psfCut+1:end-w_psfCut,w_psfCut+1:end-w_psfCut) = 1;
                crpSmth = imfilter(crpSmth,kg,'same');
                psf = bsxfun(@times, psf, crpSmth);
                

                psf = psf(:,513:2560);
                psf = imresize(psf,[size(psf,1)/downsample,size(psf,2)/downsample],'bilinear'); %(:,512:2559)
                psf(psf<0)=0;
                PSF(:,:,n) = single(psf);
                n = n+1;
            end
        end
        if mod(k,2) == 0
            for file_num = (k-1)*psfNum_eachrow+psfNum_eachrow:-1:(k-1)*psfNum_eachrow+1
                psfName = [path, ['psf_',num2str(file_num,'%.04d'),'mm.mat']];
                %        psf = im2double(imread(psfName));
                fprintf('PSF_ %d \n',file_num);
                psf = load(psfName);
                psf = psf.avgCap;
                % Smooth the boundary of psf
                w_psfCut = 100; %10
                kg = fspecial('gaussian',w_psfCut*[1,1],w_psfCut/10); %2);
                crpSmth = zeros(size(psf));
                crpSmth(w_psfCut+1:end-w_psfCut,w_psfCut+1:end-w_psfCut) = 1;
                crpSmth = imfilter(crpSmth,kg,'same');
                psf = bsxfun(@times, psf, crpSmth);
                
                psf = psf(:,513:2560);
                %  psf = imresize(psf(:,512:2559),[sensRes,sensRes]);
                psf = imresize(psf,[size(psf,1)/downsample,size(psf,2)/downsample],'bilinear');
                psf(psf<0)=0;
                PSF(:,:,n) = single(psf);
                n = n+1;
            end
        end       
    end
end

%% save original PSFs
%save('PSFs_inter1_Z2.16.mat','PSF','psfNum_eachrow');

%% Init Params
scale = 1;

Nx = size(PSF,1)/scale;
Ny = size(PSF,2)/scale;
num_psfs = size(PSF,3);
padding_parm = 6;
%downsample = 2;

%%
py = floor((Ny-Nx)/2);
PSF = single(padarray(PSF,[py,0], 0,'both'));
Nx = size(PSF,1)/scale;
Ny = size(PSF,2)/scale;
px = floor(Nx/padding_parm); py = floor(Ny/padding_parm);

PSF = single(padarray(PSF,[px,py], 0,'both'));
Nx = size(PSF,1)/scale;
Ny = size(PSF,2)/scale;
%%
center_weight = zeros(num_psfs,2);
center_show = zeros(size(PSF,1),size(PSF,2));
%figure, imshow(psf_center);

distance = 137;%90
center_row = 5;
center_col = 5;
num_col = 9; %length(psfNum_eachrow);
%inter_general = abs(floor(distance/scale)); % micron
inter_general = round(distance);
psf_overall = zeros(size(PSF,1),size(PSF,2));
psfNum_eachrow = 9;

%% Registration PSFs and FFT
n = 1;

for i = 1:num_col
    for j = 1:psfNum_eachrow%(1,i)
        fprintf('PSF #: %d \n',n);

        psf_resize = PSF(:,:,n); %cente r

        yoffSet = (center_col-j)*distance;
        xoffSet = (center_row-i)*distance;

        center_weight(n,1) = floor(-xoffSet+size(psf_resize,1)/2);
        center_weight(n,2) = floor(-yoffSet+size(psf_resize,2)/2);
        center_show(center_weight(n,1),center_weight(n,2)) = 1;

        shift_x = floor(xoffSet);
        shift_y = floor(yoffSet);
        shift = translate(strel(1),[shift_x shift_y]);
        psf_shift = imdilate(psf_resize,shift);
        psf_shift(psf_shift==-inf)=0;
        psf_shift(psf_shift<0)=0;
        psf_rc(i,j,:,:) = psf_shift;
        psf_overall = psf_overall + psf_shift;

        %   figure, imshow(psf_shift,[]);
        psf_reg(:,:,n) = psf_shift;
        Fpsf(:,:,n,1) = fft2(fftshift(single(psf_shift)));
        n = n+1;
        %  toc
    end
end
figure, imshow(psf_overall,[]);


%% save FPSFs and registered PSFs
save('FPSFs_inter1_Z2.16.mat','Fpsf','padding_parm');
save('psfsreg_inter1_Z2.16.mat','psf_reg');

%% Get spatially-varying weights

weights = zeros(size(psf_resize,1),size(psf_resize,2),size(PSF,3));
point_overall = zeros(size(psf_resize,1),size(psf_resize,2));
weights_overall = zeros(size(psf_resize,1),size(psf_resize,2));
weights_save = zeros(size(psf_resize,1),size(psf_resize,2));

for num = 1:num_psfs%start_point_x:inter:end_point_x
    fprintf('weights #: %d \n',num);
    i = center_weight(num,1);
    j = center_weight(num,2);

    center = [i j];

    pos = mod(num,num_col);

    if num ==1 % top left
        inter_left = inter_general;
        inter_up = inter_general;
        inter_right = inter_general;
        inter_down = inter_general;
    end
    if num == num_col % top right point
        inter_left = inter_general;
        inter_up = inter_general;
        inter_right = inter_general;
        inter_down = inter_general;
    end
    if num < num_col && pos ~= 1 % top-row
        inter_left = inter_general;
        inter_up = inter_general;
        inter_right = inter_general;
        inter_down = inter_general;
    end
    if num > num_col && num <= size(PSF,3)-num_col && pos == 0
        inter_left = inter_general;
        inter_up = inter_general;
        inter_right = inter_general;
        inter_down = inter_general;
    end
    if num > num_col && num <= size(PSF,3)-num_col && pos == 1 %left-row
        inter_left = inter_general;
        inter_up = inter_general;
        inter_right = inter_general;
        inter_down = inter_general;
    end

    if num > size(PSF,3)-num_col && pos ~= 0  %bottom-row
        inter_left = inter_general;
        inter_up = inter_general;
        inter_right = inter_general;
        inter_down = inter_general;
    end
    if num == size(PSF,3)-num_col+1 %bottom-left point
        inter_left = inter_general;
        inter_up = inter_general;
        inter_right = inter_general;
        inter_down = inter_general;
    end
    if num == size(PSF,3)  %bottom right point
        center_10_y = center_weight(num-1,2); % right distance
        center_10_x = center_weight(num-num_col,1); % down distance

        inter_left = inter_general;
        inter_up = inter_general;
        inter_right = inter_general;
        inter_down = inter_general;
    end

    if num > num_col && num < size(PSF,3)-num_col && pos ~= 1 && pos ~= 0 % center area
        inter_left = inter_general;
        inter_up = inter_general;
        inter_right = inter_general;
        inter_down = inter_general;
    end
    % up-left
    for m = i-inter_up:i-1
        for n = j-inter_left:j-1
            weights(m,n,num) = (m-(i-inter_up))*(n-(j-inter_left));
        end
    end
    % down-left
    for m = i:i+inter_down-1
        for n = j-inter_left:j-1
            weights(m,n,num) = (i+inter_down-m)*(n-(j-inter_left));
        end
    end
    % up-right
    for m = i-inter_up:i-1
        for n = j:j+inter_right
            weights(m,n,num) = (m-(i-inter_up))*(j+inter_right-n);
        end
    end
    % down-right
    for m = i:i+inter_down-1
        for n = j:j+inter_right-1
            weights(m,n,num) = (i+inter_down-m)*(j+inter_right-n);
        end
    end

    %figure, imshow(weights(:,:,num),[]);
    weights(:,:,num) = weights(:,:,num)./max(max(weights(:,:,num)));
    weights_overall = weights_overall+weights(:,:,num);

end
%weights(:,:,num) = single(weights(1:size(PSF,1),1:size(PSF,2),num));
figure, imshow(weights_overall,[]);

%% 
save('weights_inter1_Z2.16.mat','weights')