clear all; close all; clc
addpath(genpath('.'));
feature2run='muSqTemporalContrast';


%If cloning from github: Leave the following path and data will load; if
%data is elsewhere, modify to local path
readyDataFilename='sample ARL data/013/watch/11_28_17_01_ready_data'; 

fs=30; % sampling rate
nComp=5; % number of components to DISPLAY (all are analyzed)

Kx=20; % regularization parameter on the stimulus (reduce for higher reg.)
Ky=20; % regularization parameter on the EEG (reduce for higher reg.)

Ks=fs/2; % Starting temporal window length (0.5s)
Ke=5*fs; % Ending temporal window length (3s)
Ki=1; % Temporal window increment (1/30s)


% load the data
load(readyDataFilename);

% load the desired stimulus feature
eval(['stim=featuresCut.' feature2run ';']);

% normalize feature
stim=zscore(stim);
top3rhos=zeros(length(Ks:Ki:Ke),3);
count=uint8(0);
for K=Ks:Ki:Ke
    count=count+uint8(1);
    %make a convolution matrix extending forwards and one temporal window
    %back
    stim_tpl=revtplitz(stim,K,K);

    % correlate the EEG with the stimulus (canonical correlation analysis)
    [A,B,rhos,~,~,~,Rxx,Ryy] = myCanonCorr(stim_tpl,eeg(:,K+1:end),Kx,Ky);
    %Bk=B(:,1:nComp);
    %forwards=Ryy*Bk*inv(Bk'*Ryy*Bk);
    top3rhos(count,:)=rhos(1:3); %assign the top 3 rho values in 
end
% show the correlations and the scalp maps
figure;

plot(Ks/fs:Ki/fs:Ke/fs,top3rhos(:,1),Ks/fs:Ki/fs:Ke/fs,top3rhos(:,2),Ks/fs:Ki/fs:Ke/fs,top3rhos(:,3));
xlabel('Length of temporal window (s)');
ylabel('rho vals')
title('Corre
%for c=1:nComp
%    subplot(1,nComp,c);
%    topoplot(forwards(:,c),'JBhead96_sym.loc');
%    title(sprintf('Optimal tempwin= %0.2f  rho=%0.2f',max(top3rhos(:,1)),rhos(c)));
%end


