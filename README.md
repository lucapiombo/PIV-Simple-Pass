# PIV-Simple-Pass
This MATLAB script post-processes images obtained through Particle Image Velocimetry (PIV) experiments in a wind tunnel.

##Features
The script is capable of:

Pre-processing: Adjusts lighting and applies filters to enhance image visibility.
Calibration: Calibrates images using a target.
Mask Creation: Generates a mask to hide undesired parts of the images.
Simple-Pass Algorithm: Executes the Simple-Pass algorithm with sub-pixel interpolation.
Outlier Filtering: Filters out outliers.
Plotting: Plots the processed results.

##Notes
This code was developed for a university project and is not fully optimized. To adapt it to your specific needs, you must specify the calibration image path and the images to be processed directly within the script.
Furthermore an example of calibrarion is provided into [Calibration](/test/Calib) and one with a set of images to use is inside [Images](/test/9ms). The test represent a two camera setup for analyzing a vortex-ring-state behavior of a rotor.
