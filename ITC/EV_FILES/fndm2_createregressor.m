%This function prepares Eprime output data into fsl input data. There are 5
%parts to the output: event, subjective value, amount on screen, del/prob,
%choice. These parts are generated with two columns of onsettime and
%0.1seconds at the left. The third column becomes the respective 5 parts to
%the output. 

%There are 3 inputs required for ITC_fsldata: subjectn, session,
%and k. 

%subjectn is the identifier number for each subject.
%session is run number '1', '2', etc. k is discount rate. 


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
                if ~isempty(strfind(textSnip(1:endLine), 'y'))
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
        ITCdata(:,4) = chooser.*(1-tempdata(:,4))+(1-chooser).*tempdata(:,7); %chose delayed
        ITCdata(:,5) = chooser.*tempdata(:,5) + (1-chooser).*tempdata(:,8); %onset times
        ITCdata(:,6) = chooser.*tempdata(:,6) + (1-chooser).*tempdata(:,9); %RT
        if any(ITCdata(:,6)==0)
            keyboard
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
second = ones(50,1);
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
for a=1:50;
    onset(a,1) = ITC(a,5) - StartTime(1,1);
end 
 
%second is all 0.1 second columns
for a = 1:50;
    second(a,1) = 0.1;
end

%for/if statement for amount column
for a=1:50;
    amount(a,1) = ITC(a,2);
end


%for/If statement for subjval column
for a=1:50;
 subjval(a,1) = ITC(a,2)/(k*ITC(a,3)+1); 
end


%for/if statement for |$20-subjval|
for a=1:50;
 defsv_diff(a,1) = abs(20-ITC(a,2)/(k*ITC(a,3)+1));    
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

event = zeros(50,3);
sv = zeros(50,3);
screenamt = zeros(50,3);
del_prob = zeros(50,3);
choice = zeros(50,3);
defsvdiff = zeros(50,3);
chosenval = zeros(50,3);
missed1 = zeros(50,3);


%define event fsl input file
event(:,1) = onset(1:50,1)/1000;
event(:,2) = second(:,1);
event(:,3) = ones(50,1);
 

%define sv fsl input file
sv(:,1) = onset(1:50,1)/1000;
sv(:,2) = second(:,1);
sv(:,3) = subjval(1:50,1);

%define screenamt fsl input file
screenamt(:,1) = onset(1:50,1)/1000;
screenamt(:,2) = second(:,1);
screenamt(:,3) = amount(1:50,1);

%define del_prob fsl input file
del_prob(:,1) = onset(1:50,1)/1000;
del_prob(:,2) = second(:,1);
del_prob(:,3) = del(1:50,1);

%define choice fsl input file
choice(:,1) = onset(1:50,1)/1000;
choice(:,2) = second(:,1);
choice(:,3) = newc(1:50,1);

%define defsvdiff fsl input file
defsvdiff(:,1) = onset(1:50,1)/1000;
defsvdiff(:,2) = second(:,1);
defsvdiff(:,3) = defsv_diff(1:50,1);

%define chosen value fsl input file
chosenval(:,1) = onset(1:50,1)/1000;
chosenval(:,2) = second(:,1);
chosenval(:,3) = chosen(1:50,1);

%define missed zeros fsl input file
missed1(:,1) = 0;
missed1(:,2) = 0;
missed1(:,3) = 0;

missed2 = missed1;
missed3 = missed2;
missed4 = missed3;
missed5 = missed4;


filename = [subjectn '_itc' session '_reg_missed1'];
dlmwrite([filename], missed1, ' ');
filename = [subjectn '_itc' session '_reg_missed2'];
dlmwrite([filename], missed2, ' ');
filename = [subjectn '_itc' session '_reg_missed3'];
dlmwrite([filename], missed3, ' ');
filename = [subjectn '_itc' session '_reg_missed4'];
dlmwrite([filename], missed4, ' ');
filename = [subjectn '_itc' session '_reg_missed5'];
dlmwrite([filename], missed5, ' ')
keyboard

missedIndex=[];
missedIndex=find(missed(1:50,1))

svOrthomiss = sv(:,3);

%Orthogonalize SV to missed trials
for i = 1:length(missedIndex)
    missedRegressor = [];
    missedTime=zeros(50,1);
    missedTime(missedIndex,1)=1;
    b=polyfit(missedTime,sv(:,3),1);
    b=abs(b);
    svOrthomiss=svOrthomiss-b(1,1).*missedTime;
    missedRegressor(:,1)=onset(1:50,1)/1000;
    missedRegressor(:,2)=0.1;
    missedRegressor(:,3)=missedTime;
    %save out regressor file 
    filename = [subjectn '_itc' session '_reg_missed' num2str(i)];
    dlmwrite(filename, missedRegressor, ' ');
end


%Redefine sv fsl input file
sv(:,3) = svOrthomiss;


% %remove missed trials
% MisInd=find(missed)
% missedIndex=[];
% missedIndex=find(missed((block-1)*30+1:(block-1)*30+30,1)) 
%  
% event(missedIndex)=[];
% sv(missedIndex)=[];
% screenamt(missedIndex)=[];
% del_prob(missedIndex)=[];
% choice(missedIndex)=[];
% defsvdiff(missedIndex)=[];
% chosenval(missedIndex)=[];

%find missed trials within block, and make new regressor file for each
%missed trial


filename = [subjectn '_itc' session '_reg_event'];
dlmwrite([filename], event, ' ');

filename = [subjectn '_itc' session '_reg_sv'];
dlmwrite([filename], sv, ' ');

filename = [subjectn '_itc' session '_reg_amt'];
dlmwrite([filename], screenamt, ' ');

filename = [subjectn '_itc' session '_reg_del'];
dlmwrite([filename], del_prob, ' '); 

filename = [subjectn '_itc' session '_reg_choice'];
dlmwrite([filename], choice, ' ');

filename = [subjectn '_itc' session '_reg_defsvdiff'];
dlmwrite([filename], defsvdiff, ' ');

filename = [subjectn '_itc' session '_reg_chosenval'];
dlmwrite([filename], chosenval, ' ');




    end
    






