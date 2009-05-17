function [kernel] = gaussian_kernel( dim, replicate )
	% GAUSSIAN_KERNEL
	%
	
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
    
    kernel = repmat(kernel, [1 1 replicate]);
end