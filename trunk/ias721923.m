%% parameters definition

% frames number
max_frames = 1;
% noise definition
sigma = 15;
randn('state', 0);
% show verbose output
verbose = true;
% show graphically algorithm execution
graphic = false;
% create example image
image = double(imread('image/digest.png'));

%% execution

for f = 1:max_frames
    clear noisy_images;
    % creating the proper number of noisy images
    for i = 1:f
        noisy_images(:,:,i) = image + sigma*randn(size(image)); %#ok<AGROW>
    end

    % denoise it
    nl_images(:,:,f) = non_local_means(noisy_images, 7, 3, sigma, verbose, graphic); %#ok<AGROW>

    %[mse, psnr] = statistics(image, noisy_image);
    psnr(f) = statistics(image, nl_images(:,:,f)); %#ok<AGROW>

    % show results
    figure(1);
    subplot(1,2,1), imshow(image, []), title('original');
    subplot(1,2,2), imshow(nl_images(:,:,f), []), title('nl denoised');
end

%% plotting
if max_frames>1
    plot(1:max_frames, psnr);
end