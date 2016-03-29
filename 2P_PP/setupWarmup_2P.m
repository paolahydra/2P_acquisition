%  2P AUDITORY MAPPING EXPERIMENT WITH TRIALS CONTROL

%% 0. check or set preferences
if ~ispref('scimSavePrefs')
    addpref('scimSavePrefs', 'dataDirectory', 'flyNum')
    dataDirectory = uigetdir(pwd, 'Select a base folder for saving all your data:');
    setpref('scimSavePrefs', {'dataDirectory', 'flyNum'}, {dataDirectory, 1});
elseif ~ispref('scimSavePrefs', 'flyNum')
    addpref('scimSavePrefs', 'flyNum', 0)
%     setpref('scimSavePrefs', 'flyNum', 0);
end

%% 1. load all the settings, only need to do it once.
% This is evaluated at start of each experiment (run). 
% It is not necessarily a new fly, but always a new run.  <----
% set flyfolder first, then runfolder, then filesave (metadata)
% then wait for scanimage settings (manual)
%
% Note: Only flyNum is kept as a preference, since it is only determined by
% the previous flies recorded.

%fly
dataDirectory = getpref('scimSavePrefs', 'dataDirectory');
[flyNum, experimenter, logTxt] = setNewFly_GUI;
flyfolder = fullfile(dataDirectory, ['fly', num2str(flyNum, '%03d'), '_',experimenter]);
if exist(flyfolder, 'dir') ~= 7
    mkdir(flyfolder);
end
if ~isempty(logTxt) %save log file: 
    filename = sprintf('FLY%03d_%s_%s.txt', flyNum, experimenter, datestr(now,'YYmmdd'));
    fileID = fopen(fullfile(flyfolder, filename), 'w');
    fprintf(fileID,logTxt);
    fclose(fileID);
    filename = sprintf('IDfly%03d_%s_%s.mat', flyNum, experimenter, datestr(now,'YYmmdd'));
    flyname = sprintf('fly %d (%s) - %s.mat\n\n', flyNum, experimenter, datestr(now,'YYmmdd'));
    logTxt = [flyname logTxt];
    save(fullfile(flyfolder, filename), 'logTxt');
end

%run
d = dir(flyfolder);
d(1:2) = [];
dir_list = cat(2, d.isdir);
if ~isempty(dir_list)
    dir_names = {d(dir_list).name};
    runs = sum(cell2mat(strfind(dir_names, ['fly', num2str(flyNum, '%03d'), '_run'])));
else
    runs = 0;
end
run = runs +1;
runtag = ['fly', num2str(flyNum, '%03d'), '_run', num2str(run, '%02d')];
runfolder = fullfile(flyfolder, runtag);
mkdir(runfolder)
cd(runfolder)

% full metadata file: 'filesave'
a = clock;
a3 = [num2str(a(1)),'-', ...
    num2str(a(2),'%02d'),'-', ...
   num2str(a(3),'%02d'),'_', ...
   num2str(a(4),'%02d'), num2str(a(5),'%02d'), num2str(round(a(6)),'%02d')];
filesave = fullfile(runfolder,[runtag, '_metadata_',a3,'.mat']);
clear d dir_list a a3 runs

% Set Dir and basename in ScanImage
clipboard('copy',[runtag, '_']);
uiwait(msgbox({'Set directory and basename in ScanImage:';
               ' ';                                 ...
               ['Directory  =    ', runfolder];     ...
               ['Basename   =    ', [runtag, '_']];        ...
               ' '},                                ...
               'scanimage', 'modal'));


%% 2. decide stimulus composition 

% decide which stimuli to use and general structure and make actual trial list
%add random in the input and function
metadata.ITI = 0.5; %seconds of laser shuttered between trials.
metadata.totalDur = 14;
metadata.startPadDur = 3;
metadata.fs = 4e4;
metadata.maxVoltage = 1.2; %use max 0.5 if powering a speaker!!
plotting = 0;
[metadata, stimuli] = stimulusManager(runfolder,metadata,plotting);



%% 4. play, synch and save
% acquisition-specific settings:
settings.outputchannels = 1; 
settings.trigOut = 'port0/line0';
settings.devID = 'Dev3';
settings.fs = metadata.fs;

s = daq.createSession ('ni');
s.Rate = settings.fs; 
% set output channels:
ao = s.addAnalogOutputChannel(settings.devID, settings.outputchannels, 'Voltage');
ao(1).Name = 'Trigger';
% digital trigger out
% do = s.addDigitalChannel(settings.devID,settings.trigOut,'OutputOnly');
% set input channels:

pauseTime = metadata.ITI * (length(metadata.trials)-1); 
fprintf('\nThis run consists of %4d trials\n', length(metadata.trials) )
fprintf('It will take %3.2f minutes to complete\n\n', (metadata.totDurRun + pauseTime)/60 )


%% start acquisition
readygo = questdlg('Start experiment and recording- PIEZO?', 'Start Acquisition', ...
                   'Cancel', 'Start', 'Start');
if strcmp(readygo, 'Start')
    FS = stoploop('Stop Acquisition');
    % loop into trials
    for t = 1:length(metadata.trials)   
        fprintf('Trial n. %3d started...\t', t)
        stim = stimuli(metadata.trials(t)).stim;
        stim.maxVoltage = metadata.maxVoltage;
        extTrig = 3.3*ones(size(stim.stimulus)); %try with 1.5V? ao trigger to minimize noise on the other channel.
        
        extTrig(1) = 0;
        extTrig(end) = 0;
        extTrig(end-1) = 0;
        
        queueOutputData(s,extTrig); %check channel order and everything
        s.startForeground;
        fprintf('Completed.\n')
        if FS.Stop()
            break
        end
        pause(metadata.ITI);

    end
    FS.Clear();
    delete(s);
end