#!/bin/bash

## creates stick files for subjects ##

input=eligible_runs.csv

cat $input | while IFS='	' read -r bblid scanid run1 run2 run3 run4

do 
	echo "bblid : ${bblid}"
	echo "scanid : ${scanid}"
	echo "run1 : ${run1}"
	echo "run2 : ${run2}"
	echo "run3 : ${run3}"
	echo "run4 : ${run4}"
		

 done


