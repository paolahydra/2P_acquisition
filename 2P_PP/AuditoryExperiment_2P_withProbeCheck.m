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

% %CHIRPS
% metadata.ITI = 3; %seconds of laser shuttered between trials.
% metadata.totalDur = 12;
% metadata.startPadDur =1.5; %1.2800;
% metadata.fs = 4e4;
% metadata.maxVoltage = 4; %use max 0.5 if powering a speaker!! % 4V == 12um is the new value for 30um piezo
% plotting = 1;
% [metadata, stimuli, ALLstimuli] = stimulusManager(runfolder,metadata,plotting);

% %OK
% pip for freq tuning -- 3 CYCLES

% metadata.ITI = 0.5; %seconds of laser shuttered between trials.
% metadata.totalDur = 4;%3.5;
% metadata.startPadDur =0.75; %1.2800;
% metadata.fs = 4e4;
% metadata.maxVoltage = 4; %use max 0.5 if powering a speaker!!
% plotting = 0;
% [metadata, stimuli, ALLstimuli] = stimulusManager(runfolder,metadata,plotting);


% % pip for freq tuning
% % 
% metadata.ITI = 0.5; %seconds of laser shuttered between trials.
% metadata.totalDur = 3;
% metadata.startPadDur =0.75; %1.2800;
% metadata.fs = 4e4;
% metadata.maxVoltage = 4; %use max 0.5 if powering a speaker!!
% plotting = 0;
% [metadata, stimuli, ALLstimuli] = stimulusManager(runfolder,metadata,plotting);


% %OK 
% PI_displacem + pips
% 
metadata.ITI = 0.75; %seconds of laser shuttered between trials.
metadata.totalDur = 5;
metadata.startPadDur =0.75; %1.2800;
metadata.fs = 4e4;
metadata.maxVoltage = 4; %use max 0.5 if powering a speaker!!
plotting = 0;
[metadata, stimuli, ALLstimuli] = stimulusManager(runfolder,metadata,plotting);


%% 4. play, synch and save, experimental series
% acquisition-specific settings:
clc
settings.outputchannels =[0,1]; 
settings.inputchannels = [5,6];
settings.trigOut = 'port0/line0';
settings.devID = 'Dev3';
settings.fs = metadata.fs;
settings.aiNchan = length(settings.inputchannels);

s = daq.createSession ('ni');
s.Rate = settings.fs; 

ai = s.addAnalogInputChannel(settings.devID, settings.inputchannels , 'Voltage'); %this will be single ended because 'Differential' on this device is not supported
ai(1).Range = [-10 10];
ai(1).Name = 'Sensor';
if settings.aiNchan > 1
    ai(2).Range = [-5 5];
    ai(2).Name = 'MirrorY';
end
if settings.aiNchan > 2
    ai(1).Range = [-10 10];
    ai(1).Name = 'MirrorX';
    ai(3).Range = [-10 10];
    ai(3).Name = 'Sensor';
end

%  read DC offset first, and do again in case you need to tweak
DC_offset = startForeground(s);
DC_offset = mean(DC_offset);
DC_offset = DC_offset(1);
fprintf('The DC offset is set at %f Volts\n', DC_offset)
% other users with short-travel piezo may want to stop the process here and tweak DC_offset until acceptable


% set output channels:
ao = s.addAnalogOutputChannel(settings.devID, settings.outputchannels, 'Voltage');
ao(1).Name = 'Piezo-90um';
ao(2).Name = 'Trigger';
% digital trigger out
% do = s.addDigitalChannel(settings.devID,settings.trigOut,'OutputOnly');
% set input channels:

pauseTime = metadata.ITI * (length(metadata.trials)-1); 
fprintf('\nThis run consists of %4d trials\n', length(metadata.trials) )
fprintf('It will take %3.2f minutes to complete\n\n', (metadata.totDurRun + pauseTime)/60 )

%% check piezo displacements
handFig = figure('Name', 'online plotting','WindowStyle', 'docked'); hold on
xlabel('time (seconds)')
ylabel('Sensor Monitor (Volts)')
    title(sprintf('online plotting'))

handDataFig = figure('Name', 'Data','WindowStyle', 'docked'); hold on;
xlabel('time (seconds)')
tag = '- servo ON';
title('output to piezo and camera (trigger)')

% define relevant testset data and plot it
% stim = testsetstimuli(metadata); %36 seconds fixed testing set

checkingProbe = 0;
flyE1 = 0;
playChirp = 0;

