function [ noisy_images, sigma ] = transform_images( original_images, original_sigma, transformation )
    % TRANSFORM
    %   Generates a series of noisyimages rotated or translated starting 
    %   from the original image passed as input parameter.
    %
    %    [ noisy_images, sigma ] = transform_images( original_images, original_sigma, transformation )
    %
    %   original_images    an array of images
    %   original_sigma     original standard deviation of noise
    %   transformation     a struct defining transformation parameters, see
    %                      following skeleton for details
    %
    %   struct(    
    %     'type','oracle'|'rotated'|'translated'|'shaked'|'scaled'|'fixed',
    %     'randomize', true|false,
    %     'degree', int,
    %     'tx',int,
    %     'ty',int,
    %     'minscale',int,
    %     'maxscale',int
    %   );
    %
    %   If 'randomixed' is set to false then 'maxscale' will be used for 
    %   scaling. If 'randomize' is true then each value will be set equal
    %   to a random uniformly distributed number between 0 and the actual
    %   value passed in struct.
    %
    %
    %   Matteo Maggioni - Spring 2009
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [heigth width frames] = size(original_images);
    noisy_images = original_images;
    
    sigma = original_sigma;
    
    type = lower(transformation.type);
    
    % exclude first frame to let psnr to its thing
    for i = 2:frames
        
        if strcmp(type, 'rotated') || strcmp(type, 'shaked')
            % picking sign of the rotation
            if rand>0.5
                sign = 1;
            else
                sign = -1;
            end
            % picking value of the rotation
            if transformation.randomize
                degree = sign*transformation.degree*rand;
            else
                degree = transformation.degree;
            end

            noisy_images(:,:,i) = imrotate(noisy_images(:,:,i), degree,'bilinear', 'crop');
        end
    
        if strcmp(type, 'translated') || strcmp(type, 'shaked')
            % picking signs of the translation
            if rand>0.5
                signx = 1;
            else
                signx = -1;
            end
            if rand>0.5
                signy = 1;
            else
                signy = -1;
            end
            % picking values of the translation
            if transformation.randomize
                tx = signx*round(transformation.tx*rand);
                ty = signy*round(transformation.ty*rand);
            else
                tx = transformation.tx;
                ty = transformation.ty;
            end
            T = maketform('affine', [1 0 0; 0 1 0; tx ty 1]);
            
            noisy_images(:,:,i) = imtransform(noisy_images(:,:,i), T, 'XData',[1 width], 'YData',[1 heigth]);
        end
        
        if strcmp(type, 'scaled') || strcmp(type, 'shaked')
            % picking values of scaling
            if transformation.randomize
                scale = (transformation.maxscale-transformation.minscale)*rand + transformation.minscale;
            else
                scale = transformation.maxscale;
            end
            cropped_image = zeros(heigth, width);
            scaled_image = imresize(noisy_images(:,:,i), scale,'bilinear');
            [sh sw] = size(scaled_image);
            
            if sh~=heigth || sw~=width
                % when scale factor is close to one, the scale has no effect
                if scale>1
                    % scaled image is bigger than original
                    bitw = double(~mod(sw - width, 2));
                    bith = double(~mod(sh - heigth, 2));

                    ow = ceil((sw - width)/2);
                    oh = ceil((sh - heigth)/2);

                    cropped_image = scaled_image(oh:sh-oh-bith, ow:sw-ow-bitw);
                else
                    % scaled image is smaller than original
                    ow = ceil((width - sw)/2);
                    oh = ceil((heigth - sh)/2);

                    cropped_image(oh:sh+oh-1, ow:sw+ow-1) = scaled_image;
                end
                noisy_images(:,:,i) = cropped_image;
            end
            
        end
        
    end
    
    if strcmp(transformation.type, 'oracle')
        noisy_images = mean(noisy_images, 3);
        sigma = original_sigma / sqrt(frames);
    end
    
end