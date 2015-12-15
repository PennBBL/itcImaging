#SCRIPT GOALS
#write a bash scipt that loops through each MPRAGE folder
#runs fslcc to get the spatial correatlion between the output image (describe above) and the template image (MNI template)
#Put these results in a text file as part of the loop using the >> command
#Import these into R using read.table
#Make a histogram with hist()
#Identify outliers >2SD from the mean 

#SKILLS TO LEARN
#loops (loop through the folders)
#if statement (find the right mprage folder as in the processing loop)
#running fsl cc
#output commands a text file (>>)
#pulling a text file into R 
#identifying outliers in a distribution

#loop through MPRAGE folder, print subject all IDs
#####
subj=$(ls -d /import/monstrum/fndm2_new/subjects/*/)
outname=brain_micobc_to_mni2mm.nii.gz #name of last file created so can check if completed already
logdir=/import/monstrum/fndm2_new/progs/T1/logs/
fslccout=$logdir/fslccout.csv
std=/import/monstrum/Applications/fsl5/data/standard/MNI152_T1_2mm_brain.nii.gz #define template
####
#cleanup log
rm -f $fslccout

for s in $subj; do
	echo ""
	echo "*******"
	echo $s
	
	#get scan IDs
	scanid=$(basename $s | cut -d_ -f2)

	echo "scanid is $scanid"

	#find mprage series - confused why this is necessary
	mpragedir=$(ls -d $s/*mprage* 2> /dev/null)
	if [ ! -e "$mpragedir" ]; then
		mpragedir2=$(ls -d $s/*MPRAGE_TI1110_ipat2_moco3 2> /dev/null)
		mpragedir=$mpragedir2
#		if [ ! -e "$mpragedir2" ]; then
#			echo "mprage series missing!"
#			continue
#		fi
#	else
#		
#		echo "mprage series present"
	fi

	#check if output is present
	outfile=$(ls -d $mpragedir/${scanid}*${outname} 2> /dev/null)
	if [ -e "$outfile" ]; then
		echo "output present"
	else
		echo "no output found"
		continue
	fi

	#run fslcc
	echo "running fslcc"
	echo $outfile
	echo $std	
	corrVal=$(fslcc -p 10 $outfile $std)
	echo "$scanid,$corrVal" >> $fslccout
	#fslcc -p 10 $outfile $std >> $fslccout 

done
