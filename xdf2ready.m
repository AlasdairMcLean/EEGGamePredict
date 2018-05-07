clear all; close all; clc
dataPath='C:/Users/JacekSuper/Dropbox/ARL/data/';
dataPathSuper='D:/ARL/data/';
subjStr='018/';
condStr='play/';

% all mat files (both features and eeg) should be saved on the dropbox
matDataPath=[dataPath subjStr condStr 'mat/'];

% xdf files and video files reside on the supercomputer
xdfDataPath=[dataPathSuper subjStr condStr 'xdf/'];
aviDataPath=[dataPathSuper subjStr condStr 'avi/downsampled/'];

xdfFilenames=dir([xdfDataPath '*.xdf']);
stimFilenames=dir([matDataPath '*-features-*.mat']);

if numel(xdfFilenames)~=numel(stimFilenames)
    error('mismatch detected between xdf and feature mat files');
end
nRaces=numel(xdfFilenames);

trigger_onset_value=5376-4352; % threshold
SCREEN_CODE=220; % threshold on the value of photodiode flashes in top corner
fs=30; % FIX THIS (it's for opts in myPreprocess)

% preprocessing options
opts.Q1=1;
opts.Q2=4;
opts.zero=1;
opts.xtent=12;
opts.showSvd=0;
opts.nChan2Keep=96;
opts.rpca=1;
opts.fs=fs;
opts.fsref=fs;
opts.locfile='JBhead96_sym.loc'; % wild guess
opts.chanlocs=[];
opts.fl=0.7; % passband low
opts.fh=fs/2; % passband high
virtualeog=zeros(96,4);
virtualeog([1 34],1)=1;
virtualeog([2 35],2)=1;
virtualeog(1,3)=1;
virtualeog(2,3)=-1;
virtualeog(33,4)=1;
virtualeog(36,4)=-1;
opts.virtualeog=virtualeog;

for r = 1:nRaces
    
    xdfFilename=xdfFilenames(r).name;
    stimFilename=stimFilenames(r).name;
    
    eegFilename=[xdfFilename(1:end-4) '_eeg_and_trigger.mat'];
    saveFilename=[xdfFilename(1:end-4) '_ready_data.mat']; % where the clean data will be saved
    
    %%
    outFilename=readXdfRecord(xdfFilename,xdfDataPath,matDataPath,trigger_onset_value);
    [eeg_series_cut_resample,featuresCut] = alignStimWithEEG(outFilename,fullfile(matDataPath,stimFilename),SCREEN_CODE);
    eeg = myPreprocess(eeg_series_cut_resample,opts);
    delete(outFilename); % we don't need the non-epoched EEG and trigger series
    
    %%
    save(fullfile(matDataPath,saveFilename),'eeg','featuresCut','fs','opts')
    
end
