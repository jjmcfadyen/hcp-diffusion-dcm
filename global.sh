#!/bin/sh

subject=999999

SECONDS=0

dir_results=INSERT
dir_subject=INSERT/${subject}
dir_masks=${dir_subject}
dir_avRF=INSERT

mkdir -p ${dir_results}/fod
mkdir -p ${dir_results}/fiso
mkdir -p ${dir_results}/global
mkdir -p ${dir_results}/tckedit
mkdir -p ${dir_results}/tckedit_clusters

cd ${dir_subject}
printf "\n\n TCKGLOBAL for ${subject}..."
time tckglobal nDWI_${subject}.mif ${dir_avRF}/average_WM.txt -riso ${dir_avRF}/average_CSF.txt -riso ${dir_avRF}/average_GM.txt -mask nodif_brain_mask_fillh_${subject}.nii.gz -fod ${dir_results}/fod/global_FOD_${subject}.mif -fiso ${dir_results}/fiso/fiso_${subject}.mif -niter 2.5e8 -nthreads 1 -force ${dir_results}/global/global_${subject}.tck # more than 1 thread causes an MRtrix bug for non-OS platforms...
printf "\n Result: ${dir_results}/global/global_${subject}.tck"

printf "\n\n TCKEDIT for ${subject}..."
cd ${dir_masks}
for hemi in l r; do
	time tckedit -include SC_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz -include PUL_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz -ends_only -force ${dir_results}/global/global_${subject}.tck ${dir_results}/tckedit/global_${subject}_SC-PUL_${hemi}.tck;
	printf "\n Result: ${dir_results}/tckedit/global_SC-PUL_${hemi}_${subject}.tck"
	time tckedit -include PUL_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz -include AMY_${hemi}_dwi_bin_${subject}.nii.gz -force -ends_only ${dir_results}/global/global_${subject}.tck ${dir_results}/tckedit/global_${subject}_PUL-AMY_${hemi}.tck;
	printf "\n Result: ${dir_results}/tckedit/global_PUL-AMY_${hemi}_${subject}.tck"
done

printf "\n TCKEDIT CLUSTERS for ${subject}..."
for hemi in l r; do
	for cluster in 1 2 3 4 5; do

		time tckedit -include SC_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz -include PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz -force -ends_only ${dir_results}/global/global_${subject}.tck ${dir_results}/tckedit_clusters/global_SC-PUL_${hemi}_Cluster${cluster}_${subject}.tck;
		printf "\n Result: ${dir_results}/tckedit_clusters/global_SC-PUL_${hemi}_Cluster${cluster}_${subject}.tck"
		time tckedit -include PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz -include AMY_${hemi}_dwi_bin_${subject}.nii.gz -force -ends_only ${dir_results}/global/global_${subject}.tck ${dir_results}/tckedit_clusters/global_PUL-AMY_${hemi}_Cluster${cluster}_${subject}.tck;
		printf "\n Result: ${dir_results}/tckedit_clusters/global_PUL-AMY_${hemi}_Cluster${cluster}_${subject}.tck"

	done
done

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
