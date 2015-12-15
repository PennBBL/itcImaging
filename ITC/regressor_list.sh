#!/bin/bash

base_dir=/import/monstrum/fndm2_new/progs/ITC/
sub_dir=/import/monstrum/fndm2_new/subjects

input=$(cat /import/monstrum/fndm2_new/progs/behavioral/fndm2_eligible_runs)
echo "Running file ${input}"

for line in $input
do
	scanid=$(echo $line | cut -d, -f1)
	bblid=$(echo $line | cut -d, -f2)
 	kvalue=$(echo $line | cut -d, -f3)
	r1=$(echo $line | cut -d, -f4)
        r2=$(echo $line | cut -d, -f5)
	r3=$(echo $line | cut -d, -f6)
	r4=$(echo $line | cut -d, -f7)

echo $scanid
echo $bblid
echo $kvalue
echo $r1
echo $r2 
echo $r3
echo $r4

echo "participant $bblid $scanid"
cd $sub_dir/${bblid}_${scanid}/behavioral/

if [ $r1 -eq 1 ]; then
	echo "creating regressors for run 1"
	matlab -nosplash -nodisplay -nojvm -r "/import/monstrum/fndm2_new/progs/ITC/fndm2_createregressor('0$scanid','$r1',$kvalue); quit()"
else
	echo "run 1 is not eligible"
fi

if [ $r2 -eq 2 ]; then
    	 echo "creating regressors for run 2"
	 matlab -nosplash -nodisplay -nojvm -r "/import/monstrum/fndm2_new/progs/ITC/fndm2_createregressor('0$scanid','$r2',$kvalue); quit()"
 
else
	echo "run 2 is not eligible"
fi
 
if [ $r3 -eq 3 ]; then
	echo "creating regressors for run 3"
        matlab -nosplash -nodisplay -nojvm -r "/import/monstrum/fndm2_new/progs/ITC/fndm2_createregressor('0$scanid','$r3',$kvalue); quit()"

else
	echo "run 3 is not eligible" 
fi
 
if [ $r4 -eq 4 ]; then
	echo "creating regressors for run 4"
        matlab -nosplash -nodisplay -nojvm -r "/import/monstrum/fndm2_new/progs/ITC/fndm2_createregressor('0$scanid','$r4',$kvalue); quit()"
 
else
	echo "run 4 is not eligible"
fi
 
cd $base_dir

done
 
