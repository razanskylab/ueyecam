% File: Load_DLLs.m @ uEyeCam
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 23.10.2018

% Description: Loads the required DLLs.

function Load_DLLs(ueyecam)

	if isfile(ueyecam.CAMERADLL)
		fprintf('[uEyeCam] Loading DLLs...\n');
		NET.addAssembly(ueyecam.CAMERADLL);
	else
		error("CAMERADLL path is not pointing to a file, aborting");
	end
end