function [ nl_image ] = non_local_means( noisy_images_padded, kernel, win, neig, h )
    % NON_LOCAL_MEANS
    %   Returns an image denoised with the non local means algorithm
    %   proposed by A. Buades, B. Coll and J.M. Morel in the paper "A
    %   non-local algorithm for image denoising".
    %   
    %   Use: nl_image = non_local_means( noisy_images, win, neig, h )
    %   
    %   noisy_images_padded  an array of gray-scale (padded) images
    %   kernel               gaussian kernel
    %   win                  half-size of the search window
    %   neig                 half-size of the neighborhood
    %   h                    degree of filtering, it controls the decay of the
    %                        weights as a function of the Euclidean distances 
    %
    %
    %   Matteo Maggioni - Spring 2009
    
    [heigth width frames] = size(noisy_images_padded);
    width = width - 2*neig;
    heigth = heigth - 2*neig;
    
    % preallocating objects
    nl_image = zeros(heigth, width);
    
    wbar = waitbar(0,'Please wait...');

    for i = 1:heigth
        for j = 1:width

            % neighborhood of pixel (i, j) bounded by similarity window
            N1 = noisy_images_padded(i : i+2*neig, j : j+2*neig, 1);

            % search window boundaries
            row_min = max(i+neig-win, neig+1);
            row_max = min(i+neig+win, neig+heigth);

            col_min = max(j+neig-win, neig+1);
            col_max = min(j+neig+win, neig+width);

            % normalizing factor, sums of all weigths within search window
            z = 0;
            % denoised pixel value
            nl = 0;
            % maximum weight found so far
            mw = 0;

            % for each pixel within search window boundaries compute
            % similarity with gaussian weigthed euclidean distance between
            % neighborhoods
            for r = row_min:row_max
                for c = col_min:col_max
                    % neighborhood of current pixel (r, c)
                    N2 = noisy_images_padded(r-neig : r+neig, c-neig : c+neig, :);

                    % repeat procedure for each frame
                    for k = 1:frames

                        % exclude pixel (i, j) to avoid auto-comparison
                        if k~=1 || ~(r==i+neig && c==j+neig)

                            % gaussian weigthed euclidean distance
                            gwed = sum(sum(kernel.*((N1-N2(:,:,k)).^2)));

                            % weigth associated to N1 and N2
                            w = exp(-gwed/h^2);

                            % updating maximum
                            if w>mw
                                mw = w;
                            end

                            % updating normalizing factor
                            z = z + w;

                            % updating denoised pixel value
                            nl = nl + w*noisy_images_padded(r, c, k);
                        end

                    end
                end
            end

            % updating with values corresponding to pixel (i,j) itself
            % taking the maximum weight found
            z = z + mw;
            nl = nl + mw*noisy_images_padded(i+neig, j+neig, 1);

            % storing denoised pixel value
            nl_image(i, j) = nl / z;
        end
        
        waitbar(i/heigth);
    end
    close(wbar);

end