% read thermocouples
settings.TC = [0,1]; %channels
settings.devID_tc = 'Dev5';
settings.fs_tc = 4;

th = daq.createSession ('ni');
aith = addAnalogInputChannel(th, settings.devID_tc, settings.TC, 'Thermocouple');
th.Rate = settings.fs_tc; 
th.IsContinuous = false;

tc_ch = th.Channels;
% set(tc_ch)
for i = 1:length(settings.TC)
    tc_ch(i).ThermocoupleType = 'K';
    tc_ch(i).Units = 'Celsius';
end

data = zeros(length(settings.TC), settings.fs_tc * th.DurationInSeconds);
time = zeros(1, settings.fs_tc * th.DurationInSeconds);


%%
th.DurationInSeconds = 45*60;
basename = 'fly036_testTPost3_';
%%
figure;
[data,time] = th.startForeground();

%
plot(time, data)
xlabel('Time (secs)');
ylabel('Temperature (Celsius)');
title('temperature monitor')
legend('objective','bath')
cd('C:\Users\Paola\Dropbox\Data\Temperature')
a = clock;
nametag = [num2str(a(1)),'-', ...
    num2str(a(2),'%02d'),'-', ...
    num2str(a(3),'%02d'),'_', ...
    num2str(a(4),'%02d'), num2str(a(5),'%02d'), num2str(round(a(6)),'%02d')];
save([basename '_' nametag '_Tdata.mat'], 'time','data')
saveas(gcf,[basename '_' nametag '_Tdata.fig'])