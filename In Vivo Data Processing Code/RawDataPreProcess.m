%% Convert raw video into single frames

V = VideoReader('RawData.avi'); % Read in raw videos
V.CurrentTime = 0;
num_images = V.FrameRate*V.Duration;
i = 1;
tic,
while hasFrame(V)
    frame = readFrame(V);
    fprintf('frame%04d \n',i);
    Captured_images = im2double(frame(:,:,1));
    imwrite(Captured_images,['./SingleFrames/frame_',num2str(i,'%04d'),'.png']);
    i = i+1;    
end
toc