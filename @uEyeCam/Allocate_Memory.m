% File: Allocate_Memory.m @ uEyeCam
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 23.10.2018

% Descirption allocates the memory required for the images.

function Allocate_Memory(ueyecam)

	[ErrChk, ueyecam.img.ID] = ueyecam.cam.Memory.Allocate(true);
	if ~strcmp(ErrChk, 'Success')
    	error('Could not allocate memory');
    else
    	fprintf('[uEyeCam] Memory allocated.\n');
	end

	[ErrChk, ueyecam.img.Width, ueyecam.img.Height, ueyecam.img.Bits, ueyecam.img.Pitch] ...
	    = ueyecam.cam.Memory.Inquire(ueyecam.img.ID);
	if ~strcmp(ErrChk, 'Success')
	    error('Could not get image information');
   	else
		fprintf('[uEyeCam] Image information acquired.\n');
	end

end