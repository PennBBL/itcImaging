

#goal of this script is:

#1) to apply already-computed dramms warp and bbr coregstration so first level copes/varcopes are in standard space

#2) merge these and run a second level fixed effects analysis using a pre-specified design

#input from a loop script is an array of subject-level directories

#subjects=$1
#subjdir=$(cat $subjects|sed -n "${SGE_TASK_ID}p")  #only use for array jobs, comment out for non-grid testing


subjdir=$1  #normally comment out for non-grid testing

echo ""
cd $subjdir
pwd

#get scanid
scanid=$(echo $subjdir | cut -d/ -f6 | cut -d_ -f2)
echo "scanid is $scanid"

#define images necessary for all series
#struct=$(ls *_mprage/${scanid}_n3_maskstr_micobc.nii.gz)  #will need to be changed based on new naming
struct=$(ls *_mprage/${scanid}_t1_brain_micobc.nii.gz) #new naming for above
std=/import/monstrum/Applications/fsl5/data/standard/MNI152_T1_2mm_brain.nii.gz
#struct2std_def=$(ls *_mprage/${scanid}_n3_maskstr_micobc_to_mni2mm_warp.nii.gz 2> /dev/null)  #will need to be changed
struct2std_def=$(ls *_mprage/${scanid}_brain_micobc_to_mni2mm_warp.nii.gz 2> /dev/null)  #name changed
#featname=level1_stats_20130904.feat  #will need to be changed
featname=mag+del+task_level1_20140903.feat  #rk changed
regstddir=reg_dramms_mni2mm 
outdir=level2_fe_20150514/  #rk changed date
#level2design=/import/monstrum/day2_fndm/progs/card_face/level2design/level2design_20130904 #will need to be changed
level2design=/import/monstrum/fndm2_new/progs/ITC/level2design/level2design_20150514 #rk changed
mask=/import/monstrum/Applications/fsl5/data/standard/MNI152_T1_2mm_brain_mask.nii.gz #note that this is a cludge to avoid making a mask for each subject.. . . probably want to use the final group level mask

if [ ! -e "$struct2std_def" ]; then
	echo "no deformation to standard space found !!! exiting!!"
	exit 1
fi

if [ ! -e "$struct" ]; then
	echo "no structural image found! exiting!"
	exit 1
fi


#go by sequence: find each task sequence

serieslist=$(ls -d *itc*)  #note that does not log/check if certain functional sequences are missing-- do that at level of loop script

echo ""
echo "series list for this subject is:"
echo "$serieslist"


for s in $serieslist; do
	echo ""

	echo $s
	
	#find exmaple func
	exfunc=$(ls $s/prestats.feat/example_func.nii.gz)
        mask=$(ls $s/prestats.feat/mask.nii.gz)
	if [ ! -e "$exfunc" ] || [ ! -e "$mask" ]; then
		echo "mask or example func not found-- exiting"
		exit 1
	fi


	#copy exfunc to coreg directory (should have been done earlier)
	if [ ! -e "$s/coregistration/example_func_brain.nii.gz" ]; then
		cp $exfunc $s/coregistration
	fi

	#find coregistration
	affine=$(ls $s/coregistration/ep2struct.mat 2> /dev/null)	
	if [ ! -e "$affine" ]; then 
		echo "no coregistration found! exiting!"
		exit 1
	fi
	
	#concatenate & apply warp
	if [ ! -e "$s/coregistration/ep2mni2mm_warp.nii.gz" ]; then
		echo "concatenating warp and affine"
		/import/monstrum/Applications/dramms-1.4.0/bin/dramms-combine -c -f $exfunc -t $struct $affine $struct2std_def $s/coregistration/ep2mni2mm_warp.nii.gz 
	fi

	if [ ! -e "$s/coregistration/mask_to_mni2mm.nii.gz" ]; then
		echo "applying warp to mask & example func"
		/import/monstrum/Applications/dramms-1.4.0/bin/dramms-warp $exfunc $s/coregistration/ep2mni2mm_warp.nii.gz $s/coregistration/example_func_brain_to_mni2mm
                 /import/monstrum/Applications/dramms-1.4.0/bin/dramms-warp $mask $s/coregistration/ep2mni2mm_warp.nii.gz $s/coregistration/mask_to_mni2mm
	fi

	#apply to all copes
	featdir=$(ls -d $s/stats/${featname} 2> /dev/null)
	if [ ! -d "$featdir" ]; then
		echo "feat stats directory not present!! exiting!"
		exit 1
	fi

	#make output directory if needed
	if [ ! -d "$featdir/${regstddir}" ] ; then
		echo "making reg std dir"
		mkdir $featdir/${regstddir}
	fi	

	echo "output directory is $subjdir/$featdir/$regstddir"

	copelist=$(ls $featdir/stats/*cope*.nii.gz) # will include varcopes

	for c in $copelist; do
                copename=$(basename $c)
		if [ ! -e "$featdir/${regstddir}/${copename}" ]; then
			copename=$(basename $c)
			echo "moving $copename to standard space"
			/import/monstrum/Applications/dramms-1.4.0/bin/dramms-warp $c $s/coregistration/ep2mni2mm_warp.nii.gz $featdir/${regstddir}/${copename}
		else
			echo "$copename already present in standard space"
		fi
	done
done

echo ""
echo ""


#check to make sure all series are present
seriesnum=$(echo $serieslist | wc | awk '{print $2}')

if [ "$seriesnum" != 4 ]; then  #will need to edit if using a different number of runs
	echo "expecting four functional series, $seriesnum found! exiting!"
	exit 1
fi

#make second level output directory if not yet made
if [ ! -d "$outdir" ]; then
	echo "making output directory"
	mkdir $outdir
fi

echo "second level output directory is $subjdir/$outdir"

echo ""

#make mask
if [ ! -e "$outdir/mask.nii.gz" ]; then
	echo ""
	echo "making mask"
	#masklist=$(ls *{card,face}*/coregistration/mask_to_mni2mm.nii.gz)
	masklist=$(ls *itc*/coregistration/mask_to_mni2mm.nii.gz) #rkedited	
	fslmerge -t $outdir/mask_merged $masklist
	fslmaths $outdir/mask_merged -bin -Tmin $outdir/mask
	rm -f $outdir/mask_*.nii.gz
	echo ""
