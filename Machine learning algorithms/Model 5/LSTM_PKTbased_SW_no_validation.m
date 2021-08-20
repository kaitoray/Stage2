%% Data preparation

% Load different CSV
BaOri='dataset/Balanced/All data (original).xlsx';
Ba1='dataset/Balanced/All data (type1).xlsx';
Ba2='dataset/Balanced/All data (type2).xlsx';
Ba3='dataset/Balanced/All data (type3).xlsx';

ImbaOri='dataset/Imbalanced/All data (original).xlsx';
Imba1='dataset/Imbalanced/All data (type1).xlsx';
Imba2='dataset/Imbalanced/All data (type2).xlsx';
Imba3='dataset/Imbalanced/All data (type3).xlsx';
Imba4='dataset/Imbalanced/All data (type4).xlsx';
Imba5='dataset/Imbalanced/All data (type5).xlsx';

% Select experiment settings (Configuration)
%Learning case
Case=Imba3;
%Testing case
sheet = 'all';
testdata=readmatrix('dataset/Imbalanced/Testing data (type3).xlsx','range',1,'Sheet',sheet);
%Define window size and sliding pace
windowsize = 8;
sliding = 1;

%% Data selection

% Read data from CSV
data=readmatrix(Case,'range',1);

% define LSTM input number
if strcmp(Case,Imba5) == 1
    inputSize = 9+7;
else
    inputSize = 9+18;   
end

% define LSTM output number
if or(strcmp(Case,BaOri),strcmp(Case,ImbaOri)) == 1
    numClasses = 1+12+8;
else
    numClasses = 1+1+8;
end

% Convert data
revdata=data';
label=revdata(end,:);
X = {};
Y = [];

%Extract streaming data into defined sliding window form 
for i=1:fix((numel(label)-windowsize)/sliding)+1
    tem = mat2cell(revdata,[inputSize 1],[sliding*(i-1) windowsize numel(label)-windowsize-sliding*(i-1)]);
    X(i,1) = tem(1,2);
    Y(i,1) = max(tem{2,2});
    clearvars tem;
end

%Devide data into train and test, X and Y
%[Xtrain,Ytrain,Xtest,Ytest] = holdout(X,Y,80);

[Xtrain,Ytrain,~,~] = holdout(X,Y,100);
Ytrain=categorical(Ytrain);

%% LSTM training

%Define ML training settings which influence the accuracy
numHiddenUnits = 200;

maxEpochs = 50;

MiniBatchSize = 128;

%ValidationFrequency = floor(numel(Y)*0.8/MiniBatchSize);

%Define layers
layers = [ ...
    sequenceInputLayer(inputSize)
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

%Define training options
options = trainingOptions('adam', ...
    'ExecutionEnvironment','cpu', ...
    'GradientThreshold',1, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',MiniBatchSize, ...
    'Shuffle','never', ...
    'Verbose',1, ...
    'VerboseFrequency',floor(numel(Y)*0.8/MiniBatchSize), ...
    'Plots','training-progress');

%Training
net = trainNetwork(Xtrain,Ytrain,layers,options);

%% LSTM testing

% Prepare testing datasets
revtestdata=testdata';
testlabel=revtestdata(end,:);
XTEST = {};
YTEST = [];

% Extract streaming data into defined sliding window form 
for i=1:fix((numel(testlabel)-windowsize)/sliding)+1
    tem = mat2cell(revtestdata,[inputSize 1],[sliding*(i-1) windowsize numel(testlabel)-windowsize-sliding*(i-1)]);
    XTEST(i,1) = tem(1,2);
    YTEST(i,1) = max(tem{2,2});
    clearvars tem;
end

[~,~,Xtest,Ytest] = holdout(XTEST,YTEST,0);
Ytest=categorical(Ytest);

% Testing and results
YPred = classify(net,Xtest);
acc = sum(YPred == Ytest)./numel(Ytest);

aFP = sum(((Ytest == '0')|(Ytest == '1')|(Ytest == '101')|(Ytest == '102')|(Ytest == '105')|(Ytest == '106')|(Ytest == '107')|(Ytest == '108')|(Ytest == '109')|(Ytest == '110')|(Ytest == '111')|(Ytest == '112')|(Ytest == '113')|(Ytest == '114'))&((YPred == '901')|(YPred == '902')|(YPred == '903')|(YPred == '904')|(YPred == '905')|(YPred == '906')|(YPred == '907')|(YPred == '908')));
aFN = sum(((Ytest == '901')|(Ytest == '902')|(Ytest == '903')|(Ytest == '904')|(Ytest == '905')|(Ytest == '906')|(Ytest == '907')|(Ytest == '908'))&((YPred == '0')|(YPred == '1')|(YPred == '101')|(YPred == '102')|(YPred == '105')|(YPred == '106')|(YPred == '107')|(YPred == '108')|(YPred == '109')|(YPred == '110')|(YPred == '111')|(YPred == '112')|(YPred == '113')|(YPred == '114')));
aOthers = sum(YPred ~= Ytest)-aFP-aFN;
aTP = sum((YPred == Ytest)&((Ytest == '901')|(Ytest == '902')|(Ytest == '903')|(Ytest == '904')|(Ytest == '905')|(Ytest == '906')|(Ytest == '907')|(Ytest == '908')));
aTN = sum((YPred == Ytest)&((Ytest == '0')|(Ytest == '1')|(Ytest == '101')|(Ytest == '102')|(Ytest == '105')|(Ytest == '106')|(Ytest == '107')|(Ytest == '108')|(Ytest == '109')|(Ytest == '110')|(Ytest == '111')|(Ytest == '112')|(Ytest == '113')|(Ytest == '114')));
