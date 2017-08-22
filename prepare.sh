#!/bin/sh

subject=999999

######## DIRECTORIES ########
# Home directory where this script is located
dir_script=INSERT
# Temporary directory
dir_tmp=INSERT
# Data directory containing the data.nii.gz and nodif_brain_mask.nii.gz files
dir_hcp=INSERT
# Subject-specific output directory
dir_subject=INSERT/${subject}
mkdir -p ${dir_subject}

######## COMMANDS ########
cd ${dir_hcp}
echo "Using FSL to fill holes in ${subject}'s nodif_brain_mask..."
time fslmaths nodif_brain_mask.nii.gz -fillh -bin -thr .0000000001 ${dir_subject}/nodif_brain_mask_fillh_${subject}.nii.gz

echo "Running dwibasicorrect for ${subject}..."
time dwibiascorrect -ants -mask ${dir_subject}/nodif_brain_mask_fillh_${subject}.nii.gz -tempdir ${dir_tmp} -fslgrad bvecs bvals -force -verbose -nthreads 12 data.nii.gz ${dir_subject}/cDWI_${subject}.mif
echo "DWI Bias correction complete for ${subject}!"

echo "Computing tensors for ${subject}..."
cd ${dir_subject}
time dwi2tensor -mask nodif_brain_mask_fillh_${subject}.nii.gz -force -nthreads 12 -info cDWI_${subject}.mif DT_${subject}.mif
time tensor2metric -fa FA_${subject}.mif -force -nthreads 12 -info DT_${subject}.mif

cd ${dir_script}
echo "Finished!"
