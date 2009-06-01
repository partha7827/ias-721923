function [ noisy_image, noise_data ] = add_noise( original_image, noise, sigma )
    % ADD_NOISE
    %   Add a certain type of noise to the specified image:
    %   
    %    [ noisy_image ] = add_noise( original_image, noise, sigma )
    %
    %   original_image  the image to which add noise
    %   noise           a string containing the noise type
    %   sigma           noise standard deviation
    %
    %
    %   Matteo Maggioni - Spring 2009
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    switch noise
        case 'gaussian'
            noisy_image = imnoise(original_image, 'gaussian', 0, sigma^2);
        case 'poisson'
            noisy_image = imnoise(original_image, 'poisson');
        case 'salt & pepper'
            noisy_image = imnoise(original_image, 'salt & pepper', sigma);
        case 'speckle'
            noisy_image = imnoise(original_image, 'speckle', sigma);
        otherwise
            noisy_image = imnoise(original_image, 'gaussian', 0, sigma^2);
    end
    
    noise_data = original_image - noisy_image;
    
end