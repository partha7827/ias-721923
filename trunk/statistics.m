function [ psnr, mse ] = statistics( image1, image2 )
    % STATISTICS
    %   Compute the mean square error (MSE) and the
    %   peak-signal-to-noise-ratio (PSNR) defined respectively as:
    %       
    %       MSE = sum{(I1-I2)^2}/n
    %       PSNR = 10*log10(max_value^2/MSE)
    
    % mean squared error (MSE) of the reconstructed image
    mse = mean2((image1-image2).^2);
    
    max_intensity = max(max(image1(:), max(image2(:))));
    % peak signal-to-noise-ratio (PSNR)
    psnr = 10*log10(max_intensity^2/mse);
end