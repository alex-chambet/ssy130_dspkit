function [xhat, e, lms_coeffs, lms_coeffs_history] = my_lms(lms_state, lms_coeffs, x, block_size, mu)
	%MY_LMS Performs block_size iterations of the LMS algorithm
	%	Input: 
	%		lms_state 	The measured disturbance ('y' can be generated by looking at a subsection of this vector)
	%		lms_coeffs 	The current channel estimate
	%		x			The measured signal (disturbance passed through channel)
	%		block_size	The number of iterations to perform (also the length of x)
	%		mu 			The step-size
	%
	%	Output:
	%		xhat 		The result of convolving 'y' with the current estimated channel, for all iterations
	%		e 			The error, defined as xhat - x
	%		lms_coeffs	The new estimated channel response after block_size iterations
	%		lms_coeffs_history
	%					A matrix storing all estimated channel responses. Not present in the C-code, used here for plotting purposes only
	
	
	%Extra variable used to store lms coefficients
	%NOT PRESENT IN C-IMPLEMENTATION
	lms_coeffs_history = zeros(length(lms_state), length(lms_coeffs));
	%Pre-allocate error and xhat
	%NOT PRESENT IN C-IMPLEMENTATION
	e = zeros(block_size,1);
	xhat = zeros(block_size,1);
	
	%Do block_size LMS iterations
	for k=length(lms_coeffs):length(lms_state)
		%Generate indices of lms_state that corresponds to y(k)
		%i.e. for the current iteration, what was the vector y?
		y = lms_state(k - length(lms_coeffs) + 1:k);
		
		%Do one single LMS iteration
		[xhat(k), e(k), lms_coeffs] = doLms(y, lms_coeffs, x(k), mu);
		
		%NOT PRESENT IN C IMPLEMENTATION
		%Store this iteration's LMS filter coefficients
		lms_coeffs_history(k, :) = lms_coeffs;
	end
end

function [xhat, e, h] = doLms(y, h, x, mu)
	%Do a single LMS iteration
	xhat = y(:).' * h(:);	%Use (:) to force y, h to be column vectors, then '*' gives the dot product
	e = x - xhat;
	h = h + 2 * mu * y * e;
end