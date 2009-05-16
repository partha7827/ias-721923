function [ nl_image ] = non_local_means( noisy_images, win, neig, h, verbose )
    % NON_LOCAL_MEANS
    %   Returns an image denoised with the non local means algorithm
    %   proposed by A. Buades, B. Coll and J.M. Morel in the paper "A
    %   non-local algorithm for image denoising".
    %   
    %   Use: nl_image = non_local_means( noisy_image, win, neig, h )
    %   
    %   noisy_image     a gray-scale image
    %   win             half-size of the search window
    %   neig            half-size of the neighborhood
    %   h               degree of filtering, it controls the decay of the
    %                   weights as a function of the Euclidean distances 
    %   verbose         display output while executing algorithm
    %
    %
    %   Matteo Maggioni - Spring 2009
    
    [heigth width frames] = size(noisy_images);
    nl_image = zeros(heigth, width);
    
    % padding image to let boundary pixels have a proper neighborhood
    for i = 1:frames
        noisy_image_padded(:,:,i) = padarray(noisy_images(:,:,i), [neig neig], 'replicate'); %#ok<AGROW>
    end
    
    if verbose
        figure(1), imshow(noisy_image_padded(:,:,1), []), hold on;
    end
    
    % computing gaussian kernel of the same size of neighborhood windows
    kernel = gaussian_kernel(neig);
    
    if verbose
        neigh1 = rectangle('LineWidth',1, 'EdgeColor','red');
        %neigh2 = rectangle('LineWidth',1, 'EdgeColor','yellow');
        best_neigh = rectangle('LineWidth',1, 'EdgeColor','blue');
        window = rectangle('LineWidth',1, 'LineStyle','--', 'EdgeColor','white');
    end
    
    %start = toc;
    wbar = waitbar(0,'Please wait...');
    for i = 1:heigth
        for j = 1:width
            
            % neighborhood of pixel (i, j) bounded by similarity window
            N1 = noisy_image_padded(i : i+2*neig, j : j+2*neig, 1);
            
            if verbose
                figure(1), set(neigh1, 'Position', [j i 2*neig 2*neig]);
            end
                
            % search window boundaries
            row_min = max(i+neig-win, neig+1);
            row_max = min(i+neig+win, neig+heigth);
            
            col_min = max(j+neig-win, neig+1);
            col_max = min(j+neig+win, neig+width);
            
            if verbose
                figure(1), set(window, 'Position', [col_min row_min col_max-col_min row_max-row_min]);
            end
            
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
                    % repeat procedure for each frame
                    for k = 1:frames
                    
                        % exclude pixel (i, j) to avoid auto-comparison
                        if k~=1 && (r~=i+neig || c~=j+neig)
                            % neighborhood of current pixel (r, c)
                            N2 = noisy_image_padded(r-neig : r+neig, c-neig : c+neig, k);

                            if verbose
                                %figure(1), set(neigh2, 'Position', [c-neig r-neig 2*neig 2*neig]);
                            end

                            % gaussian weigthed euclidean distance
                            gwed = sum(sum(kernel.*((N1-N2).^2)));

                            % weigth associated to N1 and N2
                            w = exp(-gwed/h^2);

                            % updating maximum
                            if w>mw
                                mw = w;
                                if verbose
                                    figure(1), set(best_neigh, 'Position', [c-neig r-neig 2*neig 2*neig]);
                                end
                            end

                            % updating normalizing factor
                            z = z + w;

                            % updating denoised pixel value
                            nl = nl + w*noisy_image_padded(r, c, k);
                        end
                    
                    end
                    
                end
            end
            
            % updating with values corresponding to pixel (i,j) itself
            % taking the maximum weight found
            z = z + mw;
            nl = nl + mw*noisy_image_padded(i+neig, j+neig, 1);
            
            % storing denoised pixel value
            nl_image(i, j) = nl / z;
            if verbose
                pause;
            end
        end

        %disp((toc - start)/i*(heigth-i));
        waitbar(i/heigth);
    end
    close(wbar);
    
end