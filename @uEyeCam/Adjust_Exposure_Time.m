% File: Adjust_Exposure_Time.m @ uEyeCam
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 16.06.2020

% Description: Adjusts the exposure time 

function Adjust_Exposure_Time(uc, varargin)

	% default arguments
	currEt = 200; % starting exposure time ms
	thresSatPixel = uc.thresSatPixel / 10; % percentage of staurated pixels allowed, Urs may delete the "/ 10"?
	flagDisplay = uc.flagDisplay;

	for iargin=1:2:(nargin-1)
		switch varargin{iargin}
			case 'startExpTime'
				currEt = varargin{iargin + 1};
			case 'thresSatPixel'
				thresSatPixel = varargin{iargin + 1};
			case 'flagDisplay'
				flagDisplay = varargin{iargin + 1};
			otherwise
				error('Invalid input argument passed');
		end
	end

	uc.VPrintf('Adjusting exposure time...', 1);
	% Get min and max value of exposure time
	[status, rangeEt] = uc.cam.Timing.Exposure.GetRange();

	if ~strcmp(status, 'Success')
		error('Could not read allowed exposure times.');
	end

	
	stepSize = (currEt - rangeEt.Minimum)  / 2;
	done = 0;

	if flagDisplay
		figure('Name', 'Automatic exposuretime adjustment');
		uc.Acquire();
		preview = imagesc(uc.data);
		colormap(uc.imscColors);
		axis image;
		caxis([0, 255]);
	end

	iStep = 1;
	while (stepSize > rangeEt.Increment)

		uc.Acquire();

		% Update preview
		if (flagDisplay)
			set(preview, 'cdata', uc.data);
			drawnow();
		end

		% check for satuation
		satPixel = single(uc.data(:) >= 255);
		nSatPixel = sum(satPixel(:));
		nPixel = size(uc.data, 1) * size(uc.data, 2);
		percSatPixel(iStep) = nSatPixel / nPixel * 100;
		expTime(iStep) = currEt;

		if (percSatPixel(iStep) > thresSatPixel)
			dir = -1;
		else
			dir = 1;
		end

		currEt = currEt + stepSize * dir;

		% only decrease step size if we are in the right region
		if (percSatPixel(iStep) < thresSatPixel)
			stepSize = stepSize * 0.5;
		end
		uc.exposuretime = currEt;

		iStep = iStep + 1;

	end


	uc.VPrintf('done\n', 0);

end