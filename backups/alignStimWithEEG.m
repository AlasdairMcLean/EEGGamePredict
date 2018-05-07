clear all; close all; clc

dataPath='/Users/jacekdmochowski/Dropbox/ARL/data/';
subjStr='013';
condStr='play';
dateStr='11_28_17';
raceNumber=1;

eegFilename=[dataPath subjStr '/' condStr '/xdf/' dateStr '_0' num2str(raceNumber) '_eeg_and_trigger.mat'];

stimStr='2017-11-28 17-08-34-features-05-Mar-2018.mat'; %
stimFilename=[dataPath subjStr '/' condStr '/avi/downsampled/' stimStr];

outFilename=[dataPath subjStr '/' condStr '/xdf/' dateStr '_0' num2str(raceNumber) '_epoched_eeg_and_stimulus.mat'];
%%
fps=30;
eeg_fs=5000;
SCREEN_CODE=255; % for the avi frame sequence
TRIGGER_CODE=1024; % for ActiChamp auxiliary channel

load(eegFilename);
load(stimFilename);

%diode=mean(squeeze(mean(videoEpoched(1:3,end-2:end,:),1)),1);

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
%diode_series=diode; % keep variable name consistency
diode_time=(0:nFrames-1)/fps;
diff_diode_series=cat(2,0,diff(diode_series));
%diode_onsets_indices=find(diff_diode_series==SCREEN_CODE);
diode_onsets_indices=find(diff_diode_series>220);
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

save(outFilename,'eeg_series_cut_resample','featuresCut');


%%
% feature=muFlow(:).';
% feature_cut=feature(frameSamplesKept);
% for ch=1:96
% [r,p]=corrcoef(feature_cut,eeg_series_cut_resample(ch,:));
% rho(ch)=r(1,2);
% end
