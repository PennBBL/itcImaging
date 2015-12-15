

#goal of this script is:

#1) to apply already-computed dramms warp and bbr coregstration so first level copes/varcopes are in standard space

#2) merge these and run a second level fixed effects analysis using a pre-specified design

#input from a loop script is an array of subject-level directories

#subjects=$1  #expects root subject path i.e., /import/monstrum/fnd2_new/subjects/bblid_scanid
#subjdir=$(cat $subjects|sed -n "${SGE_TASK_ID}p")  #only use for array jobs, comment out for non-grid testing


scanid=$1  #normally comment out for non-grid testing
total=$2 #number of runs

####ECHO ARGUMENTS###
echo "working on subject $scanid"
echo "expecting $total total number of runs"
######################


####FIXED ARGUMENTS###
std=/import/monstrum/Applications/fsl5/data/standard/MNI152_T1_2mm_brain.nii.gz
featname=sv_level1_20151120.feat   #could make this an argument if needed
regstddir=reg_dramms_mni2mm
outdir=level2_fe_sv_20151120/
mask=/import/monstrum/Applications/fsl5/data/standard/MNI152_T1_2mm_brain_mask.nii.gz #note that this is a cludge to avoid making a mask for each subject.. . . probably want to use the final group level mask
logdir=/import/monstrum/fndm2_new/progs/ITC/itcSeriesLogs

