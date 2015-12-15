#note that this script run only on a subset of subjects.  Other T1's used xnat dicom2nifti.  

mpragedirs=/import/monstrum/fndm2_new/subjects/*_*/*_mprage/
#mpragedirs=$(cat /import/monstrum/day2_fndm/subject_lists/mprages_to_convert.txt)
for m in $mpragedirs; do
	cd $m
	echo ""
	pwd
	
	#get scanid
	scanid=$(echo $m | cut -d/ -f6 | cut -d_ -f2)
	echo "scanid is $scanid"
	
	
	if [ ! -e "${scanid}_t1.nii" ]; then	
		echo "converting to nii"
		/import/speedy/scripts/melliott/sequence2nifti.sh STRUCTURAL_RPI ${scanid}_t1 dicoms/*.dcm
		fslchfiletype NIFTI_GZ ${scanid}_t1
	fi
done
