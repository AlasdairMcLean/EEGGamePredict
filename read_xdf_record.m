% rip the raw EEG + photodiode data from XDF record 
function outFilename = readXdfRecord(dataPath,xdfFilename,trigger_onset_value,triggerXdfStreamName,dataXdfStreamName)



addpath(genpath('.'));

subjStr='013';
condStr='play';
dateStr='11_28_17';
raceNumber=1;

%dataPath='/Users/jacekdmochowski/Dropbox/ARL/data/';
%triggerXdfStreamName='BrainAmpSeries-Markers';  % streams.info.name for the trigger
%dataXdfStreamName='BrainAmpSeries';  % streams.info.name for the data
%trigger_onset_value=5376-4352;


%% form the xdf filename
%xdfFilename=[dataPath subjStr '/' condStr '/xdf/' dateStr '_0' num2str(raceNumber) '.xdf'];
xdfFilename=fullfile(dataPath,xdfFilename);
outFilename=fullfile(dataPath,'xxx.mat');
outFilename=[dataPath subjStr '/' condStr '/xdf/' dateStr '_0' num2str(raceNumber) '_eeg_and_trigger.mat'];


%% read all streams into matlab
[streams,fileheader] = load_xdf(xdfFilename);

%% find the EEG stream
nStreams=numel(streams);
for s=1:nStreams
   thisStream=streams{s};
   thisName=thisStream.info.name;
   if strcmp(thisName,dataXdfStreamName)
       eeg_series=thisStream.time_series;
       eeg_stamps=thisStream.time_stamps;
       eeg_fs=thisStream.info.nominal_srate;
   elseif strcmp(thisName,triggerXdfStreamName)
       trigger_series=thisStream.time_series;
       trigger_stamps=thisStream.time_stamps;
       trigger_fs=thisStream.info.nominal_srate;
   end
end

%% convert trigger series from strings to numeric
%func=(@x)mystr2num(x);
trigger_series_numeric=cellfun(@str2num,trigger_series);

%%
diff_trigger_series_numeric=diff(trigger_series_numeric);
diff_trigger_series_numeric=cat(2,0,diff_trigger_series_numeric);
onsets=find(diff_trigger_series_numeric==trigger_onset_value);

%%

save(outFilename,'eeg_series','eeg_stamps','trigger_series_numeric','trigger_stamps','diff_trigger_series_numeric','onsets');
