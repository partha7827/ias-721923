function [ nl_image, time ] = multi_frame_denoise( noisy_images, win, neig, h, use_mex )
    % MULTI_FRAME_DENOISE
    %   Returns an image denoised with the non local means algorithm 
    %   starting from a series of noisy frames depicting the same image.
    %   
    %    [ nl_image, time ] = multi_frame_denoise( noisy_images, win, neig, h, use_mex )
    %   
    %   noisy_images    an array of gray-scale images
    %   win             half-size of the search window
    %   neig            half-size of the neighborhood
    %   h               degree of filtering, it controls the decay of the
    %                   weights as a function of the Euclidean distances
    %   use_mex         use mex file
    %
    %
    %   Matteo Maggioni - Spring 2009
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    tic;

    start = toc;
    
    % computing gaussian kernel of the same size of neighborhood windows
    kernel = gaussian_kernel(neig);
    
    % padding image to let boundary pixels have a proper neighborhood
    noisy_images_padded = padarray(noisy_images, [neig neig], 'symmetric');
    
    % running algorithm
    if use_mex
        nl_image = non_local_means_mex(noisy_images_padded, kernel, win, neig, h);
    else
        nl_image = non_local_means(noisy_images_padded, kernel, win, neig, h);
    end
    
    time = toc - start;
    
end