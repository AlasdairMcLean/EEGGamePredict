function [X,Y] = prepStimToEeg(EEG,fsEEG,stimFilename,K,fieldsToInclude,fsForce,concat,highPass,audio)


% K: temporal aperture (length of temporal filter to apply to stimulus)
% fsForce: 

% prepare stimulus to eeg analysis
% [X,Y]=prepStimToEeg(EEG,fsEEG,stimFilename,K,fieldsToInclude,fsForce,concat,highPass,audio)
% 
% EEG assumed to be time x space x subject
% check to see it can handle EEG = time x space
% allow function to be called with stimulus vector instead of stimFilename
try 
    vars=load(stimFilename);
    
    % another hack for nested features
    if size(fieldnames(vars),1)==1
       eval(['vars=vars.' char(fieldnames(vars)) ';'])
    end
    % superhack
    if isfield(vars,'vars')  % if features are too deeply nested
        tmp=vars.vars;
        vars=tmp;
    end
    if audio
        fsFeature=round(vars.fsAudio);
    else
        if isfield(vars,'fsVideo')
            fsFeature=round(vars.fsVideo);
        elseif fsForce
            fsFeature=fsForce;
        else
            fsFeature=round(vars.fs);
        end
    end
catch
    error('JD: provided stimFilename failed to load or did not contain ''fs'' field.');
end


if nargin<6 || isempty(fsForce)
    fsForce=fsFeature;
end

if nargin<5, fieldsToInclude={}; end;

if nargin<4, K=fsForce; end; 
if nargin<7;concat=[1 1];end

%if size(EEG,1)<size(EEG,2), EEG=EEG.'; warning('JD: transposing EEG'); end;
if size(EEG,1)<size(EEG,2), EEG=permute(EEG,[2 1 3]); warning('JD: transposing EEG'); end;

nSamplesEeg=size(EEG,1);timeEeg=nSamplesEeg/fsEEG;
nSubjects=size(EEG,3);

for s=1:nSubjects
    Y(:,:,s)=resample(EEG(:,:,s),round(fsForce),fsEEG); % downsample to frame rate
    % TODO: find a way to preallocate Y
end
        

vars2use=struct;
% for f=1:numel(fieldsToExclude)
%     vars=rmfield(vars,fieldsToExclude{f});
% end
for f=1:numel(fieldsToInclude)
    if isfield(vars,fieldsToInclude{f})
        vars2use.(fieldsToInclude{f})=vars.(fieldsToInclude{f});
    else
        warning('JD: specified field not present');
    end
end
%fieldnames=fields(vars)
fieldNames=fields(vars2use);
nfields=numel(fieldNames);
if nfields>1;concat(1)=1;end

X=[];ii=1;
for i=1:nfields
    if ~strcmp(fieldNames{i},'fs')
        x=vars.(fieldNames{i});x=x(:);        
        nSamplesStim=size(x,1);

        if strcmp(fieldNames{i},'soundEnvelope')
            try
                fsFeature=vars.fsAudio;
            catch
                fsFeatures=vars.fs;
            end
            timeStim=nSamplesStim/fsFeature;
        elseif fsForce
            fsFeature=fsForce;
            timeStim=nSamplesStim/fsFeature;
        else
            fsFeature=vars.fs;
            timeStim=nSamplesStim/fsFeature;
        end
        timeDiff=timeStim-timeEeg;
        
        sampleLengthNew=1:(nSamplesStim-floor(abs(timeDiff*fsFeature)));
        fsFeature=round(fsFeature);
        x=x(sampleLengthNew);
        x=(x-nanmean(x))/nanstd(x);  % z-score for now (suboptimal for power features)
        x=x(:);
        
        % high-pass filter to match EEG
        if highPass
        [hpnum,hpdenom]=butter(2,0.5/fsFeature*2,'high');
        xpad=cat(1,zeros(5*fsFeature,1),x);
        xpadfilter=filter(hpnum,hpdenom,xpad);
        x=xpadfilter(5*fsFeature+1:end);
        end
        
        % downsample
        if fsForce ~= fsFeature
            z=resample(x,round(fsForce),fsFeature);
            resampledLength=length(z);
        else
            z=x;
            resampledLength=length(z);
        end
        
        % modify length of z to match X
        if ~isempty(X)
            if size(X,1)>numel(z) % feature missing samples
                nMissing=size(X,1)-numel(z);
                z=cat(1,z,zeros(nMissing,1));
            end
            if size(X,1)<numel(z)  % feature has too many samples
                z=z(1:size(X,1));
            end
        end
        % end of modify length of z to match X
        Z=tplitz(z,K);
        
        if concat(1)
        X=cat(2,X,Z);
        else
            X(:,:,ii)=Z;
          ii=ii+1;
        end
    end
end

lenX=size(X,1);
lenY=size(Y,1);

del=lenX-lenY;
if del>0
    Y=cat(1,zeros(abs(del),size(Y,2),size(Y,3)),Y);
elseif del<0
    Y=Y(abs(del)+1:end,:,:);
else
    % we're good
end

if concat(2)
% handle multiple subjects
Y=permute(Y,[2 1 3]); % this assumes that Y was passed as time x space x subjects
Y=Y(:,:)';
X=repmat(X,nSubjects,1);
end

return % end of function