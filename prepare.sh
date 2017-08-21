#!/bin/sh

subject=100206

######## DIRECTORIES ########
# Home directory where this script is located
dir_script=/ibscratch/users/uqjmcfad/DWI_AllSubjects/Scripts/01_prepare
# Temporary directory
dir_tmp=/ibscratch/users/uqjmcfad/DWI_AllSubjects/tmp
# Data directory containing the data.nii.gz and nodif_brain_mask.nii.gz files
dir_hcp=/ibscratch/users/uqjmcfad/DWI_AllSubjects/Scripts/01_prepare/errors/${subject}
# Subject-specific output directory
dir_subject=/ibscratch/users/uqjmcfad/DWI_AllSubjects/Scripts/01_prepare/errors/${subject}
mkdir -p ${dir_subject}

######## COMMANDS ########
cd ${dir_hcp}
echo "Using FSL to fill holes in ${subject}'s nodif_brain_mask..."
time fslmaths nodif_brain_mask.nii.gz -fillh -bin -thr .0000000001 ${dir_subject}/nodif_brain_mask_fillh.nii.gz

echo "Running dwibasicorrect for ${subject}..."
time dwibiascorrect -ants -mask ${dir_subject}/nodif_brain_mask_fillh.nii.gz -tempdir ${dir_tmp} -fslgrad bvecs bvals -force -verbose -nthreads 12 data.nii.gz ${dir_subject}/cDWI.mif
echo "DWI Bias correction complete for ${subject}!"

echo "Computing tensors for ${subject}..."
cd ${dir_subject}
time dwi2tensor -mask nodif_brain_mask_fillh.nii.gz -force -nthreads 12 -info cDWI.mif DT.mif
time tensor2metric -fa FA.mif -force -nthreads 12 -info DT.mif

cd ${dir_script}
echo "Finished!"
