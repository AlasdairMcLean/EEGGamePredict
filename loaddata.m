%quick script to quickly load and normalize a specific feature for matlab analysis


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
nComp=8; % number of components to DISPLAY (all are analyzed)
K=fs-1; % length of temporal window (1 sec minus 1 sample, in this case)
Kx=20; % regularization parameter on the stimulus (reduce for higher reg.)
Ky=20; % regularization parameter on the EEG (reduce for higher reg.)

% load the data
load(readyDataFilename);

% load the desired stimulus feature
eval(['stim=featuresCut.' feature2run ';']);

% normalize feature
stim=zscore(stim);