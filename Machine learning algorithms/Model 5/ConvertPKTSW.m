function [X,Y,Z] = ConvertPKTSW(revdata,label,windowsize,sliding,inputSize)

X = {};
Y = [];
Z = {};

% Extract streaming data into defined sliding window form

% Find and store edges of different benign and attack scenarios
NoScen=1;
for count=1:numel(label)-1
    if abs(revdata(1,count+1) - revdata(1,count)) > 50
        stoppoint(NoScen)=count;
        NoScen=NoScen+1;
    end
end
stoppoint(NoScen)=numel(label);

% If datasets contain only one scenario
if NoScen==1
    for t=1:fix((numel(label)-windowsize)/sliding)+1
        tem = mat2cell(revdata,[1 inputSize 1],[sliding*(t-1) windowsize numel(label)-windowsize-sliding*(t-1)]);
        X(t,1) = tem(2,2);
        Y(t,1) = max(tem{3,2});
        Z(t,1) = tem(1,2);
        clearvars tem;
    end
    
%If datasets contain multiple scenarios
else
% Get windows of the first scenario 
    for t=1:fix((stoppoint(1)-windowsize)/sliding)+1
        tem = mat2cell(revdata,[1 inputSize 1],[sliding*(t-1) windowsize numel(label)-windowsize-sliding*(t-1)]);
        X(t,1) = tem(2,2);
        Y(t,1) = max(tem{3,2});
        Z(t,1) = tem(1,2);
        clearvars tem;
    end
% Get windows of the rest scenarios    
    for j = 1: NoScen-1
        for i=1:fix((stoppoint(j+1)-stoppoint(j)-windowsize)/sliding)+1
            tem = mat2cell(revdata,[1 inputSize 1],[sliding*(i-1)+stoppoint(j) windowsize numel(label)-windowsize-sliding*(i-1)-stoppoint(j)]);
            t=t+1;
            X(t,1) = tem(2,2);
            Y(t,1) = max(tem{3,2});
            Z(t,1) = tem(1,2);
            clearvars tem;
        end
    end
end

% Remove Null data
    for count = 1:i-30
        if size(cell2mat(X(count)))==0
            X(count,:)=[];
            Y(count,:)=[];
            Z(count,:)=[];
        end
    end
end
