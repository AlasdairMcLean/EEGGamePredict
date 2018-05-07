clear all; close all; clc
addpath(genpath('.'));
feature2run='muSqTemporalContrast';

% ALASDAIR: change the path below to wherever you put the data on your
% machine

%readyDataFilename='sample ARL data/013/play/11_28_17_01_ready_data';  
% playing the game

%readyDataFilename='sample ARL data/013/bci/11_28_17_01_ready_data'; 
% mock bci

readyDataFilename='sample ARL data/013/watch/11_28_17_01_ready_data'; 
% watching the game

fs=30; % sampling rate
nComp=5; % number of components to DISPLAY (all are analyzed)
K=75; % length of temporal window (1 sec minus 1 sample, in this case)
Kx=20; % regularization parameter on the stimulus (reduce for higher reg.)
Ky=20; % regularization parameter on the EEG (reduce for higher reg.)

% load the data
load(readyDataFilename);

% load the desired stimulus feature
eval(['stim=featuresCut.' feature2run ';']);

% normalize feature
stim=zscore(stim);

% make a convolution matrix for temporally filtering the stimulus
% ALASDAIR: take a look at the tplitz function carefully; this is what you
% will have to edit (or make your own, non-causal version)
stim_tpl=revtplitz(stim,K,K);

% correlate the EEG with the stimulus (canonical correlation analysis)
[A,B,rhos,~,~,~,Rxx,Ryy] = myCanonCorr(stim_tpl,eeg,Kx,Ky);
Bk=B(:,1:nComp);
forwards=Ryy*Bk*inv(Bk'*Ryy*Bk);

% show the correlations and the scalp maps
figure;
for c=1:nComp
    subplot(1,nComp,c);
    topoplot(forwards(:,c),'JBhead96_sym.loc');
    title(sprintf('rho=%0.2f',rhos(c)));
end