if ~playChirp
    if checkingProbe
        if ~flyE1
            st = FastStimulusSlow; %slow for checking, fast for finding
            st.maxVoltage = 4; 
            st.amplitude = 0.2; %0.6 for checking
            stim = [st.stimulus;st.stimulus;st.stimulus;st.stimulus;0];
        else
            disp('flyE1')
            st = PI_DCoffset_PipStimulus; %slow for checking, fast for finding
            st.maxVoltage = 4; 
            st.amplitude = 0.2; %0.6 for checking
            st.DCduration = 5;
            st.DCoffset = 0.4;
            st.pipLatency = 3.5;
            st.pipDur = 1;
            st.carrierFreqHz = 200;
            st.modulationFreqHz = 1;
            st.modulationDirection = 0;
            st.totalDur =8;
            st.startPadDur = 0.5;
            stim = [st.stimulus;st.stimulus;st.stimulus;st.stimulus;0];
        end
    else
        st = FastStimulusFast; %240-280Hz
        st.maxVoltage = 4; 
        st.minEndPadDur = 0.01;
        st.totalDur = 10.5;
        st.startPadDur = 0.5;
        st.ipi = 0.250;
        st.amplitude = 0.09; %find ROI functionally
        stim = [st.stimulus;st.stimulus;st.stimulus;st.stimulus;0]; %...
%             st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus; ...
%             st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus;st.stimulus; ...
%             0];
    end
else
    st = Chirp_down;
    st.maxVoltage = 2; 
    st.chirpLength = 10;
    st.startPadDur = 0.5;
    st.totalDur = 11.5;
    st.amplitude = 0.8;
    stim = [st.stimulus;st.stimulus;st.stimulus;0];
end



ts = ((1/settings.fs) : (1/settings.fs) : 36 );
assert(range(stim) <= 10, 'Control input exceeds maximum allowed voltage (10V)')
assert(DC_offset + max(stim) <= 10, 'Check the DC offset value of the piezo')
assert(DC_offset + min(stim) >= 0, 'Check the DC offset value of the piezo')
% figure(handDataFig);
% ch = get(gca, 'Children');
% delete(ch); hold on
% plot(ts,DC_offset+stim);
axis auto
pause(1)

% play it
lh = addlistener(s,'DataAvailable', @(src, event)logAndPlotData(src, event, fid1, handFig)); 
extTrig = zeros(size(stim));
queueOutputData(s,[stim, extTrig]);
startBackground(s);

wait(s);
delete (lh)
% delete(s)
% 

%% courtship songs
load('C:\Users\Paola\Dropbox\courtshipSongs\courshipSongs5.mat')
songs = songs*3.5;
reps = 5;
count = 1;
for t = 1:5
    for iii = 1 : reps
        ALLstimuli(count).stim.stimulus = songs(t,:)';
        count = count+1;
    end
    figure; plot(songs(t,:))
end
stimuli = songs;

%% start acquisition
readygo = questdlg('Start experiment and recording- PIEZO?', 'Start Acquisition', ...
                   'Cancel', 'Start', 'Start');

%               
if strcmp(readygo, 'Start')
    fid1 = fopen(fullfile(runfolder, 'log.bin'),'a');
    FS = stoploop('Stop Acquisition');
    % loop into trials
    for t = 1:length(ALLstimuli)   
        fprintf('Trial n. %3d started...\t', t)
        stim = ALLstimuli(t).stim;
        
        
%         stim.maxVoltage = metadata.maxVoltage;
%         stim.plot;


        extTrig = 3.3*ones(size(stim.stimulus)); %try with 1.5V? ao trigger to minimize noise on the other channel.
        
        extTrig(1) = 0;
        extTrig(end) = 0;
        extTrig(end-1) = 0;
        
        queueOutputData(s,[stim.stimulus extTrig]); %check channel order and everything
        data = s.startForeground;
        fprintf('Completed.\n')
        data = data'; %now data is nxm, where n is the number of input channels in the session, and m is the number of scans acquired.
        datawrite = t * ones(1, size(data,2));
        datawrite = cat(1, data, datawrite);
        datawrite = cat(1, datawrite, stim.stimulus' );
        fwrite(fid1,datawrite,'single');
        close
        if FS.Stop()
            break
        end
        pause(metadata.ITI);

    end
    fclose(fid1);
    FS.Clear();
    delete(s);
    
    %read from log and save all data in .mat
    fid2 = fopen(fullfile(runfolder, 'log.bin'),'r');
    dataInput = fread(fid2, [settings.aiNchan + 2,inf], 'single');
    fclose(fid2);
    metadata.settings = settings;
    save(filesave,'metadata', 'dataInput', 'stimuli','ALLstimuli', '-v7.3');
    delete(fullfile(runfolder, 'log.bin'))
end


