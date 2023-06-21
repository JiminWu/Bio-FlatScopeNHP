# Bio-FlatScopeNHP
This is an open source repository of the Bio-FlatScopeNHP (Link to be updated).

"Mesoscopic calcium imaging in head-unrestrained non-human primates using a lensless microscope", Jimin Wu<sup>&</sup>, Yuzhi Chen<sup>&</sup>, Ashok Veeraraghavan, Eyal Seidemann* and Jacob T. Robinson*

<sub><sup>&</sup> Denotes equal contribution. | * Corresponding authors </sub>

## Hardware design
The directory 'Bio-FlatScopeNHP CAD Files' contains the CAD files of the system, including the illumination housing, holder for mounting the system on the cortex chamber, insert and the cortext chamber. The file 'Bio-FlatScopeNHP Assembly' provides an assembly of the system with the insert and cortex chamber. 

The directory 'Phase Mask Fabrication' contains the designed point spread function (PSF) pattern and the height map generated from phase retrieval algorithm. Detail of the phase retrieval algorithm can be found here:

* Boominathan, V., Adams, J. K., Robinson, J. T. & Veeraraghavan, A. PhlatCam: Designed Phase-Mask Based Thin Lensless Camera. IEEE Trans. Pattern Anal. Mach. Intell. 42, 1618–1629 (2020).

## System requirements
All codes are implemented in MATLAB 2021b. 
Toolbox required: Parallel Computing Toolbox, Image Processing Toolbox, Signal Processing Toolbox.

## Bio-FlatScopeNHP reconstruction

* Fast reconstruction using a single PSF:

  Two supporting fata files are necessary for fast reconstruction:
  1. A single point spread function (PSF) file, saved as a '.mat' file.
  2. Raw capture from Bio-FlatScopeNHP, saved as a '.tiff' image file.

  We have provided examples for fast reconstruction test in the directory 'Bio-FlatScopeNHP Reconstruction/Examples'. 

* Reconstruction using spatially-varying PSFs

  Three supporting data files are necessary for spatially-varying reconstruction:
  1. A '.mat' file including all the registered PSFs.
  2. A '.mat' file including all the spatially-varying weights.
  3. Raw capture from Bio-FlatScopeNHP, saved as a '.tiff' image file.

  We have provided example captures in the directory 'Bio-FlatScopeNHP Reconstruction/Examples'. The registered PSFs and spatially-varying weights are avaliable in Google Drive [Link](https://drive.google.com/file/d/1UYPXWlYjghcT7DvZNz0ZURw5mnc63Mzf/view?usp=sharing).
  
  Registered PSFs and spatially-varying weights can be generated from raw PSF measurements using 'PSFPreProcess.m'.

## Data processing code

### Position tuning

### Orientation tuning


## Contact Us
In case of any queries regarding the code, please reach out to [Jimin](mailto:jimin.wu@rice.edu).
Other raw and analysed data are available for research purpose from corresponding author upon reasonable request.

