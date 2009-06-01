function [kernel] = gaussian_kernel( dim )
	% GAUSSIAN_KERNEL
    %   Create a matrix defining a gaussian kernel defined as:
    %               1/dim * sum_{m}^{dim} 1/(2*i+1)^2
    %   where m is the distance the weigth is from the center of the
    %   filter. The kernel gives more weight to pixels near the center of,
    %   and less weight to pixels near the edge of the kernel. The weigths
    %   of the kernel do sum up to one.
    %
    %    [kernel] = gaussian_kernel( dim )
    %
    %   dim     neighborhood halved size
    %
	%   
    %   Matteo Maggioni - Spring 2009
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	kernel = zeros(2*dim+1, 2*dim+1);   
	
	for k = 1:dim
		value = 1 / (2*k+1)^2;
		for i = -k:k
			for j = -k:k
				kernel(dim+1-i, dim+1-j) = kernel(dim+1-i, dim+1-j) + value;
			end
		end
	end
	
	kernel = kernel ./ dim;
end