function [ psnr, mse ] = statistics( original_image, denoised_image )
    % STATISTICS
    %   Compute the mean square error (MSE) and the
    %   peak-signal-to-noise-ratio (PSNR) defined respectively as:
    %       
    %                   MSE = sum{(I1-I2)^2}/n
    %              PSNR = 10*log10(max_value^2/MSE)
    % 
    %    [ psnr, mse ] = statistics( original_image, denoised_image )
    %
    %   original_image  the image used as comparison
    %   denoised_image  the image produced by denoising routine
    %
    %
    %   Matteo Maggioni - Spring 2009
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % mean squared error (MSE) of the reconstructed image
    mse = mean2((original_image-denoised_image).^2);
    
    max_intensity = max(max(original_image(:), max(denoised_image(:))));
    % peak signal-to-noise-ratio (PSNR)
    psnr = 10*log10(max_intensity^2/mse);
end