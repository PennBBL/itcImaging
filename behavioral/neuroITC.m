% Written by Arthur Lee Novemeber 2014
% adapted by Rebecca Kazinka June 2015
%% acquire subject info and filenames
clear classes
clc
macdatadir = '/import/monstrum/fndm2_new/subjects/';
macnotedir = '/import/monstrum/fndm2_new/progs/behavioral/notes/';
machomedir = '/import/monstrum/fndm2_new/progs/behavioral/';

if isunix
    homedir = machomedir;
    datadir = macdatadir;
    notedir = macnotedir;
end

entiredata = [{'SNum'},{'ITC'},{'ITCanalyzed'},{'ITC:k'}, {'ITC:r2'},{'ITC:AUC'},{'ITC:RTandQEcorr'},{'ITC:medianRT'},{'ITC:percentNow'},{'ITC:errorcode'},{'ITC:%unanswered'}];
ITCdir = '/import/monstrum/fndm2_new/subjects/*';

cd(datadir)
list_dir = dir(ITCdir);
for i = 4:length(list_dir);
    localdir = (fullfile([datadir '/' list_dir(i).name '/behavioral']));
    cd(localdir)
    everything(i-3) = dir('ITC*.txt');
fn={everything.name};
subjIDs = [];
%filenames = struct;
filenames.ITC = {};
%filenames.loss = {};
%filenames.risk = {};
%filenames.fish = {};
%filenames.ratio = {};

for f = 1:length(fn)
    text = fn{f};
    if length(text)>9
        subjIDs(end+1) = str2double(text(length(text)-10:length(text)-6)); %#ok<*SAGROW>
%        switch text(1) %the first character of the filename
%            case 'I' %ITC data
                filenames.ITC{end+1} = text;
%            case 'L' %Loss aversion data
%               filenames.loss{end+1} = text;
%            case 'f' %fisherman data
%                filenames.fish{end+1} = text;
%            case 'p' %progressive ratio data
%                filenames.ratio{end+1} = text;
%            case 'R' %Risk aversion data
%                filenames.risk{end+1} = text;
%            otherwise %unexpected case
%                disp('error1')
%                keyboard
%        end
    end
end
subjects = subjIDs;
%subjIDs = sort(subjIDs);
%subjects = unique(subjIDs)'; % all the subjects who have participated
entiredata(i-2,1) = num2cell(subjects(i-3));
tasks = fieldnames(filenames);
for f = 1:length(tasks)
    datafiles = filenames.(tasks{f});
    tempcell = tasks(f);
    for q = 1:length(datafiles)
        txtname = datafiles{q};
        tempcell{find(subjects == str2double(txtname(end-10:end-6)))+1} = txtname;
    end
    entiredata(i-2,2) = tempcell(1,i-2); %#ok<*AGROW>
end
cd(notedir)
%bbids =  xlsread('SummaryScores_ALLDATA_2014-04-08','A2:A224');
%[empty, groups] =  xlsread('SummaryScores_ALLDATA_2014-04-08','D2:D224');
%for f= 2: size(entiredata,1)
%    ID = entiredata{f,1};
%    index = find(bbids == ID);
%    if ~isempty(index)
%        entiredata(f,7) = groups(index);
%    end
%end
cd(homedir)
save neuroecentiredata.mat entiredata


%% load ITC data
%clear classes

macdatadir = '/import/monstrum/fndm2_new/subjects/';
machomedir = '/import/monstrum/fndm2_new/progs/behavioral/';

if isunix
    homedir = machomedir;
    datadir = macdatadir;
end

cd(homedir)
load neuroecentiredata.mat
dataTypes={  'LeftRight: ', 'Offer: ', 'delay: ',...
    'Choice.RESP: ', 'Choice.RT: ', 'Choice1.RESP: ', 'Choice1.RT: '}; %these are the column names that we are interested in
