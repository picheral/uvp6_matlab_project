function data_of_interest = extraction_data_bru(filePattern)

% extraction_data_bru(filePattern)

%  Extraction des données d'intérêt d'un fichier .bru
%
%  Données pour 'extraction_data_bru' :
%       Input : 
%            filePattern : chemin du fichier à extraire 
%               
%       Output:
%            data_of_interest : table composée de :
%               index : index de l'image
%               area : aire de la particule observée
%               Xcenter : position X du centre de gravité de la particule observée
%               Ycenter : position Y du centre de gravité de la particule observée
%
%   Exemple : extraction_data_bru('Y:\_UVP5_projets_intercalibrage\uvp5_archives_calibrages_utiles\uvp5_sn203_aquarium_20160304\raw\HDR20160303091656\HDR20160303091656_000.bru')
%
% Blandine JACOB - 04 mai 2022

%% Extraction bru : 

% concatenation du filePattern dont on a enlevé '*.bru' et du nom du fichier bru 
filename = strcat(filePattern(1:end-5),dir(filePattern).name);

% Creation de l'objet opts contenant les proprietes pour le processus de création de la table 
opts = delimitedTextImportOptions("NumVariables", 7);  % importation de 7 variables 

% Lignes à lire, on enlève la premiere qui contient le titre de colonnes
opts.DataLines = [2,Inf];

% Specification nom colonne et types de données dans la table
opts.VariableNames = ["index", "image", "blob","area", "meangrey", "xcenter", "ycenter"];
opts.VariableTypes = ["double", "string", "double", "double", "double","double", "double"];

%delimitation entre les colonnes
opts.Delimiter = [";\t", ";\t", ";\t",";\t",";\t",";\t",";"];

%lecture du fichier
data = readtable(filename,opts);

%selection des donnees qui nous interessent, à savoir les colonnes 1 4 6 et 7
%correspondant respectivement à l'index, l'area, xcenter, ycenter
data_of_interest = data(:,[1,4,6,7])

