%% set things up:
settings.outputchannels = 1; 
settings.devID = 'Dev3';
settings.fs = 10;

%create session
s = daq.createSession ('ni');
s.Rate = settings.fs; 
ao = s.addAnalogOutputChannel(settings.devID, settings.outputchannels, 'Voltage');
%% data

duration = 30;      %(minutes) %startForeground mode
framesperminute = 12;
%frequency is one per minute
%number of frames acquired is specified in scanimage, see below


data = 5*ones(60/framesperminute*settings.fs,duration*framesperminute);
data(end,:) = 0; %V (trigger)
data  = data(:);
data(end-1:end) = 0;

%% start acquisition
queueOutputData(s, data); %check channel order and everything
s.startForeground;
fprintf('Completed.\n')


% settings in scanimage:
% #slices: 1
% # frames: as many as you want to collect (in this configuration this
% number specified in scanimage drives the acquisition)

% # REPEATS: at least as many as duration here (~double it because there will be spurious attempts of acquisitions).

% triggers:
% both rising
% next mode: advanceS