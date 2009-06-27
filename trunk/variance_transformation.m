function [ image, sigma ] = variance_transformation( direct, original_image, noise, varargin )
    % VARIANCE_TRANSFORMATION
    %   Apply a variance stabilization transformation depending on the type
    %   of noise to the image passed as parameter. In case of poissonian
    %   noise will be used the Anscombe transform.
    %                           t(I) = 2*sqrt(I+3/8)
    %   Poisson noise is signal dependant , which makes separating signal 
    %   from noise a very difficult task. However this function transforms 
    %   poissonian data to approximately gaussian white noise data of unary
    %   standard deviation.
    %
    %    [ image, sigma ] = variance_transformation( direct, original_image, noise )
    %
    %   direct          set to true to make a direct transformation, false
    %                   to make an inverse one
    %   image           the image to which apply the transformation
    %   noise           string containing the type of noise, currently only
    %                   poissonian noise it's supported
    %
    %
    %   Matteo Maggioni - Spring 2009
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    opt = size(varargin, 2);
    if opt==1
        sigma = varargin{1};
    end
    
    image = original_image;
    
    if strcmp(noise, 'poisson')
        if direct
            % variance stabilization transformation
            image = 2 * sqrt(original_image + 3/8);
            
            % sigma is the noise variance, not the image variance. use MAD
            % to compute noise std given an observation
            sigma = function_stdEst2D(image(:,:,1));
        else
            % inverse variance stabilization transformation
            image = (original_image.^2)/4 - 3/8; % biased
            %image = (original_image.^2)/4 - 1/8; % "debiased"
            
        end
    end
    
end