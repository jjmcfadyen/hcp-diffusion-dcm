#!/bin/sh

dir_script=INSERT
dir_DWI=${dir_script}/DWI
dir_BM=${dir_script}/BrainMasks
dir_subjects=INSERT
dir_tmp=INSERT

cd ${dir_script}
subjects=$(cat subsetlist.txt)

echo "[Copying DWI & Brain Mask files...]"
for subject in $subjects; do
	cd ${dir_subjects}/${subject}
	echo "[... cp ${subject}]"
	cp cDWI.mif ${dir_DWI}/${subject}_cDWI.mif
	cp nodif_brain_mask_fillh.nii.gz ${dir_BM}/${subject}_nodif_brain_mask_fillh.nii.gz
done

echo "[Running global intensity normalisation across subjects...]"
cd ${dir_script}
time dwiintensitynorm -tempdir ${dir_tmp} -nthreads 12 -verbose -force ${dir_DWI} ${dir_BM} ${dir_script}/Normalised FA_template.mif WM_mask.mif
