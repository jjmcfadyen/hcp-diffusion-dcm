#!/bin/sh

dir_tck=/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Results/SIFT2/
dir_sift=/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Results/SIFT2/
dir_save=/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Results/ROI_SeedTractography

for track in SC-PUL PUL-SC PUL-AMY AMY-PUL; do
	for hemi in l r; do

		cd ${dir_save}
		> ${track}_${hemi}.txt

		cd ${dir_tck}/${track}
		list=$(ls ${track}_${hemi}*.tck)
		for file in $list; do
			echo "Calculating mean path length of ${file}..."
			prefix="endsonly_"
			fname=${file#$prefix}
			fname=$(basename $fname .tck)
			stats=$(tckstats ${file})
			stats=$(echo $stats | cut -c36-)	# stats starts with "mean median std. dev. min max count " which si 36 characters long
			subject=$(echo ${file} | tr -dc '0-9')
			if [ -z "$stats" ]; then
				echo "$subject  0 0 0 0 0 0" >> ${dir_save}/${track}_${hemi}.txt
				echo "                                                       [[[No data for $subject $track $hemi...]]]]"
			else
				echo "$subject $stats" >> ${dir_save}/${track}_${hemi}.txt
				echo "                                                       Writing $subject $track $hemi..."
			fi
		done
	done
done
