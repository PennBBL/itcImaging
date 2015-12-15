
#only input is a txt file as an array with the mprage folder
#runs 1) MICO, 2) FIRST, & 3) DRAMMS to 2mm MNI template
#segments a single subject using MICO v1.0rc4
#runs FIRST from FSL 5.0.1
#runs dramms v1.4

#note that only imput is mprage directory-- coded rather inflexibly for day2_fndm

#note that this script assumes that skull stripping has alraeady been done-- you will need to add a line where BET is run to execute skull stripping

#to call this script outside of the loop you do this:
#example:: ./struct_proc_20140708.sh /import/monstrum/day2_fndm/subjects/18013_8532/2_mprage

#subjects=$1
#mpragedir=$(cat $subjects|sed -n "${SGE_TASK_ID}p")  #only use for array jobs, comment out for non-grid testing

#mpragedir=$1  #for non-grid testing

mpragedir=/import/monstrum/fndm2_new/subjects/11801_5200/2_mprage

echo ""
cd $mpragedir
pwd

#get scanid
scanid=$(echo $mpragedir | cut -d/ -f6 | cut -d_ -f2)
echo "scanid is $scanid"

 
#define whole-head image
t1head=$(ls ${scanid}_t1.nii.gz)  #this is output of sequence2nifti.sh command
  	if [ ! -e "$t1head" ]; then
		echo "NO T1 WHOLE HEAD INPUT IMAGE PRESENT HERE-- EXITING!!!"
		exit 1
	fi
	 

#run bet to get brain-extracted image
t1brain=$(ls ${scanid}_t1_brain.nii.gz)

	if [ ! -e "${scanid}_t1_brain.nii.gz" ]; then 
		echo "performing bet"
		bet ${scanid}_t1.nii.gz ${scanid}_t1_brain.nii.gz
	fi
		echo ""

