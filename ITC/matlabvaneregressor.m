%base_dir=import/monstrum/fdmn2_new/progs/ITC
%sub_dir=import/monstrum/fndm2_new/subjects

%filename = (import/monstrum/fndm2_new/progs/behavioral/fndm2_new/progs/behavioral/fndm2_eligible_runs)
%echo "Running file ${filename}"

%fileid=fopen(filename);
%file=fread(fileid);

load('/import/monstrum/fndm2_new/progs/behavioral/eligible_fndm2.mat')

for i = 1:size(eligible,1) 

    scanid=eligible(i,1);
    bblid=eligible(i,2);
    kvalue=eligible(i,3);
    r1=eligible(i,4);
    r2=eligible(i,5);
    r3=eligible(i,6);
    r4=eligible(i,7);
    

    
        %scanid=(echo line | cut -d, -f1)
        %bblid=(echo line | cut -d, -f2)
        %kvalue=(echo line | cut -d, -f3)
        %r1=(echo line | cut -d, -f4)
        %r2=(echo line | cut -d, -f5)
        %r3=(echo line | cut -d, -f6)
        %r4=(echo line | cut -d, -f7)
        
  %echo scanid
  %echo $bblid
  %echo $kvalue
  %echo $r1
  %echo $r2
  %echo $r3
  %echo $r4
  
  disp(strcat('participant', num2str(bblid),'_', num2str(scanid)));
  subdir = ['/import/monstrum/fndm2_new/subjects/' num2str(bblid) '_' num2str(scanid) '/behavioral'];
  cd(subdir) 
  modscanid=['0' num2str(scanid)];
  
  if r1 == 1
      fndm2_createregressor(modscanid,num2str(r1),kvalue);
      disp('creating regressors for run 1')
  else
      disp('run 1 is not eligible')
  
  end    
      
      
  if  r2 == 2
       fndm2_createregressor(modscanid,num2str(r2),kvalue)
       disp('creating regressors for run 2')
  else
      disp('run 2 is not eligible')
      
  end
  
  
  if r3 == 3
      fndm2_createregressor(modscanid,num2str(r3),kvalue)
      disp('creating regressors for run 3')
  else
      disp('run 3 is not eligible')
      
  end  
  
  if r4 == 4
      fndm2_createregressor(modscanid,num2str(r4),kvalue)
      disp('creating regressors for run 4')
  else
      disp('run 4 is not eligible')
     
      
  end
   
  
end
