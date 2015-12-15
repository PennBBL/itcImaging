for i in $( ls -d /import/monstrum/fndm2_new/subjects/*_*)

do

basename=$(echo $i | cut -d "/" -f 6)
scanid=$(echo $basename | cut -d "_" -f 2)
##t1=$($i/*[0-9]_MPRAGE*moco3/"$scanid"_t1.nii.gz)
bblid=$(echo $basename | cut -d "_" -f 1)

if [ ! -e /import/monstrum/nodra/group_level_analyses/dhw_tds_sbia_txfr_mass/$scanid* ]

then

echo "$i"/[0-9]mprage/"$scanid"_t1.nii.gz 

else

echo "$scanid present"

fi


done
