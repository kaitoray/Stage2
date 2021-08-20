function [xtrain,ytrain,xtest,ytest] = holdout( A,B,p )
n=size(A,1);
trdata=floor((n*p*0.01));
tedata=n-trdata;
index=randperm(n);
xtrain={};
xtest={};
ytrain=[];
ytest=[];
for i=1:trdata
    xtrain(i,1)=A(index(i),1);
    ytrain(i,1)=B(index(i),1);
end
for i=1:tedata
    xtest(i,1)=A(index(i+trdata),1);
    ytest(i,1)=B(index(i+trdata),1);
end



end

