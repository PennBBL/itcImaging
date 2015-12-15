%% acquire subject info and filenames
clear classes
clc
macdatadir = '/Users/Carmenere/Documents/ANALYSIS/Notes and Data/DATA/Neuroec';
macnotedir = '/Users/Carmenere/Documents/ANALYSIS/Notes and Data/NOTES/Neuroec';
machomedir = '/Users/Carmenere/Documents/ANALYSIS/Neuroec';

if isunix
    homedir = machomedir;
    datadir = macdatadir;
    notedir = macnotedir;
end

cd(datadir)
dirandfile = datadir;
everything=dir(fullfile(dirandfile));
fn={everything.name};
subjIDs = [];
filenames = struct;
filenames.ITC = {};
filenames.loss = {};
filenames.risk = {};
filenames.fish = {};
filenames.ratio = {};

for f = 1:length(fn)
    text = fn{f};
    if length(text)>9
        subjIDs(end+1) = str2double(text(length(text)-10:length(text)-6)); %#ok<*SAGROW>
        switch text(1) %the first character of the filename
            case 'I' %ITC data
                filenames.ITC{end+1} = text;
            case 'L' %Loss aversion data
                filenames.loss{end+1} = text;
            case 'f' %fisherman data
                filenames.fish{end+1} = text;
            case 'p' %progressive ratio data
                filenames.ratio{end+1} = text;
            case 'R' %Risk aversion data
                filenames.risk{end+1} = text;
            otherwise %unexpected case
                disp('error1')
                keyboard
        end
    end
