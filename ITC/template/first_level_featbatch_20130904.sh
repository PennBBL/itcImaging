
#identify card/face runs
#runs=/import/monstrum/day2_fndm/subjects/10410_6776/7_bbl1_cardA0_178/
runs=$(ls -d /import/monstrum/day2_fndm/subjects/18013_8532/*{card,face}*/)
featname=level1_stats_20130904
designdir=/import/monstrum/day2_fndm/progs/card_face/fsf_templates/
logdir=/import/monstrum/day2_fndm/progs/card_face/logs/
runlist=$logdir/level1_runlist.txt

#cleanup logs
rm -f $logdir/card_face_prestats_missing.txt
rm -f $logdir/card_face_presfile_missing.txt
rm -f $runlist

for r in $runs; do
	echo ""
	echo "************************"
	cd $r
	runpath=$r  #for more transparent naming

	#get run information
	bblid=$(echo $runpath | cut -d/ -f6 | cut -d_ -f1)
	scanid=$(echo $runpath | cut -d/ -f6 | cut -d_ -f2)
	run=$(basename $runpath)
	series=$(echo $run | cut -d_ -f1)
	tasktmp=$(echo $run | cut -d_ -f3 | cut -d0 -f1)
	task=${tasktmp%?}
	form=${tasktmp##$task}


	echo "subject is $bblid $scanid"
	echo "task $task form $form series $series"

	#check if output is present
	outfile=$(ls -d ${runpath}/stats/${featname}.feat/stats/res4d.nii.gz) # 2> /dev/null)
	if [ -e "$outfile" ]; then
		echo "output present-- skipping this subject!"
		continue
	fi

	#check if filtered_func_data from prestats is present
	prestats_file=$(ls $runpath/prestats.feat/filtered_func_data.nii.gz 2> /dev/null)
	if [ ! -e "$prestats_file" ]; then
		echo "prestats did not complete!! exiting and logging!"
		echo $scanid $task >> $logdir/card_face_prestats_missing.txt
		continue
	else 
		echo "prestats present"
	fi

	#check if behavioral data from presetntation is present
	presdir=$(ls -d /import/monstrum/day2_fndm/subjects/*_${scanid}/behavioral/pres/*${task}${form}* 2> /dev/null)
	if [ ! -d "$presdir" ]; then
		echo "processed presetnation data not present-- will log, skipping this subject"
		echo $scanid $task >> $logdir/card_face_presfile_missing.txt
		continue
	else 
		echo "presentation data present"
	fi
	
	#now replace variables in template design files
	cp $designdir/${featname}.fsf designtmp.fsf
	sed "s/XBBLIDX/$bblid/g" designtmp.fsf > designtmp2.fsf
	sed "s/XSCANIDX/$scanid/g" designtmp2.fsf > designtmp3.fsf
        sed "s/XSERIESX/$series/g" designtmp3.fsf > designtmp4.fsf	    
        sed "s/XTASKX/$task/g" designtmp4.fsf > designtmp5.fsf
        sed "s/XFORMX/$form/g" designtmp5.fsf > designtmp6.fsf
	    
	mv designtmp6.fsf ${featname}.fsf
	
	rm -f designtmp*.fsf
 	echo "running feat"	
	feat ${featname}.fsf
	
	echo $r >> $runlist

done