fi

#get number of copes from itc1
#imglist=$(ls *cardA*/stats/${featname}/${regstddir}/cope*.nii.gz)
imglist=$(ls *itc1*/stats/${featname}/${regstddir}/cope*.nii.gz) #rk edited
for i in $imglist; do
		echo ""
		img=$(basename $i | cut -d. -f1)
		echo $img
                imgnum=${img##cope} #get cope name here.
	
	if [ ! -e "$outdir/${img}/filtered_func_data.nii.gz" ]; then


                echo "merging copes and varcope for $img"


		#merge images-- note cannot merge by a unix-generated list as will sort by series number, which varies by subject due to counterbalencing
		#****anup you will want to change all this so merge copes and varcopes in order***
		#card_a_cope=$(ls *cardA*/stats/${featname}/${regstddir}/${img}.nii.gz)  
		#card_b_cope=$(ls *cardB*/stats/${featname}/${regstddir}/${img}.nii.gz)
		#face_a_cope=$(ls *faceA*/stats/${featname}/${regstddir}/${img}.nii.gz)
		#face_b_cope=$(ls *faceB*/stats/${featname}/${regstddir}/${img}.nii.gz)
		#fslmerge -t $outdir/${img}_merged $card_a_cope $card_b_cope $face_a_cope $face_b_cope

        	#card_a_varcope=$(ls *cardA*/stats/${featname}/${regstddir}/var${img}.nii.gz)
	        #card_b_varcope=$(ls *cardB*/stats/${featname}/${regstddir}/var${img}.nii.gz)
        	#face_a_varcope=$(ls *faceA*/stats/${featname}/${regstddir}/var${img}.nii.gz)
	        #face_b_varcope=$(ls *faceB*/stats/${featname}/${regstddir}/var${img}.nii.gz)
        	#fslmerge -t $outdir/var${img}_merged $card_a_varcope $card_b_varcope $face_a_varcope $face_b_varcope
		
		#edited by rk
		itc1_cope=$(ls *itc1*/stats/${featname}/${regstddir}/${img}.nii.gz)
                itc2_cope=$(ls *itc2*/stats/${featname}/${regstddir}/${img}.nii.gz)
                itc3_cope=$(ls *itc3*/stats/${featname}/${regstddir}/${img}.nii.gz)
                itc4_cope=$(ls *itc4*/stats/${featname}/${regstddir}/${img}.nii.gz)
                fslmerge -t $outdir/${img}_merged $itc1_cope $itc2_cope $itc3_cope $itc4_cope

                itc1_varcope=$(ls *itc1*/stats/${featname}/${regstddir}/var${img}.nii.gz)
                itc2_varcope=$(ls *itc2*/stats/${featname}/${regstddir}/var${img}.nii.gz)
                itc3_varcope=$(ls *itc3*/stats/${featname}/${regstddir}/var${img}.nii.gz)
                itc4_varcope=$(ls *itc4*/stats/${featname}/${regstddir}/var${img}.nii.gz)
                fslmerge -t $outdir/var${img}_merged $itc1_varcope $itc2_varcope $itc3_varcope $itc4_varcope
	else
		echo "images already merged"
	fi

	#run fixed effects model
	if [ ! -e "$outdir/$img/varcope4.nii.gz" ]; then #varcope 4 because only 4 contrasts in the second level design
		echo "running flameo fixed effects model"

		#anup you will want to have the .mat, .con, .grp files from your example 2nd level analysis that you ran.
		flameo --cope=$outdir/${img}_merged --varcope=$outdir/var${img}_merged --mask=$outdir/mask --dm=${level2design}.mat --tc=${level2design}.con --cs=${level2design}.grp --runmode=fe --ld=$outdir/$img
		mv $outdir/${img}_merged.nii.gz $outdir/$img/filtered_func_data.nii.gz
		mv $outdir/var${img}_merged.nii.gz $outdir/$img/var_filtered_func_data.nii.gz
	else
		echo "flameo already run!"
	fi

done