subjdir=$(ls -d /import/monstrum/fndm2_new/subjects/*${scanid})
cd $subjdir

#define images necessary for all series
struct=$(ls *_mprage/${scanid}_t1_brain_micobc.nii.gz) 
if [ ! -e "$struct" ]; then
	echo "looking for MPRAGE w/ NODRA naming"
	struct=$(ls *_MPRAGE_TI1110_ipat2_moco3/${scanid}_t1_brain_micobc.nii.gz)
fi

struct2std_def=$(ls *_mprage/${scanid}_brain_micobc_to_mni2mm_warp.nii.gz 2> /dev/null) 
if [ ! -e "$struct2std_def" ]; then
        #echo "looking for MPRAGE w/ NODRA naming"
        struct2std_def=$(ls *_MPRAGE_TI1110_ipat2_moco3/${scanid}_t1_brain_micobc_to_mni2mm_warp.nii.gz)
fi

if [ ! -e "$struct2std_def" ]; then
        echo "no deformation to standard space found !!! exiting!!"
        exit 1
fi

if [ ! -e "$struct" ]; then
        echo "no structural image found! exiting!"
        exit 1
fi


#determine number of inputs for level2 design
if [ "$total" = 2 ]; then
	level2design=/import/monstrum/fndm2_new/progs/ITC/level2design/level2design_2
elif [ "$total" = 3 ]; then
	level2design=/import/monstrum/fndm2_new/progs/ITC/level2design/level2design_3
elif [ "$total" = 4 ]; then
	level2design=/import/monstrum/fndm2_new/progs/ITC/level2design/level2design_4
else 
	echo "something has gone wrong! exiting!"
	exit 1	
fi



###GET SERIES LIST##
seriesFile=$(ls $logdir/${scanid}_runlist.txt)

seriesList=$(cat $seriesFile) 

echo "series to work with here are: $seriesList"

echo ""

echo "******"
echo "applying registrations for each series"

## setting up variables##

maskname1=""
maskname2=""
maskname3=""
maskname4=""
copeitc1=""
copeitc2=""
copeitc3=""
copeitc4=""
varcopeitc1=""
varcopeitc2=""
varcopeitc3=""
varcopeitc4=""

for s in $seriesList; do
	echo ""

	echo $s
	
	rundir=$(echo $s | cut -d/ -f7)
	runnum=$(echo $rundir | cut -d_ -f3 | cut -dc -f2)
	echo $runnum

	#find example func
	exfunc=$(ls $s/example_func.nii.gz)
        mask=$(ls $s/mask.nii.gz) 
	if [ ! -e "$exfunc" ] || [ ! -e "$mask" ]; then
		echo "mask or example func not found-- exiting"
		exit 1
	fi


	#copy exfunc to coreg directory (should have been done earlier)
	if [ ! -e "$rundir/coregistration/example_func_brain.nii.gz" ]; then
		cp $exfunc $s/coregistration
	fi

	#find coregistration
	affine=$(ls $rundir/coregistration/ep2struct.mat 2> /dev/null)	
	if [ ! -e "$affine" ]; then 
		echo "no coregistration found! exiting!"
		exit 1
	fi
	
	#concatenate & apply warp
	if [ ! -e "$rundir/coregistration/ep2mni2mm_warp.nii.gz" ]; then
		echo "concatenating warp and affine"
		/import/monstrum/Applications/dramms-1.4.0/bin/dramms-combine -c -f $exfunc -t $struct $affine $struct2std_def $rundir/coregistration/ep2mni2mm_warp.nii.gz 
	fi

	if [ ! -e "$rundir/coregistration/mask_to_mni2mm.nii.gz" ]; then
		echo "applying warp to mask & example func"
		/import/monstrum/Applications/dramms-1.4.0/bin/dramms-warp $exfunc $rundir/coregistration/ep2mni2mm_warp.nii.gz $rundir/coregistration/example_func_brain_to_mni2mm
                 /import/monstrum/Applications/dramms-1.4.0/bin/dramms-warp $mask $rundir/coregistration/ep2mni2mm_warp.nii.gz $rundir/coregistration/mask_to_mni2mm
	fi

	#apply to all copes
	featdir=$(ls -d $s 2> /dev/null)
	if [ ! -d "$featdir" ]; then
		echo "feat stats directory not present!! exiting!"
		exit 1
	fi

	#make output directory if needed
	if [ ! -d "$featdir/${regstddir}" ] ; then
		echo "making reg std dir"
		mkdir $featdir/${regstddir}
	fi	

	echo "output directory is $featdir/$regstddir"

	copelist=$(ls $featdir/stats/*cope*.nii.gz) # will include varcopes
	
	for c in $copelist; do
                copename=$(basename $c)
		if [ ! -e "$featdir/${regstddir}/${copename}" ]; then
			copename=$(basename $c)
			echo "moving $copename to standard space"
			/import/monstrum/Applications/dramms-1.4.0/bin/dramms-warp $c $rundir/coregistration/ep2mni2mm_warp.nii.gz $featdir/${regstddir}/${copename}
		else
			echo "$copename already present in standard space"
		fi
	done
	# find specific files for merging later
	if [ $runnum == 1 ]; then
		maskname1=$rundir/coregistration/mask_to_mni2mm.nii.gz
	fi

        if [ $runnum == 2 ]; then
                maskname2=$rundir/coregistration/mask_to_mni2mm.nii.gz
	fi

        if [ $runnum == 3 ]; then
                maskname3=$rundir/coregistration/mask_to_mni2mm.nii.gz
        fi

        if [ $runnum == 4 ]; then
                maskname4=$rundir/coregistration/mask_to_mni2mm.nii.gz
        fi
done

echo ""
echo ""


#check to make sure all series are present
seriesnum=$(echo $seriesList | wc | awk '{print $2}')

if [ "$seriesnum" != $total ]; then  
	echo "expecting $total functional series, $seriesnum found! exiting!"
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
	masklist="$maskname1 $maskname2 $maskname3 $maskname4"
	echo "$masklist"
	fslmerge -t $outdir/mask_merged $masklist
	fslmaths $outdir/mask_merged -bin -Tmin $outdir/mask
	rm -f $outdir/mask_*.nii.gz
	echo ""
fi

#get number of copes from itc2 (only run that every ppt has)
imglist=$(ls *itc2*/stats/${featname}/${regstddir}/cope*.nii.gz) 
for i in $imglist; do
		echo ""
		img=$(basename $i | cut -d. -f1)
		echo $img
                imgnum=${img##cope} #get cope name here.
	
	if [ ! -e "$outdir/${img}/filtered_func_data.nii.gz" ]; then


                echo "merging copes and varcope for $img"

        copeitc1=""
        copeitc2=""
        copeitc3=""
        copeitc4=""
        varcopeitc1=""
        varcopeitc2=""
        varcopeitc3=""
        varcopeitc4=""

	for s in $seriesList; do
	
        rundir=$(echo $s | cut -d/ -f7)
        runnum=$(echo $rundir | cut -d_ -f3 | cut -dc -f2)
        
	
		# find specific files for merging later
        	if [ $runnum == 1 ]; then
        	        copeitc1=${s}/${regstddir}/${img}.nii.gz
        		varcopeitc1=${s}/${regstddir}/var${img}.nii.gz
		fi

        	if [ $runnum == 2 ]; then
			copeitc2=${s}/${regstddir}/${img}.nii.gz
                	varcopeitc2=${s}/${regstddir}/var${img}.nii.gz
        	fi

		if [ $runnum == 3 ]; then
			copeitc3=${s}/${regstddir}/${img}.nii.gz
                	varcopeitc3=${s}/${regstddir}/var${img}.nii.gz        
		fi

        	if [ $runnum == 4 ]; then
                	copeitc4=${s}/${regstddir}/${img}.nii.gz
                	varcopeitc4=${s}/${regstddir}/var${img}.nii.gz
		fi
	done	

	echo ""
	echo "cope list is $copeitc1 $copeitc2 $copeitc3 $copeitc4"
	echo ""	


		#merge images-- note cannot merge by a unix-generated list as will sort by series number, which varies by subject due to counterbalancing
		#doesn't seem to be actually using the list as different inputs....
		#****anup you will want to change all this so merge copes and varcopes in order***
                fslmerge -t $outdir/${img}_merged.nii.gz $copeitc1 $copeitc2 $copeitc3 $copeitc4

                fslmerge -t $outdir/var${img}_merged.nii.gz $varcopeitc1 $varcopeitc2 $varcopeitc3 $varcopeitc4
	else
		echo "images already merged"
	fi

	#run fixed effects model-- will need to modify based on how many runs the subject has.
	if [ ! -e "$outdir/$img/varcope1.nii.gz" ]; then #varcope1 because we only have one contrast in the second level design
		echo "running flameo fixed effects model"

		#anup you will want to have the .mat, .con, .grp files from your example 2nd level analysis that you ran.
		flameo --cope=$outdir/${img}_merged --varcope=$outdir/var${img}_merged --mask=$outdir/mask --dm=${level2design}.mat --tc=${level2design}.con --cs=${level2design}.grp --runmode=fe --ld=$outdir/$img
		mv $outdir/${img}_merged.nii.gz $outdir/$img/filtered_func_data.nii.gz
		mv $outdir/var${img}_merged.nii.gz $outdir/$img/var_filtered_func_data.nii.gz
	else
		echo "flameo already run!"
	fi

done
