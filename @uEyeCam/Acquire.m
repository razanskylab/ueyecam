% File: Acquire.m @ uEyeCam
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 23.10.2018

% Description: Acquires an actual image.

function img = Acquire(ueyecam)

	% Acquire image
	if ~strcmp(ueyecam.cam.Acquisition.Freeze(true), 'Success')
	    warning('Could not acquire image');
	else
		fprintf('[uEyeCam] Acquired image.\n');
	end

	%   Extract image
	[ErrChk, tmp] = ueyecam.cam.Memory.CopyToArray(ueyecam.img.ID); 
	if ~strcmp(ErrChk, 'Success')
	    error('Could not obtain image data');
	else
		fprintf('[uEyeCam] Obtained image data.\n');
	end

	%   Reshape image
	ueyecam.img.Data = reshape(uint8(tmp), [ueyecam.img.Width, ueyecam.img.Height, ueyecam.img.Bits/8])';

	% Throw warning if camera saturated
	if max(ueyecam.img.Data(:) >= 255)
		warning('Camera was saturating');
	end

	img = ueyecam.img.Data;

end