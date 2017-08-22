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
dwiextract nDWI_${subject}..mif - -bzero | mrmath - mean meanb0_${subject}.mif -axis 3 -force
mrconvert meanb0_${subject}.mif meanb0_${subject}.nii -force

printf "\n ${subject}: [DWI to T1]"
time flirt -in meanb0_${subject}.nii.gz -ref ${dir_subject}/T1w_acpc_dc_restore_brain.nii.gz -omat ${dir_subject}/warps/t1_space/dif-2-t1_${subject}..mat -out ${dir_subject}/warps/t1_space/meanb0_brain_flirted_${subject}
printf "\n ${subject}: [T1 to MNI]"
time flirt -in ${dir_subject}/T1w_acpc_dc_restore_brain.nii.gz -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz -out ${dir_subject}/warps/standard_space/t1_brain_flirted_${subject}. -omat ${dir_subject}/warps/standard_space/t1-2-std_${subject}..mat
time fnirt --in=${dir_subject}/T1w_acpc_dc_restore.nii.gz --aff=${dir_subject}/warps/standard_space/t1-2-std_${subject}..mat --cout=${dir_subject}/warps/standard_space/t1-2-std_${subject}._warp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz --config=T1_2_MNI152_2mm
printf "\n ${subject}: [MNI to T1]"
time invwarp -w ${dir_subject}/warps/standard_space/t1-2-std_${subject}._warp -r ${dir_subject}/T1w_acpc_dc_restore.nii.gz -o ${dir_subject}/warps/t1_space/std-2-t1_${subject}.
time applywarp --ref=${dir_subject}/T1w_acpc_dc_restore_brain.nii.gz --in=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz --warp=${dir_subject}/warps/t1_space/std-2-t1_${subject}. --out=${dir_subject}/warps/t1_space/MNI-2-t1_warped_${subject}.
printf "\n ${subject}: [T1 to DWI]"
time convert_xfm -omat ${dir_subject}/warps/diffusion_space/t1-2-dif_${subject}..mat -inverse ${dir_subject}/warps/t1_space/dif-2-t1_${subject}..mat
time applywarp --ref=meanb0_${subject}.nii --in=${dir_subject}/T1w_acpc_dc_restore_brain.nii.gz --postmat=${dir_subject}/warps/diffusion_space/t1-2-dif_${subject}..mat --out=${dir_subject}/warps/diffusion_space/t1-2-dif_${subject}._warped_${subject}.

printf "\n ${subject}: Warping ROI masks to subject DWI space..."
for mask in SC PUL AMY
do
	for hemi in l r
	do 
		time applywarp --ref=${dir_subject}/T1w_acpc_dc_restore_brain.nii.gz --in=${dir_masks}/${mask}_${hemi}_MNI.nii.gz --warp=${dir_subject}/warps/t1_space/std-2-t1_${subject}. --out=${dir_subject}/warps/t1_space/${mask}_${hemi}_t1_${subject}.nii.gz
		time applywarp --ref=meanb0_${subject}.nii --in=${dir_subject}/warps/t1_space/${mask}_${hemi}_t1_${subject}.nii.gz --postmat=${dir_subject}/warps/diffusion_space/t1-2-dif_${subject}..mat --out=${dir_subject}/warps/diffusion_space/${mask}_${hemi}_dwi_${subject}.nii.gz;
		time fslmaths ${dir_subject}/warps/diffusion_space/${mask}_${hemi}_dwi_${subject}.nii.gz -bin -thr .0000000001 ${dir_subject}/warps/diffusion_space/${mask}_${hemi}_dwi_bin_${subject}.nii.gz;
	done
done

printf "\n ${subject}: Removing any overlap between SC and PUL..."
cd ${dir_subject}/warps/diffusion_space
for hemi in l r; do
	time fslmaths PUL_${hemi}_dwi_bin_${subject}.nii.gz -mas SC_${hemi}_dwi_bin_${subject}.nii.gz overlap_${subject}
	time fslmaths overlap_${subject}.nii.gz -bin -thr .0000000001 overlap_bin_${subject}.nii.gz
	time fslstats overlap_bin_${subject}.nii.gz -V > overlap_${subject}.txt
	cat overlap_${subject}.txt
	for roi in SC PUL; do
		time fslmaths ${roi}_${hemi}_dwi_bin_${subject}.nii.gz -sub overlap_bin_${subject}.nii.gz ${roi}_${hemi}_dwi_no-overlap_${subject}
		time fslmaths ${roi}_${hemi}_dwi_no-overlap_${subject} -bin -thr .0000000001 ${roi}_${hemi}_dwi_bin_no-overlap_${subject}
	done
done

