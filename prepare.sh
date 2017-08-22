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
time fslmaths nodif_brain_mask.nii.gz -fillh -bin -thr .0000000001 ${dir_subject}/${subject}_nodif_brain_mask_fillh.nii.gz

echo "Running dwibasicorrect for ${subject}..."
time dwibiascorrect -ants -mask ${dir_subject}/${subject}_nodif_brain_mask_fillh.nii.gz -tempdir ${dir_tmp} -fslgrad bvecs bvals -force -verbose -nthreads 12 data.nii.gz ${dir_subject}/${subject}_cDWI.mif
echo "DWI Bias correction complete for ${subject}!"

echo "Computing tensors for ${subject}..."
cd ${dir_subject}
time dwi2tensor -mask ${subject}_nodif_brain_mask_fillh.nii.gz -force -nthreads 12 -info ${subject}_cDWI.mif ${subject}_DT.mif
time tensor2metric -fa ${subject}_FA.mif -force -nthreads 12 -info ${subject}_DT.mif

cd ${dir_script}
echo "Finished!"
