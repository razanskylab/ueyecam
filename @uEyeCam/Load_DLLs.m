% File: Load_DLLs.m @ uEyeCam
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 23.10.2018

% Description: Loads the required DLLs.

function Load_DLLs(ueyecam)

	try 
		fprintf('[uEyeCam] Loading DLLs...\n');
		NET.addAssembly(ueyecam.CAMERADLL);
	catch
		error('Unable to load .NET assemblies');
	end

end