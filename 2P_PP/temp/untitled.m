t = (0:0.0001:1)';
y1 = sin(2*pi*50*t);
y2 = 2*sin(2*pi*120*t);
figure; plot(t,y1); hold on; plot(t, y2, '-r')
y = y1 + y2;
rng default;
yn = y + 0.5*randn(size(t));
figure; plot(t(1:1000),yn(1:1000))

%%
t = (0:0.001:1)';
imp = [1; zeros(99,1)];      % Impulse
unit_step = ones(100,1);     % Step (with 0 initial cond.)
ramp_sig = t;                % Ramp
quad_sig = t.^2;             % Quadratic
sq_wave = square(4*pi*t);    % Square wave with period 0.5

%%
fs = 10000;
t = 0:1/fs:1.5;
x = sawtooth(2*pi*50*t);
plot(t,x)
axis([0 0.2 -1 1])

%%
gauspuls
chirp

%%
fs = 4e4;
tend = 0.050; 
T = 0 : 1/fs : tend;
D = [0 : 1/1E2 : tend; 0.8.^(0:5)]';
Y = pulstran(T,D,'gauspuls',10E3,0.5);
figure; plot(T,Y)

T = 0:1/50E3:10E-3;
D = [0:1/1E3:10E-3;0.8.^(0:10)]';
Y = pulstran(T,D,'gauspuls',10E3,0.5);

player=audioplayer(Y,fs);
play(player);