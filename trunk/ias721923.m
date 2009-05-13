% create example image
image = double(imread('image/digest.png'));

% add zero-mean white gaussian noise
sigma = 15;
frames = 3;
randn('seed', 0);
for i = 1:frames
    noisy_images(:,:,i) = image + sigma*randn(size(image)); %#ok<AGROW>
    %noisy_images(:,:,i) = double(imnoise(image, 'gaussian', 0, sigma/100)); %#ok<AGROW>
end

% denoise it
verbose = false;
nl_image = non_local_means(noisy_images, 7, 3, sigma, verbose);

%[mse, psnr] = statistics(image, noisy_image);
nl_psnr = statistics(image, nl_image);

% show results
figure(1);
subplot(1,2,1), imshow(image, []), title('original');
subplot(1,2,2), imshow(nl_image, []), title('nl denoised');