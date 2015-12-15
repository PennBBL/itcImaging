%This function prepares Eprime output data into fsl input data. There are 7
%parts to the output: event, subjective value, amount on screen, del on screen,
%choice, difference in subjective value,chosen value. These parts are generated
%with two columns of onsettime and 4 seconds at the left (four seconds is length of each trial). 
%The third column becomes the respective 7 parts to the output. 

% The first two trials are throw-away trials - remove first 18 seconds from
% each stick file

%There are 3 inputs required for ITC_fsldata: subjectn, session,
%and k. 

%subjectn is the identifier number for each subject.
%session is run number '1', '2', etc. k is discount rate. 

% created by Rebecca Kazinka Summer 2015; adapted from
% cogtrain_createregressor.m

function [] = fndm2_createregressor(subjectn, session, k)

filename = ['RTG' session '_1ITCscanner1LLA-' subjectn '-' session '.txt'];

%[number, text, all] = xlsread(filename);

fileid=fopen(filename); %gets the fileID for the given filename
file=fread(fileid, 'uint16=>char')'; %reads in the entire textfile
lookingdistance = 15;
dataTypes={  'LeftRight: ', 'Offer: ', 'delay: ',...
    'Choice.RESP: ', 'Choice.OnsetTime: ','Choice.RT: ', 'Choice1.RESP: ', 'Choice1.OnsetTime: ','Choice1.RT: '}; %these are the column names that we are interested in
