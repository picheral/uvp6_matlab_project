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
% Blandine JACOB - 9 mai 2022

%% Récupération des données bino (vecteur X)

filename =  'Z:\UVP_incertitudes\calibrage_initial_2016\Original_data\calibrage_aquarium_sn203_20160322.xlsx' ;

table_bino = extraction_data_bino(filename);

X = table_bino.Area_bino_mm_2 ;

%% Récupération des données UVP (données Y et poids)


data_UVP = readtable('resultats.dat');

Y = data_UVP.aire_moyenne ;
poids = data_UVP.nombre_observations ;

%% Fit

fit_power(X,Y,poids);
