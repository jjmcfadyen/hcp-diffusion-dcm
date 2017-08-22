#!/bin/sh

dir_subjects=INSERT
subjects=$(cat ${dir_subjects}/subjectlist.txt)

printf "\n~~~ Compute group average response function"
types=(_WM _GM _CSF)
for type in ${types[*]}
do 
	for subject in $subjects
	do
		echo "${dir_subjects}/${subject}/RF${type}.txt"
	done > textfiles${type}.txt
	typelist=$(<textfiles${type}.txt)
	time average_response $typelist average${type}.txt
done