printf "\n ${subject}: Warping Pulvinar Clusters to subject DWI space..."
cd ${dir_subject}
for cluster in 1 2 3 4 5; do
	for hemi in l r; do 
		time applywarp --ref=T1w_acpc_dc_restore_brain.nii.gz --in=${dir_masks}/PUL_${hemi}_MNI_Cluster${cluster}.nii --warp=warps/t1_space/std-2-t1_${subject}. --out=warps/t1_space/PUL_${hemi}_Cluster${cluster}_t1_${subject}.nii.gz
		time applywarp --ref=meanb0_${subject}.nii --in=warps/t1_space/PUL_${hemi}_Cluster${cluster}_t1.nii.gz --postmat=warps/diffusion_space/t1-2-dif_${subject}..mat --out=warps/diffusion_space/PUL_${hemi}_Cluster${cluster}_dwi_${subject}.nii.gz
		time fslmaths warps/diffusion_space/PUL_${hemi}_Cluster${cluster}_dwi_${subject}.nii.gz -bin -thr .0000000001 warps/diffusion_space/PUL_${hemi}_Cluster${cluster}_dwi_bin_${subject}.nii.gz
	done
done

printf "\n ${subject}: Removing any SC/PUL overlap from Pulvinar Clusters..."
cd ${dir_subject}/warps/diffusion_space
for cluster in 1 2 3 4 5; do
	for hemi in l r; do
		time fslmaths PUL_${hemi}_Cluster${cluster}_dwi_bin_${subject}.nii.gz -mas SC_${hemi}_dwi_bin_${subject}.nii.gz cluster${cluster}_overlap_${subject}
		time fslmaths cluster${cluster}_overlap_${subject}.nii.gz -bin -thr .0000000001 cluster${cluster}_overlap_bin_${subject}.nii.gz
		time fslstats cluster${cluster}_overlap_bin_${subject}.nii.gz -V > cluster${cluster}_overlap_${subject}.txt
		cat cluster${cluster}_overlap_${subject}.txt
		time fslmaths PUL_${hemi}_Cluster${cluster}_dwi_bin_${subject}.nii.gz -sub cluster${cluster}_overlap_bin_${subject}.nii.gz PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap_${subject}.nii.gz
		time fslmaths PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap_${subject}.nii.gz -bin -thr .0000000001 PUL_${hemi}_Cluster${cluster}_dwi_bin_no-overlap_${subject}.nii.gz
	done
done

