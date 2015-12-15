%% in order to determine if missing trials throughout, or if one run is particularly bad
%for FNDM2
%if RT = 0, then subject did not answer question
% written by Rebecca Kazinka Summer 2015
 load('analyzeddata.mat')
for i=2:size(newdata,1)

ITC{i-1,1}=newdata{i,2}(2:51,:);
run1=cell2mat(ITC{i-1,1}(:,5));

%checks to make sure to assign to the correct run (1-4)
if     isequal(ITC{i-1,1}(2,7),{1})
newdata{i,12}=sum(run1 == 0);
elseif isequal(ITC{i-1,1}(2,7),{2})
newdata{i,13}=sum(run1 == 0);
elseif isequal(ITC{i-1,1}(2,7),{3})
newdata{i,14}=sum(run1 == 0);
elseif isequal(ITC{i-1,1}(2,7),{4})
newdata{i,15}=sum(run1 == 0);
end

% if they have at least two runs, it will run this section
if size(newdata{i,2},1)>51
ITC{i-1,2}=newdata{i,2}(52:101,:);
run2=cell2mat(ITC{i-1,2}(:,5));

%checks to make sure to assign to the correct run (1-4)
if     isequal(ITC{i-1,2}(2,7),{1})
newdata{i,12}=sum(run2 == 0);
elseif isequal(ITC{i-1,2}(2,7),{2})
newdata{i,13}=sum(run2 == 0);
elseif isequal(ITC{i-1,2}(2,7),{3})
newdata{i,14}=sum(run2 == 0);
elseif isequal(ITC{i-1,2}(2,7),{4})
newdata{i,15}=sum(run2 == 0);

end
end

% if they have at least three runs, it will run this section
if size(newdata{i,2},1)>101
ITC{i-1,3}=newdata{i,2}(102:151,:);
run3=cell2mat(ITC{i-1,3}(:,5));

%checks to make sure to assign to the correct run (1-4)
if     isequal(ITC{i-1,3}(2,7),{1})
newdata{i,12}=sum(run3 == 0);
elseif isequal(ITC{i-1,3}(2,7),{2})
newdata{i,13}=sum(run3 == 0);
elseif isequal(ITC{i-1,3}(2,7),{3})
newdata{i,14}=sum(run3 == 0);
elseif isequal(ITC{i-1,3}(2,7),{4})
newdata{i,15}=sum(run3 == 0);

end
end

% if they have four runs, it will run this section
if size(newdata{i,2},1)>151
ITC{i-1,4}=newdata{i,2}(152:201,:);
run4=cell2mat(ITC{i-1,4}(:,5));

%checks to make sure to assign to the correct run (1-4)
if     isequal(ITC{i-1,4}(2,7),{1})
newdata{i,12}=sum(run4 == 0);
elseif isequal(ITC{i-1,4}(2,7),{2})
newdata{i,13}=sum(run4 == 0);
elseif isequal(ITC{i-1,4}(2,7),{3})
newdata{i,14}=sum(run4 == 0);
elseif isequal(ITC{i-1,4}(2,7),{4})
newdata{i,15}=sum(run4 == 0);

end

end
%keyboard
save analyzeddata.mat newdata
end

