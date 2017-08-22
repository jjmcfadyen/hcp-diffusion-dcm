#!/bin/sh

subject=999999

SECONDS=0

######## DIRECTORIES ######## 
dir_tmp=INPUT
dir_subject=INPUT/${subject}
dir_script=INPUT
dir_masks=${dir_script}/MNI_Masks
mkdir -p ${dir_subject}/warps/diffusion_space
mkdir -p ${dir_subject}/warps/t1_space
mkdir -p ${dir_subject}/warps/standard_space

printf "\n ------------------------------------------";
printf "\n --------------GENERATE ROIS---------------";
printf "\n ------------------------------------------";

cd ${dir_subject}
printf "\n~~~ Generating meanb0 image for ${subject}"
dwiextract 999999_nDWI.mif - -bzero | mrmath - mean 999999_meanb0.mif -axis 3 -force
mrconvert 999999_meanb0.mif 999999_999999_meanb0.nii -force

printf "\n ${subject}: [DWI to T1]"
time flirt -in 999999_meanb0.nii.gz -ref ${dir_subject}/T1w_acpc_dc_restore_brain.nii.gz -omat ${dir_subject}/warps/t1_space/999999_dif-2-t1.mat -out ${dir_subject}/warps/t1_space/999999_meanb0_brain_flirted
printf "\n ${subject}: [T1 to MNI]"
time flirt -in ${dir_subject}/T1w_acpc_dc_restore_brain.nii.gz -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz -out ${dir_subject}/warps/standard_space/999999_t1_brain_flirted -omat ${dir_subject}/warps/standard_space/999999_t1-2-std.mat
time fnirt --in=${dir_subject}/T1w_acpc_dc_restore.nii.gz --aff=${dir_subject}/warps/standard_space/999999_t1-2-std.mat --cout=${dir_subject}/warps/standard_space/999999_t1-2-std_warp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz --config=T1_2_MNI152_2mm
printf "\n ${subject}: [MNI to T1]"
time invwarp -w ${dir_subject}/warps/standard_space/999999_t1-2-std_warp -r ${dir_subject}/T1w_acpc_dc_restore.nii.gz -o ${dir_subject}/warps/t1_space/999999_std-2-t1
time applywarp --ref=${dir_subject}/T1w_acpc_dc_restore_brain.nii.gz --in=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz --warp=${dir_subject}/warps/t1_space/999999_std-2-t1 --out=${dir_subject}/warps/t1_space/999999_MNI-2-t1_warped
printf "\n ${subject}: [T1 to DWI]"
time convert_xfm -omat ${dir_subject}/warps/diffusion_space/999999_t1-2-dif.mat -inverse ${dir_subject}/warps/t1_space/999999_dif-2-t1.mat
time applywarp --ref=999999_meanb0.nii --in=${dir_subject}/T1w_acpc_dc_restore_brain.nii.gz --postmat=${dir_subject}/warps/diffusion_space/999999_t1-2-dif.mat --out=${dir_subject}/warps/diffusion_space/999999_999999_t1-2-dif_warped

printf "\n ${subject}: Warping ROI masks to subject DWI space..."
for mask in SC PUL AMY
do
	for hemi in l r
	do 
		time applywarp --ref=${dir_subject}/T1w_acpc_dc_restore_brain.nii.gz --in=${dir_masks}/${mask}_${hemi}_MNI.nii.gz --warp=${dir_subject}/warps/t1_space/999999_std-2-t1 --out=${dir_subject}/warps/t1_space/999999_${mask}_${hemi}_t1.nii.gz
		time applywarp --ref=999999_meanb0.nii --in=${dir_subject}/warps/t1_space/999999_${mask}_${hemi}_t1.nii.gz --postmat=${dir_subject}/warps/diffusion_space/999999_t1-2-dif.mat --out=${dir_subject}/warps/diffusion_space/999999_${mask}_${hemi}_dwi.nii.gz;
		time fslmaths ${dir_subject}/warps/diffusion_space/999999_${mask}_${hemi}_dwi.nii.gz -bin -thr .0000000001 ${dir_subject}/warps/diffusion_space/999999_${mask}_${hemi}_dwi_bin.nii.gz;
	done
