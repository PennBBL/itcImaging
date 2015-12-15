#Single subject
subjects=$(ls -d /import/monstrum/fndm2_new/subjects/*9467)
#Subject loop
#subjects=$(ls -d /import/monstrum/fndm2_new/subjects/*)

logdir=/import/monstrum/fndm2_new/progs/dico/logs/

rm -f ${logdir}/b0_calc_loop_no_b0map.txt
rm -f ${logdir}/b0_calc_loop_no_t1.txt
rm -f ${logdir}/b0_calc_loop_secondrun.txt

for s in $subjects; do

	echo ""
	echo "***********"
	echo $s
	

	#get scanid
	scanid=$(echo $s | cut -d/ -f6 | cut -d_ -f2)
	echo "scanid is $scanid"
	
	#check to see if output is present
	output=$(ls -d $s/b0map/${scanid}_t2star.nii 2> /dev/null)
	if [ -e "$output" ]; then
		echo "output already present-- skipping"
		continue
	fi
	
	echo ""
	#check if b0map directory exists; if not, make it
	b0dir=$(ls -d $s/b0map 2> /dev/null)
	if [ ! -d "$b0dir" ]; then
		echo "making b0map directory"
		mkdir $s/b0map
	fi

	#get list of b0dicoms
	b0dicoms=$(ls $s/*B0map_onesizefitsall*/dicoms/*.dcm)
	
	b0dicom_num=$(ls $s/*B0map_onesizefitsall*/dicoms/*.dcm | wc | awk '{print $1}')
	echo "total number of b0 dicoms is $b0dicom_num"

	if [ "$b0dicom_num" == 0 ]; then
		echo "no b0map dicoms are present!! exiting and logging"
		echo $s >> ${logdir}/b0_calc_loop_no_b0map.txt
		continue
	fi

	#find T1 head and T1 brain images
	t1head=$(ls $s/*mprage*/${scanid}_t1.nii.gz 2> /dev/null)
	t1brain=$(ls $s/*mprage*/${scanid}_t1_brain.nii.gz 2> /dev/null)

	echo ""
	if [ -e "$t1head" -a -e "$t1brain" ]; then
		echo "both t1head and t1 brain are present"
		echo $t1head
		echo $t1brain
	else
		echo "t1 head and/or t1 brain not found!! skipping & logging"
		echo $s >> ${logdir}/b0_calc_loop_no_t1.txt
	fi

	echo ""
	echo "running b0calc v3"
	echo $s >> ${logdir}/b0_calc_loop_secondrun.txt

	/import/monstrum/BBL_scripts/melliott.OLD/dico_b0calc_v3.sh -xmFS2 -T $t1head -B $t1brain $s/b0map/${scanid} $b0dicoms  
#note mark reccomends the x/m flags
#note that I did not bother to parallelize this for a grid as it only takes a couple minutes per subject and will be run only once
done


