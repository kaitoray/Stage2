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

% Select case (changeable)
Case=Imba5;

% Read data from CSV
data=readmatrix(Case,'range',1);

% Cross Validation
[train,~] = holdout(data,100);

% Test set
% Xtest=test(:,1:end-1);Ytest=test(:,end);

% new Test set
testdata=readmatrix('dataset/Imbalanced/Testing data (type5).xlsx','range',1);
[~,test] = holdout(testdata,0);
Xtest=test(:,1:end-1);Ytest=test(:,end);


% Traing set
Xtrain=train(:,1:end-1);Ytrain=train(:,end);

%% Training Side
trainperf_=[];

for k=1:10
    
    % create a k Nearest Neighbour model
    kNNModel = fitcknn(Xtrain,Ytrain,'NumNeighbors',k); % kNNModel is the trained model. save it at end for doing testing

    % train performance
    trainlabel = predict(kNNModel,Xtrain);

    train_perf=sum(trainlabel==Ytrain)/size(trainlabel,1) % performance in the range of 0 to 1
    
    trainperf_=[trainperf_; k train_perf];
end

[max_fm, indx]=max(trainperf_(:,2));
k_optimal=trainperf_(indx,1)

% Use the k_optimal to train
kNNModel = fitcknn(Xtrain,Ytrain,'NumNeighbors',k_optimal); % kNNModel is the trained model. save it at end for doing testing
save('kNNModel.mat','kNNModel');

% train performance
trainlabel = predict(kNNModel,Xtrain);

train_perf=sum(trainlabel==Ytrain)/size(trainlabel,1) % performance in the range of 0 to 1

%% Testing data

% for testing load the trained model
load('kNNModel.mat');
YPred = predict(kNNModel,Xtest);

accuracy=sum(YPred==Ytest)/size(YPred,1)

aFP = sum((Ytest < 200)&(YPred > 900));
aFN = sum((Ytest > 900)&(YPred < 200));
aOthers = sum(YPred ~= Ytest)-aFP-aFN;
aTP = sum((YPred == Ytest)&(Ytest > 900));
aTN = sum((YPred == Ytest)&(Ytest < 200));