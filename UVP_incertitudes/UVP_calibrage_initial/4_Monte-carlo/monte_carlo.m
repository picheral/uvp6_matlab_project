%% Script Matlab : monte_carlo
%
%
% But : générer un nombre important de fit via la méthode de Monte Carlo afin d'étudier la propagation des incertitudes 
% 
% Blandine JACOB - 19 mai 2022


%% chargement des données

data = readtable('Z:\UVP_incertitudes\1.etude_calibrage_initial_en_aquarium\simu_monte_carlo\data.xlsx');

%enlève deux points abberants
toDelete_pts_aberrants = [66,116];
data(toDelete_pts_aberrants,:)=[];

%enlève les données NaN
toDelete = isnan(data.Area_moy);
data(toDelete,:) = [];

p=height(data); % nombre de particules
donnees_bino = data(:,[1:3]); 
donnees_uvp = data (:, [4:6]);




%% nombre d'essai


N = input('Nombre d essais Monte-Carlo: ' );


%% génération des variables aléatoires d'entrées Xi 


loi_L_ref = 'normale' ;
loi_n_px = 'normale';
loi_a_bino_px = 'normale';
loi_uvp_px = 'normale';

%boucle sur i les particules et appel de fonction generation_va

for i=1:height(donnees_bino)
    A_bino_px(i,:) = generation_va('a_bino_px',loi_a_bino_px,N,donnees_uvp,donnees_bino,i);
    L_ref(i,:) = generation_va('L_ref',loi_L_ref,N,donnees_uvp,donnees_bino,i);    
    n_px(i,:) = generation_va('n_px',loi_n_px,N,donnees_uvp,donnees_bino,i);
    A_uvp_px(i,:) = generation_va('uvp_px',loi_uvp_px,N,donnees_uvp,donnees_bino,i);
end


%% calcul de A_bino_mm² = propagation des valeurs aléatoires dans le modèle mathématique
A_bino_mm_2 = A_bino_px.*(L_ref./n_px).^2;


%% création des fits

%création des N fits avec sélection de la méthode (par la lettre A, B, C, D
%voir description de la fonction type_regression)
modele_ponderation = input('Choix ponderation oui non :') ;
modele_robuste = input('Modele robuste, off ou LAR :');
modele_regression = input('Choix type régression, A, B, C, D :');
[Aa,expo,Radjusted,conf] = type_regression(modele_ponderation, modele_robuste, modele_regression,A_uvp_px,A_bino_mm_2,N,donnees_uvp.Nb_observations);

%% enregprévenir de la fin

disp('end');