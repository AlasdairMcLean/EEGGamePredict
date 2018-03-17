function [XTrain YTrain XTest YTest xTrain xTest]=createCVData(stimulus,response,lags,cvMethod)
% createCVData
% Create test and training data for cross validation of stim to eeg, stimulus reconstruction
% and VESPA methods
%
% [XTrain YTrain XTest YTest xTrain xTest]=createCVData(stimulus,response,lags,cvMethod)
%      input -
%      lags     - Time delays between stimulus and response in samples
%               insert vector of lags
%      cvMethod - test  prediction accuracy of S2E
%               - '2fold' - divide the data into first half(training)
%               and second half(test) for 2 fold cross-validation
%               - 'r2fold' - randomized 2 fold cross-validation - takes
%               random indices

if ~exist('cvMethod','var')
    cvMethod='r2fold';
    nFolds=2;
end
nFolds=2;

nSamples=size(response,1);
nChannels=size(response,2);

if strcmp(cvMethod,'r2fold')
    cvInds = crossvalind('Kfold', nSamples, nFolds);
    testInd=find(cvInds==1);
    trainInd=setdiff(1:nSamples,testInd);
    trainN=nSamples;
    testN=nSamples;
    cutOff=0;
elseif strcmp(cvMethod,'2fold')
    cutOff=ceil(floor(nSamples/length(lags))/2)*length(lags);
    trainInd=1:cutOff-1;
    trainN=length(trainInd);
    testInd=(cutOff):(cutOff+trainN-2);
    testN=length(testInd);
else
    print('incorrect cross validation method')
    return
end
    
% create stimulus lags
% train
xTrain=zeros(trainN,1);
xTrain(trainInd)=stimulus(trainInd);
XTrain=LagGenerator(xTrain,lags);
% XTrain=cat(2,XTrain,ones(nSamples,1));

% test
xTest=zeros(testN,1);
xTest(testInd-cutOff+1)=stimulus(testInd);
XTest=LagGenerator(xTest,lags);
% XTest=cat(2,XTest,ones(nSamples,1));

% neural response
% train
Y=response;
YTrain=zeros(trainN,nChannels);
YTrain(trainInd,:)=Y(trainInd,:);

% test
YTest=zeros(testN,nChannels);
YTest(testInd-cutOff+1,:)=Y(testInd,:);


