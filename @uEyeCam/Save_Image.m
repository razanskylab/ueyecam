% File: Save_Image.m @ uEyeCam
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 10.06.2020

% Description: Saves an acquired image to a file

function Save_Image(uc, path)

	uc.VPrintf('Save image to file... ', 1);
	image = uc.img;
	save(path, 'image', '-v7');

	exptime = uc.exposuretime;
	save(path, 'exptime', '-append');

	uc.VPrintf('done!\n');
end