#####
subj=$(ls -d /import/monstrum/day2_fndm/subjects/18013_8532/) #edit accordingly
logdir=/import/monstrum/day2_fndm/progs/card_face/logs/ #edit log directory
joblist=$logdir/level2_joblist.txt #for array jobs
outfile=level2_fe_20130904//mask.nii.gz  #change to 2nd level FSF name
featname=level1_stats_20130904.feat  #change to your actual 1st level feat name
#cleanup logs
rm -f $joblist
rm -f $logdir/level2_stats_missing.txt
rm -f $logdir/level2_struct_or_def_missing.txt

for s in $subj; do
	echo ""
	echo "*******"
	echo $s

	#get scan ID for identification of scan
	scanid=$(basename $s | cut -d_ -f2)
	#echo $scanid

	#check if output is present and skip subject if it is

	if [ -e "$s/$outfile" ]; then
		echo "output present-- skipping this subject"
		continue
	fi

	#check that are 4 functional series with stats run
	statsnum=$(ls $s/*itc*/stats/${featname}/stats/res4d.nii.gz | wc  | awk '{print $1}')
	
	if [ "$statsnum" != 4 ]; then
		echo "expecting four stats directories, only $statsnum found!  will log and skip this subj"
		echo $s >> $logdir/level2_stats_missing.txt
		continue
	fi

	#check that there are 4 affine coregistration matricies 
	affinenum=$(ls $s/*{card,face}*/coregistration/ep2struct.mat | wc  | awk '{print $1}')

	 if [ "$affinenum" != 4 ]; then
                echo "expecting four affine matricies, only $affinenum found!  will log and skip this subj"
                echo $s >> $logdir/level2_coreg_missing.txt
                continue
         fi

	#check that deformation & T1 brain are present
	def=$(ls $s/*_mprage/${scanid}_n3_maskstr_micobc_to_mni2mm_warp.nii.gz 2> /dev/null)  #you willneed to change these
	struct=$(ls $s/*_mprage/${scanid}_n3_maskstr_micobc.nii.gz 2> /dev/null)  #change also
	if [ ! -e "$def" ] || [ ! -e "$struct" ]; then
		echo "either t1 or t1->std deformation not present-- logging and skipping this subj"
		echo $s >> $logdir/level2_struct_or_def_missing.txt
	fi


	#IF GOT TO HERE THEN ALL FILES THERE, ADD TO ARRAY JOB LIST
#	echo $s >> $joblist  #comment out for non-grid testing

	#comment out below for running on grid
	/import/monstrum/fndm2_new/progs/ITC/dramms_reg_apply_and_level2_fe_20130905.sh $s  #check path to make sure this is right
done

echo ""

ntasks=$(cat $joblist | wc -l)
echo "number of jobs in array is $ntasks"

#NOW SUBMIT TO SGE AS TASK ARRAY
qsub -V -q veryshort.q -S /bin/bash -o ~/sge_out -e ~/sge_out -t 1-${ntasks} /import/monstrum/fndm2_new/progs/itc/dramms_reg_apply_and_level2_fe_20130905.sh $joblist
