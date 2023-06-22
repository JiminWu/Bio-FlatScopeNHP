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

  We have provided example captures in the directory 'Bio-FlatScopeNHP Reconstruction/Examples'. The original captured PSFs [link](https://drive.google.com/file/d/1fL0Vs781GPKXCO3BQB9BdJbiCLgyKiEe/view?usp=sharing), registered PSFs after FFT [link](https://drive.google.com/file/d/16QVv3m3JOxVFdN6qdpZpp_Dw-3_euGGZ/view?usp=sharing) and spatially-varying weights [link](https://drive.google.com/file/d/1Q0ncFi6z5vQexDA_asKif7S0e6ojxybf/view?usp=sharing) are avaliable in Google Drive.
  
  Registered PSFs and spatially-varying weights can be generated from raw PSF measurements using 'PSFPreProcess.m'.

## In vivo data processing
The directory 'In Vivo Data Processing Code' contains the customized MATLAB code for processing the position tuning data and orientation columns maps.
Data processing pipelines are the same for ground truth data and Bio-FlatScopeNHP data. Supporting functions can be found in the directory 'In Vivo Data Processing Code/Tools'. References of the data processing code:
* Chen, Y., Geisler, W. S. & Seidemann, E. Optimal decoding of correlated neural population responses in the primate visual cortex. Nat. Neurosci. 9, 1412–1420 (2006).
* Palmer, C. R., Chen, Y. & Seidemann, E. Uniform spatial spread of population activity in primate parafoveal V1. J. Neurophysiol. 107, 1857–1867 (2012).
* Seidemann, E. et al. Calcium imaging with genetically encoded indicators in behaving primates. eLife 5, e16178 (2016).
* Benvenuti, G. et al. Scale-Invariant Visual Capabilities Explained by Topographic Representations of Luminance and Texture in Primate V1. Neuron 100, 1504-1512.e4 (2018).

## Contact Us
In case of any queries regarding the code, please reach out to [Jimin](mailto:jimin.wu@rice.edu).
Other raw and analysed data are available for research purpose from corresponding author upon reasonable request.

