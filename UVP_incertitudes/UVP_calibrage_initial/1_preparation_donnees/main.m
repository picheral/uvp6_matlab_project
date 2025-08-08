%% Script Matlab principal du dossier 1_preparation_donnees
% 
% Contexte: on travaille sur les données de l'expérience du calibrage
%           initial de l'UVP5-sn203 en aquarium
%
% But du script: préparer les données afin de tracer des graphiques d'aires et de
%                trajectoires à partir desquels on sélectionne manuellement les points
%                correspondant à la particule d'intérêt
%
% 
% Fonctions utilisées dans ce script:
%
%   extraction_data_bru
%   process_table
%   remove_noise
%   graph_area
%   graph_trajectories
%
% Dossiers appelés dans ce script: (attention, dossiers appelés en 'dur')
%
%   uvp5_sn203_aquarium_20160304 --> archive contenant les résultats bruts
%                                   de l'expérience de calibrage initial
%   UVP_incertitudes\pipette --> dossier créé lors du stage afin de traiter
%                                la présence de la pipette sur les images (voir dossier pipette dans le
%                                projet pour plus de détails)
%
% Blandine JACOB - 05 mai 2022

%% sélection du dossier de travail raw 

% --------------------------------- !!! attention chemin en dur !!! ---------------------------------

cd('Y:\_UVP5_projets_intercalibrage\uvp5_archives_calibrages_utiles\sn203\2016\uvp5_sn203_aquarium_20160304\raw')
pathname = uigetdir();
inputFolder = fullfile(pathname);

%% extraction des données brutes à partir des fichiers bru

% recherche du fichier 'bru' dans le dossier de travail
filePattern = fullfile(inputFolder, '*.bru');

% fonction extraction_data_bru pour récupérer les variables d'intérêt
table_brute = extraction_data_bru(filePattern);

%%  chargement des vecteurs de booléen presence_pipette (obtenu par le script pipette)

% sélection du dossier où est stocké le vecteur booléen presence_pipette
% correspondant au dossier raw

% --------------------------------- !!! attention chemin en dur !!! ---------------------------------

cd('Z:\UVP_incertitudes\1.etude_calibrage_initial_en_aquarium\projet_Matlab_inabouti\pipette');
cd(pathname(end-16:end));
load('presence_pipette.mat');

%% traitement de la table en vue de l'analyse

%retour au dossier où se trouve les fonctions de traitement des données
% fonction process_table 
table_processed = process_table(table_brute,presence_pipette);

%% suppression des lignes dans la table qui correspondent à du bruit - fonction remove_noise

bruit = 2 ; 
table_filtrees = remove_noise(table_processed,bruit);

%% Affichage des graphiques d'aires et de trajectoires

graph_area(table_filtrees);

graph_trajectories(table_filtrees);

cd('C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\UVP_incertitudes\UVP_calibrage_initial\1_preparation_donnees')