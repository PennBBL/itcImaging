
#####
subj=$(ls -d /import/monstrum/fndm2_new/subjects/*/)
logdir=/import/monstrum/fndm2_new/progs/T1/logs/
joblist=$logdir/mico_drams_subjlist.txt #for array jobs
#outname=/first/3931_subcort_all_fast_firstseg.nii.gz  #to check first output separately
outname=brain_micobc_mni2mm_ravens_250.nii.gz #name of last file created so can check if completed already
sge_log_dir=/import/monstrum/fndm2_new/progs/T1/sge_logs
####

#cleanup logs-- 
rm -f $logdir/mprage_series_missing.txt 
rm -f $logdir/t1brain_missing.txt
rm -f $logdir/t1head_missing.txt
rm -f $joblist

for s in $subj; do
	echo ""
	echo "*******"
	echo $s
	
	#get scan ID for identification of scan
	scanid=$(basename $s | cut -d_ -f2)

	#echo $scanid

	#check if mprage series exists
	mpragedir=$(ls -d $s/*mprage* 2> /dev/null)
	if [ ! -e "$mpragedir" ]; then
		echo "mprage series missing! logging and skipping this subject"
		echo $s >> $logdir/mprage_series_missing.txt
		continue
	else
		echo "mprage series present"
	fi

	#check if T1 head present

	t1head=$(ls ${mpragedir}/${scanid}_t1.nii.gz)
	if [ ! -e "$t1head" ]; then
		echo "NO T1 WHOLE HEAD INPUT IMAGE PRESENT HERE-- SKIPPING & LOGGING!!!"
		echo $scanid >> $logdir/t1head_missing.txt
		continue	
	fi


	#check if output is present and skip subject if it is
	outfile=$(ls -d $mpragedir/${scanid}_${outname} 2> /dev/null)

	if [ -e "$outfile" ]; then
		echo "output present-- skipping this subject"
		continue
	fi

	#IF GOT TO HERE THEN ALL FILES THERE, ADD TO ARRAY JOB LIST
	echo $mpragedir >> $joblist  #comment out for non-grid testing

	done
	
ntasks=$(cat $joblist | wc -l)
echo $ntasks
			
#NOW SUBMIT TO SGE AS TASK ARRAY
qsub -V -q all.q -S /bin/bash -o $sge_log_dir -e $sge_log_dir -t 1-${ntasks} /import/monstrum/fndm2_new/progs/T1/struct_proc_V6.sh $joblist  #I forgot what "-V" does.   #S is for your environmen variables
#-o and -e are for output fies  -- you want the directory to exist.  #-e is errors from the program, -o is non-error output.  Here one of these ouptut (text) files will exist for every item in the array job you are calling.  

#for debugging i would NOT use qsub-- just would put /import/monstrum/fndm2_new/progs/T1/struct_proc_V6.sh $mpragedir in the loop above

#but! have to adjust the script being called to comment out the qsub array job lingo and make sure it is taking the right variable w/o qsub

#also if you DON'T want to use qsub, try screen: http://aperiodic.net/screen/quick_reference

