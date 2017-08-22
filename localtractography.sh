#!/bin/sh

subject=999999

SECONDS=0

nthreads=4;

dir_results=INSERT
dir_subject=INSERT
dir_masks=${dir_subject}/warps/diffusion_space
dir_script=INSERT

mkdir -p ${dir_results}/ROI_SeedTractography/tckgen/noends
mkdir -p ${dir_results}/ROI_SeedTractography/tckgen/endsonly
mkdir -p ${dir_results}/ROI_SeedTractography/tckgen_clusters/noends
mkdir -p ${dir_results}/ROI_SeedTractography/tckgen_clusters/endsonly

cd ${dir_masks}
printf "\n TCKGEN, TCKEDIT, and SIFT for ${subject}..."
for hemi in l r; do

	printf "\n ... SC-PUL"
	mask1="SC_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz"
	mask2="PUL_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz"
	tracklabel="SC-PUL"

	# note that this block is identical to the blocks below - no need to edit, should just need to edit the labels in the block above
 	time tckgen -seed_image ${mask1} -include ${mask2} -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen/noends/noends_${tracklabel}_${hemi}_${subject}.tck
	time tckedit -include ${mask1} -include ${mask2} -ends_only ${dir_results}/ROI_SeedTractography/tckgen/noends/noends_${tracklabel}/${tracklabel}_${hemi}_${subject}.tck ${dir_results}/ROI_SeedTractography/tckgen/endsonly/endsonly_${tracklabel}_${hemi}_${subject}.tck
	time tcksift2 -info -force -nthreads ${nthreads} -act ${dir_subject}/5TT_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen/endsonly/endsonly_${tracklabel}_${hemi}_${subject}.tck ${dir_subject}/WM_FODs.mif ${dir_results}/ROI_SeedTractography/tckgen/endsonly/sift2_endsonly_${tracklabel}_${hemi}_${subject}.txt
	
	printf "\n ... PUL-SC"
	mask1="PUL_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz"
	mask2="SC_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz"
	tracklabel="PUL-SC"

	# note that this block is identical to the blocks below - no need to edit, should just need to edit the labels in the block above
 	time tckgen -seed_image ${mask1} -include ${mask2} -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen/noends/noends_${tracklabel}_${hemi}_${subject}.tck
	time tckedit -include ${mask1} -include ${mask2} -ends_only ${dir_results}/ROI_SeedTractography/tckgen/noends/noends_${tracklabel}/${tracklabel}_${hemi}_${subject}.tck ${dir_results}/ROI_SeedTractography/tckgen/endsonly/endsonly_${tracklabel}_${hemi}_${subject}.tck
	time tcksift2 -info -force -nthreads ${nthreads} -act ${dir_subject}/5TT_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen/endsonly/endsonly_${tracklabel}_${hemi}_${subject}.tck ${dir_subject}/WM_FODs.mif ${dir_results}/ROI_SeedTractography/tckgen/endsonly/sift2_endsonly_${tracklabel}_${hemi}_${subject}.txt
	
	printf "\n ... PUL-AMY"
	mask1="PUL_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz"
	mask2="AMY_${hemi}_dwi_bin_${subject}.nii.gz"
	tracklabel="PUL-AMY"

	# note that this block is identical to the blocks below - no need to edit, should just need to edit the labels in the block above
 	time tckgen -seed_image ${mask1} -include ${mask2} -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen/noends/noends_${tracklabel}_${hemi}_${subject}.tck
	time tckedit -include ${mask1} -include ${mask2} -ends_only ${dir_results}/ROI_SeedTractography/tckgen/noends/noends_${tracklabel}/${tracklabel}_${hemi}_${subject}.tck ${dir_results}/ROI_SeedTractography/tckgen/endsonly/endsonly_${tracklabel}_${hemi}_${subject}.tck
	time tcksift2 -info -force -nthreads ${nthreads} -act ${dir_subject}/5TT_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen/endsonly/endsonly_${tracklabel}_${hemi}_${subject}.tck ${dir_subject}/WM_FODs.mif ${dir_results}/ROI_SeedTractography/tckgen/endsonly/sift2_endsonly_${tracklabel}_${hemi}_${subject}.txt
	
	printf "\n ... PUL-AMY"
	mask1="AMY_${hemi}_dwi_bin_${subject}.nii.gz"
	mask2="PUL_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz"
	tracklabel="AMY-PUL"

	# note that this block is identical to the blocks below - no need to edit, should just need to edit the labels in the block above
 	time tckgen -seed_image ${mask1} -include ${mask2} -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen/noends/noends_${tracklabel}_${hemi}_${subject}.tck
	time tckedit -include ${mask1} -include ${mask2} -ends_only ${dir_results}/ROI_SeedTractography/tckgen/noends/noends_${tracklabel}/${tracklabel}_${hemi}_${subject}.tck ${dir_results}/ROI_SeedTractography/tckgen/endsonly/endsonly_${tracklabel}_${hemi}_${subject}.tck
	time tcksift2 -info -force -nthreads ${nthreads} -act ${dir_subject}/5TT_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen/endsonly/endsonly_${tracklabel}_${hemi}_${subject}.tck ${dir_subject}/WM_FODs.mif ${dir_results}/ROI_SeedTractography/tckgen/endsonly/sift2_endsonly_${tracklabel}_${hemi}_${subject}.txt
	
