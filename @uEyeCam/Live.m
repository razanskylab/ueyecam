% File: Live.m @ uEyeCam
% Author: Urs Hofmann
% Date: 10.06.2020
% Mail: hofmannu@biomed.ee.ethz.ch

% Description: Live preview of uEyeCam

% TODO 
% 	- make exposure time adjustable in live preview using slider

function Live(ueyecam, varargin)

	% default input arguments

	% read user specific input arguments

	ueyecam.Allocate_Memory();

	figure('Name', 'uEyeCam Live Preview');
	ueyecam.Acquire();
	iSc = imagesc(ueyecam.data);
	axis image;
	colormap(bone(1024));
	colorbar;
	caxis([0 255])

	H = uicontrol('Style', 'PushButton', ...
		'String', 'Break', ...
    'Callback', 'delete(gcbf)');

	while ishandle(H)
		ueyecam.Acquire();
		set(iSc, 'cdata', ueyecam.data);
		drawnow();
	end


end