function [ processed_image ] = preprocess( original_image, window )
    % PREPROCESS
    %   Transform a series of n images of size widthxheigth pixels in a
    %   single 4-dim matrix, whose dimensions repressents respectively:
    %       [width, heigth, n, neighbothood vector of pixel (i, j)]
    
    [heigth width frames] = size(original_image);
    
    processed_image = zeros(heigth, width, frames, (2*window+1)^2);
    
    for k = 1:frames
        padded_image = padarray(original_image(:,:,k), [window window], 'replicate');
        for i = 1:heigth
            for j = 1:width
                processed_image(i, j, k, :) = reshape(padded_image(i : i+2*window, j : j+2*window), 1, (2*window+1)^2);
            end
        end
    end
    
end