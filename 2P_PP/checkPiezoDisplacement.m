%% set up DAQ input channel
clc
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

%%  read DC offset first, and do again in case you need to tweak
DC_offset = startForeground(s);
DC_offset = mean(DC_offset);
DC_offset = DC_offset(1);
fprintf('The DC offset is set at %f Volts\n', DC_offset)
% users with short-travel piezo may want to stop the process here and tweak DC_offset until acceptable


%% add output channel to check piezo displacements
% set output channels:
ao = s.addAnalogOutputChannel(settings.devID, settings.outputchannels, 'Voltage');
ao(1).Name = 'Piezo-30um';

%% stimulus 1
stim = Stimulus2CorrectAmplitude; %with correction now
stim.startPadDur = 1;
stim.amplitude = 0.25;
stim.totalDur = 12;
stim.maxVoltage = 4;

%% stimulus 2
stim = PI_DCoffset_PipStimulus;
stim.totalDur = 5;
stim.DCoffset = -0.95;
stim.modulationDirection = 0;
stim.startPadDur =0.75; %1.2800;
stim.amplitude = 0.01;
stim.maxVoltage = 4;
stim.carrierFreqHz = 80;
stim.pipDur = 0;
stim.DCduration = 3.5;
% stim.plot;
assert(range(stim.stimulus) <= 10, 'Control input exceeds maximum allowed voltage (10V)')
assert(DC_offset + max(stim.stimulus) <= 10, 'Check the DC offset value of the piezo')
assert(DC_offset + min(stim.stimulus) >= 0, 'Check the DC offset value of the piezo')

%% stimulus 3
stim = PI_DCoffset_PipStimulus;
stim.totalDur = 8.1;
stim.DCoffset = 0;
stim.modulationDirection = 0;
stim.startPadDur =0.5; %1.2800;
stim.amplitude = 0.2;
stim.maxVoltage = 4;
stim.carrierFreqHz = 240;
stim.pipLatency = 0;
stim.DCduration = 7.6;
stim.pipDur = 7.5;

% stim.plot;
assert(range(stim.stimulus) <= 10, 'Control input exceeds maximum allowed voltage (10V)')
assert(DC_offset + max(stim.stimulus) <= 10, 'Check the DC offset value of the piezo')
assert(DC_offset + min(stim.stimulus) >= 0, 'Check the DC offset value of the piezo')

%% play and plot
queueOutputData(s,stim.stimulus);
sensdata = startForeground(s);
%
ts = 0:1/settings.fs:stim.totalDur-1/settings.fs;
handFig = figure('Name', 'online plotting','WindowStyle', 'docked'); hold on
xlabel('time (seconds)')
ylabel('Sensor Monitor (Volts)')
title(sprintf('plotting'))
plot(ts,stim.stimulus+DC_offset)
plot(ts,sensdata,'-r')
% xlim([0.96,2])

%% if correcting for frequency-dependent amplitude changes (not main function of this script anymore)
% carriers = stim.carriers;
% data = sensdata;
% save('sensDataCorr4.mat', 'carriers', 'data', 'DC_offset', 'stim','-v7.3')


