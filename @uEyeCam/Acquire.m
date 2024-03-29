% File: Acquire.m @ uEyeCam
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 23.10.2018

% Description: Acquires an actual image.

function img = Acquire(uc)

	% Acquire image
	uc.VPrintf('Acquire image... ', 1);
	flagSuccess = 0;

	oldData = uc.data;

	while ~flagSuccess
	

		ErrChk = uc.cam.Acquisition.Freeze();
		if ~strcmp(ErrChk, 'Success')
			txtMsg = ['Could not acquire image: ', ErrChk];
		  error(txtMsg);
		end

		while ~uc.isFinished
			% do nothing
		end

		% Extract image
		[ErrChk, tmp] = uc.cam.Memory.CopyToArray(uc.img.ID); 
		if ~strcmp(ErrChk, 'Success')
			txtMsg = ['Could not obtain image data: ', ErrChk];
		  error(txtMsg);
	end

		% Reshape image
		tmp = reshape(uint8(tmp), [uc.img.Width, uc.img.Height, uc.img.Bits /8]);
		uc.data =	tmp;

		if ~isempty(oldData)
			% compare if we actually acquired a new image
			deltaImg = single(oldData) - single(uc.data);

			if sum(abs(deltaImg(:))) > 0
				flagSuccess = 1;
			end
		else
			if ~isempty(uc.data)
				flagSuccess = 1;
			end
		end

	end

	% check for satuation
	satPixel = single(uc.data(:) >= 255);
	nSatPixel = sum(satPixel(:));
	nPixel = size(uc.data, 1) * size(uc.data, 2);
	percSatPixel = nSatPixel / nPixel * 100;

	if (percSatPixel > uc.thresSatPixel)
		warning('Camera was saturating');
	end

	img = uc.data; % get data to return

	uc.VPrintf('done!\n', 0);

end