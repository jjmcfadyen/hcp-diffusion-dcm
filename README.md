# HCP Diffusion DCM Experiment
---

# About
### The Project
This project is the second experiment for my PhD at the Queensland Brain Institute in collaboration with my supervisors Dr Marta Garrido and Professor Jason Mattingley.

Our research question was, 'What evidence is there for a structural subcortical route to the amygdala in humans?'

### The Data
To adequately answer this question, we made use of the freely available Human Connectome Project ([HCP](http://www.humanconnectome.org/)). We used the S900 release, containing approximately 900 participants aged between 18 and 35 who participated the HCP's battery of tests. Data for all participants were collected at Washington University in St Louis, USA.

The data from the S900 release was stored on the high performance computing platform [MASSIVE 3](https://www.massive.org.au/userguide/workflow-instructions/neuroimaging), located at Monash University in Melbourne, Australia. This was made possible by affiliation with the Australian Research Council's [Centre of Excellence for Integrative Brain Function (CIBF)](http://www.cibf.edu.au/). Due to the high computational load of this project, we conducted analyses on both M3 and also by transferring data from M3 to cluster computing systems at the Queensland Brain Institute, The University of Queensland in Brisbane, Australia.

We were granted [restricted access](https://store.humanconnectome.org/data/data-use-terms/restricted-access-overview.php) to potentially idenfying demographic information so that we could get accurate information pertaining to age, as well as information regarding fear and anxiety processing.

### The Scripts
The scripts include R, Matlab, and Unix Shell code. The following toolboxes were used:
* FSL 5.0.9
* MRTrix3 0.3.15-294-ge8a525c6 built Oct 12 2016 using Eigen 3.2.9 (used in preprocessing steps)
* MRTrix3 0.3.16 built Jul 11 2017 using Eigen 3.3.0 (used in tractography steps)
* Matlab 2016a
* RStudio

The scripts are organised by numbered processing stages. Within the top folder is a script where you can update your file paths in all scripts within the subdirectories.

# Analysis Steps
Note that an example subject code of "99999" will be used in all filenames (instead of a real code, such as 100307).

## Data Selection
The first filtering step was to only include subjects that had complete data for the structural MRI, diffusion MRI, and the emotion fMRI task. We then excluded participants who had abnormal colour vision and tested positive for any drug/alcohol tests.

The script also chooses a random subset of 60 participants to be used for generating the population template in the "Global Intensity Normalisation" step. Note that this step is run on a maximum of 60 subjects to reduce intense computational load. Also, it is believed that a random subset of 60 participants from a total sample of several hundred should be sufficiently representative to generate an accurate population template.

#### Script: selectSubjects.R

Input:
1. unrestricted.csv

  * Provided by [HCP Connectome DB](https://db.humanconnectome.org) under WU-Minn HCP Data - 900 Subjects > Resources > Quick Downloads > Behavioral Data

2. restricted.csv

  * Provided by [HCP Connectome DB](https://db.humanconnectome.org) under WU-Minn HCP Data - 900 Subjects after being granted restricted access and selecting Current Project as "Restricted" using the drop-down menu at the top of the screen. The file can then be accessed from Resources > Quick Downloads > Restricted Data

Output:
1. subjectlist.txt
  * A list of all the subjects in the S900 HCP release that satisfied our selection criteria. In numerical order from lowest to highest.
2. subsetlist.txt
  * A list of a subset of 60 of the above subjects to be used in generating the population template for global intensity normalisation. Note that this subset will change randomly each time the script is run.

## Data Preprocessing
The following steps were designed in accordance with the MRTrix3 [ISMRM tutorial](https://mrtrix.readthedocs.io/en/latest/quantitative_structural_connectivity/ismrm_hcp_tutorial.html) for reconstructing connectomes using HCP data. 

### 1: Prepare
#### Script: prepare.sh

Steps
1. Fills any holes in the non-b0-weighted brain masks (that may lead to errors)
2. Converts data into MRTrix3 format using bvecs and bvals, bias correction
3. Computes diffusion tensors and fractional anisotropy (FA) images

Input: Located in the HCP subject's file structure under: 999999/T1w/Diffusion
* data.nii.gz
* bvals
* bvecs
* nodif_brain_mask.nii.gz

Output
1. 999999_nodif_brain_mask_fillh.nii.gz (non-diffusion-weighted brain mask with no holes)
2. 999999_DWI.mif (diffusion images in MRTRix3 format)
3. 999999_cDWI.mif (bias-corrected diffusion images)
4. 999999_DT.mif (diffusion tensor image)
5. 999999_FA.mif (fractional anisotropy image)

### 2: Global Intensity Normalisation
#### Script: globalintensity.sh

Steps
1. Copy cDWI.mif and nodif_brain_mask_fillh.nii.gz files for subset participants to designated folder
2. Conduct global intensity normalisation using subset

Input
1. cDWI.mif x 60 subset participants
2. nodif_brain_mask_fillh.nii.gz x 60 subset participants

Output
1. FA_template.mif
2. WM_mask.mif

#### Script: normalise.sh

Input:
1. 999999_FA.mif
2. 999999_nodif_brain_mask_fillh.nii.gz
3. WM_mask.mif
4. FA_template.mif

Output:
1. 999999_nDWI.mif
  * Normalised diffusion weighted image

### 3: Estimate Response Function
#### Script: responsefunction.sh
Steps:
1. Generate 5TT (five tissue type) image using freesurfer output provided by HCP
2. Calculate response function using multi-shell multi-tissue (msmt) algorithm

Input:
1. aparc+aseg.nii.gz
  * This file should be located in the HCP data structure under 999999/T1w
2. 999999_nDWI.mif

Output:
1. 999999_RF_WM.txt
2. 999999_RF_GM.txt
3. 999999_RF_CSF.txt
4. 999999_RF_voxels.mif

#### Script: average_responsefunction.sh
Input:
1. RF_WM, RF_GM, and RF_CSF text files for all subjects

Output:
1. average_RF_WM.txt
2. average_RF_GM.txt
3. average_RF_CSF.txt

### 4: Spherical Deconvolution
Conduct multi-shell, multi-tissue (msmt) constrained spherical deconvolution (CSD).

Input:
1. average_WM.txt
2. average_GM.txt
3. average_CSF.txt
4. 999999_nodif_brain_mask_fillh.nii.gz
5. 999999_nDWI.mif

Output:
1. 999999_WM_FODs.mif
2. 999999_GM.mif
3. 999999_CSF.mif
4. 999999_tissueRGB.mif

