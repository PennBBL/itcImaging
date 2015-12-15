name=`ls /import/monstrum/fndm2_new/progs/ITC/EV_FILES`
for n in $name
do 
name2=`echo $n |tr '[:upper:]' '[:lower:]'`
mv -i $n $name2 
done 
