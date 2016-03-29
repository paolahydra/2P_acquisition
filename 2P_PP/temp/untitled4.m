%% one click
fs = 4e4;
tend = 0.04;
T = 0 : 1/fs : tend;
a = linspace(0, tend, 1);      
D = [a; 10.^(0:length(a)-1)]';
Y = pulstran(T,D,'gauspuls',3000,0.5);   
% figure; 
plot(T,Y); xlim([0, 0.050])

player=audioplayer(Y,fs);
play(player);

%% one click - can be parametrized and changed a bit
tend        = 0.01;
freqGauss   = 800;      %700 ?      
expGauss    = 0.4;      %0.4 ? 0.3-1, 1 piu' tonfo. Meno di 0.3, sweep

T = 0 : 1/fs : tend;   
D = [tend; 1]';
Y = pulstran(T,D,'gauspuls',freqGauss,expGauss);
%figure;
plot(T,Y); xlim([0, 0.050])

player=audioplayer(Y,fs);
play(player);

%% one click
fs = 4e4;
tend = 0.04;
T = 0 : 1/fs : tend;
a = linspace(0, tend, 1);      
D = [a; 10.^(0:length(a)-1)]';
Y = pulstran(T,D,'gauspuls',1000,2);   
% figure; 
plot(T,Y); xlim([0, 0.050])

player=audioplayer(Y,fs);
play(player);

%% ONE, WEIRD (from two combined)
fs = 4e4;
tend = 0.001;
T = 0 : 1/fs : tend;
a = linspace(0, tend, 2);      
D = [a; [5 1]]';
Y = pulstran(T,D,'gauspuls',1000,1);   

a = linspace(0, tend, 2);      
D = [a; [1 5]]';
Y2 = pulstran(T,D,'gauspuls',500,0.5);

YF = [Y, Y2];
TF = 0 : 1/fs : 2*tend;
% figure; 
plot(TF,YF(1:end-1)); xlim([0, 0.012])

player=audioplayer(YF,fs);
play(player);
