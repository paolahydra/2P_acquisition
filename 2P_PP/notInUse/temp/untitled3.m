%% exploration. Electric zzzz
fs = 4e4;
tend = 0.050; 
T = 0 : 1/fs : tend;
D = [0 : 1/1E2 : tend; 0.8.^(0:5)]';
Y = pulstran(T,D,'gauspuls',10E3,0.5);
figure; plot(T,Y)

player=audioplayer(Y,fs);
play(player);