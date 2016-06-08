% This script can be used to check piezo displacements or evoke responses
% before recording.
% INDEX of sections in this file:
% 1. adapt your DAQ definition and run block 1.
% 2. read DC_offset, tweak and repeat as necessary.
% 3. run when the DC_offset is all set.
% 4a - 4b. choose and define your stimulus.
% 5. play (and plot)
% 6. clear things up when done


%% 1. set up your DAQ input channel
set(0,'DefaultFigureWindowStyle','docked')

settings.outputchannels = 0; 
settings.inputchannels = 5;
settings.trigOut = 'port0/line0';
settings.devID = 'Dev3';
settings.fs = 4e4;
settings.aiNchan = length(settings.inputchannels);

s = daq.createSession ('ni');
s.Rate = settings.fs; 

ai = s.addAnalogInputChannel(settings.devID, settings.inputchannels , 'Voltage'); %this will be single ended because 'Differential' on this device is not supported
ai(1).Range = [-10 10];
ai(1).Name = 'Sensor';

%%  2. read DC offset first, and do again in case you need to tweak
DC_offset = startForeground(s);
DC_offset = mean(DC_offset);
DC_offset = DC_offset(1);
fprintf('The DC offset is set at %f Volts\n', DC_offset)
% users with short-travel piezo may want to stop the process here and tweak DC_offset until acceptable


%% 3. add output channel to check piezo displacements
ao = s.addAnalogOutputChannel(settings.devID, settings.outputchannels, 'Voltage');
ao(1).Name = 'Piezo-30um';


%% 4a. stimulus - choice a
% define a single stimulus
stim = PI_DCoffset;
stim.endPadDur = 0.5;
stim.DCoffset = -0.95;
stim.maxVoltage = 5;
assert(range(stim.stimulus) <= 10, 'Control input exceeds maximum allowed voltage (10V)')
assert(DC_offset + max(stim.stimulus) <= 10, 'Check the DC offset value of the piezo')
assert(DC_offset + min(stim.stimulus) >= 0, 'Check the DC offset value of the piezo')

stim.plot;
st2play = stim.stimulus;

queueOutputData(s,st2play);
sensdata = startForeground(s);
%% 4a. stimulus - choice a
% define a single stimulus
stim = PipStimulus;
stim.endPadDur = 0.5;
stim.amplitude = 0.3;
stim.maxVoltage = 5;
stim.carrierFreqHz =8;
stim.modulationFreqHz = 0.25;

stim.pipDur = 12;
assert(range(stim.stimulus) <= 10, 'Control input exceeds maximum allowed voltage (10V)')
assert(DC_offset + max(stim.stimulus) <= 10, 'Check the DC offset value of the piezo')
assert(DC_offset + min(stim.stimulus) >= 0, 'Check the DC offset value of the piezo')

stim.plot;
st2play = stim.stimulus;

queueOutputData(s,st2play);
sensdata = startForeground(s);

%% 4a. stimulus - Wed_ON
% define a single stimulus
stim = PipStimulus;
stim.endPadDur = 0.5;
stim.amplitude = 0.2;
stim.maxVoltage = 5;
stim.carrierFreqHz =8;
stim.modulationFreqHz = 4;

stim.pipDur = 8;
assert(range(stim.stimulus) <= 10, 'Control input exceeds maximum allowed voltage (10V)')
assert(DC_offset + max(stim.stimulus) <= 10, 'Check the DC offset value of the piezo')
assert(DC_offset + min(stim.stimulus) >= 0, 'Check the DC offset value of the piezo')

stim.plot;
st2play = stim.stimulus;

queueOutputData(s,st2play);
sensdata = startForeground(s);

%%
stim = Chirp_up;
stim.amplitude = 0.75;
stim.startPadDur = 0.5;
stim.chirpLength = 14;
stim.endPadDur = 0.5;
stim.plot;
st2play = stim.stimulus;

%% 4b. stimulus - choice b
% a continuous array of stimuli that you'll define.

% GENERAL SETTINGS (check once) and no need to change after that.
%set here the command voltage to the piezo you don't want to exceed.
metadata.maxVoltage     = 5;     % 4V == 12um is the value for 30um piezo
runfolder = fileparts(userpath); %will write the stimulus settings in this folder, and overwrite everytime 
metadata.samplingTime2P = 0.0640; % period in seconds of my acquisition at 15.625 Hz. Doesn't matter for the purposes of this script. Ignore.
metadata.fs             = settings.fs;
metadata.maxiPreWL      = 1;    % seconds to wait before the first stimulus is played
metadata.maxiReps       = 3;    % this script only supports 1.
metadata.maxiITI        = 1;    % does not matter here. 
metadata.startPadDur    = 0;    % no need to change here.

% SPECIFIC SETTINGS:
% define your stimuli:
metadata.endPadDur       = 0;    % this defines the period of each individual stimulus.
                                % It includes the stimulus duration (which
                                % you can define later) and the duration of
                                % the pause following it.
metadata.random         = 0;    % randomize stimuli?

metadata.stimulusPath =  '';    % you can set your own path here to a saved stimulus set
[metadata, M, ST] = stimulusManagerMaxi(runfolder,metadata,0); %let you define your stimulus composition.

figure; plot(1/metadata.fs: 1/metadata.fs : length(ST(1).stimulus)/metadata.fs , ST(1).stimulus);
st2play = ST(1).stimulus;

%% 5. play (and plot)
queueOutputData(s,st2play);
sensdata = startForeground(s);

% plot
% ts = 0:1/settings.fs:stim.totalDur-1/settings.fs;
% ts = 1/metadata.fs: 1/metadata.fs : length(st2play)/metadata.fs;
% handFig = figure('Name', 'online plotting','WindowStyle', 'docked'); hold on
% xlabel('time (seconds)')
% ylabel('Sensor Monitor (Volts)')
% title(sprintf('plotting'))
% 
% plot(ts,st2play+DC_offset)
% plot(ts,sensdata,'-r')
% 
% 
% save('ToCorrectAmplitude2.mat', 'sensdata')
%%
figure; plot(ts,sensdata-DC_offset,'-r')
ylim([-1.5,1.5])


%% 6. clear things up
delete(s)
% clear all

close all
