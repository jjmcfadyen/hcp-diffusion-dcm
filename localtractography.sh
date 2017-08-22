#!/bin/sh

subject=999999

SECONDS=0

nthreads=4;

dir_results=INSERT
dir_subject=INSERT
dir_masks=${dir_subject}/warps/diffusion_space
dir_script=INSERT

mkdir -p ${dir_results}/ROI_SeedTractography/tckgen
mkdir -p ${dir_results}/ROI_SeedTractography/tckgen_clusters

cd ${dir_masks}
printf "\n TCKGEN for ${subject}..."
for hemi in l r; do
	printf "\n ... SC-PUL"
 	time tckgen -seed_image SC_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz -include PUL_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen/SCPUL/SC-PUL_${hemi}_${subject}.tck
	printf "\n ... PUL-AMY"
	time tckgen -seed_image PUL_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz -include AMY_${hemi}_dwi_bin_${subject}.nii.gz -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen/PULAMY/PUL-AMY_${hemi}_${subject}.tck
	printf "\n ... PUL-SC"
	time tckgen -seed_image PUL_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz -include SC_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen/PULSC/PUL-SC_${hemi}_${subject}.tck
	printf "\n ... AMY-PUL"
	time tckgen -seed_image AMY_${hemi}_dwi_bin_${subject}.nii.gz -include PUL_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen/AMYPUL/AMY-PUL_${hemi}_${subject}.tck
done

printf "\n TCKGEN CLUSTERS for ${subject}..."
for cluster in 1 2 3 4 5; do
	for hemi in l r; do
		printf "\n ... SC-PUL"
	 	time tckgen -seed_image SC_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz -include PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen_clusters/SC-PUL_${hemi}_${subject}.tck
		printf "\n ... PUL-AMY"
		time tckgen -seed_image PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz -include AMY_${hemi}_dwi_bin_${subject}.nii.gz -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen_clusters/PUL-AMY_${hemi}_${subject}.tck
		printf "\n ... PUL-SC"
		time tckgen -seed_image PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz -include SC_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen_clusters/PUL-SC_${hemi}_${subject}.tck
		printf "\n ... AMY-PUL"
		time tckgen -seed_image AMY_${hemi}_dwi_bin_${subject}.nii.gz -include PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen_clusters/AMY-PUL_${hemi}_${subject}.tck
	done
done

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
cd ${dir_script}
echo ${subject} >> finished.txt
