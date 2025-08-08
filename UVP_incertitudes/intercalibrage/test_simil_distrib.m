% Script Matlab test_simil_distrib:
%
% But: tester les distributions en fréquence des paramètres Aa et exp des différentes
%      simulations MC à l'aide du test de Kolmogorov-Smirnov
%
%
%
% Blandine JACOB - juillet 2022
%
%%

intercalibrage = input('Quelles distributions de quel intercalibrage sont comparées? sn002/sn201/sn000008lp (il y a cinq 0): ');

while (strcmp(intercalibrage,'sn002') || strcmp(intercalibrage,'sn201') || strcmp(intercalibrage,'sn000008lp'))==0
    intercalibrage = input('Mauvais nom: quelles distributions de quel intercalibrage sont comparées? sn002/sn201/sn000008lp (il y a cinq 0): ');
end

switch intercalibrage
    case 'sn002'
        load('Z:\UVP_incertitudes\2_etude_intercalibrages\methode_monte_carlo\sn002_from_sn203\avec_esd_min=0.1\results\donnees_matlab\MC_params_aa_exp_ref_adj_sans_valeurs_aberrantes.mat')
    case 'sn201'
        load('Z:\UVP_incertitudes\2_etude_intercalibrages\methode_monte_carlo\sn201_from_sn203\results\donnees_matlab\MC_params_aa_exp_ref_adj.mat')
    case 'sn000008lp'
        load('Z:\UVP_incertitudes\2_etude_intercalibrages\methode_monte_carlo\sn000008lp_from_sn002\results\donnees_matlab\MC_params_aa_exp_ref_adj.mat')
end 

%% Aa 

% ref - centré réduit
   
mean_aa_ref = mean(couple_Aa_exp_ref(1,:));
std_aa_ref = std(couple_Aa_exp_ref(1,:));
x1_moy = (couple_Aa_exp_ref(1,:) - mean_aa_ref)/std_aa_ref ;


% adj - centré réduit

mean_aa_adj = mean(couple_Aa_exp_adj(1,:));
std_aa_adj = std(couple_Aa_exp_adj(1,:));
x2_moy = (couple_Aa_exp_adj(1,:) - mean_aa_adj)/std_aa_adj;

% test de Kolmogorov-Smirnov grâce à la fonction kstest2 déjà implémenté
% dans Matlab

sort(x1_moy);
sort(x2_moy);
[h_aa,p_aa,k_aa] = kstest2(x1_moy',x2_moy')


 
%% Exp


% ref - centré réduit
   
mean_expo_ref = mean(couple_Aa_exp_ref(2,:));
std_expo_ref = std(couple_Aa_exp_ref(2,:));
x1_moy_exp = (couple_Aa_exp_ref(2,:) - mean_expo_ref)/std_expo_ref;

 
% adj - centré réduit

mean_expo_adj = mean(couple_Aa_exp_adj(2,:));
std_expo_adj = std(couple_Aa_exp_adj(2,:));
x2_moy_exp = (couple_Aa_exp_adj(2,:) - mean_expo_adj)/std_expo_adj;

% test de Kolmogorov-Smirnov grâce à la fonction kstest2 déjà implémenté
% dans Matlab

sort(x1_moy_exp);
sort(x2_moy_exp);

[h_exp,p_exp,k_exp] = kstest2(x1_moy_exp',x2_moy_exp')

