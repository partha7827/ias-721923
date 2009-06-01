%% parameters definition

% clear workspace and clean console
%clear
%clc

% frames number
max_frames = 4;
% noise definition
sigma = 15;
randn('state', 0);
% use mex file
use_mex = true;
% search window size
win = 7;
% neighborhood size
neig = 3;
% create example image
image = double(imread('image/digest.png'));
% define rotation and translation
par = struct('type','messy', 'randomize',true ,'degree',5, 'method','crop', 'tx',5, 'ty',5);


%% execution

for f = 1:max_frames
    % creating the proper number of noisy images
    noisy_images(:,:,f) = image + sigma*randn(size(image)); %#ok<AGROW>

    % denoise it
    [nl_images(:,:,f) psnr(f) time(f)] = multi_frame_denoise(image, noisy_images, win, neig, sigma, par, use_mex); %#ok<AGROW>

    % show results
    fig = figure(1);
    set(fig, 'Name', sprintf('%d frames denoising', f), 'NumberTitle','Off');
    subplot(2,2,1), imshow(image, []), title('original');
    subplot(2,2,2), imshow(noisy_images(:,:,f), []), title('noisy');
    subplot(2,2,3), imshow(nl_images(:,:,f), []), title('nl denoised');
    subplot(2,2,4), imshow(nl_images(:,:,f)-noisy_images(:,:,f), []), title('residuals');
end


%% plotting

if max_frames>1
    figure(2);
    plot(1:max_frames,psnr,'-o', 1:max_frames,time,'--'), grid;
    l = legend('psnr', 'time', 2);
    set(l,'Interpreter','none');
end