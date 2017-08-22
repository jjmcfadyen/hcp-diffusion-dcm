#!/bin/sh

subject=999999

dir_avRF=INSERT
dir_subject=INSERT

# Perform Multi-Shell, Multi-Tissue Constrained Spherical Deconvolution
printf "\n ------------------------------------------";
printf "\n ----------SPHERICAL DECONVOLUTION---------";
printf "\n ------------------------------------------";
cd ${dir_subject}
printf "\n~~~ Running Spherical Deconvolution for: $subject"
time dwi2fod msmt_csd ${dir_subject}/999999_nDWI.mif ${dir_avRF}/average_WM.txt 999999_WM_FODs.mif ${dir_avRF}/average_GM.txt 999999_GM.mif ${dir_avRF}/average_CSF.txt 999999_CSF.mif -mask 999999_nodif_brain_mask_fillh.nii.gz -force -nthreads 4 -info
time mrconvert 999999_WM_FODs.mif - -coord 3 0 | mrcat 999999_CSF.mif 999999_GM.mif - 999999_tissueRGB.mif -axis 3 -force # for visualisation purposes only
