%% parameters definition

% clear workspace and clean console
clear
clc

% test repetitions
rep = 1;

% noise definition
% type of noise: 'gaussian', 'poisson' or 'poiss & gauss'
noise = 'poisson';
seed = 0;
a = 1/200;
b = 10/255;
clip = false;
% don't change this variable
direct = true;

% boolean - set to true to use mex file
use_mex = true;
% maximum number of frames in array
min_frames = 1;
max_frames = 4;
% search window halved size
win = 7;
% neighborhood halved size
neig = 3;

% read image - values range is [0, 1]
image = im2double(imread('image/digest.png'));
[heigth width] = size(image);

% comment out the transformations you don't want to test
type = { ...
    'mono', ... 
    'oracle', ...
    'fixed', ...
    'shaked', ...
    %'scaled', ...
    %'rotated', ...
    %'translated', ...
};
% define synthetic movement
transformation = struct( ...
    'type','shaked', ...
    'randomize',true, ...
    'degree',5, ...
    'tx',5, ...
    'ty',5, ...
    'minscale',0.9, ...
    'maxscale',1.1 ...
);

% displaying general information
disp(sprintf('test repetitions: %d times', rep));
disp(sprintf('image size: %dx%d pixel', width, heigth));
disp(sprintf('frames: %d', max_frames));
disp(sprintf('search (similarity) window: %dx%d pixel', win*2+1, win*2+1));
disp(sprintf('neighborhood window: %dx%d pixel', neig*2+1, neig*2+1));
disp(sprintf('noise type: %s', noise));
disp(sprintf('noise defintion: a=%g b=%g clip=%d', a, b, clip));
if use_mex
    disp(sprintf('using MEX file'));
else
    disp(sprintf('using MAT file'));
end

% preallocating objects
images = repmat(image, [1 1 max_frames]);
nl_images = zeros(heigth, width, max_frames, length(type));
noisy_images = zeros(heigth, width, max_frames, length(type));
noise_data = zeros(heigth, width, max_frames, length(type));
psnr = zeros(max_frames, length(type), rep);
time = zeros(max_frames, length(type), rep);



%% execution

for z = 1:rep
    % for each repetition we use a different seed
    seed = seed + 1;
    
    for i = 1:length(type)

        % setting the transformaion type
        transformation.type = char(type(i));
        disp(sprintf('\ncreating %d %s images with %s noise', max_frames, transformation.type, noise));


        % adding transformation to images
        noisy_images(:,:,:,i) = transform_images(images, transformation);
        % adding noise
        [noisy_images(:,:,:,i) noise_data(:,:,:,i)] = add_noise(noisy_images(:,:,:,i), noise, a, b, clip, seed);


        disp(sprintf('starting denoising with %s frames', char(type(i))));
        for f = min_frames:max_frames
            disp(sprintf('\n\tnumber of frames: %d', f));

            if strcmp(char(type(i)), 'oracle')
                % sum pixels value
                final_noisy_images = sum(noisy_images(:,:,1:f,i), 3);

                if strcmp(noise, 'poisson')
                    % direct variance transformation
                    [final_noisy_images sigma] = variance_transformation(direct, final_noisy_images, noise, b);
                    % averaging every pixel
                    final_noisy_images = final_noisy_images ./ f;
                    % updating standard deviation
                    h = sigma / f;
                else
                    % averaging every pixel
                    final_noisy_images = final_noisy_images ./ f;
                    % updating standard deviation
                    h = b / sqrt(f);
                end

            else
                final_noisy_images = noisy_images(:,:,1:f,i);
                if strcmp(noise, 'poisson')
                    [final_noisy_images sigma] = variance_transformation(direct, final_noisy_images, noise, b);
                    h = sigma;
                else
                    h = b;
                end

            end
            
            if strcmp(char(type(i)), 'mono')
                final_noisy_images = final_noisy_images(:,:,1);
                search_win = (sqrt(f)*(2*win+1)-1)/2;
            else
                search_win = win;
            end
            
            disp(sprintf('\th: %g', h));

            % denoising
            [nl_images(:,:,f,i) time(f,i,z)] = multi_frame_denoise(final_noisy_images, search_win, neig, h, use_mex);

            if strcmp(noise, 'poisson')
                % inverse variance transformation
                nl_images(:,:,f,i) = variance_transformation(~direct, nl_images(:,:,f,i), noise);
                nl_images(:,:,f,i) = nl_images(:,:,f,i) .* a;
            end

            scale = strcmp(noise, 'poisson') && strcmp(char(type(i)), 'oracle') && f>1;

            % getting quality measure
            psnr(f,i,z) = statistics(image, nl_images(:,:,f,i), scale);

            disp(sprintf('\texecution time: %g seconds', time(f,i)));
            disp(sprintf('\tpsnr: %g dB', psnr(f,i)));

            % showing results
            fig = figure(1);
            set(fig, 'Name', sprintf('%d frames - %s sequence - %s noise', f, transformation.type, noise), 'NumberTitle','Off');
            subplot(2,2,1), imshow(image, []), title('original');
            subplot(2,2,2), imshow(noise_data(:,:,f,i), []), title('noise');
            subplot(2,2,3), imshow(nl_images(:,:,f,i), []), title('nl denoised');
            if strcmp(noise, 'poisson')
                subplot(2,2,4), imshow( scale_images(nl_images(:,:,f,i)) - scale_images(noisy_images(:,:,1,i)), []), title('residuals');
            else
                subplot(2,2,4), imshow(nl_images(:,:,f,i) - noisy_images(:,:,1,i), []), title('residuals');
            end
        end
    end
    
end

% cleaning workspace
clear noise seed a b clip direct rep;
clear use_mex win neig;
clear heigth width transformation;
clear images final_noisy_images;
clear f fig i z;



%% plotting

% averaging test results
psnr_avg = mean(psnr, 3);

if max_frames>1
    figure(2);
    %subplot(2,1,1);
    plot(psnr_avg,'-o'), grid, title('psnr'), ylabel('dB'), legend(type, 2);
    %subplot(2,1,2), plot(time,'-o'), grid, title('time'), ylabel('seconds'), legend(type, 2);
end