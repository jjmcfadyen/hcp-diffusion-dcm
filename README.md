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

# Analysis Steps
## Data Selection
The first filtering step was to only include subjects that had complete data for the structural MRI, diffusion MRI, and the emotion fMRI task. We then excluded participants who had abnormal colour vision and tested positive for any drug/alcohol tests.
**Scripts**: selectSubjects.R
**Data**: CSV files for the unrestricted _and_ restricted data for the S900 release
## Data Preprocessing
The following steps were designed in accordance with the MRTrix3 [ISMRM tutorial](https://mrtrix.readthedocs.io/en/latest/quantitative_structural_connectivity/ismrm_hcp_tutorial.html) for reconstructing connectomes using HCP data. 
### 1: Prepare
Fills any holes in the non-b0-weighted brain masks (that may lead to errors), converts 
**Data**: Located in the HCP file structure under: 