printf "\n ${subject}: Removing any overlap between Pulvinar Clusters..."
cd ${dir_subject}/warps/diffusion_space
for hemi in l r; do

	time fslmaths PUL_${hemi}_Cluster1_dwi_bin_no-overlap_${subject}.nii.gz -mas PUL_${hemi}_Cluster2_dwi_bin_no-overlap_${subject}.nii.gz cluster1-2_overlap_${subject}
	time fslmaths cluster1-2_overlap_${subject}.nii.gz -bin -thr .0000000001 cluster1-2_overlap_${subject}_bin.nii.gz
	time fslmaths PUL_${hemi}_Cluster1_dwi_bin_no-overlap_${subject}.nii.gz -mas PUL_${hemi}_Cluster3_dwi_bin_no-overlap_${subject}.nii.gz cluster1-3_overlap_${subject}
	time fslmaths cluster1-3_overlap_${subject}.nii.gz -bin -thr .0000000001 cluster1-3_overlap_${subject}_bin.nii.gz
	time fslmaths PUL_${hemi}_Cluster1_dwi_bin_no-overlap_${subject}.nii.gz -mas PUL_${hemi}_Cluster4_dwi_bin_no-overlap_${subject}.nii.gz cluster1-4_overlap_${subject}
	time fslmaths cluster1-4_overlap_${subject}.nii.gz -bin -thr .0000000001 cluster1-4_overlap_${subject}_bin.nii.gz
	time fslmaths PUL_${hemi}_Cluster1_dwi_bin_no-overlap_${subject}.nii.gz -mas PUL_${hemi}_Cluster5_dwi_bin_no-overlap_${subject}.nii.gz cluster1-5_overlap_${subject}
	time fslmaths cluster1-5_overlap_${subject}.nii.gz -bin -thr .0000000001 cluster1-5_overlap_${subject}_bin.nii.gz

	time fslmaths PUL_${hemi}_Cluster2_dwi_bin_no-overlap_${subject}.nii.gz -mas PUL_${hemi}_Cluster3_dwi_bin_no-overlap_${subject}.nii.gz cluster2-3_overlap_${subject}
	time fslmaths cluster2-3_overlap_${subject}.nii.gz -bin -thr .0000000001 cluster2-3_overlap_${subject}_bin.nii.gz
	time fslmaths PUL_${hemi}_Cluster2_dwi_bin_no-overlap_${subject}.nii.gz -mas PUL_${hemi}_Cluster4_dwi_bin_no-overlap_${subject}.nii.gz cluster2-4_overlap_${subject}
	time fslmaths cluster2-4_overlap_${subject}.nii.gz -bin -thr .0000000001 cluster2-4_overlap_${subject}_bin.nii.gz
	time fslmaths PUL_${hemi}_Cluster2_dwi_bin_no-overlap_${subject}.nii.gz -mas PUL_${hemi}_Cluster5_dwi_bin_no-overlap_${subject}.nii.gz cluster2-5_overlap_${subject}
	time fslmaths cluster2-5_overlap_${subject}.nii.gz -bin -thr .0000000001 cluster2-5_overlap_${subject}_bin.nii.gz

	time fslmaths PUL_${hemi}_Cluster3_dwi_bin_no-overlap_${subject}.nii.gz -mas PUL_${hemi}_Cluster4_dwi_bin_no-overlap_${subject}.nii.gz cluster3-4_overlap_${subject}
	time fslmaths cluster3-4_overlap_${subject}.nii.gz -bin -thr .0000000001 cluster3-4_overlap_${subject}_bin.nii.gz
	time fslmaths PUL_${hemi}_Cluster3_dwi_bin_no-overlap_${subject}.nii.gz -mas PUL_${hemi}_Cluster5_dwi_bin_no-overlap_${subject}.nii.gz cluster3-5_overlap_${subject}
	time fslmaths cluster3-5_overlap_${subject}.nii.gz -bin -thr .0000000001 cluster3-5_overlap_${subject}_bin.nii.gz

	time fslmaths PUL_${hemi}_Cluster4_dwi_bin_no-overlap_${subject}.nii.gz -mas PUL_${hemi}_Cluster5_dwi_bin_no-overlap_${subject}.nii.gz cluster4-5_overlap_${subject}
	time fslmaths cluster4-5_overlap_${subject}.nii.gz -bin -thr .0000000001 cluster4-5_overlap_${subject}_bin.nii.gz



	time fslmaths PUL_${hemi}_Cluster1_dwi_bin_no-overlap_${subject}.nii.gz -sub cluster1-2_overlap_${subject}_bin.nii.gz -sub cluster1-3_overlap_${subject}_bin.nii.gz -sub cluster1-4_overlap_${subject}_bin.nii.gz -sub cluster1-5_overlap_${subject}_bin.nii.gz PUL_${hemi}_Cluster1_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz
	time fslmaths PUL_${hemi}_Cluster1_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz -bin -thr .0000000001 PUL_${hemi}_Cluster1_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz

	time fslmaths PUL_${hemi}_Cluster2_dwi_bin_no-overlap_${subject}.nii.gz -sub cluster1-2_overlap_${subject}_bin.nii.gz -sub cluster2-3_overlap_${subject}_bin.nii.gz -sub cluster2-4_overlap_${subject}_bin.nii.gz -sub cluster2-5_overlap_${subject}_bin.nii.gz PUL_${hemi}_Cluster2_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz
	time fslmaths PUL_${hemi}_Cluster2_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz -bin -thr .0000000001 PUL_${hemi}_Cluster2_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz

	time fslmaths PUL_${hemi}_Cluster3_dwi_bin_no-overlap_${subject}.nii.gz -sub cluster1-3_overlap_${subject}_bin.nii.gz -sub cluster2-3_overlap_${subject}_bin.nii.gz -sub cluster3-4_overlap_${subject}_bin.nii.gz -sub cluster3-5_overlap_${subject}_bin.nii.gz PUL_${hemi}_Cluster3_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz
	time fslmaths PUL_${hemi}_Cluster3_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz -bin -thr .0000000001 PUL_${hemi}_Cluster3_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz

	time fslmaths PUL_${hemi}_Cluster4_dwi_bin_no-overlap_${subject}.nii.gz -sub cluster1-4_overlap_${subject}_bin.nii.gz -sub cluster2-4_overlap_${subject}_bin.nii.gz -sub cluster3-4_overlap_${subject}_bin.nii.gz -sub cluster4-5_overlap_${subject}_bin.nii.gz PUL_${hemi}_Cluster4_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz
	time fslmaths PUL_${hemi}_Cluster4_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz -bin -thr .0000000001 PUL_${hemi}_Cluster4_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz

	time fslmaths PUL_${hemi}_Cluster5_dwi_bin_no-overlap_${subject}.nii.gz -sub cluster1-5_overlap_${subject}_bin.nii.gz -sub cluster2-5_overlap_${subject}_bin.nii.gz -sub cluster3-5_overlap_${subject}_bin.nii.gz -sub cluster4-5_overlap_${subject}_bin.nii.gz PUL_${hemi}_Cluster5_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz
	time fslmaths PUL_${hemi}_Cluster5_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz -bin -thr .0000000001 PUL_${hemi}_Cluster5_dwi_bin_no-overlap_noclusteroverlap_${subject}.nii.gz
done

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
