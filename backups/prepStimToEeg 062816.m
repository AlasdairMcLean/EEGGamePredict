function [X,Y] = prepStimToEeg(EEG,fsEEG,stimFilename,K,fieldsToInclude,fsForce)

% EEG assumed to be time x space x subject
% check to see it can handle EEG = time x space
% allow function to be called with stimulus vector instead of stimFilename

try 
    vars=load(stimFilename);
    
    % superhack
    if isfield(vars,'vars')  % if features are too deeply nested
        tmp=vars.vars;
        vars=tmp;
    end
    
    fsFeature=round(vars.fs);
catch
    error('JD: provided stimFilename failed to load or did not contain ''fs'' field.');
end

if nargin<6 || isempty(fsForce)
    fsForce=fsFeature;
end

if nargin<5, fieldsToInclude={}; end;

if nargin<4, K=fsForce; end; 

%if size(EEG,1)<size(EEG,2), EEG=EEG.'; warning('JD: transposing EEG'); end;
if size(EEG,1)<size(EEG,2), EEG=permute(EEG,[2 1 3]); warning('JD: transposing EEG'); end;

nSubjects=size(EEG,3);
for s=1:nSubjects
    Y(:,:,s)=resample(EEG(:,:,s),fsForce,fsEEG); % downsample to frame rate
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
fieldnames=fields(vars2use);

X=[];
for i=1:numel(fieldnames)
    if ~strcmp(fieldnames{i},'fs')
        x=vars.(fieldnames{i});
        x=x(:);
        % high-pass filter to match EEG
        [hpnum,hpdenom]=butter(2,0.5/fsFeature*2,'high');
        xpad=cat(1,zeros(5*fsFeature,1),x);
        xpadfilter=filter(hpnum,hpdenom,xpad);
        x=xpadfilter(5*fsFeature+1:end);
        %%
        x=resample(x,fsForce,fsFeature);
        % check for gaussianity / log-normality (?)
        z=(x-nanmean(x))/nanstd(x);  % z-score for now (suboptimal for power features)
        z=z(:);
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
        X=cat(2,X,Z); 
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

% handle multiple subjects
Y=permute(Y,[2 1 3]); % this assumes that Y was passed as time x space x subjects
Y=Y(:,:)';
X=repmat(X,nSubjects,1);

return % end of function