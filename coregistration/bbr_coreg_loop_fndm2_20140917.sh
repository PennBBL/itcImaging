
#####
subj=$(ls -d /import/monstrum/fndm2_new/subjects/*_*/)  
logdir=/import/monstrum/fndm2_new/progs/coregistration/logs/
joblist=$logdir/coreg_joblist.txt #for array jobs  
outroot=itc2 #will look within a series directory for .nii.gz file with this in the filename, card b is best as missing the least
featname=sv_level1_20151120.feat

#cleanup logs
rm -f $joblist
rm -f $logdir/coreg_no_t1.txt

for s in $subj; do
	echo ""
	echo "*******"
	echo $s

	#get scan ID for identification of scan
	scanid=$(basename $s | cut -d_ -f2)

	#echo $scanid

	#check if output is present and skip subject if it is
	outfile=$(ls -d ${s}/*${outroot}*/coregistration/ep2struct.nii.gz) # 2> /dev/null)

	if [ -e "$outfile" ]; then
		echo "output present-- skipping this subject"
		continue
	fi

#check to see if t1brain image is present  #note that do not check prestats directories as are so many per subject-- check within script

	t1brain=$(ls ${s}/*mprage/${scanid}_t1.nii.gz 2> /dev/null)  

	if [ ! -e "$t1brain" ]; then

		#perhaps it is because of the new naming for NODRA?

		t1brain=$(ls ${s}/*_MPRAGE_TI1110_ipat2_moco3/${scanid}_t1.nii.gz)

		if [ ! -e "$t1brain" ]; then
			echo "t1 brain image not present, logging & skipping"
			echo $s >> $logdir/coreg_no_t1.txt
			continue
		fi
	fi
#check if stats were already run
	featname=sv_level1_20151120.feat
	featfile=$(ls -d ${s}/*${outroot}*/stats/${featname}/filtered_func_data.nii.gz)
	
	if [ ! -e "$featfile" ]; then
		echo "lower level feat has not been run. skipping this subject!"
		continue
	fi

#IF GOT TO HERE THEN ALL FILES THERE, ADD TO ARRAY JOB LIST
	echo "will run coregistration for subject $s"
	echo $s >> $joblist  #comment out for non-grid testing


done

echo ""

ntasks=$(cat $joblist | wc -l)
echo "number of jobs in array is $ntasks"

#NOW SUBMIT TO SGE AS TASK ARRAY
qsub -V -q veryshort.q -S /bin/bash -o ~/sge_out -e ~/sge_out -t 1-${ntasks} /import/monstrum/fndm2_new/progs/coregistration/bbr_coreg_fndm2_sv_20151202.sh $joblist 

