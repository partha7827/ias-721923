function [ psnr ] = compare_algorithms( win, neig, h, varargin )
    % COMPARE
    %   Compare performace of non local means implementations.
    %
    %    [ psnr ] = compare_algorithms( win, neig, h, image )
    %
    %   win     search window
    %   neig    neighborhood window
    %   h       non local means parameter (noise std)
    %   image   [optional] the image used to compare the algorithms, if not
    %           specified will be used a default image
    %
    %
    %   Matteo Maggioni - Spring 2009
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    optargs = size(varargin,2);
    if optargs==1
        image = varargin{1};
    else
        image = im2double(imread('image/digest.png'));
    end
    
    randn('state',0);
    noisy = image + h*randn(size(image));
    tic;
    start = toc;
    
    mat_nl = non_local_means(padarray(noisy, [neig neig], 'symmetric'), gaussian_kernel(neig), win, neig, h);
    mat_time = toc - start;
    psnr(1) = statistics(image, mat_nl);
    disp(sprintf('\tMAT\tpsnr: %g dB (%g seconds)', psnr(1), mat_time));
    
    mex_nl = non_local_means_mex(padarray(noisy, [neig neig], 'symmetric'), gaussian_kernel(neig), win, neig, h);
    mex_time = toc - mat_time;
    psnr(2) = statistics(image, mex_nl);
    disp(sprintf('\tMEX\tpsnr: %g dB (%g seconds)', psnr(2), mex_time));
    
    bd_nl = NLmeansfilter(noisy, win, neig, h);
    baud_time = toc - (mat_time + mex_time);
    psnr(3) = statistics(image, bd_nl);
    disp(sprintf('\tBaudes\tpsnr: %g dB (%g seconds)', psnr(3), baud_time));
    
end