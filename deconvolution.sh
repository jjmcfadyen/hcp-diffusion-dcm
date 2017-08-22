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
time dwi2fod msmt_csd ${dir_subject}/nDWI_${subject}.mif ${dir_avRF}/average_WM.txt WM_FODs_${subject}.mif ${dir_avRF}/average_GM.txt GM_${subject}.mif ${dir_avRF}/average_CSF.txt CSF_${subject}.mif -mask nodif_brain_mask_fillh_${subject}.nii.gz -force -nthreads 4 -info
time mrconvert WM_FODs_${subject}.mif - -coord 3 0 | mrcat CSF_${subject}.mif GM_${subject}.mif - tissueRGB_${subject}.mif -axis 3 -force # for visualisation purposes only
