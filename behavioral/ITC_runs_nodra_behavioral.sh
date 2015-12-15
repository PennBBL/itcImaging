### compiles all ITC runs into one file ###

#Single Subject
#runs=$(ls -d /import/monstrum/fndm2_new/subjects/100088_7944/behavioral/itc/RTG*.txt)

#Multi-Subject NODRA
runs=$(ls -d /import/monstrum/fndm2_new/subjects/*/behavioral/itc/RTG*.txt)

#runlist=/import/monstrum/fndm2_new/progs/behavioral/nodra_combine_running.txt

subjdir=/import/monstrum/fndm2_new/subjects

#rm -f $runlist

for r in $runs; do
	echo ""
	echo "******NEXT SUBJECT******"
	#get subject ID & series from path
	subjid=$(echo $r | cut -d/ -f6)
	subj=$(echo $r | cut -d/ -f9 | cut -d- -f2)
	series=$(echo $r | cut -d/ -f9 | cut -d- -f3 | cut -d. -f1)
	echo "subject is $subj"
	echo "run is $series"
	
	#if [ ${series} = 1 ] && [ -e "${subjdir}/${subjid}/behavioral/ITC_combined_${subj}--.txt" ]; then
		#rm -f ${subjdir}/${subjid}/behavioral/ITC_combined_${subj}--.txt
		#echo "** removing previously existing combined file **"
	#fi

cp ${subjdir}/${subjid}/behavioral/itc/RTG${series}_1ITCscanner1LLA-${subj}-${series}.txt ${subjdir}/${subjid}/behavioral/

	
#cat ${subjdir}/${subjid}/behavioral/itc/RTG${series}_1ITCscanner1LLA-${subj}-${series}.txt >> ${subjdir}/${subjid}/behavioral/ITC_combined_${subj}--.txt
	
	#chmod ugo+rwx ${subjdir}/${subjid}/behavioral/ITC_combined_${subj}--.txt

	#echo ${subj}_${series} >> $runlist
done
