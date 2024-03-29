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
stim = PI_DCoffset_PipStimulus;
stim.totalDur = 6.1;

stim.DCoffset = -0.9;
stim.amplitude = 0.01;

stim.modulationDirection = 0;
stim.modulationFreqHz = 1;
stim.startPadDur =0.5; %1.2800;
stim.maxVoltage = 4;
stim.carrierFreqHz = 6;
stim.pipLatency = 0;
stim.DCduration = 5;
stim.pipDur = 0;


assert(range(stim.stimulus) <= 10, 'Control input exceeds maximum allowed voltage (10V)')
assert(DC_offset + max(stim.stimulus) <= 10, 'Check the DC offset value of the piezo')
assert(DC_offset + min(stim.stimulus) >= 0, 'Check the DC offset value of the piezo')

stim.plot;
st2play = stim.stimulus;

%%
stim = Chirp_up;
stim.maxVoltage = 4;
stim.amplitude = 0.5;
stim.startPadDur = 0.7;
stim.chirpLength = 14;
stim.totalDur = 16;
stim.plot;
st2play = stim.stimulus;

%%
stim = PipStimulus;
stim.maxVoltage = 4;
stim.amplitude = 0.4;

stim.startPadDur = 0.5;
stim.pipDur = 14;
stim.totalDur = 16;

stim.carrierFreqHz = 2;
stim.modulationFreqHz = 0.125;

stim.plot;
st2play = stim.stimulus;

%% 4b. stimulus - choice b
% a continuous array of stimuli that you'll define.

% GENERAL SETTINGS (check once) and no need to change after that.
%set here the command voltage to the piezo you don't want to exceed.
metadata.maxVoltage     = 4;     % 4V == 12um is the value for 30um piezo
runfolder = fileparts(userpath); %will write the stimulus settings in this folder, and overwrite everytime 
metadata.samplingTime2P = 0.0640; % period in seconds of my acquisition at 15.625 Hz. Doesn't matter for the purposes of this script. Ignore.
metadata.fs             = settings.fs;
metadata.maxiPreWL      = 2;    % seconds to wait before the first stimulus is played
metadata.maxiReps       = 1;    % this script only supports 1.
metadata.maxiITI        = 2;    % does not matter here. 
metadata.startPadDur    = 0;    % no need to change here.

% SPECIFIC SETTINGS:
% define your stimuli:
metadata.totalDur       = 4;    % this defines the period of each individual stimulus.
                                % It includes the stimulus duration (which
                                % you can define later) and the duration of
                                % the pause following it.
metadata.random         = 0;    % randomize stimuli?

metadata.stimulusPath =  'C:\Users\Paola\Dropbox\Data\fly067_PP\fly067_run02\stimuliSettings.mat';    % you can set your own path here to a saved stimulus set
[metadata, M, ST] = stimulusManagerMaxi(runfolder,metadata,0); %let you define your stimulus composition.

figure; plot(1/metadata.fs: 1/metadata.fs : length(ST(1).stimulus)/metadata.fs , ST(1).stimulus);
st2play = ST(1).stimulus;

%% 5. play (and plot)
queueOutputData(s,st2play);
sensdata = startForeground(s);

% plot
% ts = 0:1/settings.fs:stim.totalDur-1/settings.fs;
ts = 1/settings.fs: 1/settings.fs : length(st2play)/settings.fs;
handFig = figure('Name', 'online plotting','WindowStyle', 'docked'); hold on
xlabel('time (seconds)')
ylabel('Sensor Monitor (Volts)')
title(sprintf('plotting'))

plot(ts,st2play+DC_offset)
plot(ts,sensdata,'-r')

%% 6. clear things up
delete(s)
clear all
close all
