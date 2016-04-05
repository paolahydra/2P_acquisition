function data = testsetstimuli(metadata)

data = [];

%% 1 slow pip to check a2
stim = PipStimulus;
stim.sampleRate = metadata.fs;
stim.maxVoltage = metadata.maxVoltage - 0.5; %test with a slightly higher range

stim.startPadDur = 1;
stim.pipDur = 8;
stim.totalDur = stim.startPadDur +stim.pipDur +1;

stim.amplitude = 1;
stim.carrierFreqHz = 1;
stim.modulationDepth = 0;
data = cat(1, data, stim.stimulus);

%% 2 fast pip (20 Hz)
stim = PipStimulus;
stim.sampleRate = metadata.fs;
stim.maxVoltage = metadata.maxVoltage - 0.5; %test with a slightly higher range

stim.startPadDur = 0;
stim.pipDur = 4;
stim.totalDur = stim.startPadDur +stim.pipDur +1;

stim.amplitude = 1;
stim.carrierFreqHz =20;
stim.modulationDepth = 0;
data = cat(1, data, stim.stimulus);

%% 3 faster pip (300 Hz)
stim = PipStimulus;
stim.sampleRate = metadata.fs;
stim.maxVoltage = metadata.maxVoltage - 0.5; %test with a slightly higher range

stim.startPadDur = 0;
stim.pipDur = 4;
stim.totalDur = stim.startPadDur +stim.pipDur +1;

stim.amplitude = 1;
stim.carrierFreqHz =300;
stim.modulationDepth = 0;
data = cat(1, data, stim.stimulus);

%% tonic displ
stim = PI_tonicDisplacement;
stim.sampleRate = metadata.fs;
stim.maxVoltage = metadata.maxVoltage - 0.4; %test with a slightly higher range

stim.startPadDur = 0;
stim.time1 = 0;
stim.time2 = 2;
stim.time3 = 0;
stim.time4 = 2;
stim.time5 = 0;
stim.voltage2 = 1;
stim.voltage4 = -1;
stim.totalDur = stim.startPadDur +stim.stimDur +1;

data = cat(1, data, stim.stimulus);

%% 5
stim = ClickStimulus;
stim.sampleRate = metadata.fs;
stim.maxVoltage = metadata.maxVoltage - 0.5; %test with a slightly higher range

stim.startPadDur = 0;
stim.maxClicksDur = 4;
stim.freqHz = 50;
stim.totalDur = stim.startPadDur +stim.stimDur +1;

data = cat(1, data, stim.stimulus);

%% 6 close with light pip to double check a2
stim = PipStimulus;
stim.sampleRate = metadata.fs;
stim.maxVoltage = metadata.maxVoltage - 0.5; %test with a slightly higher range

stim.startPadDur = 1;
stim.pipDur = 4;
stim.totalDur = stim.startPadDur +stim.pipDur +1;

stim.amplitude = 0.6;
stim.carrierFreqHz = 1;
stim.modulationDepth = 0;
data = cat(1, data, stim.stimulus);

end