done

printf "\n ${subject}: Removing any overlap between SC and PUL..."
cd ${dir_subject}/warps/diffusion_space
for hemi in l r; do
	time fslmaths 999999_PUL_${hemi}_dwi_bin.nii.gz -mas 999999_SC_${hemi}_dwi_bin.nii.gz 999999_overlap
	time fslmaths 999999_overlap.nii.gz -bin -thr .0000000001 999999_overlap_bin.nii.gz
	time fslstats 999999_overlap_bin.nii.gz -V > 999999_overlap.txt
	cat 999999_overlap.txt
	for roi in SC PUL; do
		time fslmaths 999999_${roi}_${hemi}_dwi_bin.nii.gz -sub 999999_overlap_bin.nii.gz 999999_${roi}_${hemi}_dwi_no-overlap
		time fslmaths 999999_${roi}_${hemi}_dwi_no-overlap -bin -thr .0000000001 999999_${roi}_${hemi}_dwi_bin_no-overlap
	done
done

printf "\n ${subject}: Warping Pulvinar Clusters to subject DWI space..."
cd ${dir_subject}
for cluster in 1 2 3 4 5; do
	for hemi in l r; do 
		time applywarp --ref=T1w_acpc_dc_restore_brain.nii.gz --in=${dir_masks}/PUL_${hemi}_MNI_Cluster${cluster}.nii --warp=warps/t1_space/999999_std-2-t1 --out=warps/t1_space/999999_PUL_${hemi}_Cluster${cluster}_t1.nii.gz
		time applywarp --ref=999999_meanb0.nii --in=warps/t1_space/PUL_${hemi}_Cluster${cluster}_t1.nii.gz --postmat=warps/diffusion_space/999999_t1-2-dif.mat --out=warps/diffusion_space/999999_PUL_${hemi}_Cluster${cluster}_dwi.nii.gz
		time fslmaths warps/diffusion_space/999999_PUL_${hemi}_Cluster${cluster}_dwi.nii.gz -bin -thr .0000000001 warps/diffusion_space/999999_PUL_${hemi}_Cluster${cluster}_dwi_bin.nii.gz
	done
done

printf "\n ${subject}: Removing any SC/PUL overlap from Pulvinar Clusters..."
cd ${dir_subject}/warps/diffusion_space
for cluster in 1 2 3 4 5; do
	for hemi in l r; do
		time fslmaths 999999_PUL_${hemi}_Cluster${cluster}_dwi_bin.nii.gz -mas 999999_SC_${hemi}_dwi_bin.nii.gz 999999_cluster${cluster}_overlap
		time fslmaths 999999_cluster${cluster}_overlap.nii.gz -bin -thr .0000000001 999999_cluster${cluster}_overlap_bin.nii.gz
		time fslstats 999999_cluster${cluster}_overlap_bin.nii.gz -V > 999999_cluster${cluster}_overlap.txt
		cat 999999_cluster${cluster}_overlap.txt
		time fslmaths 999999_PUL_${hemi}_Cluster${cluster}_dwi_bin.nii.gz -sub 999999_cluster${cluster}_overlap_bin.nii.gz 999999_PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap.nii.gz
		time fslmaths 999999_PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap.nii.gz -bin -thr .0000000001 999999_PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap.nii.gz
	done
done

