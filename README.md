# BinnedProfileIntensityOverTime

This pair of scripts is used to create plots to display the intensity along fixed lines over time from time series images.

Users should open each image they wish to analyse in ImageJ, draw a line along the region of interest, choosing a suitable thickness, and then run the ImageJ script (Profile_intensity_time_course.ijm), choosing a location to save Results files when prompted.

Users can then use these results to create colour-coded plots of intensity over time and space using the Matlab script (Binning_profile_intensity_time_course.m), which can create multiple plots when reading from the global Results folder in which the ImageJ macro results are saved.

The Matlab script requires shadedE​rrorBar.m from the Matlab package "raacampbell/shadedE​rrorBar".
