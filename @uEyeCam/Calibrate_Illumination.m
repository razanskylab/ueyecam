function Calibrate_Illumination(ueyecam)
	% Put exposure time to low value

	oldEt = ueyecam.exposuretime;

	fprintf('[uEyeCam] Adjusting exposure time.\n');
	ueyecam.exposuretime = 20;
	ueyecam.Acquire();
	while (max(ueyecam.img.Data(:)) > 220)
		ueyecam.exposuretime = ueyecam.exposuretime - 0.5;
		ueyecam.Acquire();
	end

	f = figure();
	imagesc(ueyecam.img.Data);
	axis image;
end