printf "\n ${subject}: Removing any overlap between Pulvinar Clusters..."
cd ${dir_subject}/warps/diffusion_space
for hemi in l r; do

	time fslmaths 999999_PUL_${hemi}_Cluster1_dwi_bin_no-overlap.nii.gz -mas 999999_PUL_${hemi}_Cluster2_dwi_bin_no-overlap.nii.gz 999999_cluster1-2_overlap
	time fslmaths 999999_cluster1-2_overlap.nii.gz -bin -thr .0000000001 999999_cluster1-2_overlap_bin.nii.gz
	time fslmaths 999999_PUL_${hemi}_Cluster1_dwi_bin_no-overlap.nii.gz -mas 999999_PUL_${hemi}_Cluster3_dwi_bin_no-overlap.nii.gz 999999_cluster1-3_overlap
	time fslmaths 999999_cluster1-3_overlap.nii.gz -bin -thr .0000000001 999999_cluster1-3_overlap_bin.nii.gz
	time fslmaths 999999_PUL_${hemi}_Cluster1_dwi_bin_no-overlap.nii.gz -mas 999999_PUL_${hemi}_Cluster4_dwi_bin_no-overlap.nii.gz 999999_cluster1-4_overlap
	time fslmaths 999999_cluster1-4_overlap.nii.gz -bin -thr .0000000001 999999_cluster1-4_overlap_bin.nii.gz
	time fslmaths 999999_PUL_${hemi}_Cluster1_dwi_bin_no-overlap.nii.gz -mas 999999_PUL_${hemi}_Cluster5_dwi_bin_no-overlap.nii.gz 999999_cluster1-5_overlap
	time fslmaths 999999_cluster1-5_overlap.nii.gz -bin -thr .0000000001 999999_cluster1-5_overlap_bin.nii.gz

	time fslmaths 999999_PUL_${hemi}_Cluster2_dwi_bin_no-overlap.nii.gz -mas 999999_PUL_${hemi}_Cluster3_dwi_bin_no-overlap.nii.gz 999999_cluster2-3_overlap
	time fslmaths 999999_cluster2-3_overlap.nii.gz -bin -thr .0000000001 999999_cluster2-3_overlap_bin.nii.gz
	time fslmaths 999999_PUL_${hemi}_Cluster2_dwi_bin_no-overlap.nii.gz -mas 999999_PUL_${hemi}_Cluster4_dwi_bin_no-overlap.nii.gz 999999_cluster2-4_overlap
	time fslmaths 999999_cluster2-4_overlap.nii.gz -bin -thr .0000000001 999999_cluster2-4_overlap_bin.nii.gz
	time fslmaths 999999_PUL_${hemi}_Cluster2_dwi_bin_no-overlap.nii.gz -mas 999999_PUL_${hemi}_Cluster5_dwi_bin_no-overlap.nii.gz 999999_cluster2-5_overlap
	time fslmaths 999999_cluster2-5_overlap.nii.gz -bin -thr .0000000001 999999_cluster2-5_overlap_bin.nii.gz

	time fslmaths 999999_PUL_${hemi}_Cluster3_dwi_bin_no-overlap.nii.gz -mas 999999_PUL_${hemi}_Cluster4_dwi_bin_no-overlap.nii.gz 999999_cluster3-4_overlap
	time fslmaths 999999_cluster3-4_overlap.nii.gz -bin -thr .0000000001 999999_cluster3-4_overlap_bin.nii.gz
	time fslmaths 999999_PUL_${hemi}_Cluster3_dwi_bin_no-overlap.nii.gz -mas 999999_PUL_${hemi}_Cluster5_dwi_bin_no-overlap.nii.gz 999999_cluster3-5_overlap
	time fslmaths 999999_cluster3-5_overlap.nii.gz -bin -thr .0000000001 999999_cluster3-5_overlap_bin.nii.gz

	time fslmaths 999999_PUL_${hemi}_Cluster4_dwi_bin_no-overlap.nii.gz -mas 999999_PUL_${hemi}_Cluster5_dwi_bin_no-overlap.nii.gz 999999_cluster4-5_overlap
	time fslmaths 999999_cluster4-5_overlap.nii.gz -bin -thr .0000000001 999999_cluster4-5_overlap_bin.nii.gz



	time fslmaths 999999_PUL_${hemi}_Cluster1_dwi_bin_no-overlap.nii.gz -sub 999999_cluster1-2_overlap_bin.nii.gz -sub 999999_cluster1-3_overlap_bin.nii.gz -sub 999999_cluster1-4_overlap_bin.nii.gz -sub 999999_cluster1-5_overlap_bin.nii.gz 999999_PUL_${hemi}_Cluster1_dwi_bin_no-overlap_noclusteroverlap.nii.gz
	time fslmaths 999999_PUL_${hemi}_Cluster1_dwi_bin_no-overlap_noclusteroverlap.nii.gz -bin -thr .0000000001 999999_PUL_${hemi}_Cluster1_dwi_bin_no-overlap_noclusteroverlap.nii.gz

	time fslmaths 999999_PUL_${hemi}_Cluster2_dwi_bin_no-overlap.nii.gz -sub 999999_cluster1-2_overlap_bin.nii.gz -sub 999999_cluster2-3_overlap_bin.nii.gz -sub 999999_cluster2-4_overlap_bin.nii.gz -sub 999999_cluster2-5_overlap_bin.nii.gz 999999_PUL_${hemi}_Cluster2_dwi_bin_no-overlap_noclusteroverlap.nii.gz
	time fslmaths 999999_PUL_${hemi}_Cluster2_dwi_bin_no-overlap_noclusteroverlap.nii.gz -bin -thr .0000000001 999999_PUL_${hemi}_Cluster2_dwi_bin_no-overlap_noclusteroverlap.nii.gz

	time fslmaths 999999_PUL_${hemi}_Cluster3_dwi_bin_no-overlap.nii.gz -sub 999999_cluster1-3_overlap_bin.nii.gz -sub 999999_cluster2-3_overlap_bin.nii.gz -sub 999999_cluster3-4_overlap_bin.nii.gz -sub 999999_cluster3-5_overlap_bin.nii.gz 999999_PUL_${hemi}_Cluster3_dwi_bin_no-overlap_noclusteroverlap.nii.gz
	time fslmaths 999999_PUL_${hemi}_Cluster3_dwi_bin_no-overlap_noclusteroverlap.nii.gz -bin -thr .0000000001 999999_PUL_${hemi}_Cluster3_dwi_bin_no-overlap_noclusteroverlap.nii.gz

	time fslmaths 999999_PUL_${hemi}_Cluster4_dwi_bin_no-overlap.nii.gz -sub 999999_cluster1-4_overlap_bin.nii.gz -sub 999999_cluster2-4_overlap_bin.nii.gz -sub 999999_cluster3-4_overlap_bin.nii.gz -sub 999999_cluster4-5_overlap_bin.nii.gz 999999_PUL_${hemi}_Cluster4_dwi_bin_no-overlap_noclusteroverlap.nii.gz
	time fslmaths 999999_PUL_${hemi}_Cluster4_dwi_bin_no-overlap_noclusteroverlap.nii.gz -bin -thr .0000000001 999999_PUL_${hemi}_Cluster4_dwi_bin_no-overlap_noclusteroverlap.nii.gz

	time fslmaths 999999_PUL_${hemi}_Cluster5_dwi_bin_no-overlap.nii.gz -sub 999999_cluster1-5_overlap_bin.nii.gz -sub 999999_cluster2-5_overlap_bin.nii.gz -sub 999999_cluster3-5_overlap_bin.nii.gz -sub 999999_cluster4-5_overlap_bin.nii.gz 999999_PUL_${hemi}_Cluster5_dwi_bin_no-overlap_noclusteroverlap.nii.gz
	time fslmaths 999999_PUL_${hemi}_Cluster5_dwi_bin_no-overlap_noclusteroverlap.nii.gz -bin -thr .0000000001 999999_PUL_${hemi}_Cluster5_dwi_bin_no-overlap_noclusteroverlap.nii.gz
done

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
