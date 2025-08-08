%% Script Matlab : propag_incert_analyt_esd
%
%
% But : propager les incertitudes de Aa et exp du calibrage initial sur Sm et taille ESD à
% partir des formules théoriques analytiques
% 
% Blandine JACOB - 16 juin 2022

%%

% Aa et expo défini par Monte-Carlo
Aa = 0.0042 ;
expo = 1.142 ; 

% incertitude élargie à 95% (écart-type ou covariance multiplié par 1.96)
u_Aa = 0.00356;
u_expo = 0.121 ;
delta_Aa_expo = 0.00021 ;

% chargement des mesures uvp en px
table = readtable('Z:\UVP_incertitudes\1.etude_calibrage_initial_en_aquarium\copie_calibrage_initial_2016\Original_data\calibrage_aquarium_sn203_20160322.xlsx');
area_moy_sp =table.AreaMoy;

%on enlève la donnée aberrante
area_moy_sp(66,1)=NaN; 

% dérivée partielle de f en fonction de Aa
df_dAa = area_moy_sp.^expo;
df_dexpo = Aa.*log(area_moy_sp).*(area_moy_sp.^expo);
dfdf_dexpodAa = log(area_moy_sp).*(area_moy_sp.^expo);
u_sm = (sqrt(((df_dAa.^2).*(u_Aa.^2))+((df_dexpo.^2).*(u_expo.^2))+(2.*(dfdf_dexpodAa).*(delta_Aa_expo))))./2; 

figure(1)
sm_calc = Aa .* area_moy_sp.^expo;
errorbar(area_moy_sp,sm_calc,u_sm,'horizontal','r.')
title('Sm, Sp & error bar')
xlabel('Area uvp (px)')
ylabel('Aa*x^{exp}')

%% propagation incertitudes dans le calcul ESD

esd = 2*sqrt(sm_calc./pi);
df_dsm = 1./sqrt(pi.*sm_calc);
u_esd = (df_dsm .* u_sm)./2 ;

figure(2) 
errorbar(esd,area_moy_sp,u_esd,'horizontal','.')
title('ESD, Sp & error bar')
xlabel('ESD size')
ylabel('Area uvp (px)')