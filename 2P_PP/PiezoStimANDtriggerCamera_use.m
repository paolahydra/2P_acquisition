%DELIVER STIMULI WITH THE PIEZO WHILE TRIGGERING THE CAMERA(S)
%this is not continuous. Just one stimulus at the time
a = clock;
foldertag = [num2str(a(1)),'-', ...
    num2str(a(2),'%02d'),'-', ...
   num2str(a(3),'%02d')];

%session-specific settings
savefolder = ['C:\Users\Paola\Dropbox\Data\Piezo+Camera\', foldertag];
disp(savefolder)
mkdir(savefolder)
clipboard('copy', savefolder)
filesavetag1 = 'piezo+camera164';

% acquisition-specific settings:
settings.inputchannels = 5;     %[8, 9, 10];   %sensor monitor, strobe out -164
settings.outputchannels = [0, 1];   %sensor monitor, strobe out -164
settings.devID = 'Dev3';
settings.fs = 4e4;
settings.queueChunkSeconds = 6;     %define also length of stimulus, will be rounded up
settings.cameraFR = 60;             %Hz, will be rounded up


s = daq.createSession ('ni');
s.Rate = settings.fs; 
% set input channels and read DC offset first
aiNchan = length(settings.inputchannels);
% set input channels:
ai = s.addAnalogInputChannel(settings.devID, settings.inputchannels , 'Voltage'); %this will be single ended because 'Differential' on this device is not supported
ai(1).Range =  [-10 10];
ai(1).Name = 'SensorMonitor';
% 
% ai(1).Range = [-5 5];
% ai(1).Name = 'PiezoCopy';
% ai(2).Range = [-10 10];
% ai(2).Name = 'SensorMonitor';
% ai(3).Range = [-5 5];
% ai(3).Name = 'StrobeOut';

%%  read DC offset first, and do again in case you need to tweak
DC_offset = startForeground(s);
DC_offset = mean(DC_offset);
DC_offset = DC_offset(1);
fprintf('The DC offset is set at %f Volts\n', DC_offset)


%% set output channels:
ao = s.addAnalogOutputChannel(settings.devID, settings.outputchannels, 'Voltage');
ao(1).Range = [-5 5];    %abs range is then 10, safer.
ao(1).Name = 'PiezoStim';
% ao(2).Range = [-5 5];
% ao(2).Name = 'CameraTrigger';


%% handle figures and files
handFig = figure('Name', 'online plotting','WindowStyle', 'docked'); hold on
xlabel('time (seconds)')
ylabel('Sensor Monitor (Volts)')
    title(sprintf('online plotting'))

handDataFig = figure('Name', 'Data','WindowStyle', 'docked'); hold on;
xlabel('time (seconds)')
tag = '- servo ON';
title('output to piezo and camera (trigger)')


%% define stim data

% stim = PipStimulus;
% stim.startPadDur = 1;
% stim.pipDur = 10;
% stim.totalDur = stim.startPadDur +stim.pipDur +1;
% stim.sampleRate = settings.fs;
% stim.carrierFreqHz =100;
% stim.modulationDepth = 0;
% stim.maxVoltage = 1.2;
% stim.amplitude = 0.78;
% data = stim.stimulus;
% carrier = stim.carrierFreqHz;


stim = PipStimulus;
stim.startPadDur = 1;
stim.pipDur = 8;
stim.totalDur = stim.startPadDur +stim.pipDur +1;
stim.sampleRate = settings.fs;
stim.carrierFreqHz =20;
stim.modulationDepth = 0;
stim.maxVoltage = 1.2;
stim.amplitude = 1;
data = stim.stimulus;
carrier = stim.carrierFreqHz;


% stim = PI_tonicDisplacement;
% stim.startPadDur = 1;
% stim.freqHz = 40;
% stim.freqGauss = 600;
% stim.totalDur = stim.startPadDur +stim.maxClicksDur +1;
% stim.sampleRate = settings.fs;
% stim.direction = 1;
% stim.D = 0.5;
% stim.maxVoltage = 1;
% data = stim.stimulus;
% carrier = stim.freqGauss;

% 
% stim = Chirp;
% stim.startPadDur = 1;
% stim.chirpLength = 3;
% stim.totalDur = 5;
% stim.sampleRate = settings.fs;
% stim.startFrequency = 50;
% stim.endFrequency = 50;
% stim.maxVoltage = ;
% data = stim.stimulus;
% carrier = stim.startFrequency;

ts = ((1/settings.fs) : (1/settings.fs) : stim.totalDur );
assert(range(data) <= 10, 'Control input exceeds maximum allowed voltage (10V)')
assert(DC_offset + max(data) <= 10, 'Check the DC offset value of the piezo')
assert(DC_offset + min(data) >= 0, 'Check the DC offset value of the piezo')
figure(handDataFig);
ch = get(gca, 'Children');
delete(ch); hold on
plot(ts, DC_offset+data);
axis auto
title(sprintf('command (-b), sensor (-r) %s', tag))
ylabel(sprintf('Piezo Input Voltage (Volts, including DC-offset)\n(stim command carrier: %d Hz)', carrier), 'Interpreter', 'none')
set(gca, 'YGrid', 'on')

% trigger camera
dataCamTr = zeros(ceil(settings.fs/settings.cameraFR), stim.totalDur*settings.cameraFR); %each column is a trigger cycle
dataCamTr(round(ceil(settings.fs/settings.cameraFR)/4):round(ceil(settings.fs/settings.cameraFR)/2),:) = 3.8; %Should be a LVTTL. This would work with both.
dataCamTr = dataCamTr(:);
dataCamTr(length(data)+1:end) = [];
figure(handDataFig); plot(ts, dataCamTr, '-r');
plot(ts, DC_offset+data);



%% do it
% set unique filename
figure(handFig)
ch = get(gca, 'Children');
delete(ch); hold on

a = clock;
disp(savefolder)
disp(datestr(now))

filesavetag = [num2str(a(1)),'-', ...
    num2str(a(2),'%02d'),'-', ...
   num2str(a(3),'%02d'),'_', ...
   num2str(a(4),'%02d'), num2str(a(5),'%02d'), num2str(round(a(6)),'%02d')];  %unique tag
clipboard('copy',[filesavetag1 '_' filesavetag]);
logname = fullfile(savefolder, ['log_' filesavetag '.bin']);
filename =  fullfile(savefolder, [filesavetag1 '_' filesavetag '.mat']);
figurename = fullfile(savefolder, [filesavetag1 '_' filesavetag]);

fid1 = fopen(logname,'a');

% start acquisition
lh = addlistener(s,'DataAvailable', @(src, event)logAndPlotData(src, event, fid1, handFig)); 
queueOutputData(s,[data, dataCamTr]);
startBackground(s);

% check
wait(s);
delete (lh)
fclose(fid1);

% read from log and save all data in .mat
fid2 = fopen(logname,'r');
dataInput = fread(fid2, [aiNchan+1,inf], 'double'); %first row is timestamps, second is data (analog input).
fclose(fid2);
save(filename,'settings', 'data', 'dataCamTr', 'dataInput', '-v7.3');
delete(logname)


figure(handFig)
title(sprintf('command (-g), sensor (-b) - %s - - %s', tag, filesavetag), 'Interpreter', 'none')
ylabel(sprintf('green: Piezo Input Voltage, including DC-offset\n(stim command carrier: %d Hz)\n(Volts)', carrier), 'Interpreter', 'none')
saveas(handDataFig, [figurename '.fig'])
axis auto
saveas(handDataFig, [figurename '_autoAxis.jpg'])