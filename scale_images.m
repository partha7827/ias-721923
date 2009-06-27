function [ scaled_images ] = scale_images( original_images )
    % SCALE_IMAGES
    %   Scale back to [0,1] the images passed as parameter and optionally
    %   the standard deviation.
    %
    %    [ scaled_images ] = scale_images( original_images )
    %
    %
    %   Matteo Maggioni - Spring 2009
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    scaled_images = zeros(size(original_images));
    
    for i=1:size(original_images,3)
        image = original_images(:,:,i);
        
        scaled_images(:,:,i) = (image-min(image(:))) ./ (max(image(:))-min(image(:)));
        
    end

end
