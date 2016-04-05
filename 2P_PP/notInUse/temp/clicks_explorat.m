%% this will be a realistic click, like mouse click or shutter opening.
% two components, not too fast. The second seems to me higher frequency.

fs = 4e4;  %temp
tend = 0.10;       %how long does a click last? let's say 100 ms.

%crystal bang
T = 0 : 1/fs : tend;
a = 0 : 1/1E3 : tend;
D = [a; 0.8.^(0:length(a)-1)]';
Y = pulstran(T,D,'gauspuls',10E3,0.5);   %tripuls
% figure; plot(T,Y)

player=audioplayer(Y,fs);
play(player);


%% one, much a better click that the previous one.... GREAT.
tend = 0.04;
T = 0 : 1/fs : tend;
a = linspace(0, tend, 1);      
D = [a; 10.^(0:length(a)-1)]';
Y = pulstran(T,D,'gauspuls',3000,0.5);   
% figure; plot(T,Y); xlim([0, 0.050])

player=audioplayer(Y,fs);
play(player);

%% two slower. OK
tend = 0.04;       
T = 0 : 1/fs : tend;
a = linspace(0, tend, 2);
D = [a; 1.5.^(0:length(a)-1)]';
Y = pulstran(T,D,'gauspuls',900,0.5);  
% figure; plot(T,Y)

player=audioplayer(Y,fs);
play(player);

%two faster, clicks. OK, GOOD.
tend = 0.025;       
T = 0 : 1/fs : tend;
a = linspace(0, tend, 2);
D = [a; 1.4.^(0:length(a)-1)]';
Y = pulstran(T,D,'gauspuls',1200,0.5);   
% figure; plot(T,Y); xlim([0, 0.050])

player=audioplayer(Y,fs);
play(player);

%two complete: these are not clicks. OK
tend = 0.05;       
T = 0 : 1/fs : tend;
a = linspace((tend/4), (tend*3/4), 2);
D = [a; 1.4.^(0:length(a)-1)]';
Y = pulstran(T,D,'gauspuls',1200,0.5); 
% figure; 
plot(T,Y); xlim([0, 0.050])

player=audioplayer(Y,fs);
play(player);


%% LET's COMBINE TWO CLICKS TOGETHER...
%one, much a better click that the previous one.... OK
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
plot(TF,YF(1:end-1)); xlim([0, 0.050])

player=audioplayer(YF,fs);
play(player);

%% two, down-up.... TWEAKING
tend = 0.008;
T = 0 : 1/fs : tend;
a = linspace(0, tend, 1);      
D = [a; 1]';
Y = pulstran(T,D,'gauspuls',1000,15);   

a = linspace(0, tend, 1);      
D = [a; 3]';
Y2 = pulstran(T,D,'gauspuls',3000,16);

YF = [fliplr(Y), Y2];
TF = 0 : 1/fs : 2*tend;
% figure; 
plot(TF,YF(1:end-1)); xlim([0, 0.050])

player=audioplayer(YF,fs);
play(player);



%% two, down-up.... TWEAKING
tend = 0.008;
T = 0 : 1/fs : tend;
a = linspace(0, tend, 1);      
D = [a; 0.6]';
Y = pulstran(T,D,'gauspuls',1000,0.5);   

a = linspace(0, tend, 1);      
D = [a; 1]';
Y2 = pulstran(T,D,'gauspuls',3000,0.5);

YF = [fliplr(Y), Y2];
TF = 0 : 1/fs : 2*tend;
% figure;
plot(TF,YF(1:end-1)); xlim([0, 0.050])

player=audioplayer(YF,fs);
play(player);


%% series, same freq
tend = 1;
T = 0 : 1/fs : tend;
a = linspace(0, tend, 10);      
D = [a; linspace(0.5,15,10)]';
Y = pulstran(T,D,'gauspuls',3000,0.5);   
% figure; plot(T,Y); %xlim([0, 0.050])

player=audioplayer(Y,fs);
play(player);


%% series, different freq, not clean first and last. Not so meaningful....
tend = 0.100;
T = 0 : 1/fs : tend;
a = linspace(0, tend, 10);      
D = [a; linspace(0.5,15,10)]';
freq = linspace(500, 1000, 10);
YF = [];
for i = 1:10
    Y = pulstran(T,D(i,:),'gauspuls',freq(i),0.5);
    YF = [YF, Y];
end
TF = 0 : 1/fs : 10*(tend+1/fs);
TF(end) = [];
plot(TF,YF); %xlim([0, 0.050])
player=audioplayer(YF,fs);
play(player);
