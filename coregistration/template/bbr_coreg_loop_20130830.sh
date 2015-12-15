
#####
subj=$(ls -d /import/monstrum/day2_fndm/subjects/*/)  #AS: adjust for your directory scheme
logdir=/import/monstrum/day2_fndm/progs/coregistration/logs/ #adjust to your log dir
joblist=$logdir/coreg_joblist.txt #for array jobs  
outroot=MGH #will look within a series directory for .nii.gz file with this in the filename, card b is best as missing the least
 #AS: you will want to make this ITC4 I think.

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
	outfile=$(ls -d ${s}/*${outroot}/coregistration/ep2struct.nii.gz 2> /dev/null)

	if [ -e "$outfile" ]; then
		echo "output present-- skipping this subject"
		continue
	fi

	#check to see if t1brain image is present  #note that do not check prestats directories as are so many per subject-- check within script
	t1brain=$(ls ${s}/*mprage/*_n3_maskstr.nii.gz 2> /dev/null)  #you will want to adjust this for your T1 brain image.
	if [ ! -e "$t1brain" ]; then
		echo "t1 brain image not present, logging & skipping"
		echo $s >> $logdir/coreg_no_t1.txt
		continue
	fi

	#IF GOT TO HERE THEN ALL FILES THERE, ADD TO ARRAY JOB LIST
	echo $s >> $joblist  #comment out for non-grid testing


done

echo ""

ntasks=$(cat $joblist | wc -l)
echo "number of jobs in array is $ntasks"

#NOW SUBMIT TO SGE AS TASK ARRAY
qsub -V -q veryshort.q -S /bin/bash -o ~/sge_out -e ~/sge_out -t 1-${ntasks} /import/monstrum/fdm2_new/progs/coregistration/bbr_coreg_20130830.sh $joblist  #may need further adjustments including log path etc

