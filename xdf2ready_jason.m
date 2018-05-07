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

    
    %% read and xdf and trigger
    %   outFilename=readXdfRecord(xdfFilename,xdfDataPath,matDataPath,trigger_onset_value);
    writeDataPath='/Users/jacekdmochowski/Dropbox/ARL/data/'
    xdfRoot=xdfFilename(1:end-4);
    outFilename=fullfile(writeDataPath,[xdfRoot '_eeg_and_trigger.mat']);
    
    %read all streams into matlab
    tic;
    [streams,fileheader] = load_xdf(fullfile(xdfDataPath,xdfFilename));
    disp('xdf loading:')
    xdfLoadingTime = toc;

    % Streams metadata
    dataXdfStreamName='BrainAmpSeries';
    triggerXdfStreamName='BrainAmpSeries-Markers';
    trigger_onset_value=5376-4352;
    
    % find the EEG stream
    nStreams=numel(streams);
    for s=1:nStreams
        thisStream=streams{s};
        thisName=thisStream.info.name;
        if strcmp(thisName,dataXdfStreamName)
            eeg_series=thisStream.time_series;
            eeg_stamps=thisStream.time_stamps;
            eeg_fs=str2num(thisStream.info.nominal_srate);
        elseif strcmp(thisName,triggerXdfStreamName)
            trigger_series=thisStream.time_series;
            trigger_stamps=thisStream.time_stamps;
            trigger_fs=str2num(thisStream.info.nominal_srate);
        end
    end
    
    % convert trigger series from strings to numeric
    % trigger_series_numeric=cellfun(@str2num,trigger_series);
    trigger_series_numeric=str2num(cell2mat(trigger_series'))'; % faster computation time
    
    diff_trigger_series_numeric=diff(trigger_series_numeric);
    diff_trigger_series_numeric=cat(2,0,diff_trigger_series_numeric);
    onsets=find(diff_trigger_series_numeric==trigger_onset_value);

    %% Align stimulus and eeg
    % [eeg_series_cut_resample,featuresCut] = alignStimWithEEG(outFilename,fullfile(matDataPath,stimFilename),SCREEN_CODE);
    stimFilePath=fullfile(matDataPath,stimFilename);
    load(stimFilePath,'features');
    fps=features.fs;
    diode=features.diode;
    
    
    
    %% manually epoch photodiode trigger to discard unwanted data
    [trigger_stamps_cut,trigger_series_numeric_cut]=cutTrigger(trigger_stamps,trigger_series_numeric);
    diff_trigger_series_numeric_cut=cat(2,0,diff(trigger_series_numeric_cut));
    onsets_indices=find(diff_trigger_series_numeric_cut==TRIGGER_CODE);
    if isempty(onsets_indices)
        error('No ActiChamp events found');
    end
    
    onsets_time=trigger_stamps_cut(onsets_indices);
    
    %% figure out time of on-screen flashes from frame sequence
    nFrames=numel(diode);
    diode_series=diode.'; % keep variable name consistency
    diode_time=(0:nFrames-1)/fps;
    diff_diode_series=cat(2,0,diff(diode_series));
    %diode_onsets_indices=find(diff_diode_series==SCREEN_CODE);
    diode_onsets_indices=find(diff_diode_series>SCREEN_CODE);
    if isempty(diode_onsets_indices)
        error('No screen flashes found');
    end
    diode_onsets_time=diode_time(diode_onsets_indices);
    frameSamplesKept=diode_onsets_indices(1):diode_onsets_indices(end);
    nFrameSamplesKept=numel(frameSamplesKept);
    
    %% cut up the EEG based on first and last triggers
    [~,eeg_stamp_start_index]=min(abs(eeg_stamps-onsets_time(1)));
    
    if numel(onsets_time)==numel(diode_onsets_time)+1
        [~,eeg_stamp_stop_index]=min(abs(eeg_stamps-onsets_time(end-1)));
    else
        warning('Number of flash onsets does not match.  Check recording.');
        numel(onsets_time)
        numel(diode_onsets_time)
        [~,eeg_stamp_stop_index]=min(abs(eeg_stamps-onsets_time(end)));
        
    end
    eegSamplesKept=eeg_stamp_start_index:eeg_stamp_stop_index;
    eeg_stamps_cut=eeg_stamps(eegSamplesKept);
    eeg_series_cut=eeg_series(:,eegSamplesKept);
    
    %% resample the eeg to the frame rate of the video
    eeg_series_cut_resample=(resample(eeg_series_cut.',fps,eeg_fs)).';
    nEEGresamplesKept=size(eeg_series_cut_resample,2);
    
    %% logic bit to make the stim and eeg same length
    if nEEGresamplesKept>nFrameSamplesKept
        nSamplesToRemove=nEEGresamplesKept-nFrameSamplesKept;
        eeg_series_cut_resample=eeg_series_cut_resample(:,1:end-nSamplesToRemove);
    elseif nEEGresamplesKept<nFrameSamplesKept
        nSamplesToRemove=nFrameSamplesKept-nEEGresamplesKept;
        frameSamplesKept=frameSamplesKept(1:end-nSamplesToRemove);
    else
        % lengths match
    end
    
    % cut up the stimulus features based on the first and last flashes in top corner
    featuresCut=features;
    featuresCut.muFlow=features.muFlow(frameSamplesKept);
    featuresCut.muSqFlow=features.muSqFlow(frameSamplesKept);
    featuresCut.muTemporalContrast=features.muTemporalContrast(frameSamplesKept);
    featuresCut.muSqTemporalContrast=features.muSqTemporalContrast(frameSamplesKept);
    featuresCut.muLuminance=features.muLuminance(frameSamplesKept);
    featuresCut.muSqLuminance=features.muSqLuminance(frameSamplesKept);
    featuresCut.muLocalContrast=features.muLocalContrast(frameSamplesKept);
    featuresCut.stdLocalContrast=features.stdLocalContrast(frameSamplesKept);
    featuresCut.muSqLocalContrast=features.muSqLocalContrast(frameSamplesKept);
    featuresCut.diode=features.diode(frameSamplesKept);
    if numel(features.soundEnvelopeDown)>=frameSamplesKept
        featuresCut.soundEnvelopeDown=features.soundEnvelopeDown(frameSamplesKept);
    else
        warning('Excluding sound envelope due to insufficient samples');
    end

    eeg = myPreprocess(eeg_series_cut_resample,opts);
    delete(outFilename); % we don't need the non-epoched EEG and trigger series
    
    %%
    save(fullfile(matDataPath,saveFilename),'eeg','featuresCut','fs','opts')
    
end