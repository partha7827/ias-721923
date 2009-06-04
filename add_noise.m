function [ noisy_images, noise_data ] = add_noise( original_images, noise_type, varargin )
    % ADD_NOISE
    %   Add a certain type of noise to the specified image:
    %   
    %    [ noisy_images ] = add_noise( original_images, noise_type, sigma, a, b, clip )
    %
    %   original_images the array of images to which add noise
    %   noise_type      a string containing the noise type, it can be one
    %                   of the following values: 'gaussian', 'poisson', 
    %                   'poiss & gauss', 'salt & pepper', 'speckle'
    %   a               semantic varies in function of the noise type
    %   b               gaussian noise standard deviation
    %   clip            choose whether to clip pixel vlue or not (only in 
    %                   case of 'poiss & gauss' noise)
    %
    %
    %   Matteo Maggioni - Spring 2009
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    optargs = size(varargin,2);
    
    if optargs>=1
        a = varargin{1};
    end
    if optargs>=2
        b = varargin{2};
    end
    if optargs==3
        clip = varargin{3};
    end
    
    frames = size(original_images, 3);
    
    noisy_images = zeros(size(original_images));
    noise_data = zeros(size(original_images));
    
    for f = 1:frames
        
        original_image = original_images(:,:,f);
        noisy_image = zeros(size(original_image));
    
        switch noise_type
            case 'gaussian'
                %noisy_image = imnoise(original_image, 'gaussian', a, b^2);
                noisy_image = original_image + a + b*randn(size(original_image));
            case 'poisson'
                noisy_image = imnoise(original_image, 'poisson');
            case 'poiss & gauss'
                    if a~=0
                        chi = 1/a;
                        noisy_image = poissrnd(max(0,chi*original_image)) / chi + min(original_image,0);
                    end

                    %noisy_image = imnoise(noisy_image, 'gaussian', 0, b^2);
                    noisy_image = noisy_image + b*randn(size(noisy_image));

                    if clip
                        noisy_image = min(noisy_image,1);
                        noisy_image = max(0,noisy_image);
                    end
            case 'salt & pepper'
                noisy_image = imnoise(original_image, 'salt & pepper', a);
            case 'speckle'
                noisy_image = imnoise(original_image, 'speckle', a);
            otherwise
                %noisy_image = imnoise(original_image, 'gaussian', a, b^2);
                noisy_image = original_image + a + b*randn(size(original_image));
        end
        
        noisy_images(:,:,f) = noisy_image;
        noise_data(:,:,f) = original_image - noisy_image;
    
    end
    
end