end
subjIDs = sort(subjIDs);
subjects = unique(subjIDs)'; % all the subjects who have participated
entiredata = [{'SNum'};num2cell(subjects)];
tasks = fieldnames(filenames);
for f = 1:length(tasks)
    datafiles = filenames.(tasks{f});
    tempcell = tasks(f);
    for q = 1:length(datafiles)
        txtname = datafiles{q};
        tempcell{find(subjects == str2double(txtname(end-10:end-6)))+1} = txtname;
    end
    entiredata = [entiredata, tempcell']; %#ok<*AGROW>
end
cd(notedir)
bbids =  xlsread('SummaryScores_ALLDATA_2014-04-08','A2:A224');
[empty, groups] =  xlsread('SummaryScores_ALLDATA_2014-04-08','D2:D224');
for f= 2: length(entiredata)
    ID = entiredata{f,1};
    index = find(bbids == ID);
    if ~isempty(index)
        entiredata(f,7) = groups(index);
    end
end
cd(homedir)
save neuroecentiredata.mat entiredata

%% load ITC data
clear classes

macdatadir = '/Users/Carmenere/Documents/ANALYSIS/Notes and Data/DATA/Neuroec';
machomedir = '/Users/Carmenere/Documents/ANALYSIS/Neuroec';

if isunix
    homedir = machomedir;
    datadir = macdatadir;
end

cd(homedir)
load neuroecentiredata.mat
dataTypes={  'LeftRight: ', 'AmtL: ', 'AmtR: ', 'DelL: ', 'DelR: ',...
    'Amount6.RESP: ', 'Amount6.RT: ',  'Amount14.RESP: ', 'Amount14.RT: '}; %these are the column names that we are interested in

cd(datadir)
lookingdistance = 15; %how many characters to look for after the dataname has ended
for f = 2:length(entiredata)
    f %#ok<*NOPTS>
    if ~isempty(entiredata{f,2})
        fileid=fopen(entiredata{f,2}); %gets the fileID for the given filename
        file=fread(fileid, 'uint16=>char')'; %reads in the entire textfile
        tempdata = nan(51,1);
        ITCdata = [];
        for m = 1:length(dataTypes)
            str = dataTypes{m};
            len = length(str);
            indices = strfind(file, str);
            temp = [];
            for q = 1 :length(indices)
                textSnip = file(indices(q)+len-1:indices(q)+len+lookingdistance);
                endLine=strfind(textSnip,  sprintf('\n'));
                if ~isempty(strfind(textSnip(1:endLine), 'now'))
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
        tempdata(:,1) = [];
        tempdata(find(isnan(tempdata))) = -1; %#ok<*FNDSB>
        ITCdata(:,1:5) = tempdata(:,1:5);
        chooser = tempdata(:,1);
        ITCdata(:,6) = chooser.*(1-tempdata(:,6))+(1-chooser).*tempdata(:,8); %chose delayed
        ITCdata(:,7) = chooser.*tempdata(:,7) + (1-chooser).*tempdata(:,9); %RTs
        if any(ITCdata(:,7)==0)
            keyboard
        end
        ITCdata(:,8) = chooser.*tempdata(:,6) + (1-chooser).*tempdata(:,8); %chose left
        header = {'delay on right', 'AmtL', 'AmtR', 'DelL', 'DelR', 'ChoseDelayed', 'RT', 'ChoseLeft'};
        ITCdata = [header;num2cell(ITCdata)];
        entiredata{f,2} = ITCdata;
    end
end

cd(homedir)
save neuroecentiredata.mat entiredata

%% load loss aversion data
clear classes

macdatadir = '/Users/Carmenere/Documents/ANALYSIS/Notes and Data/DATA/Neuroec';
machomedir = '/Users/Carmenere/Documents/ANALYSIS/Neuroec';

if isunix
    homedir = machomedir;
    datadir = macdatadir;
end

cd(homedir)
load neuroecentiredata.mat
dataTypes={  'Attribute1: ', 'Attribute3: ', 'choice1.RESP: ','choice1.RT: '};
cd(datadir)
lookingdistance = 15; %how many characters to look for after the dataname has ended
for f = 2:length(entiredata)
    f
    if ~isempty(entiredata{f,3})
        fileid=fopen(entiredata{f,3}); %gets the fileID for the given filename
        file=fread(fileid, 'uint16=>char')'; %reads in the entire textfile
        tempdata = nan(64,1);
        for m = 1:length(dataTypes)
            str = dataTypes{m};
            len = length(str);
            indices = strfind(file, str);
            temp = [];
            for q = 1 :length(indices)
                textSnip = file(indices(q)+len-1:indices(q)+len+lookingdistance);
                endLine=strfind(textSnip,  sprintf('\n'));
                textSnip = strtrim(textSnip(1:endLine));
                temp(end+1) = str2double(textSnip);
            end
            if length(temp) == 66
                temp = temp(3:end);
            end
            tempdata = [tempdata temp'];
        end
        tempdata(:,1) = [];
        if sum(sum(isnan(tempdata))) ~= 0
            keyboard
        end
        lossdata = {'Gain', 'Loss', 'Resp', 'RT'};
        lossdata = [lossdata; num2cell(tempdata)];
        entiredata{f,3} = lossdata;
    end
end

cd(homedir)
save neuroecentiredata.mat entiredata

%% load risk aversion data
clear classes
macdatadir = '/Users/Carmenere/Documents/ANALYSIS/Notes and Data/DATA/Neuroec';
machomedir = '/Users/Carmenere/Documents/ANALYSIS/Neuroec';

if isunix
    homedir = machomedir;
    datadir = macdatadir;
end

cd(homedir)
load neuroecentiredata.mat
dataTypes={'LeftRight: ','Attribute1: ','Attribute2: ','AmtR: ','Amount6.RESP: ','Amount6.RT: ','Amount14.RESP: ','Amount14.RT: '};
cd(datadir)
lookingdistance = 15; %how many characters to look for after the dataname has ended
for f = 2:length(entiredata)
    if ~isempty(entiredata{f,4})
        f
        fileid=fopen(entiredata{f,4}); %gets the fileID for the given filename
        file=fread(fileid, 'uint16=>char')'; %reads in the entire textfile
        tempdata = nan(60,1);
        riskdata = [];
        for m = 1:length(dataTypes)
            str = dataTypes{m};
            len = length(str);
            indices = strfind(file, str);
            temp = [];
            for q = 1 :length(indices)
                textSnip = file(indices(q)+len-1:indices(q)+len+lookingdistance);
                endLine=strfind(textSnip,  sprintf('\n'));
                textSnip = strtrim(textSnip(1:endLine));
                if m == 3 && strcmp(textSnip(1), '$')
                    textSnip = textSnip(2:end);
                end
                temp(end+1) = str2double(textSnip);
            end
            if length(temp) == 62
                temp = temp(3:end);
            end
            tempdata = [tempdata temp'];
        end
        tempdata(:,1) = [];
        subject = [tempdata(:,7) tempdata(:,5) tempdata(:,4) tempdata(:,2) tempdata(:,1)];
        % Removing trials without responses
        subject(isnan(subject(:,1)) & subject(:,5) == 0,:) = [];
        subject(isnan(subject(:,2)) & subject(:,5) == 1,:) = [];
        
        % Setting up choice
        % 0 = chose certain option
        % 1 = chose risky option
        for i = 1:size(subject)
            if subject(i,5) == 0 && subject(i,1) == 1 %reading from amount 14
                subject(i,6) = 0;
                subject(i,7) = tempdata(i,8);
                subject(i,8) = 1;
            elseif subject(i,5) == 0 && subject(i,1) == 0 %reading from amount 14
                subject(i,6) = 1;
                subject(i,7) = tempdata(i,8);
                subject(i,8) = 0;
            end
            
            if subject(i,5) == 1 && subject(i,2) == 1 %reading from amount 6
                subject(i,6) = 1;
                subject(i,7) = tempdata(i,6);
                subject(i,8) = 1;
            elseif subject(i,5) == 1 && subject(i,2) == 0 %reading from amount 6
                subject(i,6) = 0;
                subject(i,7) = tempdata(i,6);
                subject(i,8) = 0;
            end
        end
        header = {'riskyonleft', '50%amt1', '50%amt2', 'certainamt', 'choserisky', 'RT', 'ChoseLeft'};
        riskdata = [subject(:,5), subject(:,4), zeros(size(subject(:,4))), subject(:,3), subject(:,6), subject(:,7), subject(:,8)];
        riskdata = [header;num2cell(riskdata)];
        entiredata{f,4} = riskdata;
    end
end

cd(homedir)
save neuroecentiredata.mat entiredata

%% load fisherman data
clear classes
macdatadir = '/Users/Carmenere/Documents/ANALYSIS/Notes and Data/DATA/Neuroec';
machomedir = '/Users/Carmenere/Documents/ANALYSIS/Neuroec';

if isunix
    homedir = machomedir;
    datadir = macdatadir;
end

cd(homedir)
load neuroecentiredata.mat
dataTypes={  'Lake.RESP: ', 'Lake.RT: ', 'Outcome: ','RichSide: '};

cd(datadir)
lookingdistance = 15; %how many characters to look for after the dataname has ended
for f = 2:length(entiredata)
    f
    if ~isempty(entiredata{f,5})
        fileid=fopen(entiredata{f,5}); %gets the fileID for the given filename
        file=fread(fileid, 'uint16=>char')'; %reads in the entire textfile
        tempdata = nan(300,1);
        for m = 1:length(dataTypes)
            str = dataTypes{m};
            len = length(str);
            indices = strfind(file, str);
            temp = [];
            for q = 1 :length(indices)
                textSnip = file(indices(q)+len-1:indices(q)+len+lookingdistance);
                endLine=strfind(textSnip,  sprintf('\n'));
                textSnip = strtrim(textSnip(1:endLine));
                if strcmp(textSnip, 'z')
                    temp(end+1) = 1;
                elseif strcmp(textSnip, 'x')
                    temp(end+1) = 0;
                else
                    temp(end+1) = str2double(textSnip);
                end
            end
            if length(temp) == 330
                temp = temp(31:end);
            end
            tempdata = [tempdata temp'];
        end
        tempdata(:,1) = [];
        if sum(sum(isnan(tempdata))) ~= 0
            keyboard
        end
        fishdata = {'Resp', 'RT', 'catch', 'richside'};
        fishdata = [fishdata; num2cell(tempdata)];
        entiredata{f,5} = fishdata;
    end
end

cd(homedir)
save neuroecentiredata.mat entiredata

%% ITC data extraction
clear classes
clc
macdatadir = '/Users/Carmenere/Documents/ANALYSIS/Notes and Data/DATA/Neuroec';
machomedir = '/Users/Carmenere/Documents/ANALYSIS/Neuroec';

if isunix
    homedir = machomedir;
    datadir = macdatadir;
end

cd(homedir)
load neuroecentiredata.mat
newdata = [entiredata(:,1) entiredata(:,7)];
temp = {'ITC:k', 'ITC:r2','ITC:AUC','ITC:RTandQEcorr','ITC:medianRT','ITC:errorcode'};%, 'ITC:exp-k', 'ITC:exp-r2','ITC:exp-AUC','ITC:exp_RTcorr'};
for f = 2: length(entiredata)
    f
    participant = num2str(entiredata{f,1});
    data = entiredata{f,2};
    if ~isempty(data)
        percentchoseleft = (sum(cell2mat(data(2:end,8)) == 1) / (length(data)-1)) * 100;
        ITC = cell2mat(data(2:end,2:7));
        trialnum = length(ITC);
        [ITC]=removerows(ITC,'ind',ITC(:,6)==0);
        badrows = any(isnan(ITC),2);
        ITC(badrows,:) = [];
        if trialnum ~= length(ITC)
            disp(strcat('unanswered question exist for participant',num2str(participant)));
            keyboard
        end
        [subjdata] = ITCanalysis(ITC(:,5),ITC(:,1),ITC(:,3),ITC(:,2),ITC(:,4),ITC(:,6),participant);
        temp{f,1} = subjdata.k;
        temp{f,2} = subjdata.r2;
        temp{f,3} = subjdata.AUC;
        temp{f,4} = subjdata.RTandSubjValueCorr;
        temp{f,5} = subjdata.medianRT;
        temp{f,6} = subjdata.errorcode;
    end
end
newdata = [newdata temp];
cd(homedir)
save analyzeddata.mat newdata

%% loss data extraction
clear classes
clc
macdatadir = '/Users/Carmenere/Documents/ANALYSIS/Notes and Data/DATA/Neuroec';
machomedir = '/Users/Carmenere/Documents/ANALYSIS/Neuroec';

if isunix
    homedir = machomedir;
    datadir = macdatadir;
end

cd(homedir)
load neuroecentiredata.mat
load analyzeddata.mat
temp = {'Loss:Beta', 'Loss:r2','Loss:RTandQEcorr','Loss:medianRT','Loss:errorcode','Loss:noise'};
for f=2:length(entiredata)
    f
    participant = num2str(entiredata{f,1});
    data = entiredata{f,3};
    if ~isempty(data)
        gain = cell2mat(data(2:end,1));
        loss = cell2mat(data(2:end,2));
        loss = -loss;
        resp = cell2mat(data(2:end,3));
        RT = cell2mat(data(2:end,4));
        if length(gain) ~= 64 || length(loss) ~= 64 || length(resp) ~= 64 || length(RT) ~= 64
            keyboard
        end
        [subjdata] = lossfit2(gain,loss,resp,RT);
        temp{f,1} = subjdata.beta;
        temp{f,2} = subjdata.r2;
        temp{f,3} = subjdata.RTandSubjValueCorr;
        temp{f,4} = subjdata.medianRT;
        temp{f,5} = subjdata.errorcode;
        temp{f,6} = subjdata.noise;
    end
end
cd(homedir)
newdata = [newdata temp];
save analyzeddata.mat newdata

%% risk data extraction
clear classes
clc
macdatadir = '/Users/Carmenere/Documents/ANALYSIS/Notes and Data/DATA/Neuroec';
machomedir = '/Users/Carmenere/Documents/ANALYSIS/Neuroec';

if isunix
    homedir = machomedir;
    datadir = macdatadir;
end

cd(homedir)
load neuroecentiredata.mat
load analyzeddata.mat
temp = {'Risk:Alpha', 'Risk:Alpha-r2', 'Risk:RTandQEcorr', 'Risk:medianRT', 'Risk:errorcode'};
for f = 2:length(entiredata)
    f
    participant = num2str(entiredata{f,1});
    data = entiredata{f,4};
    if ~isempty(data)
        riskyamount = cell2mat(data(2:end,2));
        certainamount = cell2mat(data(2:end,4));
        choserisky = logical(cell2mat(data(2:end,5)));
        RT = cell2mat(data(2:end,6));
        [output] = riskutilityfit(riskyamount,certainamount,choserisky,RT,participant);
        temp{f,1} = output.a;
        temp{f,2} = output.r2;
        temp{f,3} = output.RTandSubjValueCorr;
        temp{f,4} = output.medianRT;
        temp{f,5} = output.errorcode;
    end
end
cd(homedir)
newdata = [newdata temp];
save analyzeddata.mat newdata

%% fisherman data extraction
clear classes
clc
macdatadir = '/Users/Carmenere/Documents/ANALYSIS/Notes and Data/DATA/Neuroec';
machomedir = '/Users/Carmenere/Documents/ANALYSIS/Neuroec';

if isunix
    homedir = machomedir;
    datadir = macdatadir;
end

cd(homedir)
load neuroecentiredata.mat
load analyzeddata.mat
temp = {'Fish:pickedrich','Fish:winandstay','Fish:loseandswitch','Fish:wontrials','Fish:pickingrich',...
    'Fish:4p_alpha','Fish:4p_LL','Fish:4P_r2',...
    'Fish:stp2p_LL','Fish:stp2p_r2',...
    'Fish:smart2p_alpha','Fish:smart2p_LL','Fish:smart2p_r2', 'Fish:4pvsstp2p_chistat'};
weirdguys = [];
regularguys = [];
for f = 2: length(entiredata)
    data = entiredata{f,5};
    f
    if ~isempty(data)
        if sum(cell2mat(data(2:end,1))==0) == (length(data)-1) || sum(cell2mat(data(2:end,1))==1) == (length(data)-1)
            keyboard
        end
        resp = (1-cell2mat(data(2:end,1)))+1;
        richside = cell2mat(data(2:end,4));
        caught = cell2mat(data(2:end,3))./10;
        pickedrich = resp == richside;
        pickedrich = pickedrich';
        pickedrich = [pickedrich(1:30);pickedrich(31:60);pickedrich(61:90);pickedrich(91:120);pickedrich(121:150);...
            pickedrich(151:180);pickedrich(181:210);pickedrich(211:240);pickedrich(241:270);pickedrich(271:300)];
        pickedrich = nanmean(pickedrich);
        winandstay = 0;
        loseandswitch = 0;
        wontrials = 0;
        for q = 1:length(resp)-1
            if caught(q) == 1
                wontrials = wontrials+1;
                if resp(q) == resp(q+1)
                    winandstay = winandstay + 1;
                end
            elseif caught(q) == 0
                if resp(q) ~= resp(q+1)
                    loseandswitch = loseandswitch + 1;
                end
            else
                keyboard
            end
        end
        winandstay = winandstay/wontrials;
        loseandswitch = loseandswitch/(300-wontrials);
        result = struct;
        result.pseudoR2 = 0;
        output = struct;
        output.pseudoR2 = 0;
        answer = struct;
        answer.pseudoR2 = 0;
        response = [resp 3-resp];
        for c = -1:1:1
            for d = -1:1:1
                for a = 0:0.1:1
                    for b = 0:1:2
                        inx = [a b c d];
                        result2 = RL_4P_Arthur(inx, response, caught);
                        if result2.pseudoR2 > result.pseudoR2
                            result = result2;
                        end
                        
                        if c == -1 && d == -1
                            init = [a b];
                            answer2 = RL_2P(init,response, caught);
                            if answer2.pseudoR2 > answer.pseudoR2
                                answer = answer2;
                            end
                        end
                    end
                end
                iny = [c d];
                output2 = RL_stupid2P(iny, response);
                if output2.pseudoR2 > output.pseudoR2
                    output = output2;
                end
            end
        end
        temp{f,1} = sum(resp == richside)/300;
        temp{f,2} = winandstay;
        temp{f,3} = loseandswitch;
        temp{f,4} = wontrials/300;
        temp{f,5} = pickedrich;
        
        temp{f,6} = result.alpha;
        temp{f,7} = result.modelLL;
        temp{f,8} = result.pseudoR2;
        
        temp{f,9} = output.modelLL;
        temp{f,10} = output.pseudoR2;
        
        temp{f,11} = answer.alpha;
        temp{f,12} = answer.modelLL;
        temp{f,13} = answer.pseudoR2;
        
        chi2stat=-2*(output.modelLL-result.modelLL);
        pvalue=1-chi2cdf(chi2stat,2)
        temp{f,14} = pvalue;
        
    end
end
cd(homedir)
newdata = [newdata temp];
save analyzeddata.mat newdata

%% ITC graphical analysis
clear classes
clc
machomedir = '/Users/Carmenere/Documents/ANALYSIS/Neuroec';
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

%% Loss aversion graphical analysis
clear classes
clc

machomedir = '/Users/Carmenere/Documents/ANALYSIS/Neuroec';
if isunix
    homedir = machomedir;
end
cd(homedir)

load neuroecentiredata.mat
load analyzeddata.mat

analyzeddata = newdata(2:end,[1,2,9:14]);
originaldata = entiredata(2:end,3);
emptyindex = cellfun('isempty',analyzeddata(:,3));

originaldata = originaldata(~emptyindex);
participant = cell2mat(analyzeddata(~emptyindex,1));
group = analyzeddata(~emptyindex,2);
beta = cell2mat(analyzeddata(~emptyindex,3));
r2 = cell2mat(analyzeddata(~emptyindex,4));
RTcorr = cell2mat(analyzeddata(~emptyindex,5));
medianRT = cell2mat(analyzeddata(~emptyindex,6));
errorcode = analyzeddata(~emptyindex,7);
noise = cell2mat(analyzeddata(~emptyindex,8));

% individual choice graphs
% selector = find(r2<=0.3);
% for index = 1:length(selector)
%     gain = cell2mat(originaldata{selector(index)}(2:end,1));
%     loss = -cell2mat(originaldata{selector(index)}(2:end,2));
%     resp = cell2mat(originaldata{selector(index)}(2:end,3));
%     figure()
%     hold on
%     plot(loss(resp==1),gain(resp==1),'bo')
%     plot(loss(resp==0),gain(resp==0),'ro')
%     ylim([0 45])
%     xlim([0 20])
%     xlabel('Loss')
%     ylabel('Gain')
%     title(strcat(num2str(participant(selector(index))), '__r2:', num2str(r2(selector(index))), '__beta:', num2str(beta(selector(index)))))
%     plot(1:20,beta(selector(index)).*(1:20),'k')
% end

qualitycontrol = find(r2<0.3);
participant(qualitycontrol) = [];
originaldata(qualitycontrol) = [];
group(qualitycontrol) = [];
beta(qualitycontrol) = [];
r2(qualitycontrol) = [];
RTcorr(qualitycontrol) = [];
medianRT(qualitycontrol) = [];
errorcode(qualitycontrol) = [];
noise(qualitycontrol) = [];


figure()
scatterhist(beta,r2,'Group',group,'Location','SouthEast','NBins',[1,30],...
    'Direction','out','Color','rgbkc','LineStyle',{'-','-','-','-','-'},...
    'LineWidth',[2,2,2,2,2],'Marker','d','MarkerSize',[4,4,4,4,4]);


[h p] = jbtest(beta);
[p stats] = vartestn(beta,group,'TestType','LeveneAbsolute')

groupcode = group;
groupcode(strcmp(groupcode,'PT')) = {1};
groupcode(strcmp(groupcode,'FM')) = {2};
groupcode(strcmp(groupcode,'NC')) = {3};
groupcode(strcmp(groupcode,'BPD')) = {4};
groupcode(strcmp(groupcode,'MDD')) = {5};
groupcode = cell2mat(groupcode);
data = [beta groupcode]
welchanova(data,0.05)
[p table stats] = kruskalwallis(beta,group);
anova1(beta,group)

x = groupcode;
for index = 1:length(x)
    x(index) = x(index) + normrnd(0, 0.1);
end
figure()
plot(x(groupcode==1),beta(groupcode==1),'ro','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',[1,0,0])
hold on
plot(x(groupcode==2),beta(groupcode==2),'go','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',[0,1,0])
plot(x(groupcode==3),beta(groupcode==3),'bo','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',[0,0,1])
plot(x(groupcode==4),beta(groupcode==4),'mo','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',[1,0,1])
plot(x(groupcode==5),beta(groupcode==5),'yo','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',[1,1,0])

[p table stats] = kruskalwallis(r2,group);

%% Risk aversion graphical analysis
clear classes
clc
machomedir = '/Users/Carmenere/Documents/ANALYSIS/Neuroec';
if isunix
    homedir = machomedir;
end
cd(homedir)

load neuroecentiredata.mat
load analyzeddata.mat
load riskversionclassifier.mat

analyzeddata = newdata(2:end,[1,2,15:19]);
originaldata = entiredata(2:end,4);
emptyindex = cellfun('isempty',analyzeddata(:,3));

originaldata = originaldata(~emptyindex);
participant = cell2mat(analyzeddata(~emptyindex,1));
group = analyzeddata(~emptyindex,2);
alpha = cell2mat(analyzeddata(~emptyindex,3));
r2 = cell2mat(analyzeddata(~emptyindex,4));
RTcorr = cell2mat(analyzeddata(~emptyindex,5));
medianRT = cell2mat(analyzeddata(~emptyindex,6));
errorcode = analyzeddata(~emptyindex,7);

% individual choice graphs
% selector = find(r2<0.3 & strcmp(group,'PT'));
% for index = 1:length(selector)
%     riskyamt = cell2mat(originaldata{selector(index)}(2:end,2));
%     certainamt = cell2mat(originaldata{selector(index)}(2:end,4));
%     choserisky = cell2mat(originaldata{selector(index)}(2:end,5));
%     figure()
%     hold on
%     plot(certainamt(choserisky==1),riskyamt(choserisky==1),'bo')
%     plot(certainamt(choserisky==0),riskyamt(choserisky==0),'ro')
%     ylim([0 100])
%     xlim([0 70])
%     xlabel('CertainAmt')
%     ylabel('RiskyAmt')
%     title(strcat(num2str(participant(selector(index))), '__r2:', num2str(r2(selector(index))), '__alpha:', num2str(alpha(selector(index)))))
%     a = alpha(selector(index));
%     plot(1:70,(2^(1/a)).*(1:70),'k')
% end

qualitycontrol = find(r2<0.3);
participant(qualitycontrol) = [];
originaldata(qualitycontrol) = [];
group(qualitycontrol) = [];
alpha(qualitycontrol) = [];
r2(qualitycontrol) = [];
RTcorr(qualitycontrol) = [];
medianRT(qualitycontrol) = [];
errorcode(qualitycontrol) = [];

figure()
scatterhist(alpha,r2,'Group',group,'Location','SouthEast','NBins',[1,30],...
    'Direction','out','Color','rgbkc','LineStyle',{'-','-','-','-','-'},...
    'LineWidth',[2,2,2,2,2],'Marker','d','MarkerSize',[4,4,4,4,4]);

[h p] = jbtest(alpha);
[p stats] = vartestn(alpha,group,'TestType','LeveneAbsolute');
[p table stats] = kruskalwallis(alpha, group);

[p table stats] = kruskalwallis(r2, group);

%% Fisherman task graphical analysis
clear classes
clc
machomedir = '/Users/Carmenere/Documents/ANALYSIS/Neuroec';
if isunix
    homedir = machomedir;
end
cd(homedir)

load neuroecentiredata.mat
load analyzeddata.mat

analyzeddata = newdata(2:end, [1,2,20:end]);
emptyindex = cellfun('isempty',analyzeddata(:,3));
participant = cell2mat(analyzeddata(~emptyindex,1));
group = analyzeddata(~emptyindex,2);
pickedrich = cell2mat(analyzeddata(~emptyindex,3));
winandstay = cell2mat(analyzeddata(~emptyindex,4));
loseandswitch = cell2mat(analyzeddata(~emptyindex,5));
wontrials = cell2mat(analyzeddata(~emptyindex,6));
pickingrich = analyzeddata(~emptyindex,7);

alpha4p = cell2mat(analyzeddata(~emptyindex,8));
LL4p = cell2mat(analyzeddata(~emptyindex,9));
r24p = cell2mat(analyzeddata(~emptyindex,10));
LL2p = cell2mat(analyzeddata(~emptyindex,11));
r22p = cell2mat(analyzeddata(~emptyindex,12));

smart2palpha = cell2mat(analyzeddata(~emptyindex,13));
smart2pLL = cell2mat(analyzeddata(~emptyindex,14));
smart2pR2 = cell2mat(analyzeddata(~emptyindex,15));

chistat = cell2mat(analyzeddata(~emptyindex,16));
power = log(2)/log(20);
transformedchistat = chistat.^power;
logchistat = log(chistat);

selector = transformedchistat<0.5;
figure()
[h] = scatterhist(transformedchistat,alpha4p,'Group',group,'Location','SouthEast','NBins',[1,30],...
    'Direction','out','Color','rgbkc','LineStyle',{'-','-','-','-','-'},...
    'LineWidth',[2,2,2,2,2],'Marker','d','MarkerSize',[4,4,4,4,4]);

[h] = scatterhist(transformedchistat,r24p,'Group',group,'Location','SouthEast','NBins',[1,30],...
    'Direction','out','Color','rgbkc','LineStyle',{'-','-','-','-','-'},...
    'LineWidth',[2,2,2,2,2],'Marker','d','MarkerSize',[4,4,4,4,4]);

[h] = scatterhist(logchistat,smart2pR2,'Group',group,'Location','SouthEast','NBins',[1,30],...
    'Direction','out','Color','rgbkc','LineStyle',{'-','-','-','-','-'},...
    'LineWidth',[2,2,2,2,2],'Marker','d','MarkerSize',[4,4,4,4,4]);

[h] = scatterhist(smart2palpha,smart2pR2,'Group',group,'Location','SouthEast','NBins',[1,30],...
    'Direction','out','Color','rgbkc','LineStyle',{'-','-','-','-','-'},...
    'LineWidth',[2,2,2,2,2],'Marker','d','MarkerSize',[4,4,4,4,4]);

alpha4p(selector) = [];
r24p(selector) = [];
group(selector) = [];


[h] = scatterhist(alpha4p,r24p,'Group',group,'Location','SouthEast','NBins',[1,30],...
    'Direction','out','Color','rgbkc','LineStyle',{'-','-','-','-','-'},...
    'LineWidth',[2,2,2,2,2],'Marker','d','MarkerSize',[4,4,4,4,4]);

%% quality control
clear classes
clc
machomedir = '/Users/Carmenere/Documents/ANALYSIS/Neuroec';
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
    if newdata{index,10}<0.3 %Loss
        for bug = 9:14
            newdata{index,bug} = 'ruledout';
        end
    end
    if newdata{index,16}<0.3 %Risk
        for bug = 15:19
            newdata{index,bug} = 'ruledout';
        end
    end
    if nanmean(newdata{index,24}(16:end))<.523
        counter = counter+1
        for bug = 20:33
            newdata{index,bug} = 'ruledout';
        end
    end
end

newdata(:,24) = [];

save controlleddata.mat newdata