runType ={'Session: '};
cd(localdir)
lookingdistance = 15; %how many characters to look for after the dataname has ended
%for f = 2:size(entiredata,1);
    i %#ok<*NOPTS>
    if ~isempty(entiredata{i-2,2})
        fileid=fopen(entiredata{i-2,2}); %gets the fileID for the given filename
        file=fread(fileid, 'uint16=>char')'; %reads in the entire textfile
        tempdata = []; %nan(50,1);
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
        for m = 1:length(runType)
            str = runType{m};
            len = length(str);
            indices = strfind(file, str);
            runtemp = [];
            for q = 1 :length(indices)
                textSnip = file(indices(q)+len-1:indices(q)+len+lookingdistance);
                endLine=strfind(textSnip,  sprintf('\n'));
                if ~isempty(strfind(textSnip(1:endLine), 'r'))
                    textSnip = '0';
                else
                    textSnip = textSnip(1:endLine);
                end
                runtemp(end+1) = str2double(textSnip);
            end
                runNum = unique(runtemp);
        end
        %tempdata(:,1) = [];
        tempdata(find(isnan(tempdata))) = 1; %#ok<*FNDSB>
        ITCdata(:,1:3) = tempdata(:,1:3);
        chooser = tempdata(:,1);
        ITCdata(:,4) = chooser.*(tempdata(:,4))+(1-chooser).*(1-tempdata(:,6)); %chose delayed
        ITCdata(:,5) = chooser.*tempdata(:,5) + (1-chooser).*tempdata(:,7); %RTs
%        if any(ITCdata(:,5)==0)
%            keyboard
%        end
        ITCdata(:,6) = chooser.*tempdata(:,4) + (1-chooser).*tempdata(:,6); %chose left
        header = {'delay on right', 'Amt', 'Del', 'ChoseDelayed', 'RT', 'ChoseLeft'};
        ITCdata = [header;num2cell(ITCdata)];
         % input run number to each set of 50 questions (specific to fnmd2)

        runlist = [];
        for jj = 1:length(runNum)
        if jj==1
            runlist(2:51,1) = repmat(runNum(1,jj),50,1);
        end
        
        if jj == 2
            runlist(52:101,1) = repmat(runNum(1,jj),50,1);
        end
   
        if jj == 3
            runlist(102:151,1) = repmat(runNum(1,jj),50,1);
        end
        if jj == 4
            runlist(152:201,1) = repmat(runNum(1,jj),50,1);
        end
        end
       
        runlist_cell=num2cell(runlist);
        runlist_cell{1,1} ={'runNum'};
        ITCdata(:,7) = runlist_cell;
        entiredata{i-2,2} = ITCdata;
   end
%end
cd(homedir)
save neuroecentiredata.mat entiredata


%% ITC data extraction
%clear classes
clc
macdatadir = '/import/monstrum/fndm2_new/subjects/';
machomedir = '/import/monstrum/fndm2_new/progs/behavioral/';

if isunix
    homedir = machomedir;
    datadir = macdatadir;
end

cd(homedir)
load neuroecentiredata.mat
newdata(1,:) = entiredata(1,:);
newdata(i-2,1:2) = entiredata(i-2,1:2);
temp = {'ITC:k', 'ITC:r2','ITC:AUC','ITC:RTandQEcorr','ITC:medianRT','ITC:percentNow', 'ITC:errorcode'};%, 'ITC:exp-k', 'ITC:exp-r2','ITC:exp-AUC','ITC:exp_RTcorr'};
%for f = 2: size(entiredata,1);
%    f
    participant = num2str(entiredata{i-2,1});
    data = entiredata{i-2,2};
    if ~isempty(data)
        percentchoseleft = (sum(cell2mat(data(2:end,6)) == 1) / (length(data)-1)) * 100;
        ITC =[];
        ITC = cell2mat(data(2:end,2:5));
        trialnum = length(ITC);
        [ITC]=removerows(ITC,'ind',ITC(:,4)==0);
        badrows = any(isnan(ITC),2);
        ITC(badrows,:) = [];
        if trialnum ~= length(ITC)
            disp(strcat('unanswered question exist for participant',num2str(participant)));
