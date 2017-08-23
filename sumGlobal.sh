## Get streamline count for track types
dir_results=/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Results/Global
for tcktype in SC-PUL PUL-AMY; do
	cd ${dir_results}/endsonly/${tcktype}
	rm -rf ${dir_results}/${tcktype}/count_*
	for i in *.tck; do
		filename=$(basename ${i} .tck)
		count=$(tckinfo ${i}  | sed '3!d' | grep -Eo '[0-9]')
		count=$(echo $count | tr -d ' ')
		subject=$(echo $filename | egrep -o [0-9]+ | tail -c 7)
		tckname=$(basename ${i} _${subject}.tck)
		echo "Writing streamline count ${count} for ${tckname}, ${subject}..."
		echo "$subject $count" >> ${dir_results}/endsonly/${tcktype}/count_${tckname}.txt
	done
done
