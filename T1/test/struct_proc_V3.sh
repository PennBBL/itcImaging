
#only input is a txt file as an array with the mprage folder
#runs 1) MICO, 2) FIRST, & 3) DRAMMS to 2mm MNI template
#segments a single subject using MICO v1.0rc4
#runs FIRST from FSL 5.0.1
#runs dramms v1.4

#note that only imput is mprage directory-- coded rather inflexibly for day2_fndm

#ANUP!!:  note that this script assumes that skull stripping has alraeady been done-- you will need to add a line where BET is run to execute skull stripping

#to call this script outside of the loop you do this:
#example:: ./struct_proc_20140708.sh /import/monstrum/day2_fndm/subjects/18013_8532/2_mprage

#subjects=$1
#mpragedir=$(cat $subjects|sed -n "${SGE_TASK_ID}p")  #only use for array jobs, comment out for non-grid testing

#mpragedir=$1  #for non-grid testing

mpragedir=/import/monstrum/fndm2_new/subjects/10410_6843/2_mprage

echo ""
cd $mpragedir
pwd

#get scanid
scanid=$(echo $mpragedir | cut -d/ -f6 | cut -d_ -f2)
echo "scanid is $scanid"

#anup you will first add bit where you convert dicom to nifti 
for m in $mpragedir; do
        cd $m
        echo ""
        pwd

        #get scanid
        scanid=$(echo $m | cut -d/ -f6 | cut -d_ -f2)
        echo "scanid is $scanid"

        if [ ! -e "${scanid}_t1.nii" ]; then
                echo "converting to nii"
                /import/speedy/scripts/melliott/sequence2nifti.sh STRUCTURAL_RPI ${scanid}_t1 dicoms/*.dcm
                fslchfiletype NIFTI_GZ ${scanid}_t1
		rm -f "${scanid}_t1.nii"
        fi
 	       
 
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


#MICO: segment T1 image if not already done

#check out: Li, C., Gore, J.C., and Davatzikos, C. (2014). Multiplicative Intrinsic Component Optimization (MICO) for MRI Bias Field Estimation and Tissue Segmentation. Magn Reson Imaging 

mico_out=$(ls ${scanid}_n3_maskstr_micoseg.nii.gz 2> /dev/null)
	if [ ! -e "$mico_out" ]; then
		echo "running MICO segmentation"
		/import/monstrum/Applications/sbia/mico/bin/mico --bias-correct --bias-correct-suffix _micobc --suffix _micoseg --fuzzy --fuzzy-suffix _micoprob $t1brain 
	fi
       
mico_out=$(ls ${scanid}_t1_brain_micoseg.nii.gz 2> /dev/null) 
	if [ ! -e "$mico_out" ]; then
		echo "mico output not present-- it must have failed-- exiting!!"
		exit 1 
	else
 
		echo "MICO already run-- skipping"
	
	fi

#save individual image segments
wm=$(ls ${scanid}_n3_maskstr_mico_wm.nii.gz) 
	if [ ! -e "$wm" ]; then
		echo "creating individual segment images"
		fslmaths $mico_out -thr 10 -uthr 10 -bin ${scanid}_brain_mico_csf.nii.gz
		fslmaths $mico_out -thr 150 -uthr 150 -bin ${scanid}_brain_mico_gm.nii.gz
		fslmaths $mico_out -thr 250 -uthr 250 -bin ${scanid}_brain_mico_wm.nii.gz
	else
		echo "MICO tissues segments present"
	fi

		echo ""

#run FIRST on whole-head images
#firstdir=$(ls -d first 2> /dev/null)
#if [ ! -d "$firstdir" ]; then
#	echo "making first directory"
#	mkdir first
#fi

#check if first has run
#first_out=$(ls -d first/${scanid}_subcort_all_fast_firstseg.nii.gz 2> /dev/null )
#if [ ! -e "$first_out" ]; then
#	echo "running first"
#	#note that this auto-submits to grid-- will fork off separate process, means that cannot compute stats on these vols from within this script
#	run_first_all -i $t1head -o first/${scanid}_subcort
#else
#	echo "first already run-- skipping this step"
#fi

echo ""

#check if dramms has been run
dramms_out=$(ls -d ${scanid}_brain_micobc_mni2mm_ravens_250.nii.gz 2> /dev/null)

	if [ ! -e "$dramms_out" ]; then

	#define template
	std=/import/monstrum/Applications/fsl5/data/standard/MNI152_T1_2mm_brain.nii.gz 

	#define input impage-- use MICO corrected image
	t1brain_mico=$(ls ${scanid}_t1_brain_micobc.nii.gz 2> /dev/null)
	if [ ! -e "$t1brain_mico" ]; then
		echo " NO MICO CORRECTED IMAGE-- EXITING!"
		exit 1
	fi
	
	#check out dramms tutorial: http://www.cbica.upenn.edu/sbia/software/dramms/
	#check out: Ou, Y., Sotiras, A., Paragios, N., and Davatzikos, C. (2011). DRAMMS: Deformable registration via attribute matching and mutual-saliency weighting. Med Image Anal 15, 622-639.

	#calculate deformation T1 to MNI
	echo "running dramms-- calculating T1 to MNI warp"
	/import/monstrum/Applications/dramms-1.4.0/bin/dramms -S $t1brain_mico -T $std -D ${scanid}_brain_micobc_to_mni2mm_warp -O ${scanid}_brain_micobc_to_mni2mm -J ${scanid}_brain_micobc_to_mni2mm_jac

	#calculate MNI to T1 deformation and make ravens maps
	echo "calculating ravens maps via MNI to T1 warp"
	/import/monstrum/Applications/dramms-1.4.0/bin/dramms -S $t1brain_mico -T $std -D ${scanid}_mni2mm_to_brain_micobc_warp  -O ${scanid}_mni2mm_to_brain_micobc -R ${scanid}_brain_micobc_mni2mm_ravens -L $mico_out -l 10,150,250

else
	echo "dramms already complete"

fi
done
