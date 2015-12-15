function [] = eligibility_fndm2

% This script is written to determine the list of subjects eligible after
% exclusions are applied:
%   - R2 < 0.30
%   - Participants chose >99% now or later, unless RT & difficulty
%   correlation is > -.165 (one-tailed p value >.05) based on 100 trials
%   - for each run the mean relative motion is <.30
%   - each run must also answer >=90% of trials (>=45 trials) and movement
%   - participants must have at least 2 eligible runs
%
% This will spit out a list of the subject and eligible runs plus k value,
% to be fed into the script to create stick files and run fsl stats
%
% save file so that non-eligible runs can be counted/checked


%load ITC data and epiQA10 data
analyzeddata = load('analyzeddata.mat');
ITCdata = analyzeddata.newdata;
[epiQA_num,epiQA_text,epiQA_raw] = xlsread('combined epiQA10.xls','epiQA10');

%pull out relevant movement data (scanid, bblid,run number, relative motion)
mvmtdatacell(:,1:4) = epiQA_raw(:,[2 3 17 34]);
mvmtdatacell(1,3) = {'runNum'};
mvmtdatacell(1,:) = [];
mvmtdata = cell2mat(mvmtdatacell);

xx = isnan(mvmtdata(:,3));
mvmtdata(xx,:) = [];

% Split data into matrices for each subject by creating cell array

mvmtdata = sortrows(mvmtdata,1);

idx = cumsum(diff([0;mvmtdata(:,1)])>0); % separate by subject number
idxn = histc(idx,unique(idx)); %number of runs per subject
C = mat2cell(mvmtdata,idxn,size(mvmtdata,2));

% pull out subject number, run numbers, and mean movement data

for i= 1:size(C,1)
    C{i,1}=sortrows(C{i,1},3);
    C{i,2}=C{i,1}(1,1);
    C{i,3}=C{i,1}(1,2);
    for d=1:size(C{i,1},1)
    if C{i,1}(d,3) == 1
        C{i,4}= C{i,1}(d,4);
    elseif C{i,1}(d,3) == 2
        C{i,5}= C{i,1}(d,4);
    elseif C{i,1}(d,3) == 3
        C{i,6}= C{i,1}(d,4);
    elseif C{i,1}(d,3) == 4
        C{i,7}= C{i,1}(d,4);
    end
    end

end

datalist(:,1:11) = ITCdata(:,[1 4 5 7 9 10 11 12 13 14 15]);
datalist(1,8:15) = {'run1_NumMissed','run2_NumMissed','run3_NumMissed','run4_NumMissed','run1_movement','run2_movement','run3_movement','run4_movement'};

datalist(2:end,:) = sortrows(datalist(2:end,:),1);
%participant 18391 is the bblid; we want the scan id!
[x,y]=find([datalist{:,1}]==18391);
fixID={9403};

datalist(y-3,1)=fixID;
for i = 1:size(C,1)
    subid = C(i,2);
    subid = cell2mat(subid);
    [x,y] = find([datalist{:,1}] == subid);
    % if it finds the subid, it will put in the movement data. y-3 to
    % account for the string input at the beginning (SNum)
    if ~isempty(x)
    datalist(y-3,12:16)= C(i,[4 5 6 7 3]);
    end
end

datalist(1,16:21) = {'bblid','too_few_runs','low R2','all now or later','eligible','diagnosis'};

% create new array to calculate run errors


criteria(:,1:2) = datalist(:,[1 16]);

criteria(1,1:19) = {'SNum','bblid','run1_missed','run2_missed','run3_missed','run4_missed','run1_mvmt','run2_mvmt','run3_mvmt','run4_mvmt','run1_empty','run2_empty','run3_empty','run4_empty', 'run1_ineligible','run2_ineligible','run3_ineligible','run4_ineligible','too_few_runs'};

% test if there are runs where they miss too many trials

for jj = 2:size(datalist,1)
    
    if datalist{jj,8} > 5
        criteria{jj,3} = 1;
    else
        criteria{jj,3} = 0;
    end
    
    if datalist{jj,9} > 5
        criteria{jj,4} = 1;
    else
        criteria{jj,4} = 0;
    end
    
    if datalist{jj,10} > 5
        criteria{jj,5} = 1;
    else
        criteria{jj,5} = 0;
    end
    
    if datalist{jj,11} > 5
        criteria{jj,6} = 1;
    else 
        criteria{jj,6} = 0;
    end

% test if there are runs where they move too much
    
    if datalist{jj,12} > .3
        criteria{jj,7} = 1;
    else
        criteria{jj,7} = 0;
    end
    
    if datalist{jj,13} > .3
        criteria{jj,8} = 1;
    else
        criteria{jj,8} = 0;
    end
    
    if datalist{jj,14} > .3
        criteria{jj,9} = 1;
    else
        criteria{jj,9} = 0;
    end
    
    if datalist{jj,15} > .3
        criteria{jj,10} = 1;
    else
        criteria{jj,10} = 0;
    end