slide1=('Slide1.OffsetTime: ');
tempdata = nan(50,1);
 ITCdata = [];
         for m = 1:length(dataTypes)
            str = dataTypes{m};
            len = length(str);
            indices = strfind(file, str);
            temp = [];
            for q = 1 :length(indices)
                textSnip = file(indices(q)+len-1:indices(q)+len+lookingdistance);
                endLine=strfind(textSnip,  sprintf('\n'));
                if ~isempty(strfind(textSnip(1:endLine), 'r'))
                    textSnip = '0';
                else
                    textSnip = textSnip(1:endLine);
                end
                temp(end+1) = str2double(textSnip);
            end
            if length(temp) == 53
                temp = temp(3:end);
            end
            tempdata = [tempdata temp'];
         end
         len=length(slide1);
         indices =strfind(file,slide1);
         StartTime = [];
         for q = 1: length(indices)
                textSnip = file(indices(q)+len-1:indices(q)+len+lookingdistance);
                endLine=strfind(textSnip, sprintf('\n'));
                textSnip=textSnip(1:endLine);
                StartTime = str2double(textSnip);
        tempdata(:,1) = [];
        tempdata(find(isnan(tempdata))) = 1; %#ok<*FNDSB>
       ITCdata(:,1:3) = tempdata(:,1:3);
        chooser = tempdata(:,1);
        ITCdata(:,4) = chooser.*(tempdata(:,4))+(1-chooser).*(1-tempdata(:,7)); %chose delayed
        ITCdata(:,5) = chooser.*tempdata(:,5) + (1-chooser).*tempdata(:,8); %onset times
        ITCdata(:,6) = chooser.*tempdata(:,6) + (1-chooser).*tempdata(:,9); %RT
        if any(ITCdata(:,6)==0)
%            keyboard
        end

        ITCdata(:,7) = chooser.*tempdata(:,4) + (1-chooser).*tempdata(:,7); %chose left
        header = {'delay on right', 'Amt', 'Del', 'ChoseDelayed', 'OnsetTime', 'RT', 'ChoseLeft'};
        ITCdata = [header;num2cell(ITCdata)];        
        
        
%Columns should be constructed for
%stimulus onset time is the 44th column in 'number' array
%waiting for scanner offset 54th column in 'number' array
%subjective value is calculated with input  'k' 
%AmtLater is column 22
%Amtr is column 23

onset = zeros(50,1);

amount = zeros(50,1);
subjval = zeros(50,1);
defsv_diff = zeros(50,1);% the absolute value of the difference between
%default option and the offer
del = zeros(50,1);
newc = ones(50,1);
chosen = ones(50,1);
ITC=cell2mat(ITCdata(2:end,1:7));
%onset column is 44th column - 54th column
% true because matlab cuts off the first column from the excel file 
%for FNDM experiment, first two trials are deleted (they are throw-away
%trials) two trials = 18 seconds

for a=1:50;
 onset(a,1) = ITC(a,5) - StartTime(1,1) - 18000;
end 
 
%second is all 4 second columns
second = ones(48,1)*4;

%for/if statement for amount column
for a=1:50;
    amount(a,1) = ITC(a,2);
end

%for/If statement for subjval column
for a=1:50
    subjval(a,1) = (ITC(a,2))./(k.*ITC(a,3)+1); 
end

%for/if statement for |$20-subjval|
for a=1:50;
 defsv_diff(a,1) = abs(20-ITC(a,2)./(k.*ITC(a,3)+1));    
end
%for/If statement for Delay on screen
for a=1:50;
 del(a,1) = ITC(a,3);

end

%newc is trials when delayed was chosen
for a=1:50
newc(a,1)=ITC(a,4);
end

%for/if statement for chosen value
for a=1:50;

        if ITC(a,4) == 1; % chose later 
            chosen(a,1) = subjval(a,1);
        else chosen(a,1) = 20;
        end
end


%find missed trials 

missed=zeros(50,1);
for a=1:50;
if ITC(a,6) == 0;
    missed(a,1) = 1;
else
    missed(a,1)=0;
end
end

event = zeros(48,3);
sv = zeros(48,3);
screenamt = zeros(48,3);
del_prob = zeros(48,3);
choice = zeros(48,3);
defsvdiff = zeros(48,3);
chosenval = zeros(48,3);
missed1 = zeros(48,3);


%define event fsl input file
event(:,1) = round(onset(3:50,1)./1000);
event(:,2) = second(:,1);
event(:,3) = ones(48,1);
 

%define sv fsl input file
sv(:,1) = round(onset(3:50,1)./1000);
sv(:,2) = second(:,1);
sv(:,3) = subjval(3:50,1);

%define screenamt fsl input file
screenamt(:,1) = round(onset(3:50,1)./1000);
screenamt(:,2) = second(:,1);
screenamt(:,3) = amount(3:50,1);

%define del_prob fsl input file
del_prob(:,1) = round(onset(3:50,1)./1000);
del_prob(:,2) = second(:,1);
del_prob(:,3) = del(3:50,1);

%define choice fsl input file
choice(:,1) = round(onset(3:50,1)./1000);
choice(:,2) = second(:,1);
choice(:,3) = newc(3:50,1);

%define defsvdiff fsl input file
defsvdiff(:,1) = round(onset(3:50,1)./1000);
defsvdiff(:,2) = second(:,1);
defsvdiff(:,3) = defsv_diff(3:50,1);

%define chosen value fsl input file
chosenval(:,1) = round(onset(3:50,1)./1000);
chosenval(:,2) = second(:,1);
chosenval(:,3) = chosen(3:50,1);

%generate missed trial regressor of zeros (default if no missed trials)
filename = [subjectn '_itc' session '_reg_missed.txt'];
dlmwrite([filename], missed1, ' ');

%looks for missed trials
missedIndex=[];
missedIndex=find(missed(3:50,1))

%svOrthomiss = sv(:,3);

%Orthogonalize SV to missed trials
%if ~isempty(missedIndex)
%    Excluded=zeros(48,1);
%    Excluded(missedIndex,1)=1;
%    b=polyfit(Excluded,sv(:,3),1);
%    b=abs(b);
%    svOrthomiss(missedIndex,1)=b(1,2);
%end
%create new missed regressor for missed trials

if ~isempty(missedIndex)
    missedRegressor = zeros(48,3);
    missedTime=zeros(48,1);
    missedTime(missedIndex,1)=1;
    missedRegressor(missedIndex,1)=round(onset(missedIndex+2,1)/1000);
    missedRegressor(missedIndex,2)=4;
    missedRegressor(:,3)=missedTime;
    %save out regressor file 
    filename = [subjectn '_itc' session '_reg_missed.txt'];
    dlmwrite(filename, missedRegressor, ' ');
   %remove missed trials
    sv(missedIndex,:)=zeros;
    choice(missedIndex,:)=zeros;
    defsvdiff(missedIndex,:)=zeros;
    chosenval(missedIndex,:)=zeros;
    event(missedIndex,:)=zeros;
    screenamt(missedIndex,:)=zeros;
    del_prob(missedIndex,:)=zeros;
end

%Redefine sv fsl input file
%sv(:,3) = svOrthomiss;

filename = [subjectn '_itc' session '_reg_event.txt'];
dlmwrite([filename], event, ' ');

filename = [subjectn '_itc' session '_reg_amt.txt'];
dlmwrite([filename], screenamt, ' ');

filename = [subjectn '_itc' session '_reg_del.txt'];
dlmwrite([filename], del_prob, ' '); 

filename = [subjectn '_itc' session '_reg_sv.txt'];
dlmwrite([filename], sv, ' ');

filename = [subjectn '_itc' session '_reg_choice.txt'];
dlmwrite([filename], choice, ' ');

filename = [subjectn '_itc' session '_reg_defsvdiff.txt'];
dlmwrite([filename], defsvdiff, ' ');

filename = [subjectn '_itc' session '_reg_chosenval.txt'];
dlmwrite([filename], chosenval, ' ');

    end
    






