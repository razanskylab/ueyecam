function Adjust_Exposure_Time(ueyecam, etMax)

	% Get min and max value of exposure time
	[status, rangeEt] = ueyecam.cam.Timing.Exposure.GetRange()

	if ~strcmp(status, 'Success')
		error('[uEyeCam] Could not read allowed exposure times.');
	end

	dist = (etMax - rangeEt.Minimum)/2;
	et = (etMax - rangeEt.Minimum) /2 + rangeEt.Minimum;
	done = 0;
	
	while (done == 0)
		ueyecam.exposuretime = et;

		ueyecam.Acquire();

		% if we saturate we have to decrease the exposure time otherwise we have to increase
		if (max(ueyecam.img.Data(:)) >= 255)
			dir = -1;
		else
			dir = 1;
		end

		et = et + dir * dist;
		dist = dist / 2;

		if (dist <= rangeEt.Increment)
			done = 1;
		end

	end


end