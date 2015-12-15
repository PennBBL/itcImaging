###creates output to calculate correlations in coregistration ####

#Single Subject
#runs=$(ls -d /import/monstrum/fndm2_new/subjects/10410_6843/*itc*)

#Multi-Subject
runs=$(ls -d /import/monstrum/fndm2_new/subjects/*_*/*itc*)

subjdir=/import/monstrum/fndm2_new/subjects

coregmissed=/import/monstrum/fndm2_new/progs/coregistration/coreg_missed.txt
runlist=/import/monstrum/fndm2_new/progs/coregistration/fslcc_QA.txt

rm -f $runlist
rm -f $coregmissed

for r in $runs; do
	echo ""
	echo "****NEXT SUBJECT****"
	#get subject ID & run from path
	
	subj=$(echo $r | cut -d/ -f6)
	scanid=$(echo $r | cut -d/ -f6 | cut -d_ -f2)
	series=$(echo $r | cut -d/ -f7 | cut -d_ -f3)
	echo "subject is $scanid"
	echo "run is $series"

	outdir=${r}/coregistration
	featdir=${r}/stats/sv_level1_20151120.feat
	

	#check if feat run
	if [ ! -e "$featdir" ]; then
		echo "feat not run because of eligibility! skipping this run"
		continue
	fi

	#check if coregistration run
	output=$(ls ${outdir}/ep2struct.nii.gz 2> /dev/null)

	if [ ! -e "$output" ]; then
		echo "coregistration not completed! logging this file"
		echo	$scanid $serires  >> $coregmissed
		continue
	fi

	# run fslcc list
	mpragedir=$(ls -d ${subjdir}/${subj}/*_mprage 2> /dev/null)
	if [ ! -e "$mpragedir" ]; then
		echo "checking NODRA format for structural scan"
		mpragedir=$(ls -d ${subjdir}/${subj}/*_MPRAGE_TI1110_ipat2_moco3 2> /dev/null)
	fi
	if [ ! -e "$mpragedir" ]; then	
		echo "mprage not found. exiting!!"
		continue
	fi
	echo "coregistration file is ${outdir}/ep2struct.nii.gz"
	echo "structural image file is ${mpragedir}/${scanid}_t1_brain.nii.gz"
	QA=$(fslcc ${outdir}/ep2struct.nii.gz ${mpragedir}/${scanid}_t1_brain.nii.gz)
	
	echo $scanid $series $QA>>$runlist
	

done
