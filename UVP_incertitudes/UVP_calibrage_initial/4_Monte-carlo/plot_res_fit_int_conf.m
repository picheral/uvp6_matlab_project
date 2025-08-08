%% Script Matlab : plot_res_fit_int_conf
%
%
% But : créer un graphique avec le fit issu de la simulation Monte-carlo
% avec une enveloppe de confiance (pour cela on propage les incertitudes de
% Aa et exp dans le calcul de Sm)
% 
%
% Blandine JACOB - 20 juin 2022

%% load data

% --------------------------------- !!! attention chemin en dur !!! ---------------------------------
data = readtable('Z:\UVP_incertitudes\1.etude_calibrage_initial_en_aquarium\simu_monte_carlo\data');

%enlève un points abberant qui "ruine" la régression
toDelete_pts_aberrants = [66,116];
data(toDelete_pts_aberrants,:)=[];

% remove NaN data
toDelete = isnan(data.Area_moy);
data(toDelete,:) = [];

p=height(data); % number of particles
donnees_bino = data(:,[1:3]); 
donnees_uvp = data (:, [4:6]);

%% calcul de Sm et de son incertitude à partir des résultats de la simu Monte-Carlo

% Aa et expo défini par Monte-Carlo
Aa = 0.0042 ;
expo = 1.142 ; 

% incertitude élargie à 95% (écart-type ou covariance multiplié par 1.96)
u_Aa = 0.00356; 
u_expo = 0.121 ;
delta_Aa_expo = 0.00021 ;

% dérivées partielles de f
df_dAa = data.Area_moy.^expo;
df_dexpo = Aa.*log(data.Area_moy).*(data.Area_moy.^expo);
dfdf_dexpodAa = log(data.Area_moy).*(data.Area_moy.^expo);

% calcul de Sm et de son incertitude
u_sm = (sqrt(((df_dAa.^2).*(u_Aa.^2))+((df_dexpo.^2).*(u_expo.^2))+(2.*(dfdf_dexpodAa).*(delta_Aa_expo))))./2; 
sm_calc = Aa .* data.Area_moy.^expo;

%% fit et enveloppe de fit

[fitresult, gof,output] = fit_power(data.Area_moy, sm_calc, data.Nb_observations,'oui','off');
[fitresult1, gof1,output1] = fit_power(data.Area_moy, sm_calc+u_sm, data.Nb_observations,'oui','off');
[fitresult2, gof2,output2] = fit_power(data.Area_moy, sm_calc-u_sm, data.Nb_observations,'oui','off');

figure(1)
scatter(data.Area_moy,data.Area_bino_mm_2, '+');
hold on
h = plot(fitresult, data.Area_moy, sm_calc) ;
h(1).Marker = 'none';
hold on
h1 = plot(fitresult1, data.Area_moy, sm_calc+u_sm);
h1(2).Color = 'blue';
h1(1).Marker = 'none';
hold on
h2 = plot(fitresult2, data.Area_moy, sm_calc-u_sm);
h2(2).Color = 'blue';
h2(1).Marker = 'none';
legend('donnees originelles', 'fit monte-carlo',' intervalle monte-carlo',' intervalle monte-carlo')
title('Données originelles et fit issu de la simulation Monte-Carlo n°11')
xlabel('Mesure UVP en px')
ylabel('Mesure bino en mm²')
grid on