#!/bin/sh

subject=999999

######## DIRECTORIES ######## 
dir_tmp=INSERT
dir_subject=INSERT/${subject}

cd ${dir_subject}

# # Do bias correction and conversion of DWI into MRtrix format for all subjects
#printf "\n ------------------------------------------"
#printf "\n ---------------GENERATE 5TT---------------"
#printf "\n ------------------------------------------"

time 5ttgen freesurfer -force -sgm_amyg_hipp -nthreads 4 -verbose -nocrop -lut $FREESURFER_HOME/FreeSurferColorLUT.txt -tempdir ${dir_tmp} aparc+aseg.nii.gz 5TT_${subject}.mif
echo "5TT.mif created for ${subject}!"

printf "\n ------------------------------------------"
printf "\n ----------GENERATE NORMALISED RF----------"
printf "\n ------------------------------------------"
time dwi2response msmt_5tt nDWI_${subject}.mif 5TT_${subject}.mif RF_WM_${subject}.txt RF_GM_${subject}.txt RF_CSF_${subject}.txt -voxels RF_voxels_${subject}.mif -force -tempdir ${dir_tmp} -nthreads 4
echo "Response functions generated for ${subject}!"