%            keyboard
        end
        ITC(:,5)=20;
        ITC(:,6)=0;
        % ITCanalysis input: choice,v1,d1,v2,d2,RT, participant
        [subjdata] = ITCanalysis(ITC(:,3),ITC(:,5),ITC(:,6),ITC(:,1),ITC(:,2),ITC(:,4),participant);
        temp{2,1} = subjdata.k;
        temp{2,2} = subjdata.r2;
        temp{2,3} = subjdata.AUC;
        temp{2,4} = subjdata.RTandSubjValueCorr;
        temp{2,5} = subjdata.medianRT;
        temp{2,6} = subjdata.percentNow;
        temp{2,7} = subjdata.errorcode;
    end
%end
newdata{i-2,3} = ITC;
newdata(i-2,4:10) = temp(2,1:7);
newdata{i-2,11}= (size(newdata{i-2,2},1)-1-size(newdata{i-2,3},1))/(size(newdata{i-2,2},1)-1);
cd(homedir)
save analyzeddata.mat newdata
%keyboard
end
%% ITC graphical analysis
clear classes
clc
machomedir = '/import/monstrum/fndm2_new/progs/behavioral/';
if isunix
    homedir = machomedir;
end
cd(homedir)

load neuroecentiredata.mat
load analyzeddata.mat

analyzeddata = newdata(2:end,1:8);
originaldata = entiredata(2:end,2);
emptyindex = cellfun('isempty',analyzeddata(:,3));

originaldata = originaldata(~emptyindex);
participant = analyzeddata(~emptyindex,1);
group = analyzeddata(~emptyindex,2);
logk = log(cell2mat(analyzeddata(~emptyindex,3)));
r2 = cell2mat(analyzeddata(~emptyindex,4));
AUC = cell2mat(analyzeddata(~emptyindex,5));
RTcorr = cell2mat(analyzeddata(~emptyindex,6));
medianRT = cell2mat(analyzeddata(~emptyindex,7));
errorcode = analyzeddata(~emptyindex,8);

% individual choice graph
% for ty = 1:length(r2)
%     if r2(ty) < .3
%         odddata = originaldata{ty};
%         immediate = cell2mat(odddata(2:end,2));
%         delayed = cell2mat(odddata(2:end,3));
%         delay = cell2mat(odddata(2:end,5));
%         chosedelayed = logical(cell2mat(odddata(2:end,6)));
%         percentage = immediate./delayed;
%         figure()
%         hold on
%         plot(delay(chosedelayed), percentage(chosedelayed),'ro');
%         plot(delay(~chosedelayed),percentage(~chosedelayed),'bo');
%         ylim([0 1])
%         title(strcat(num2str(participant{ty}), '__r2:', num2str(r2(ty)), '__medianRT:', num2str(medianRT(ty))))
%     end
% end


qualitycontrol = find(r2<0.3);
participant(qualitycontrol) = [];
originaldata(qualitycontrol) = [];
group(qualitycontrol) = [];
logk(qualitycontrol) = [];
r2(qualitycontrol) = [];
AUC(qualitycontrol) = [];
RTcorr(qualitycontrol) = [];
medianRT(qualitycontrol) = [];
errorcode(qualitycontrol) = [];


figure()
scatterhist(logk,r2,'Group',group,'Location','SouthEast','NBins',[1,30],...
    'Direction','out','Color','rgbyc','LineStyle',{'-','-','-','-','-'},...
    'LineWidth',[2,2,2,2,2],'Marker','o','MarkerSize',[4,4,4,4,4]);



%% quality control
clear classes
clc
machomedir = '/import/monstrum/fndm2_new/progs/behavioral/';
if isunix
    homedir = machomedir;
end
cd(homedir)

load neuroecentiredata.mat
load analyzeddata.mat

counter = 0;
for index = 2:length(newdata)
    if newdata{index,4}<0.3 %ITC
        for bug = 3:8
            newdata{index,bug} = 'ruledout';
        end
    end
%    if newdata{index,10}<0.3 %Loss
%        for bug = 9:14
%            newdata{index,bug} = 'ruledout';
%        end
%    end
%    if newdata{index,16}<0.3 %Risk
%        for bug = 15:19
%            newdata{index,bug} = 'ruledout';
%        end
%    end
%    if nanmean(newdata{index,24}(16:end))<.523
%        counter = counter+1
%        for bug = 20:33
%            newdata{index,bug} = 'ruledout';
%        end
%                end
end

newdata(:,24) = [];

save controlleddata.mat newdata