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
Imba5='dataset/Imbalanced/All data (type5).xlsx';

% Select experiment settings (Configuration)
%Learning case
Case=Imba5;


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
x = data(:,1:end-1);
y = categorical(data(:,end));


% Assign xtrain, ytrain, xtest
Xtrain = {x'}';
Ytrain = {y'}';

%% LSTM training

%Define hidden neurons 
numHiddenUnits = 200;

%Define layers
layers = [ ...
    sequenceInputLayer(inputSize)
    bilstmLayer(numHiddenUnits,'OutputMode','sequence')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

maxEpochs = 50;

%Define training options
options = trainingOptions('adam', ...
    'ExecutionEnvironment','cpu', ...
    'GradientThreshold',2, ...
    'MaxEpochs',maxEpochs, ...
    'Shuffle','never', ...
    'Verbose',1, ...
    'Plots','training-progress');

%Training
net = trainNetwork(Xtrain,Ytrain,layers,options);

%% LSTM testing
% Prepare testing datasets
sheet = 'all';
testdata=readmatrix('dataset/Imbalanced/Testing data (type5).xlsx','range',1,'Sheet',sheet);

% Convert data
x = testdata(:,1:end-1);
y = categorical(testdata(:,end));

% Assign xtrain, ytrain, xtest
Xtest = {x'}';
Ytest = {y'}';

YPred = classify(net,Xtest);
Ypredict = categorical(YPred{1,1})';
acc = sum(Ypredict == y)./numel(y);

aFP = sum(((y == '0')|(y == '1')|(y == '101')|(y == '102')|(y == '105')|(y == '106')|(y == '107')|(y == '108')|(y == '109')|(y == '110')|(y == '111')|(y == '112')|(y == '113')|(y == '114'))&((Ypredict == '901')|(Ypredict == '902')|(Ypredict == '903')|(Ypredict == '904')|(Ypredict == '905')|(Ypredict == '906')|(Ypredict == '907')|(Ypredict == '908')));
aFN = sum(((y == '901')|(y == '902')|(y == '903')|(y == '904')|(y == '905')|(y == '906')|(y == '907')|(y == '908'))&((Ypredict == '0')|(Ypredict == '1')|(Ypredict == '101')|(Ypredict == '102')|(Ypredict == '105')|(Ypredict == '106')|(Ypredict == '107')|(Ypredict == '108')|(Ypredict == '109')|(Ypredict == '110')|(Ypredict == '111')|(Ypredict == '112')|(Ypredict == '113')|(Ypredict == '114')));
aOthers = sum(Ypredict ~= y)-aFP-aFN;
aTP = sum((Ypredict == y)&((y == '901')|(y == '902')|(y == '903')|(y == '904')|(y == '905')|(y == '906')|(y == '907')|(y == '908')));
aTN = sum((Ypredict == y)&((y == '0')|(y == '1')|(y == '101')|(y == '102')|(y == '105')|(y == '106')|(y == '107')|(y == '108')|(y == '109')|(y == '110')|(y == '111')|(y == '112')|(y == '113')|(y == '114')));
