########EDITABLE PARAMETERS###########

#Single Subject
#runs=$(ls -d /import/monstrum/fndm2_new/subjects/10410_6843/*itc*/nifti/*_dico.nii.gz)
#Multi-Subject
runs=$(ls -d /import/monstrum/fndm2_new/subjects/*/*itc*/nifti/*_dico.nii.gz)

design=/import/monstrum/fndm2_new/progs/prestats/prestats_design_fndm2_20140826.fsf #find fsf template here
runlist=/import/monstrum/fndm2_new/progs/prestats/prestats_running.txt
#######
rm -f $runlist


for r in $runs; do
	echo ""
	echo "*******NEXT SUBJECT***********"
	
	#get subject ID & series from path
	subj=$(echo $r | cut -d/ -f6)
	bblid=$(echo $subj | cut -d_ -f1)
	scanid=$(echo $subj | cut -d_ -f2)
	series=$(echo $r | cut -d/ -f7)
	echo "subject is $subj"
	echo "series is $series"
	
	seriesdir=$(ls -d /import/monstrum/fndm2_new/subjects/${subj}/${series}/)
	outdir=${seriesdir}/prestats.feat/	
	
	#check if run
	output=$(ls ${outdir}/filtered_func_data.nii.gz 2> /dev/null)
	if [ -e "$output" ]; then
		echo "already run! skipping this run"
		continue
	fi

	

	#find/replace variables in .fsf file
	cd $seriesdir
	pwd	
	cp $design tmp.fsf



	sed "s/XBBLIDX/$bblid/g" tmp.fsf > tmp2.fsf
	sed "s/XSCANIDX/$scanid/g" tmp2.fsf > tmp3.fsf
	sed "s/XSERIESX/$series/g" tmp3.fsf > tmp4.fsf

	cp tmp4.fsf prestats_design.fsf
	echo "running feat now"
	echo $bblid >> $runlist
	feat prestats_design.fsf &
	rm -f tmp*.fsf

	
done
