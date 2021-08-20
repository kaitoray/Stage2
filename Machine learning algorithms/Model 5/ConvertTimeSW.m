function [X,Y,Z] = ConvertTimeSW(revdata,label,windowsize,sliding,inputSize)

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

% If only one scenario
if NoScen==1
% Get the first window
    for k = 1:fix((revdata(1,stoppoint(1))-revdata(1,1))/sliding)-windowsize+1
        if and(revdata(1,k+1) >= (revdata(1,1) + windowsize),revdata(1,k) <= (revdata(1,1) + windowsize))
            tem = mat2cell(revdata,[1 inputSize 1],[k numel(label)-k]);
            X(1,1) = tem(2,1);
            Y(1,1) = max(tem{3,1});
            Z(1,1) = tem(1,1);
            clearvars tem;
        end
    end
% Get the rest windows
    for t=1:fix((revdata(1,stoppoint(1))-revdata(1,1))/sliding)-windowsize+1
        for j=1:stoppoint(1)-1
            if and(revdata(1,j+1) >= (revdata(1,1) + sliding*t),revdata(1,j) <= (revdata(1,1) + sliding*t))
                for k = j:stoppoint(1)-1
                    if and(revdata(1,k+1) >= (revdata(1,j+1) + windowsize),revdata(1,k) <= (revdata(1,j+1) + windowsize))
                        tem = mat2cell(revdata,[1 inputSize 1],[j k-j numel(label)-k]);
                        X(t+1,1) = tem(2,2);
                        Y(t+1,1) = max(tem{3,2});
                        Z(t+1,1) = tem(1,2);
                        clearvars tem;
                    end
                end
            end
        end
    end
    
%If datasets contain multiple scenarios
else
% Get the first window of the first scenario    
    for k = 1:fix((revdata(1,stoppoint(1))-revdata(1,1))/sliding)-windowsize+1
        if and(revdata(1,k+1) >= (revdata(1,1) + windowsize),revdata(1,k) <= (revdata(1,1) + windowsize))
            tem = mat2cell(revdata,[1 inputSize 1],[k numel(label)-k]);
            X(1,1) = tem(2,1);
            Y(1,1) = max(tem{3,1});
            Z(1,1) = tem(1,1);
            clearvars tem;
        end
    end
% Get the rest windows of the first scenario
    for t=1:fix((revdata(1,stoppoint(1))-revdata(1,1))/sliding)-windowsize+1
        for j=1:stoppoint(1)
            if and(revdata(1,j+1) >= (revdata(1,1) + sliding*t),revdata(1,j) <= (revdata(1,1) + sliding*t))
                for k = j:stoppoint(1)
                    if and(revdata(1,k+1) >= (revdata(1,j+1) + windowsize),revdata(1,k) <= (revdata(1,j+1) + windowsize))
                        tem = mat2cell(revdata,[1 inputSize 1],[j k-j numel(label)-k]);
                        X(t+1,1) = tem(2,2);
                        Y(t+1,1) = max(tem{3,2});
                        Z(t+1,1) = tem(1,2);
                        clearvars tem;
                    end
                end
            end
        end
    end
% Get the first window of the rest scenarios (except the last one)
    for x=1:NoScen-2
        for k = stoppoint(x)+1:stoppoint(x+1)
            if and(revdata(1,k+1) >= (revdata(1,stoppoint(x)+1) + windowsize),revdata(1,k) <= (revdata(1,stoppoint(x)+1) + windowsize))
                tem = mat2cell(revdata,[1 inputSize 1],[stoppoint(x) k-stoppoint(x) numel(label)-k]);
                t=t+2;
                X(t,1) = tem(2,2);
                Y(t,1) = max(tem{3,2});
                Z(t,1) = tem(1,2);
                clearvars tem;
            end
        end
% Get the rest windows of the rest scenarios (except the last one)
        for CountSlding=1:fix((revdata(1,stoppoint(x+1))-revdata(1,stoppoint(x)+1))/sliding)-windowsize+1
            for j=stoppoint(x)+1:stoppoint(x+1)
                if and(revdata(1,j+1) >= (revdata(1,stoppoint(x)+1) + sliding*CountSlding),revdata(1,j) <= (revdata(1,stoppoint(x)+1) + sliding*CountSlding))
                    for k = j:stoppoint(x+1)
                        if and(revdata(1,k+1) >= (revdata(1,j+1) + windowsize),revdata(1,k) <= (revdata(1,j+1) + windowsize))
                            tem = mat2cell(revdata,[1 inputSize 1],[j k-j numel(label)-k]);
                            t=t+1;
                            X(t,1) = tem(2,2);
                            Y(t,1) = max(tem{3,2});
                            Z(t,1) = tem(1,2);
                            clearvars tem;
                        end
                    end
                end
            end
        end
    end
% Get the first window of the last scenarios
    for k = stoppoint(NoScen-1)+1:stoppoint(NoScen)-1
        if and(revdata(1,k+1) >= (revdata(1,stoppoint(NoScen-1)+1) + windowsize),revdata(1,k) <= (revdata(1,stoppoint(NoScen-1)+1) + windowsize))
            tem = mat2cell(revdata,[1 inputSize 1],[stoppoint(NoScen-1) k-stoppoint(NoScen-1) numel(label)-k]);
            t=t+1;
            X(t,1) = tem(2,2);
            Y(t,1) = max(tem{3,2});
            Z(t,1) = tem(1,2);
            clearvars tem;
        end
    end
% Get the last window of the last scenarios
    for CountSlding=1:fix((revdata(1,stoppoint(NoScen))-revdata(1,stoppoint(NoScen-1)+1))/sliding)-windowsize+1
        for j=stoppoint(NoScen-1)+1:stoppoint(NoScen)-1
            if and(revdata(1,j+1) >= (revdata(1,stoppoint(NoScen-1)+1) + sliding*CountSlding),revdata(1,j) <= (revdata(1,stoppoint(NoScen-1)+1) + sliding*CountSlding))
                for k = j:stoppoint(NoScen)-1
                    if and(revdata(1,k+1) >= (revdata(1,j+1) + windowsize),revdata(1,k) <= (revdata(1,j+1) + windowsize))
                        tem = mat2cell(revdata,[1 inputSize 1],[j k-j numel(label)-k]);
                        t=t+1;
                        X(t,1) = tem(2,2);
                        Y(t,1) = max(tem{3,2});
                        Z(t,1) = tem(1,2);
                        clearvars tem;
                    end
                end
            end
        end
    end
% Remove Null data
    for count = 1:t-30
        if size(cell2mat(X(count)))==0
            X(count,:)=[];
            Y(count,:)=[];
            Z(count,:)=[];
        end
    end
end
