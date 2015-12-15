
#identify ITC runs
#runs=/import/monstrum/fndm2_new/subjects/18382_9374/11_ep2d_itc1_168
runs=$(ls -d /import/monstrum/fndm2_new/subjects/*/*itc*)

featname=level1_stats_fndm2_sv_template_20151120
outputname=sv_level1_20151120
designdir=/import/monstrum/fndm2_new/progs/ITC/fsf_templates/
logdir=/import/monstrum/fndm2_new/progs/ITC/logs/
runlist=$logdir/level1_sv_runlist.txt

#cleanup logs
rm -f $logdir/itc_sv_presfile_missing.txt
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
	form=$(echo $run | cut -d_ -f3 | cut -dc -f2)
cd
	echo "subject is $bblid $scanid"
	echo "series $series run $form"

	#check if output is present
	outfile=$(ls -d ${runpath}/stats/${outputname}.feat/stats/res4d.nii.gz  2> /dev/null)
	if [ -e "$outfile" ]; then
		echo "output present-- skipping this subject!"
		continue
	fi

	#check if filtered_func_data from prestats is present
	#prestats_file=$(ls $runpath/prestats.feat/filtered_func_data.nii.gz 2> /dev/null)
	#if [ ! -e "$prestats_file" ]; then
#	echo "prestats did not complete!! exiting and logging!"
#		echo $scanid $task >> $logdir/itc_prestats_missing.txt
#		continue
#	else 
#		echo "prestats present"
#	fi

	#check if stick files from behavioral data is present
	presdir=$(ls -d /import/monstrum/fndm2_new/subjects/${bblid}_${scanid}/behavioral/*itc${form}_reg_missed.txt 2> /dev/null)
	if [ ! -e "$presdir" ]; then
		echo "processed stick file data not present-- will log, skipping this subject"
		echo "$presdir"
		echo $scanid >> $logdir/itc_sv_presfile_missing.txt
		continue
	else 
		echo "stick files present"
	fi

	#now replace variables in template design files
	cp $designdir/${featname}.fsf designtmp.fsf 
	sed "s/XBBLIDX/$bblid/g" designtmp.fsf > designtmp2.fsf
	sed "s/XSCANIDX/$scanid/g" designtmp2.fsf > designtmp3.fsf
        sed "s/XSERIESX/$series/g" designtmp3.fsf > designtmp4.fsf	    
        sed "s/XFORMX/$form/g" designtmp4.fsf > designtmp5.fsf
	    
	mv designtmp5.fsf ${featname}.fsf
	
	rm -f designtmp*.fsf
 	echo "running feat"	
	feat ${featname}.fsf
	
	echo $r >> $runlist



done
