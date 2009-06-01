function [ transformed_images ] = transform_image( original_images, transformation )
    % TRANSFORM
    %   Generates a series of images rotated or translated starting from
    %   the series passed as input parameter.
    %
    %   Use: [ transformed_images ] = transform( original_images, transformation )
    %
    %   original_images    an array of images
    %   transformation     a struct defining transformation parameters, see
    %                      following skeleton for details
    %                           struct(    
    %                               'type','rotated'|'translated'|'messy'|'fixed',
    %                               'randomize', true|false,
    %                               'degree', int,
    %                               'method','crop'|'loose',
    %                               'tx',int,
    %                               'ty',int
    %                           );
    %
    %   Matteo Maggioni - Spring 2009
    
    randn('state', 0);
    
    [heigth width frames] = size(original_images);
    
    transformed_images = original_images;
    
    type = lower(transformation.type);
    
    if strcmp(type, 'rotated') || strcmp(type, 'messy')
        for i = 1:frames
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

            transformed_images(:,:,i) = imrotate(transformed_images(:,:,i), degree, transformation.method);
        end
    end
    
    if strcmp(type, 'translated') || strcmp(type, 'messy')
        for i = 1:frames
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
            
            transformed_images(:,:,i) = imtransform(transformed_images(:,:,i), T, 'XData', [1 width], 'YData', [1 heigth]);

        end
    end
    
end