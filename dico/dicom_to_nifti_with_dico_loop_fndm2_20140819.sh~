#loop scripts that creates grid array job
#first checks if each functional series that is expected is present


#####
subj=$(ls -d /import/monstrum/fndm2_new/subjects/*/)
logdir=/import/monstrum/fndm2_new/progs/dico/logs/
joblist=$logdir/dicom_to_nifti_with_dico_joblist.txt #for array jobs
series_check_flag=1 #if 1 will go through and check if each series exists, if 0 will not
outroot=ep2d_itc1_168 #will look within a series directory for .nii.gz file with this in the filename, itc1 is best as missing the least

#cleanup logs-- 
if [ "$series_check_flag" == 1 ]; then
	echo "deleting series check logs in prep for checking series from start"
	rm -f $logdir/dicom_to_nifti_with_dico_no_*bbl*.txt
		rm -f $logdir/dicom_to_nifti_with_dico_no_*ep2d*.txt
else 
	echo "not checking series this time"
fi


#cleanup other logs
rm -f $joblist
rm -f $logdir/dicom_to_nifti_with_dico_no_b0.txt

for s in $subj; do
	echo ""
	echo "*******"
	echo $s
	
	#get scan ID for identification of scan
	scanid=$(basename $s | cut -d_ -f2)
	#echo $scanid


	#check if rpsmap exists
	rpsmap=$(ls $s/b0map/${scanid}_rpsmap.nii 2> /dev/null)

	if [ ! -e "$rpsmap" ]; then
		echo "no rpsmap! logging and skipping this subject"
		echo $s >> $logdir/dicom_to_nifti_with_dico_no_b0.txt
		continue
	else
		echo "b0map present"
	fi


	#check series if specified to do so
	if [ "$series_check_flag" == 1 ]; then	
		echo ""
		echo "checking series presence"

		serieslist="ep2d_itc1_168 ep2d_itc2_168 ep2d_itc3_168 ep2d_itc4_168 ep2d_restbold_168"
		for series in $serieslist; do

			seriespath=$(ls -d $s/*${series})
			if [ ! -d "$seriespath" ]; then
				echo "no $series found!!!!"
				echo $s >> $logdir/dicom_to_nifti_with_dico_no_${series}.txt
			else
				echo "$series present"
			fi
		done
	fi

        #check if output is present and skip subject if it is
        outfile=$(ls -d ${s}/*${outroot}/nifti/*${outroot}*_dico.nii.gz 2> /dev/null)

        if [ -e "$outfile" ]; then
                echo "output present-- skipping this subject"
                continue
        fi

	#IF GOT TO HERE THEN ALL FILES THERE, ADD TO ARRAY JOB LIST
	echo $s >> $joblist  #comment out for non-grid testing
	

done

echo ""
	
ntasks=$(cat $joblist | wc -l)
echo "number of jobs in array is $ntasks"
			
#NOW SUBMIT TO SGE AS TASK ARRAY
qsub -V -q veryshort.q -S /bin/bash -o ~/sge_out -e ~/sge_out -t 1-${ntasks} /import/monstrum/fndm2_new/progs/dico/dicom_to_nifti_with_dico_fndm2_20140819.sh $joblist 
