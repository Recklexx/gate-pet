# GATE Simulation
----------------------------------------------------------------------
## Title: GATE based positron emission tomography simulation
## Date : 2019.05.07.
## Qiqi, Lu, Southern Medical University
----------------------------------------------------------------------
# Calculation
## The code is for Matlab
The folders, "Calculation_PET" and "Calculation_SPECT", are for the calculation of the Spatial resolurion, Sensitivity and Scatter fraction.

# Reconstruction
## The code is for STIR and ROOT software.
## I use ROOT to compress the data and rebin the coincidence, and use STIR to reconstruct image.
The folders, "Reconstruction_PET" and "Reconstruction_SPECT", are for the image reconstruction using the data from the GATE simulation.

# Simulation
## The code is for GATE
The folders, "Simulation_PET" and "Simulation_SPECT" are for the GATE Simulation.

# Use
##  When using these code, you should use GATE simulation to produce the simulation data; then the reconstruction code will use the output file (.root) to reconstruct images (you can use several reconstruction method in the reconstruction folder); finally the calculation code will calculate the Spatial resolution, sensetivity and scatter fraction if you want.
----------------------------------------------------------------------
# P.S.
<!-- You will find more information in the folders. -->
