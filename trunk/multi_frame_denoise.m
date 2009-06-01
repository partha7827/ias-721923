function [ nl_image, psnr, time ] = multi_frame_denoise( image, noisy_images, win, neig, h, transformation, use_mex )
    % MULTI_FRAME_DENOISE
    %   Returns an image denoised with the non local means algorithm 
    %   starting from a series of noisy frames depicting the same image.
    %   
    %   Use: [nl_image, psnr, time] = multi_frame_denoise( image, noisy_images, win, neig, h, use_mex )
    %   
    %   image           original image
    %   noisy_images    an array of gray-scale images
    %   win             half-size of the search window
    %   neig            half-size of the neighborhood
    %   h               degree of filtering, it controls the decay of the
    %                   weights as a function of the Euclidean distances
    %   transformation  struct containig parameters to transform image
    %   use_mex         use mex file
    %
    %
    %   Matteo Maggioni - Spring 2009
    
    % add transformation to images
    noisy_images = transform_image(noisy_images, transformation);
    
    [heigth width frames] = size(noisy_images);
    
    % preallocating objects
    noisy_images_padded = zeros(heigth+neig*2, width+neig*2, frames);
    
    tic;
    
    disp(sprintf('Start denoising with %d frames', frames));
    disp(sprintf('\timage size: %dx%d pixel', width, heigth));
    disp(sprintf('\tsearch (similarity) window: %dx%d pixel', win*2+1, win*2+1));
    disp(sprintf('\tneighborhood window: %dx%d pixel', neig*2+1, neig*2+1));
    disp(sprintf('\tnoise standard deviation: %d', h));
    disp(sprintf('\ttransformation type: %s', transformation.type));
    
    start = toc;
    
    % computing gaussian kernel of the same size of neighborhood windows
    kernel = gaussian_kernel(neig, 1);
    
    % padding image to let boundary pixels have a proper neighborhood
    for i = 1:frames
        noisy_images_padded(:,:,i) = padarray(noisy_images(:,:,i), [neig neig], 'replicate');
    end
    
    % running algorithm
    if use_mex
        disp(sprintf('\tusing MEX file'));
        nl_image = non_local_means_mex(noisy_images_padded, kernel, win, neig, h);
    else
        disp(sprintf('\tusing MAT file'));
        nl_image = non_local_means(noisy_images_padded, kernel, win, neig, h);
    end
    
    psnr = statistics(image, nl_image);
    
    time = ceil(toc - start);
    
    disp(sprintf('\tpsnr: %g dB', psnr));
    disp(sprintf('\texecution time: %d seconds\n', time));
end