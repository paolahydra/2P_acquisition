settings.outputchannels = [0];   %sensor monitor, strobe out -164
settings.devID = 'Dev3';
settings.fs = 4e4;

s = daq.createSession ('ni');
s.Rate = settings.fs; 

ao = s.addAnalogOutputChannel(settings.devID, settings.outputchannels, 'Voltage');
data = repmat([0,1], 5*settings.fs, 5);
data = data(:);
queueOutputData(s,data);
%%
startForeground(s);