function Save_Image(ueyecam, path)

	image = ueyecam.img;
	exptime = ueyecam.exposuretime;

	save(path, 'image', '-v7');
	save(path, 'exptime', '-append');

end