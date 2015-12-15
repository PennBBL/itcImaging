runList=$(cat /import/monstrum/fndm2_new/progs/behavioral/fndm2_eligible_runs.csv)
firstLevel=sv_level1_20151120.feat
logdir=/import/monstrum/fndm2_new/progs/ITC/itcSeriesLogs
for r in $runList; do 
	echo ""

	#get scanid first

	scanid=$(echo $r | cut -d, -f1)

        echo "**************"
        echo "NEW SUBJECT SCANID $scanid"
        echo "**************"

	#check each run

	run1=$(echo $r | cut -d, -f4)
	echo $run1
	if [ "$run1" = "NaN" ]; then
		echo "run 1 not present or failed QA"
		run1Path=""
	else
		echo "run 1 present and will be included in second level anaylsis"
                run1Path=$(ls -d /import/monstrum/fndm2_new/subjects/*${scanid}/*_ep2d_itc1_168/stats/${firstLevel})
		echo $run1Path
		echo ""
	fi

        run2=$(echo $r | cut -d, -f5)
        echo $run2
        if [ "$run2" = "NaN" ]; then
                echo "run 2 not present or failed QA"
                run2Path=""
        else
                echo "run 2 present and will be included in second level anaylsis"
                run2Path=$(ls -d /import/monstrum/fndm2_new/subjects/*${scanid}/*_ep2d_itc2_168/stats/${firstLevel})
                echo $run2Path
                echo ""
        fi

        run3=$(echo $r | cut -d, -f6)
        echo $run3
        if [ "$run3" = "NaN" ]; then
                echo "run 3 not present or failed QA"
                run3Path=""
        else
                echo "run 3 present and will be included in second level anaylsis"
                run3Path=$(ls -d /import/monstrum/fndm2_new/subjects/*${scanid}/*_ep2d_itc3_168/stats/${firstLevel})
                echo $run3Path
		echo ""
        fi

        run4=$(echo $r | cut -d, -f7)
        echo $run4
        if [ "$run4" = "NaN" ]; then
                echo "run 4 not present or failed QA"
                run4Path=""
        else
                echo "run 4 present and will be included in second level anaylsis"
                run4Path=$(ls -d /import/monstrum/fndm2_new/subjects/*${scanid}/*_ep2d_itc4_168/stats/${firstLevel})
                echo $run4Path
                echo ""
        fi

	runlist="$run1Path $run2Path $run3Path $run4Path"
	#clear old version of list
	rm -f $logdir/${scanid}_runlist.txt
	echo "$runlist" >> $logdir/${scanid}_runlist.txt
	echo $runlist
	numruns=$(echo $runlist | wc | awk '{ print $2 }')

	echo""

	echo "looks like there are $numruns runs present for this subject!!"
	echo "RUNNING THIS SUBJECT"
	echo "********"
	echo ""	
	/import/monstrum/fndm2_new/progs/ITC/dramms_reg_apply_and_level2_fe_sv_20151120.sh $scanid $numruns 

#	exit 0
done
	

