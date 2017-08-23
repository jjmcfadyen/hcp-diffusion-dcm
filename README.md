# HCP Diffusion DCM Experiment
---

## Table of Contents
* [About](#about)
  * [The Project](#the-project)
  * [The Data](#the-data)
  * [The Scripts](#the-scripts)
* [DWI Analysis](#dwi-analysis)
  * [Data Selection](#data-selection)
    * [selectSubjects.R](#script-selectsubjectsr)
  * [Preprocessing](#preprocessing)
    * [1: Prepare](#1-prepare)
      * [prepare.sh](#script-preparesh)
    * [2: Global Intensity Normalisation](#global-intensity-normalisation)
      * [globalintensity.sh](#script-globalintensitysh)
      * [normalise.sh](#script-normalisesh)
    * [3: Estimate Response Function](#estimate-response-function)
      * [responsefunction.sh](#script-responsefunctionsh)
      * [average_responsefunction.sh](#script-average-responsefunctionsh)
    * [4: Spherical Deconvolution](#spherical-deconvolution)
      * [deconvolution.sh](#script-deconvolutionsh)
    * [5: Create ROI Masks](#create-roi-masks)
      * [rois.sh](#script-roissh)
  * [Tractography](#tractography)
    * [Global Tractography](#global-tractography)
      * [globaltractography.sh](#script-globaltractographysh)
      * [sumGlobal.sh](#script-sumglobalsh)
    * [Local Tractography](#local-tractography)
      * [localtractography.sh](#script-localtractographysh)
      * [printStats.sh](#script-printstatssh)
      * [collateData.m](#script-collatedatam)
      * [sumWeights.sh](#script-sumweightssh)
* [fMRI Analysis](#fmri-analysis)
  * [Image Preprocessing and First Level Analysis](#image-preprocessin-and-first-level-analysis)
    * [firstLevel.m](#script-firstlevelm)
  * [Second Level Analysis and VOIs](#second-level-analysis-and-vois)
    * [secondLevel.m](#script-secondlevelm)
    * [extractVOIs.m](#script-extractvoism)
    * [checkVOIs.m](#script-checkvoism)
* [DCM Analysis](#dcm-analysis)

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

# DWI Analysis
Note that an example subject code of "99999" will be used in all filenames (instead of a real code, such as 100307).

## Data Selection
The first filtering step was to only include subjects that had complete data for the structural MRI, diffusion MRI, and the emotion fMRI task. We then excluded participants who had abnormal colour vision and tested positive for any drug/alcohol tests.

The script also chooses a random subset of 60 participants to be used for generating the population template in the "Global Intensity Normalisation" step. Note that this step is run on a maximum of 60 subjects to reduce intense computational load. Also, it is believed that a random subset of 60 participants from a total sample of several hundred should be sufficiently representative to generate an accurate population template.

#### Script: selectSubjects.R

Input:
* `unrestricted.csv`

  * Provided by [HCP Connectome DB](https://db.humanconnectome.org) under WU-Minn HCP Data - 900 Subjects > Resources > Quick Downloads > Behavioral Data

* `restricted.csv`

  * Provided by [HCP Connectome DB](https://db.humanconnectome.org) under WU-Minn HCP Data - 900 Subjects after being granted restricted access and selecting Current Project as "Restricted" using the drop-down menu at the top of the screen. The file can then be accessed from Resources > Quick Downloads > Restricted Data

Output:
* `subjectlist.txt`
  * A list of all the subjects in the S900 HCP release that satisfied our selection criteria. In numerical order from lowest to highest.
* `subsetlist.txt`
  * A list of a subset of 60 of the above subjects to be used in generating the population template for global intensity normalisation. Note that this subset will change randomly each time the script is run.

## Preprocessing
The following steps were designed in accordance with the MRTrix3 [ISMRM tutorial](https://mrtrix.readthedocs.io/en/latest/quantitative_structural_connectivity/ismrm_hcp_tutorial.html) for reconstructing connectomes using HCP data. 

### 1: Prepare
#### Script: `prepare.sh`

Steps
1. Fills any holes in the non-b0-weighted brain masks (that may lead to errors)
2. Converts data into MRTrix3 format using bvecs and bvals, bias correction
3. Computes diffusion tensors and fractional anisotropy (FA) images

Input: Located in the HCP subject's file structure under: 999999/T1w/Diffusion
* `data.nii.gz`
* `bvals`
* `bvecs`
* `nodif_brain_mask.nii.gz`

Output
* `999999_nodif_brain_mask_fillh.nii.gz` (non-diffusion-weighted brain mask with no holes)
* `999999_DWI.mif` (diffusion images in MRTRix3 format)
* `999999_cDWI.mif` (bias-corrected diffusion images)
* `999999_DT.mif` (diffusion tensor image)
* `999999_FA.mif` (fractional anisotropy image)

### 2: Global Intensity Normalisation
#### Script: `globalintensity.sh`

Steps
1. Copy cDWI.mif and nodif_brain_mask_fillh.nii.gz files for subset participants to designated folder
2. Conduct global intensity normalisation using subset

Input
* `cDWI.mif` x 60 subset participants
* `nodif_brain_mask_fillh.nii.gz` x 60 subset participants

Output
* `FA_template.mif`
* `WM_mask.mif`

#### Script: `normalise.sh`

Input:
* `999999_FA.mif`
* `999999_nodif_brain_mask_fillh.nii.gz`
* `WM_mask.mif`
* `FA_template.mif`

Output:
* `999999_nDWI.mif` (normalised diffusion weighted image)

### 3: Estimate Response Function
#### Script: `responsefunction.sh`
Steps:
1. Generate 5TT (five tissue type) image using freesurfer output provided by HCP
2. Calculate response function using multi-shell multi-tissue (msmt) algorithm

Input:
* `aparc+aseg.nii.gz`
  * This file should be located in the HCP data structure under 999999/T1w
* `999999_nDWI.mif`

Output:
* `999999_RF_WM.txt`
* `999999_RF_GM.txt`
* `999999_RF_CSF.txt`
* `999999_RF_voxels.mif`

#### Script: `average_responsefunction.sh`
Input:
* RF_WM, RF_GM, and RF_CSF text files for all subjects

Output:
* `average_RF_WM.txt`
* `average_RF_GM.txt`
* `average_RF_CSF.txt`

### 4: Spherical Deconvolution
Conduct multi-shell, multi-tissue (msmt) constrained spherical deconvolution (CSD).

#### Script: `deconvolution.sh`

Input:
* `average_WM.txt`
* `average_GM.txt`
* `average_CSF.txt`
* `999999_nodif_brain_mask_fillh.nii.gz`
* `999999_nDWI.mif`

Output:
* `999999_WM_FODs.mif`
* `999999_GM.mif`
* `999999_CSF.mif`
* `999999_tissueRGB.mif`

### 5: Create ROI Masks
Warp MNI masks for the left/right superior colliculus, pulvinar, and amygdala into native T1 space then native diffusion space.

The amygdala mask was retrieved from the Havard-Oxford subcortical atlas at a threshold of 50% probability. The pulvinar clusters were supplied by 
Daniel Baron from the following publication:

Barron, D. S., Eickhoff, S. B., Clos, M., & Fox, P. T. (2015). Human pulvinar functional organization and connectivity. Human brain mapping, 36(7), 2417-2431.

The clusters were merged together in FSL and gaps between the clusters were filled in manually. The superior colliculi were manually hand-drawn with reference to anatomical atlases.

Steps:
1. Save MNI masks for left/right superior colliculi, pulvinar, and amygdala according to the above
2. Create transformation files for each subject from diffusion to T1 to MNI and in reverse
3. Warp the MNI masks in to native diffusion and T1 space
4. Superior colliculus and pulvinar are spatially very close together, so remove any overlap as a result of the warping

#### Script: `rois.sh`

Input:
* `999999_nDWI.mif`
* `T1w_acpc_dc_restore_brain.nii.gz`
  * This file should be located in the HCP data structure under 999999/T1w

Output:

*Transformed images*:
* `999999_meanb0.mif`
* `999999_meanb0_brain_flirted.mif`
* `999999_t1_brain_flirted.mif`
* `999999_MNI-2-t1_warped.nii.gz`
* `999999_t1-2-dif_warped.nii.gz`

*Transformation files*:
* `999999_dif-2-t1`
* `999999_t1-2-std.mat`
* `999999_t1-2-std.warp`
* `999999_std-2-t1.mat`
* `999999_t1-2-dif.mat`

## Tractography
### Global Tractography
#### Script: `globaltractography.sh`
Input:
*Subject data*:
* `nDWI_999999.mif`
* `nodif_brain_mask_fillh_999999.nii.gz`
*Group average response functions*:
* `average_WM.txt`
* `average_CSF.txt`
* `average_GM.txt`
*ROIs in native diffusion space*: left/right SC, PUL, AMY

Output:

*Whole brain global tractograms*:
* `global_FOD_999999.mif`
* `global_fiso_999999.mif`
* `global_999999.tck`

*Edited ROI-specific tracks*: left/right SC-PUL, PUL-AMY for whole pulvinar and clusters 1-5

#### Script: `sumGlobal.sh`
This script cycles through the edited global tracks and uses `tckinfo` to print out the count. It then saves this number to a text file. One text file per track type (e.g. `count_endsonly_SC-PUL_l.txt`), one row per subject (subject ID listed in first column).

### Local Tractography
#### Script: `localtractography.sh`
Input:
*Subject data*:
* `5TT_999999.mif`
* `WM_FODs_999999.mif`
*ROIs in native diffusion space*: left/right SC, PUL, AMY

Output:

*Edited ROI-specific tracks*: left/right SC-PUL, PUL-AMY for whole pulvinar and clusters 1-5
* Done for both seeding directions (e.g. SC-PUL, PUL-SC)
* Done for both cropping at ends (i.e. streamlines terminating at white/grey matter boundaries) and without cropping ("no ends")
* SIFT2 weights saved as text files

**Note that the null distribution estimates can be estimated using the scripts above, except adding `-algorithm NullDist2` after `tckgen`

#### Script: `printStats.sh`
This script cycles through a series of .tck files and prints out the track statistics (given by `tckstats`): path length mean, median, SD, min, max, and count. It then saves these statistics in one file per track, where each row is a subject (first column indicates subject ID). These files are then used in `sumStreamlines.sh`.

#### Script: `collateData.m`
This script uses the textfile output of `printStats.sh` to give summary statistics of the streamline count and path length, including Matlab figures and XLS/CSV files.

#### Script: `sumWeights.sh`
This script reads the textfile output of SIFT2 run during the local tractography step. It simply reads the files per track/hemisphere/cluster and sums up the values. The output is a .mat file and/or a XLS/CSV file that can be put into a statistics program such as SPSS.

# fMRI Analysis
The aim of this stage was to map out task-related functional activity during a face viewing task, which the subcortical route to the amygdala should theoretically be active during. The resultant fMRI activation would then be entered into the final DCM analysis to get measures of effective connectivity to be related back to the diffusion imaging results.

We used fMRI data from the "Emotion" task in the HCP battery. Full information about the task can be found in Appendix 6 of the S900 release manual, listed [here](https://www.humanconnectome.org/study/hcp-young-adult/document/900-subjects-data-release).

## Image Preprocessing and First Level Analysis
We used the minimally processed data provided by HCP. Our processing approach closely followed that of [Hillebrandt et al. (2014)](10.1038/srep06240)  who also conducted DCM on a HCP task-related fMRI dataset. 

#### Script: `firstLevel.m`
This script applies a 4 x 4 x 4mm smoothing to the preprocessed HCP images. It then runs a first-level SPM GLM analysis.

Input:
* `tfMRI_EMOTION_LR.nii.gz`
* `tfMRI_EMOTION_RL.nii.gz`
* `Movement_Regressors.txt`
  * These files are located in the HCP file structure under `999999/MNINonLinear/Results/tfMRI_EMOTION_LR` or `RL`
* `fear.txt` (onsets of face blocks)
* `neut.txt` (onsets of shape blocks)
  * These files are located in the above directory in the `EVs` subdirectory
  * Note that the script ignores the last block of each condition because they were not equal (due to an HCP error, the last half of the faces block is missing).
  
Output:
* `tfMRI_EMOTION_LR.nii.gz` (smoothed)
* `tfMRI_EMOTION_RL.nii.gz` (smoothed)
* `SPM.mat` and associated files

## Second Level Analysis and VOIs
#### Script: `secondLevel.m`
This simply compares Faces > Shapes without any covariates.

Importantly, the resulting SPM whole-brain statistics are used to inform the next VOI extraction step by providing group coordinates for key areas (in this case, the IOG and FG).

#### Script: `extractVOIs.m`
The MNI masks used in this step (to extract activity in the superior colliculus and pulvinar) needed to be resliced to 2mm resolution, which is the same as the fMRI images. This can be done using the following FSL commands:

```
flirt -in mask.nii.gz -ref MNI152_T1_2mm.nii.gz -applyxfm -out resliced2mm_mask
fslmaths resliced2mm_mask.nii.gz -bin resliced2mm_mask_bin
```

Any overlap between masks can also be removed using FSL:

```
fslmaths resliced2mm_mask1.nii.gz -mas resliced2mm_mask2.nii.gz overlap
fslmaths overlap.nii.gz -bin overlap_bin
fslmaths resliced2mm_mask1.nii.gz -sub overlap_bin.nii.gz resliced2mm_mask1_no-overlap.nii.gz
```

#### Script: `checkVOIs.m`
This script serves two purposes:
1. To check for any overlap across VOIs
2. To summarise which subjects had activity significant at *p* <. 05 uncorrected within each VOI for each of the two sessions. This is displayed graphically. It determines which subjects can be entered into the DCM analysis.

# DCM Analysis
The aim of this stage was to investigate the probability of *a priori* defined neural networks (i.e. subcortical vs. cortical pathways to the amygdala). This served two purposes:
1. To establish the probability of an *effective* subcortical connection
2. To relate this statistically to the *structural* subcortical connection reconstructed using tractography, helping to elucidate whether the tractograms were functionally meaningful
