#####
subj=$(ls -d /import/monstrum/fndm2_new/subjects/18013_8549/) #single subject
#subj=$(ls -d /import/monstrum/fndm2_new/subjects/*/) 
logdir=/import/monstrum/fndm2_new/progs/ITC/logs/ #edit log directory
joblist=$logdir/level2_joblist.txt #for array jobs
outfile=level2_fe_sv_20151120/mask.nii.gz  #change to 2nd level FSF name
featname=sv_level1_20151120.feat  #change to your actual 1st level feat name
subjdir=/import/monstrum/fndm2_new/subjects/
#cleanup logs
rm -f $joblist
rm -f $joblist2
rm -f $logdir/level2_stats_missing.txt
rm -f $logdir/level2_struct_or_def_missing.txt

#read in list of eligible subjects and runs
input=$(cat /import/monstrum/fndm2_new/progs/behavioral/fndm2_eligible_runs.csv)
echo "Running file ${input}"

#extract relevant information
for line in $input
do
        scanid=$(echo $line | cut -d, -f1)
        bblid=$(echo $line | cut -d, -f2)
        kvalue=$(echo $line | cut -d, -f3)
        r1=$(echo $line | cut -d, -f4)
        r2=$(echo $line | cut -d, -f5)
        r3=$(echo $line | cut -d, -f6)
        r4=$(echo $line | cut -d, -f7)
        total=$(echo $line | cut -d, -f8)

s=${subjdir}/${bblid}_${scanid}

#for s in $subj; do
#	echo ""
	echo "*******"
	echo $s

#	#get scan ID for identification of scan
#	scanid=$(basename $s | cut -d_ -f2)
	#echo $scanid

	#check if output is present and skip subject if it is
	if [ -e "$s/$outfile" ]; then
		echo "output present-- skipping this subject"
		continue
	fi

	#check that all eligible runs have functional series with stats run
	statsnum=$(ls $s/*itc*/stats/${featname}/stats/res4d.nii.gz | wc  | awk '{print $1}')
	
	if [ "$statsnum" != $total ]; then
		echo "expecting $total stats directories, only $statsnum found!  will log and skip this subj"
		echo $s >> $logdir/level2_stats_missing.txt
		continue
	fi

	#check that all eligible runs have coregistration matricies 
 	affinenum=$(ls $s/*itc*/coregistration/ep2struct.mat | wc  | awk '{print $1}') 
	 if [ "$affinenum" != $total ]; then
                echo "expecting four affine matricies, only $affinenum found!  will log and skip this subj"
                echo $s >> $logdir/level2_coreg_missing.txt
		continue
         fi

	#check that deformation & T1 brain are present
	#def=$(ls $s/*_mprage/${scanid}_n3_maskstr_micobc_to_mni2mm_warp.nii.gz 2> /dev/null)  #you willneed to change these
	#struct=$(ls $s/*_mprage/${scanid}_n3_maskstr_micobc.nii.gz 2> /dev/null)  #change also
	def=$(ls $s/*_mprage/${scanid}_brain_micobc_to_mni2mm_warp.nii.gz 2> /dev/null)
        if [ ! -e "$def" ]; then
        echo "looking for MPRAGE w/ NODRA naming"
        def=$(ls *_MPRAGE_TI1110_ipat2_moco3/${scanid}_t1_brain_micobc_to_mni2mm_warp.nii.gz)
	fi

	struct=$(ls $s/*_mprage/${scanid}_t1_brain_micobc.nii.gz)
if [ ! -e "$struct" ]; then
        #echo "looking for MPRAGE w/ NODRA naming"
        struct=$(ls *_MPRAGE_TI1110_ipat2_moco3/${scanid}_t1_brain_micobc.nii.gz)
	fi
	if [ ! -e "$def" ] || [ ! -e "$struct" ]; then
		echo "either t1 or t1->std deformation not present-- logging and skipping this subj"
		echo $s >> $logdir/level2_struct_or_def_missing.txt
	fi


	#IF GOT TO HERE THEN ALL FILES THERE, ADD TO ARRAY JOB LIST
#	echo $s >> $joblist  #comment out for non-grid testing
#	echo $total >> $joblist2

	#comment out below for running on grid
 	/import/monstrum/fndm2_new/progs/ITC/dramms_reg_apply_and_level2_fe_sv_20151120.sh $s $total
 
done

echo ""

ntasks=$(cat $joblist | wc -l)
echo "number of jobs in array is $ntasks"

#NOW SUBMIT TO SGE AS TASK ARRAY
qsub -V -q veryshort.q -S /bin/bash -o ~/sge_out -e ~/sge_out -t 1-${ntasks} /import/monstrum/fndm2_new/progs/ITC/dramms_reg_apply_and_level2_fe_20151120.sh $joblist $joblist2
