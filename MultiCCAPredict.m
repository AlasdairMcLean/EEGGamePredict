function MultiCCAPredict(feature2run,condition,num)

addpath(genpath('.')); %necessary for accessing the data

% Valid inputs from featuresCut

% muFlow:               [5290×1 double]
% muSqFlow:             [5290×1 double]
% muTemporalContrast:   [5290×1 double]
% muSqTemporalContrast: [5290×1 double]
% muLuminance:          [5290×1 double]
% muSqLuminance:        [5290×1 double]
% muLocalContrast:      [5290×1 double]
% muSqLocalContrast:    [5290×1 double]
% stdLocalContrast:     [5290×1 double]



%If cloning from github: Leave the following path and data will load; if
%data is elsewhere, modify to local path

%pull the correct dataset from the user input
if strcmp(condition,'play') && num==1
    readyDataFilename='sample ARL data/013/play/11_28_17_01_ready_data'; 
elseif strcmp(condition,'watch') && num==1
    readyDataFilename='sample ARL data/013/watch/11_28_17_01_ready_data'; 
elseif strcmp(condition,'bci') && num==1
    readyDataFilename='sample ARL data/013/bci/11_28_17_01_ready_data'; 
elseif strcmp(condition,'play') && num==2
    readyDataFilename='sample ARL data/013/play/11_28_17_02_ready_data'; 
elseif strcmp(condition,'watch') && num==2
    readyDataFilename='sample ARL data/013/watch/11_28_17_02_ready_data'; 
elseif strcmp(condition,'bci') && num==2
    readyDataFilename='sample ARL data/013/bci/11_28_17_02_ready_data'; 
end


fs=30; % sampling rate
nComp=5; % number of components to DISPLAY (all are analyzed)

Kx=20; % regularization parameter on the stimulus (reduce for higher reg.)
Ky=20; % regularization parameter on the EEG (reduce for higher reg.)

Ks=fs/2; % Starting temporal window length (0.5s)
Ke=7*fs; % Ending temporal window length (3s)
Ki=1; % Temporal window increment (1/30s)


% load the data
load(readyDataFilename);

% load the desired stimulus feature
eval(['stim=featuresCut.' feature2run ';']);


% normalize feature
stim=zscore(stim);
top3rhos=zeros(length(Ks:Ki:Ke),3); %preallocate an array to hold the top 3 rho vals
count=uint8(0); %start a low-memory counter
for K=Ks:Ki:Ke %iterate through temporal windows
    count=count+uint8(1); %add to the count since our increment != index
    %make a convolution matrix extending forwards and one temporal window
    %back
    stim_tpl=revtplitz(stim,K,K);

    % correlate the EEG with the stimulus (canonical correlation analysis)
    [A,B,rhos,~,~,~,Rxx,Ryy] = myCanonCorr(stim_tpl,eeg(:,K+1:end),Kx,Ky);
    %Bk=B(:,1:nComp);
    %forwards=Ryy*Bk*inv(Bk'*Ryy*Bk);
    top3rhos(count,:)=rhos(1:3); %assign the top 3 rho values in 
end
% plot the top 3 rho values as a function of temporal window
figure;

%plot the three top rho values corresponding to the temporal window we ran
%them at
plot(Ks/fs:Ki/fs:Ke/fs,top3rhos(:,1),Ks/fs:Ki/fs:Ke/fs,top3rhos(:,2),Ks/fs:Ki/fs:Ke/fs,top3rhos(:,3));
xlabel('Length of temporal window (s)');
ylabel('rho vals')
title(['Varying temporal window: ' feature2run ' ' condition ' ' num2str(num)])


