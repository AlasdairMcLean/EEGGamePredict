
addpath(genpath('.')); %necessary for accessing the data

% Valid inputs from featuresCut

% muFlow:               [5290×1 double]
% muSqFlow:             [5290×1 double]
% muTemporalContrast:   [5290×1 double]
% muSqTemporalContrast: [5290×1 double]
% muLuminance:          [5290×1 double]
% muSqLuminance:        [5290×1 double]
% muLocalContrast:      [5290×1 double]
% muSqLocalContrast:    [5290×1 double]
% stdLocalContrast:     [5290×1 double]
feature2run='muFlow';

fs=30; % sampling rate
nComp=5; % number of components to DISPLAY (all are analyzed)

Kx=20; % regularization parameter on the stimulus (reduce for higher reg.)
Ky=20; % regularization parameter on the EEG (reduce for higher reg.)

K=75; %2.5s temporal window based on MultiCCAPredict results


%If cloning from github: Leave the following path and data will load; if
%data is elsewhere, modify to local path
Avals1=zeros(152,20,30);
Bvals1=zeros(96,20,30);
rhos1=zeros(20,30);

%Avals2=zeros(152,20,30);
%Bvals2=zeros(96,20,30);
%rhos2=zeros(20,30);
conditions={'play','watch','bci'};
trialdates={'11_28_17','11_29_17','11_29_17', '11_30_17','12_01_17','12_01_17','12_04_17', '12_05_17', '12_06_17', '12_06_17', '12_07_17', '12_13_17','02_19_18','02_20_18','02_20_18','02_21_18','02_21_18','02_22_18','02_22_18','03_02_18','03_03_18','03_03_18'};
for trialnum=20:29
    for j=1:3
        condition=conditions{j};
        %pull the correct dataset from the user input
        readyDataFilename1=['/media/alasdair/BIPRA 320GB/' num2str(trialnum) '/' condition '/mat/' trialdates{trialnum-19+7} '_01_ready_data_jason'];
%        readyDataFilename2=['/media/alasdair/BIPRA 320GB/' num2str(trialnum) '/' condition '/mat/' trialdates{trialnum-12} '_02_ready_data_jason'];
        % load the data
        load(readyDataFilename1);

        % load the desired stimulus feature
        eval(['stim=featuresCut.' feature2run ';']);
        stim_tpl=revtplitz(stim,K,K);
        % correlate the EEG with the stimulus (canonical correlation analysis)
        [A,B,rhos,~,~,~,Rxx,Ryy] = myCanonCorr(stim_tpl,eeg(:,K+1:end),Kx,Ky);
        Avals1(:,:,trialnum-12)=A;
        Bvals1(:,:,trialnum-12)=B;
        rhos1(:,trialnum-12)=rhos;
        
        
        % load the data
 %       load(readyDataFilename2);

        % load the desired stimulus feature
  %      eval(['stim=featuresCut.' feature2run ';']);
   %     stim_tpl=revtplitz(stim,K,K);
    %    % correlate the EEG with the stimulus (canonical correlation analysis)
  %      [A,B,rhos,~,~,~,Rxx,Ryy] = myCanonCorr(stim_tpl,eeg(:,K+1:end),Kx,Ky);
  %      Avals2(:,:,trialnum-12)=A;
  %      Bvals2(:,:,trialnum-12)=B;
  %      rhos2(:,trialnum-12)=rhos;
  %      
  %      %Bk=B(:,1:nComp);
  %      %forwards=Ryy*Bk*inv(Bk'*Ryy*Bk);
  %  
    end
end
    