done

printf "\n TCKGEN, TCKEDIT, and SIFT CLUSTERS for ${subject}..."
for cluster in 1 2 3 4 5; do
	for hemi in l r; do

		printf "\n ... SC-PUL"
		mask1="SC_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz"
		mask2="PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz"
		tracklabel="SC-PUL_Cluster{cluster}"
	 	time tckgen -seed_image ${mask1} -include ${mask2} -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen_clusters/noends/noends_${tracklabel}_${hemi}_${subject}.tck
		time tckedit -include ${mask1} -include ${mask2} -ends_only ${dir_results}/ROI_SeedTractography/tckgen/noends/noends_${tracklabel}/${tracklabel}_${hemi}_${subject}.tck ${dir_results}/ROI_SeedTractography/tckgen_clusters/endsonly/endsonly_${tracklabel}_${hemi}_${subject}.tck
		
		printf "\n ... PUL-SC"
		mask1="PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz"
		mask2="SC_${hemi}_dwi_bin_no-overlap_${subject}.nii.gz"
		tracklabel="PUL-SC_Cluster{cluster}"
	 	time tckgen -seed_image ${mask1} -include ${mask2} -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen_clusters/noends/noends_${tracklabel}_${hemi}_${subject}.tck
		time tckedit -include ${mask1} -include ${mask2} -ends_only ${dir_results}/ROI_SeedTractography/tckgen/noends/noends_${tracklabel}/${tracklabel}_${hemi}_${subject}.tck ${dir_results}/ROI_SeedTractography/tckgen_clusters/endsonly/endsonly_${tracklabel}_${hemi}_${subject}.tck
		
		printf "\n ... PUL-AMY"
		mask1="PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz"
		mask2="AMY_${hemi}_dwi_bin_${subject}.nii.gz"
		tracklabel="PUL-AMY_Cluster{cluster}"
	 	time tckgen -seed_image ${mask1} -include ${mask2} -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen_clusters/noends/noends_${tracklabel}_${hemi}_${subject}.tck
		time tckedit -include ${mask1} -include ${mask2} -ends_only ${dir_results}/ROI_SeedTractography/tckgen/noends/noends_${tracklabel}/${tracklabel}_${hemi}_${subject}.tck ${dir_results}/ROI_SeedTractography/tckgen_clusters/endsonly/endsonly_${tracklabel}_${hemi}_${subject}.tck
		
		printf "\n ... AMY-PUL"
		mask1="AMY_${hemi}_dwi_bin_${subject}.nii.gz"
		mask2="PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz"
		tracklabel="PAMY-PUL_Cluster{cluster}"
	 	time tckgen -seed_image ${mask1} -include ${mask2} -stop -act ${dir_subject}/5TT_${subject}.mif -crop_at_gmwmi -number 10000 -maxnum 25000 -cutoff 0.06 -force -nthreads ${nthreads} ${dir_subject}/WM_FODs_${subject}.mif ${dir_results}/ROI_SeedTractography/tckgen_clusters/noends/noends_${tracklabel}_${hemi}_${subject}.tck
		time tckedit -include ${mask1} -include ${mask2} -ends_only ${dir_results}/ROI_SeedTractography/tckgen/noends/noends_${tracklabel}/${tracklabel}_${hemi}_${subject}.tck ${dir_results}/ROI_SeedTractography/tckgen_clusters/endsonly/endsonly_${tracklabel}_${hemi}_${subject}.tck
		
	done
done

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
cd ${dir_script}
echo ${subject} >> finished.txt
