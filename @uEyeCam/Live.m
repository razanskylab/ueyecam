function Live(ueyecam)

	figure();
	ueyecam.Acquire();
	iSc = imagesc(ueyecam.img.Data);
	axis image;
	colormap bone;
	colorbar;
	caxis([0 255])

	while true
		ueyecam.Acquire();
		set(iSc, 'cdata', ueyecam.img.Data);
		drawnow;
		

	end


end