function [ psnr, mse ] = statistics( original, synth )
    % STATISTICS
    %   Compute the mean square error (MSE) and the
    %   peak-signal-to-noise-ratio (PSNR) defined respectively as:
    %       
    %       MSE = sum{(I1-I2)^2}/n
    %       PSNR = 10*log10(max_value^2/MSE)
    
    % mean squared error (MSE) of the reconstructed image
    mse = mean2((original-synth).^2);
    
    max_intensity = max(max(original(:), max(synth(:))));
    % peak signal-to-noise-ratio (PSNR)
    psnr = 10*log10(max_intensity^2/mse);
end