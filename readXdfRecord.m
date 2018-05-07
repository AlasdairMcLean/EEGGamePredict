% rip the raw EEG + photodiode data from XDF record 

function outFilename = readXdfRecord(xdfFilename,readDataPath,writeDataPath,trigger_onset_value,triggerXdfStreamName,dataXdfStreamName)
if nargin<6, dataXdfStreamName='BrainAmpSeries'; end
if nargin<5, triggerXdfStreamName='BrainAmpSeries-Markers'; end
if nargin<4, trigger_onset_value=5376-4352; end
if nargin<3, writeDataPath='/Users/jacekdmochowski/Dropbox/ARL/data/'; end
if nargin<2, readDataPath='D:/ARL/data/'; end
if nargin<1, error('At least one argument required'); end

xdfRoot=xdfFilename(1:end-4);
outFilename=fullfile(writeDataPath,[xdfRoot '_eeg_and_trigger.mat']);


%%read all streams into matlab
[streams,fileheader] = load_xdf(fullfile(readDataPath,xdfFilename));

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

save(outFilename,'-v7.3','eeg_series','eeg_stamps','trigger_series_numeric','trigger_stamps','diff_trigger_series_numeric','onsets','eeg_fs','trigger_fs');
