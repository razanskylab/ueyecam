% File: uEyeCam.m @ uEyeCam
% Author: Urs Hofmann
% Mail: hofmannu@student.ethz.ch
% Date: 23rd Okt 2018

% Description: Library used to control the uEye camera.

% TODO
% 		- redirect all verboseS output over VPrintf

classdef uEyeCam < handle

	properties (Constant, Hidden)
		CAMERADLL(1, :) char = ...
			"C:\Program Files\IDS\uEye\Develop\DotNet\signed\uEyeDotNet.dll";
		CAMERACLASSNAME(1, :) char ='uEye.Camera';
		connectOnInit(1, 1) logical = 1; % connect cam on startup?
	end

	properties
		cam; % holds DLL object
		colormode(1, :) char; % raw8, raw16
		img; % struct containing all the image information
		data(:, :); % contains image after Acquire()
		boost(1, 1) logical; % either 0 or 1
		flagVerbose(1, 1) logical = 1; % enable or disable verbose output
		flagDisplay(1, 1) logical = 1; % enable or disable visual output
		imscColors(:, 3) double; % colormap to display images
		thresSatPixel(1, 1) single = 1; % threshold for saturation warning [%]
	end

	properties(Dependent)
		triggermode(1, :) char; % software,
		gammacorrection(1, 1) logical;
		displaymode(1, :) char; % bitmap, 
		exposuretime(1, 1) single; % ms
		isFinished(1, 1) logical; % is acqisition finished
	end

	methods

		% Constructor
		function uEyeCam = uEyeCam()
			uEyeCam.Load_DLLs;
			uEyeCam.cam = uEye.Camera;
			if uEyeCam.connectOnInit
				status = uEyeCam.cam.Init(0);
				if strcmp(status, 'Success')
					fprintf('[uEyeCam] Connection established.\n');
					uEyeCam.gammacorrection = 0;
					uEyeCam.displaymode = 'DiB';
					uEyeCam.colormode = 'raw8';
					uEyeCam.triggermode = 'software';
					uEyeCam.boost = 0;
					uEyeCam.Allocate_Memory();
				else
					txtMsg = ['Could not open connection, status: ', status];
					warning(txtMsg);
				end
			end
			
			% build colormap
			uEyeCam.imscColors = bone(1024); % use bone as default colormap
			uEyeCam.imscColors(end, :) = [1, 0, 0]; % make max element red to see saturation
		end

		% destructor
		function delete(ueyecam)
			status = ueyecam.cam.Exit();
			if strcmp(status, 'Success')
				fprintf('[uEyeCam] Connection closed.\n');
			else
				warning('[uEyeCam] Could not close connection');
			end
		end

		function isFinished = get.isFinished(uc)
			[errCheck, isFinished] = uc.cam.Acquisition.IsFinished;
			if ~strcmp(errCheck, 'Success')
				error('Could not check if finished');
			end
		end

		% Exposuretime
		function et = get.exposuretime(ueyecam)
			[status, et] = ueyecam.cam.Timing.Exposure.Get();
			if ~strcmp(status, 'Success')
				txtMsg = ['Could not read exposure time from camera: ', status];
				error(txtMsg);
			end
		end

		function set.exposuretime(ueyecam, et)
			[status, isSupported] = ueyecam.cam.Timing.Exposure.GetSupported();
			if strcmp(status, 'Success')
				if isSupported
					[status, rangeEt] = ueyecam.cam.Timing.Exposure.GetRange();
					if strcmp(status, 'Success')
						if (et < rangeEt.Minimum)
							et = rangeEt.Minimum;
							warning(['Will use min exp time of ', num2str(et), '.']);
						elseif (et > rangeEt.Maximum)
							et = rangeEt.Maximum;
							warning(['Will use max exp time of ', num2str(et), '.']);
						else
							steps = round((et - rangeEt.Minimum) / rangeEt.Increment);
							et = rangeEt.Minimum + rangeEt.Increment * steps;
						end
						status = ueyecam.cam.Timing.Exposure.Set(et);
						if ~strcmp(status, 'Success')
							error('Could not set exposure time');
						else
							fprintf(['[uEyeCam] Successfully set exposure time to ', num2str(et), ' ms.\n']);
						end				
					else
						error('Problems communicating with camera.');
					end
				else
					error('Setting exposure time is not supported for this camera.');
				end
			else
				error('Problems communicating with camera.');
			end
		end

		function set.gammacorrection(ueyecam, gc)
			gc = logical(gc);
			if islogical(gc)
				fprintf(['[uEyeCam] Setting gamma correction to ', num2str(gc), '.\n']);
				status = ueyecam.cam.Gamma.Hardware.SetEnable(gc);
				if ~strcmp(status, 'Success')
					error('Could not set gamma correction.');
				end
			else
				error('Gamma correction needs to be either 0 or 1.\n');
			end
		end

		function gc = get.gammacorrection(ueyecam)
			[status, gc] = ueyecam.cam.Gamma.Hardware.GetEnable;
			if ~strcmp(status, 'Success')
				warning('Something went wrong while reading gammacorrection.');
			end 
		end

		% Displaymode

		function set.displaymode(ueyecam, dpm)
			if strcmp(dpm, 'DiB')
				dispMode = uEye.Defines.DisplayMode.DiB;
			else
				error('Unknown displaymode');
			end
			
			status = ueyecam.cam.Display.Mode.Set(dispMode);
			if ~strcmp(status, 'Success')
				error('[uEyeCam] Could not set display mode.');
			end
		end

		function dpm = get.displaymode(ueyecam)
			[status, dpm] = ueyecam.cam.Display.Mode.Get;
			if ~strcmp(status, 'Success')
				error('Could not get displaymode');
			end
		end

		% Colormode

		function set.colormode(ueyecam, cm)
			if strcmp(cm, 'raw8')
				colorMode = uEye.Defines.ColorMode.SensorRaw8;
			elseif strcmp(cm, 'raw12')
				colorMode = uEye.Defines.ColorMode.SensorRaw12;
			elseif strcmp(cm, 'raw16')
				colorMode = uEye.Defines.ColorMode.SensorRaw16;
			else
				error('Unknown colormode');
			end
			
			status = ueyecam.cam.PixelFormat.Set(colorMode);
			if ~strcmp(status, 'Success')
				error('[uEyeCam] Could not set colormode.');
			end
		end

		% Triggermode

		function set.triggermode(ueyecam, tm)
			if strcmp(tm, 'software')
				triggerMode = uEye.Defines.TriggerMode.Software;
			else
				error('Unknown triggermode');
			end
			
			status = ueyecam.cam.Trigger.Set(triggerMode);
			if ~strcmp(status, 'Success')
				error('[uEyeCam] Could not set trigger mode.');
			end
		end

		function tm = get.triggermode(ueyecam, tm)
			[status, tm] = ueyecam.cam.Trigger.Get;

			if ~strcmp(status, 'Success')
				error('Could not read triggermode.');
			end
		end
		
		% Boost
		function set.boost(ueyecam, bst)
			boolBst = logical(bst);
			status = ueyecam.cam.Gain.Hardware.Boost.SetEnable(boolBst);
			if strcmp(status, 'Success')
				fprintf(['[uEyeCam] Successfully set boost to ', num2str(boolBst), '.\n']);
			else
				error('Could not set boost.');
			end
		end

		function bst = get.boost(ueyecam)
			[status, bst] = ueyecam.cam.Gain.Hardware.Boost.GetEnable();
			if ~strcmp(status, 'Success')
				error('Error while reading boost');
			end 
		end

		% Externally defined methods
		Load_DLLs(ueyecam);
		Allocate_Memory(ueyecam);
		img = Acquire(ueyecam);
		Calibrate_Illumination(ueyecam);
		Adjust_Exposure_Time(ueyecam, varargin); % etMax maximum acceptable exposure time in ms
		Live(ueyecam);
		Save_Image(uc, path);
		VPrintf(uc, txtMsg, flagName);

	end



end