% denote trials where they did not complete a run 
    if or(isempty(datalist{jj,8}),isempty(datalist{jj,12}))
        criteria{jj,11} = 1;
    else criteria{jj,11} = 0;
    end
    
    if or(isempty(datalist{jj,9}),isempty(datalist{jj,13}))
        criteria{jj,12} = 1;
    else criteria{jj,12} = 0;
    end
    
    if or(isempty(datalist{jj,10}),isempty(datalist{jj,14}))
        criteria{jj,13} = 1;
    else criteria{jj,13} = 0;
    end
    
    if or(isempty(datalist{jj,11}),isempty(datalist{jj,15}))
        criteria{jj,14} = 1;
    else criteria{jj,14} = 0;
    end
  
 % note if run is ineligible
   
 if criteria{jj,3} + criteria{jj,7} + criteria{jj,11} > 0
     criteria{jj,15} = 1;
 else criteria{jj,15} = 0;
 end
 
 if criteria{jj,4} + criteria{jj,8} + criteria{jj,12} > 0
     criteria{jj,16} = 1;
 else criteria{jj,16} = 0;
 end
 
 if criteria{jj,5} + criteria{jj,9} + criteria{jj,13} > 0
     criteria{jj,17} = 1;
 else criteria{jj,17} = 0;
 end
 
 if criteria{jj,6} + criteria{jj,10} + criteria{jj,14} > 0
     criteria{jj,18} = 1;
 else criteria{jj,18} = 0;
 end

if criteria{jj,15} + criteria{jj,16} + criteria{jj,17} + criteria{jj,18} > 2
     criteria{jj,19} = 1;
else criteria{jj,19} = 0;
end

end
% transfer too few runs criteria to datalist
datalist(:,17) = criteria(:,19);

% calculate other eligibility criteria (R2, all now or later)
for jj = 2:size(datalist,1)
    
    if datalist{jj,3} < .3
        datalist{jj,18} = 1;
    else datalist{jj,18} = 0;
    end
        
    if or(and(datalist{jj,4} > -0.165,datalist{jj,5} > 99), and(datalist{jj,4} > -0.165,datalist{jj,5} < 1))
        datalist{jj,19} = 1;
    else datalist{jj,19} = 0;
    end
% Are they still eligible? 1= yes, 0 = no    
    if datalist{jj,17} + datalist{jj,18} + datalist{jj,19} > 0
        datalist{jj,20} = 0;
    else datalist{jj,20}= 1;
    end
        
end


eligible =NaN(179,7);
ineligible=NaN(179,2);

bbids =  xlsread('Wolf_Satt_all_study_diagnosis_2015-11-17','B2:B403');
[empty, groups] =  xlsread('Wolf_Satt_all_study_diagnosis_2015-11-17','E2:E403');
for f= 2: size(datalist,1)

    ID = datalist{f,16};
    index = find(bbids == ID);
   
    if ~isempty(index)
        datalist(f,21) = groups(index,5);
    end
    
end


% create list of eligible participants (with scanID, bblID, and k)
for k = 1:size(datalist,1)-1
if datalist{k+1,20} == 1
    eligible(k,1) = datalist{k+1,1};
    eligible(k,2) = datalist{k+1,16};  
    eligible(k,3) = datalist{k+1,2};      
 % create list of excluded participants (scanID and bblID)  
elseif datalist{k+1,20} == 0
    ineligible(k,1) = datalist{k+1,1}; %scanID
    ineligible(k,2) = datalist{k+1,16:19};% bblID, 
    ineligible(k,3) = datalist{k+1,17};% too few runs
    ineligible(k,4) = datalist{k+1,18}; % low R2
    ineligible(k,5) = datalist{k+1,19}; % all now or later
%    ineligible=mat2cell(ineligible);
%    ineligible(1,1:5) = {'scanid','bblid','too few runs','low R2','all now or all later'};
    
    
end

%add in a list of eligible runs for each participant (and leave blank
%ineligible runs)

if and(datalist{k+1,20} == 1, criteria{k+1,15} == 0)
    eligible(k,4) = 1;
end

if and(datalist{k+1,20} == 1, criteria{k+1,16} == 0)
    eligible(k,5) = 2;
end

if and(datalist{k+1,20} == 1, criteria{k+1,17} == 0)
    eligible(k,6) = 3;

end

if and(datalist{k+1,20} == 1, criteria{k+1,18} == 0)
    eligible(k,7) = 4;
end
end
    
eligiblenan=isnan(eligible(:,1));
eligible(eligiblenan,:)=[];
ineligiblenan=isnan(ineligible(:,1));
ineligible(ineligiblenan,:)=[];

%save lists

save eligible_fndm2.mat eligible
save ineligible_fndm2.mat ineligible 
save completeddata.mat datalist

for ii=1:size(eligible,1)
eligible(ii,8)=4-sum(isnan(eligible(ii,4:7)));
end
csvwrite('fndm2_eligible_runs.csv',eligible)
end



