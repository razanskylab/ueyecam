% File: VPrintf.m @ uEyeCam
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 10.06.2020

% Description: Verbose output of class

function VPrintf(uc, txtMsg, flagName)

	if uc.flagVerbose
		if flagName
			txtMsg = ['[uEyeCam] ', txtMsg];
		end
		fprintf(txtMsg);
	end
end