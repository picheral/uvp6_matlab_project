% Test du calcul géostrophique
%
% les distances entre stations doivent etre calculées en metre
% la vitesse est en cm/s

% données de Copin
P= [0 10 20 30 50 75 100 150 200 300]';
T = [20.44 20.42 20.31 20.26 15.86 14.34 13.66 13.16 13.3 13.59]';
S = [37.85 37.85 37.84 37.86 37.77 37.88 37.94 38.19 38.35 38.51]';

% Script de seawater
ga = sw_gpan(S,T,P); % l'intégration se fait avec comme référence la surface

% données de Copin
ga1 =[0 0.122 0.243 0.362 0.5 0.5 0.428 0.174 -0.165 -0.894]';
ga2=[0 0.116 0.225 0.283 0.264 0.146 -0.024 -0.404 -0.8 -1.576]';

figure(1)
subplot(211)
plot(ga1,ga,'*')
xlabel('Anomalies Copin');
ylabel('Anomalies Script');

w=7.29E-5; %rad s-1
sinphi = sin(43*pi/180);
1/((2*w*sinphi)*18520);

v=sw_gvel_temp([ga1 ga2],[43 43],[7 7]); % la vitesse est en m/s
v2 = [37.02 36.69 36.04 32.73 24.21 17.8 12.48 5.65 2.55 0]';

v1 = v(end)-v;
figure(1)
subplot(212)
plot(v1*100,-P,'-*')
hold on
plot(v2,-P,'r')
legend('Script','Copin')
xlabel('Vitesse en cm/s')
ylabel('Pression en dB');