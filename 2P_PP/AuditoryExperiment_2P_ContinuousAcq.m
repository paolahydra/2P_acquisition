%  2P AUDITORY MAPPING EXPERIMENT WITH TRIALS CONTROL
%% 1. load all the settings, only need to do it once.
% This is evaluated at start of each experiment (run). 
% It is not necessarily a new fly, but always a new run.  <----
% set flyfolder first, then runfolder, then filesave (metadata)
% then wait for scanimage settings (manual)
%
% Note: Only flyNum is kept as a preference, since it is only determined by
% the previous flies recorded.

% 0. check or set preferences
if ~ispref('scimSavePrefs')
    dataDirectory = uigetdir(pwd, 'Select a base folder for saving all your data:');
    setpref('scimSavePrefs', {'dataDirectory', 'flyNum'}, {dataDirectory, 1});
elseif ~ispref('scimSavePrefs', 'flyNum')
    addpref('scimSavePrefs', 'flyNum', 0)           % setpref('scimSavePrefs', 'flyNum', 0); %(reset)
end
if ~ispref('correctFreqDisplacPiezo')
    [FileName,PathName,~] = uigetfile(pwd, 'Select the path to the file with the freq/displacement correction for the 30um piezo:');
    correctorFunction30umPath = fullfile(PathName, FileName);
    addpref('correctFreqDisplacPiezo', 'Piezo30um', correctorFunction30umPath);
end

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

metadata.samplingTime2P = 0.0640;
metadata.fs             = 4e4;
metadata.maxVoltage     = 4;    % 4V == 12um is the new value for 30um piezo

metadata.maxiITI        = 15;    % seconds of laser shuttered between maxi-trials.
metadata.maxiPreWL      = 4;    %metadata.samplingTime2P*16 * 3;     % last is ~seconds
metadata.maxiReps       = 10;
metadata.totalDur       = 6;   %metadata.samplingTime2P * 56;     %8X = 0.512sec; 
metadata.startPadDur    = 0;    %metadata.samplingTime2P * 0;
metadata.random         = 1;
plotting                = 0;


%% % PI_displacem + pips
metadata.stimulusPath = 'C:\Users\Paola\Dropbox\Data\stimSettings\displANDPips.mat'; 
[metadata, M, ST] = stimulusManagerMaxi(runfolder,metadata,plotting);
%% %
metadata.stimulusPath = 'C:\Users\Paola\Dropbox\Data\stimSettings\PipsANDAmplitudes';
[metadata, M, ST] = stimulusManagerMaxi(runfolder,metadata,plotting);
%% %
metadata.stimulusPath = 'C:\Users\Paola\Dropbox\Data\stimSettings\conitinPipsOnly';
[metadata, M, ST] = stimulusManagerMaxi(runfolder,metadata,plotting);


%% 4. play, synch and save, experimental series
% acquisition-specific settings:
clc
settings.outputchannels =[0,1]; 
settings.inputchannels = [5,6];
% settings.trigOut = 'port0/line0';
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
    ai(3).Range = [-10 10];
    ai(3).Name = 'digitalStimulus';
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
% % digital trigger out
% do = s.addDigitalChannel(settings.devID, settings.trigOut, 'OutputOnly');


pauseTime = metadata.maxiITI * (metadata.maxiReps-1); 
totDur = (metadata.maxiReps*length(ST(1).stimulus)/metadata.fs + pauseTime)/60;
fprintf('\nThis run consists of %4d maxi trials\n', metadata.maxiReps )
fprintf('It will take %3.2f minutes to complete\n\n', totDur )


% start acquisition
readygo = questdlg('Start experiment and recording- PIEZO?', 'Start Acquisition', ...
                   'Cancel', 'Start', 'Start');

%               
if strcmp(readygo, 'Start')
    fid1 = fopen(fullfile(runfolder, 'log.bin'),'a');
    FS = stoploop('Stop Acquisition');
    
    
    
    % loop into trials
    for t = 1 : metadata.maxiReps  
        fprintf('MaxiTrial n. %3d started...\t', t)
        stim = ST(t).stimulus;
%         digital = ST(t).digital; % I am not recording it in DAQ, because
%         it is synchronous with ST(t).digital, which is already saved.

        extTrig = 3.3*ones(size(stim)); %try with 1.5V? ao trigger to minimize noise on the other channel.
        extTrig(1) = 0;
        extTrig(end) = 0;
        extTrig(end-1) = 0;
        
        queueOutputData(s,[stim, extTrig]);
        
        data = s.startForeground;
        fprintf('Completed.\n')
        data = data'; %now data is nxm, where n is the number of input channels in the session, and m is the number of scans acquired.
        datawrite = t * ones(1, size(data,2));
        datawrite = cat(1, data, datawrite);
        datawrite = cat(1, datawrite, stim' );
        fwrite(fid1,datawrite,'single');
        if FS.Stop()
            break
        end
        if t ~= metadata.maxiReps
            pause(metadata.maxiITI);
        end

    end
    
    
    
    fclose(fid1);
    FS.Clear();
    
    %read from log and save all data in .mat
    fid2 = fopen(fullfile(runfolder, 'log.bin'),'r');
    dataInput = fread(fid2, [settings.aiNchan + 2,inf], 'single');
    fclose(fid2);
    metadata.settings = settings;
    save(filesave,'metadata', 'dataInput', 'M','ST', '-v7.3');
    delete(fullfile(runfolder, 'log.bin'))
end

delete(s);
