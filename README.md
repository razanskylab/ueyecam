# ueyecam
# ueyecam

An object-oriented code wrapper used to access the uEyeCam directly from MATLAB.

## Installation
The code relies on the DLLs delivered with the uEyeCam software. Please download the software package / driver package for your camera from [IDS Imaging](https://de.ids-imaging.com).

We tested this software with the version 4.94 of the IDS software. At some point in 4.95 they introduced some renaming and a different dll scheme. Therefore please stick to the older version of the software.

Make sure that the path defined in the file `@uEyeCam/uEyeCam.m` is pointing to the correct installation location. If this is not correct you will get an error thrown while initializing the object.

Before getting started with the MATLAB version of the code, please make sure that the camera itself works using the uEye Cockpit application.


