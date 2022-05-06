% Script Matlab pour tester les fonctions suivantes :
%
%   extraction_data_bru
%   control_images
%   process_table
%   remove_noise
%   graph_area
%   graph_trajectories


% Blandine JACOB - 05 mai 2022

%% sélection du dossier de travail
pathname = uigetdir()

inputFolder = fullfile(pathname);

%% extraction des données brutes à partir des fichiers bru


% recherche du fichier 'bru' dans le dossier de travail
filePattern = fullfile(inputFolder, '*.bru');

% fonction extraction_data_bru pour récupérer les variables d'intérêt
table_brute = extraction_data_bru(filePattern);

%%  contrôle des images pour déterminer si on voit ou non la pipette

% fonction control_image

pipette = control_images(pathname)

%% traitement de la table en vue de l'analyse

% fonction process_table 
table_processed = process_table(table_brute,pipette);

%% suppression des lignes dans la table qui correspondent à du bruit - fonction remove_noise

bruit = 2 ; 
table_filtrees = remove_noise(table_processed,bruit);

%% Affichage des graphiques d'aires et de trajectoires

graph_area(table_filtrees);

graph_trajectories(table_filtrees);

%% Analyse statistique des données

% %if ~ exist('to_analyze')
%     answer = questdlg('Sélectionner des données à analyser (outil brush)');
%     results = ana_stat(to_analyze);
%end
  
