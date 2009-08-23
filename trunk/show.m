clear
clc

load workspace/barbara_poiss.mat;
noise = 'poisson';

figure(1), imshow(image, []), title('original');
figure(2), imshow(noise_data(:,:,1,4), []), title('noise');
figure(3), imshow(nl_images(:,:,1,4), []), title('denoised');
if strcmp(noise, 'poisson')
    figure(4), imshow( scale_images(nl_images(:,:,1,4)) - scale_images(noisy_images(:,:,1,4)), []), title('residuals');
else
    figure(4), imshow(nl_images(:,:,1,4) - noisy_images(:,:,1,4), []), title('residuals');
end
figure(5), imshow(noisy_images(:,:,1,4),[]), title('noisy');