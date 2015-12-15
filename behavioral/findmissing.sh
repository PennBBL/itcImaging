for i in `ls -d /import/monstrum/fndm2_new/subjects/*_*`;


#for i in /import/monstrum/fndm2/subjects/*/1*_*/data/behavioral/stickfiles/;
#for i in /import/monstrum/fndm2/effort/subjects/*/1*_*/data/images/;
do   

if [ ! -e $i/*_mprage/[0-9]*t1.nii.gz ];
#if [ ! -d $i/*_mprage/ ];
#if [ ! -d $i/ep2d_itc1_168_Series00008 ]; 
#if [ ! -f $i/stats/zstat7.nii.gz ];#for beh and wm, zstat7 is last zstat#;

then echo "$i"; 

fi; 
done
