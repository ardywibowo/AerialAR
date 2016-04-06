# AerialAR
Augmented Reality App for Unmanned Aerial Vehicles

This project provides a proof of concept app which displays Points of Interest (POI) in UAV Imagery. 
The program gets Points of Interest using the Google Maps API, and camera position/orientation 
from sensors built into an Unamnned Aerial Vehicle (UAV).
Using these values, the program can determine which POIs are in the image 
and can project them onto it through camera projection algorithms.
The program assumes that the camera has been properly calibrated to not take distorted images.

Also, as an added functionality, the program handles sketch recognition for selecting locations. 
This allows users to specify GPS locations by circling on a particular area.
This is an inverse of the above method. By projecting pixels in 3D space as lines, 
the program is able to find the intersection of these lines with the ground plane. using that,
a shape resembling a circle in 3D space can be constructed with its position and dimensions known.

## Screenshots
Please find screenshots in the Screenshots folder
