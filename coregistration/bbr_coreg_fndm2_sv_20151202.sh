
#input is a subject level directory from an array job

#Single Subject

#subjdir=$(ls -d /import/monstrum/fndm2_new/subjects/18406_9467)  #for non-grid testing, 

#Subject loop (only use for array jobs)
subjects=$1
subjdir=$(cat $subjects|sed -n "${SGE_TASK_ID}p")  

#loop through each functional run present
echo $subjdir
echo ""
cd $subjdir
pwd
 
#get scanid
scanid=$(echo $subjdir | cut -d/ -f6 | cut -d_ -f2)
echo "scanid is $scanid"

#define structural target image
mpragedir=$(ls -d $subjdir/*mprage/ 2> /dev/null)
if [ ! -d "$mpragedir" ]; then
	echo "looking for MPRAGE w/ NODRA naming"
	mpragedir=$(ls -d ${subjdir}/*_MPRAGE_TI1110_ipat2_moco3/)
fi

t1brain=$(ls $mpragedir/${scanid}_t1_brain.nii.gz 2> /dev/null)  
t1head=$(ls $mpragedir/${scanid}_t1.nii.gz 2> /dev/null) 
wmseg=$(ls $mpragedir/${scanid}_t1_brain_mico_wm.nii.gz 2> /dev/null)  #note updated 12/02/15 to add "_t1_" back in name-- hope this as not missing.  Feel free to rename old images if need to to include _t1_ 


if [ ! -e "$t1brain" ]; then
		echo "no t1 brain found to register to!!! exiting"
		exit 1
else
	echo "structural target image is $t1brain"
	echo "wm segment for bbr is $wmseg"
fi

#now go by sequence: find each task sequence

serieslist=$(ls -d *itc*) 

echo ""
echo "series list for this subject is:"
echo "$serieslist"

for s in $serieslist; do
	echo ""
	echo "#######"

	echo $s
	outdir=$(ls -d ${subjdir}/${s}/coregistration 2> /dev/null) #define output directory

	#make output directory
	if [ ! -d "$outdir" ]; then
		echo "making output directory"
		mkdir ${subjdir}/${s}/coregistration
		outdir=$(ls -d ${subjdir}/${s}/coregistration)
	fi

	#check if output is present
	output=$(ls ${outdir}/ep2struct.mat 2> /dev/null)
	if [ -e "$output" ]; then
		echo "output present!-- skipping"
		continue
	fi

	#define stats directory and example_func

	statsdir=$(ls -d ${subjdir}/${s}/stats/sv_level1_20151120.feat/ 2> /dev/null) #changed to look for example func in stats directory w/ SV models as of 20151202
	example_func=$(ls $statsdir/example_func.nii.gz)
	if [ ! -e "$example_func" ]; then
		echo "example func not present-- was stats run? skipping this run"
		exit 0
	fi

	#bet the example_func image if not done
	if [ ! -e "$statsdir/example_func_brain.nii.gz" ]; then
		echo "running bet on example_func"
		bet $example_func $statsdir/example_func_brain -f 0.3
	fi

	#run bbr
	echo "running epi_reg_tds"
	/import/monstrum/fndm2_new/progs/coregistration/epiregtd3v3_fndm2_20140917.sh --epi=$statsdir/example_func_brain --t1=$t1head --t1brain=$t1brain --t1wm=$wmseg --wd=$outdir -v --out=$outdir/ep2struct
  	echo "output is $outdir/ep2struct.nii.gz"	
done
