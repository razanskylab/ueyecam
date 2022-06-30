% File: Load_DLLs.m @ uEyeCam
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 23.10.2018

% Description: Loads the required DLLs.

function Load_DLLs(ueyecam)

	if isfile(ueyecam.CAMERADLL)
		fprintf('[uEyeCam] Loading DLLs... ');
		tStart = tic();
		NET.addAssembly(ueyecam.CAMERADLL);
		fprintf("done after %.1f sec!\n", toc(tStart));
	else
		error("CAMERADLL path is not pointing to a file, aborting");
	end

end