#!/bin/sh

subject=999999

dir_script=INSERT
dir_subject=INSERT/${subject}
dir_tmp=INSERT

echo "mrregister: ${subject}"
time mrregister ${dir_script}/FA_template.mif ${dir_subject}/FA_${subject}.mif -mask2 ${dir_subject}/nodif_brain_mask_fillh_${subject}.nii.gz -nl_scale 0.5,0.75,1.0 -nl_niter 5,5,15 -nl_warp ${dir_subject}/FA_${subject}.mif ${dir_subject}/tmp.mif -force -nthreads 4 -info
echo "mrtransform: ${subject}"
time mrtransform ${dir_script}/WM_mask.mif -template ${dir_subject}/cDWI_${subject}.mif -warp ${dir_subject}/FA_${subject}.mif ${dir_subject}/transformed.mif -force -nthreads 4 -info
echo "dwinormalise: ${subject}"
time dwinormalise ${dir_subject}/cDWI_${subject}.mif ${dir_subject}/transformed.mif ${dir_subject}/nDWI_${subject}.mif -force -nthreads 4 -info

echo "Finished!"
echo "Cleaning up files..."
rm ${dir_subject}/transformed.mif
rm ${dir_subject}/tmp.mif
