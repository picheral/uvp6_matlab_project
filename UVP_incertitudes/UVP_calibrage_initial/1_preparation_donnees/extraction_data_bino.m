function data_bino = extraction_data_bino(filename);

%% Fonction extraction_data_bino(filename)
%
%  Extraction des données bino d'un fichier .xlsx
%
%  Données pour 'extraction_data_bino' :
%       Input : 
%            filename : nom du fichier à extraire 
%            --> exemple :  'Z:\UVP_incertitudes\calibrage_initial_2016\Original_data\calibrage_aquarium_sn203_20160322.xlsx'  
%                           --> ce dossier est une copie de
%                               'Y:\_UVP5_projets_intercalibrage\uvp5_archives_calibrages_utiles\sn203\2016\uvp5_sn203_aquarium_20160304\bino\calibrage_aquarium_sn203_20160322.xlsx'
%                                où Y est le serveur uvp_reglages. Le fichier a été copié afin de le modifier pour qu'il soit prêt à être exploité par un code matlab 
%                                (par ex ajout de "NaN" au lieu de cases vides ou de "_" à la place de " ")        
%               
%       Output:
%            data_bino : table composée de :
%               - folder : dossier de travail correspondant de l'UVP 
%               - area_bino : aire de la particule observée au microscope binoculaire
%               
%  
%
% Blandine JACOB - 06 mai 2022

%%
 

%lecture du fichier excel
all_data = readtable(filename);


%conservation des colonnes 1 'folder' et 7 'aire en mm^2'
data_bino = all_data(:,[1,7]);

 
