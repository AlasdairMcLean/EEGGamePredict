Multiple Canonical correlation analysis:

trial 13 from Nov.13 2017



code available online from https://github.com/AlasdairMcLean/EEGGamePredict

code run using RunMultiCCAPredict.m
to use, in matlab run:
MultiCCApredict(feature2run, condition, num)

where feature2run is a char array corresponding to the feature from featuresCut
valid entries:
% muFlow: [5290×1 double]
% muSqFlow: [5290×1 double]
% muTemporalContrast: [5290×1 double]
% muSqTemporalContrast: [5290×1 double]
% muLuminance: [5290×1 double]
% muSqLuminance: [5290×1 double]
% muLocalContrast: [5290×1 double]
% muSqLocalContrast: [5290×1 double]
% stdLocalContrast: [5290×1 double]

where condition is a char array corresponding to one of the three test conditions
valid entries:
play
bci
watch

where num is a double precision floating point number corresponding to the run number
valid entries:
1
2



Parameters:

Foldername=featuresCut feature

data: sample ARL data/013/[condition]/11_28_17_0[num]_ready_data

conditions: {play, watch, bci}

nums: {1, 2}

sampling rate: 30sps

stimulus regularization parameter (Kx): 20
EEG regularization parameter (Ky): 20

temporal window varied between 0.5s to 3s in increments of 1/30s


Description:

stimdata is formed into a toeplitz matrix with temporal window extending back and forwards from 'present' time

data is canonically correlated and the top three canonical correlation coefficients (rho) are graphed.
