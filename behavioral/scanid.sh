for i in $(ls -d /import/monstrum/fndm2_new/subjects/*_*)

do 

id=$(echo $i | cut -d "/" -f 6) 
scanid=$(echo $id | cut -d "_" -f 2)

echo $scanid 

done

