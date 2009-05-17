%% parameters definition

% frames number
max_frames = 4;
% noise definition
sigma = 15;
randn('state', 0);
% show verbose output
verbose = true;
% show graphically algorithm execution
graphic = false;
% search window size
win = 7;
% neighborhood size
neig = 3;
% create example image
image = double(imread('image/stream.png'));

%% execution

for f = 1:max_frames
    % creating the proper number of noisy images
    noisy_images(:,:,f) = image + sigma*randn(size(image)); %#ok<AGROW>

    % denoise it
    nl_images(:,:,f) = non_local_means(noisy_images, win, neig, sigma, verbose, graphic); %#ok<AGROW>

    %[mse, psnr] = statistics(image, noisy_image);
    psnr(f) = statistics(image, nl_images(:,:,f)); %#ok<AGROW>

    % show results
    figure(1);
    subplot(2,2,1), imshow(image, []), title('original');
    subplot(2,2,2), imshow(noisy_images(:,:,f), []), title('noisy');
    subplot(2,2,3), imshow(nl_images(:,:,f), []), title('nl denoised');
    subplot(2,2,4), imshow(nl_images(:,:,f)-noisy_images(:,:,f), []), title('residuals');
end

%% plotting

if max_frames>1
    figure(2);
    plot(1:max_frames, psnr);
end