%% Script Matlab : courbe de calibrage
%
%
% But : récupérer les données bino et les données UVP et tracer le fit
%       puissance pour établir la relation entre les deux et trouver les
%       coefficients Aa et exp
%
% Fonction utilisée : extraction_data_bino
%
% Fichier utilisé :     fichier excel de référence avec les données bino
%                       resultats.dat qui est le fichier issu de analyse.m 
%
%
% !!!! ----- Le fichier resultats.dat n'existent pas car nous n'avons pas été au bout de la sélection des particules qui coulent ----- !!!!
% !!!! ----- Ce code n'a donc jamais tourné ----- !!!!
%
% Blandine JACOB - 9 mai 2022

%% Récupération des données bino (vecteur X)

% --------------------------------- !!! attention chemin en dur !!! ---------------------------------
filename =  'Z:\UVP_incertitudes\1.etude_calibrage_initial_en_aquarium\copie_calibrage_initial_2016\Original_data\calibrage_aquarium_sn203_20160322.xlsx' ;

table_bino = extraction_data_bino(filename);

X = table_bino.Area_bino_mm_2 ;

%% Récupération des données UVP (données Y et poids)


data_UVP = readtable('resultats.dat');

Y = data_UVP.aire_moyenne ;
poids = data_UVP.nombre_observations ;

%% Fit

% paramètres de la courbe de calibrage effectué en 2016, fit à l'époque non
% robuste et pondéré par le nb d'observations
modele_ponderation = 'oui';
modele_robuste = 'off';

fit_power(X,Y,poids,modele_ponderation,modele_robuste);
