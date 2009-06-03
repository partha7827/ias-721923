%% parameters definition

% clear workspace and clean console
clear
clc

% maximum number of frames in array
max_frames = 4;
% noise definition
a = 1/200;
b = 10/255;
clip = true;
% boolean - set to true to use mex file
use_mex = true;
% search window halved size
win = 7;
% neighborhood halved size
neig = 3;

% read example image - values range from 0 to 1
image = im2double(imread('image/digest.png'));
[heigth width] = size(image);

% comment out the transformations you don't want to test
type = { ...
    %'oracle', ...
    %'rotated', ...
    %'translated', ...
    %'shaked', ...
    %'scaled', ...
    'fixed' ...
};
% define synthetic movement
transformation = struct( ...
    'type','shaked', ...
    'randomize',true, ...
    'degree',5, ...
    'tx',5, ...
    'ty',5, ...
    'minscale',0.8, ...
    'maxscale',1.2 ...
);

% type of noise
noise = {'gaussian', 'poisson', 'poiss & gauss', 'salt & pepper', 'speckle'};
% index of the noise type to use - 1:gaussian, 2:poisson, etc...
index = 3;



%% execution

disp(sprintf('image size: %dx%d pixel', width, heigth));
disp(sprintf('search (similarity) window: %dx%d pixel', win*2+1, win*2+1));
disp(sprintf('neighborhood window: %dx%d pixel', neig*2+1, neig*2+1));
disp(sprintf('noise type: %s', char(noise(index))));
disp(sprintf('noise defintion: a=%g b=%g clip=%d', a, b, clip));
if use_mex
    disp(sprintf('using MEX file'));
else
    disp(sprintf('using MAT file'));
end

psnr = zeros(max_frames, length(type));
time = zeros(max_frames, length(type));

for f = 1:max_frames
    
    % creating the proper number of noisy images
    [noisy_images(:,:,f) noise_data] = add_noise(image, char(noise(index)), a, b, clip); %#ok<AGROW>
    
    for i = 1:length(type)
        % set the transformaion type
        transformation.type = char(type(i));
        
        disp(sprintf('\n\ttransformation type: %s', char(type(i))));
        disp(sprintf('\tnumber of frames: %d', f));
        
        % add transformation to images
        [messy_images h] = transform_images(noisy_images, b, transformation);
        
        % denoise it
        [nl_images(:,:,f,i) time(f,i)] = multi_frame_denoise(messy_images, win, neig, h, use_mex); %#ok<AGROW>
        
        % getting qulaity measure
        psnr(f,i) = statistics(image, nl_images(:,:,f,i));
        
        disp(sprintf('\texecution time: %g seconds', time(f,i)));
        disp(sprintf('\tpsnr: %g dB', psnr(f,i)));
        
        % show results
        fig = figure(1);
        set(fig, 'Name', sprintf('%d frames - %s sequence - %s noise', f, transformation.type, char(noise(index))), 'NumberTitle','Off');
        subplot(2,2,1), imshow(image, []), title('original');
        subplot(2,2,2), imshow(noise_data, []), title('noise');
        subplot(2,2,3), imshow(nl_images(:,:,f,i), []), title('nl denoised');
        subplot(2,2,4), imshow(nl_images(:,:,f,i)-noisy_images(:,:,1), []), title('residuals');
    end
    
end



%% plotting

if max_frames>1
    figure(2);
    subplot(2,1,1), plot(psnr,'-'), grid, title('psnr'), ylabel('dB'), legend(type, 2);
    subplot(2,1,2), plot(time,'-'), grid, title('time'), ylabel('seconds'), legend(type, 2);
end