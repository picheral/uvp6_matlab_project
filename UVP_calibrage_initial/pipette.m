%% Script Matlab 'pipette' :
%  
% Objet : automatisation de la création et de la récupération d'un vecteur
% presence_pipette 
%
% Contexte : 123 lâchers de particules à analyser, pour chaque lâcher on dispose d'un certain nombre de photographies. 
%             Pour chaque lâcher on souhaite regarder si la pipette est présente sur les photographies. 
%
% Fonction utilisées :
%   'extraction_data_bino' : ici utilisée pour récupérer le nom des dossiers de travail
%   'control_images' : fonction qui permet de détecter la présence de la
%   pipette
% 
%
%
% Blandine JACOB - 06 mai 2022
%
% boucle while non terminé, à reprendre en commençant à i = 23
%% 


%récupération du nom du fichier excel où sont inscrits les noms des dossiers de référence
filename =  'Z:\UVP_incertitudes\calibrage_initial_2016\Original_data\calibrage_aquarium_sn203_20160322.xlsx' ;

%création d'une table a partir de la fonction extraction_data_bino
table_bino = extraction_data_bino(filename);

%récupération du nombre de particules lachées dans l'aquarium
nombre_objet_preleves = size(table_bino.Folder, 1);


i = 1;

% boucle sur le nombre d'objet prélevés
while i <= nombre_objet_preleves
    
    %récupération nom de répertoire de travail (exemple 'HDR20160303091941')
    name_work_folder = table_bino.Folder(i);
    
    
    %retour dans le dossier de travail où se trouve la fonction presence_pipette
    cd('C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\UVP_calibrage_initial')
    
    %les dossiers 'HDR2016030XHHMMSS' sont rangés dans deux dossiers
    %différents  X = 3 ou 4
    test_dossier = char(name_work_folder);
    

    if test_dossier(11) == '3'; % si X = 3 dossier 'uvp5_sn203_aquarium_20160304'
        pathname = strcat('Y:\_UVP5_projets_intercalibrage\uvp5_archives_calibrages_utiles\uvp5_sn203_aquarium_20160304\raw\',char(name_work_folder));
    else % si X = 4 dossier 'uvp5_sn203_aquarium_20160305'
        pathname = strcat('Y:\_UVP5_projets_intercalibrage\uvp5_archives_calibrages_utiles\uvp5_sn203_aquarium_20160305\raw\',char(name_work_folder));
    end

    % boite de dialogue afin de sortir de la boucle en cas de besoin
    answer = questdlg('Passer à l image suivante?', 'Question','Oui', 'Non','Non');

    switch answer

        case 'Oui'
           %détermination de la presence d'une pipette grâce à la fonction
           %control_images
           presence_pipette = control_images(pathname);
           %création d'un dossier de même nom que name_work_folder où on
           %ranger les résultats
           cd('Z:\UVP_incertitudes\pipette\')
           mkdir(char(name_work_folder));
           filenom=strcat('Z:\UVP_incertitudes\pipette\',char(name_work_folder),'\','presence_pipette','.mat');
           save(filenom);
           i = i +1 ; 

        case 'Non'
           i = nombre_objet_preleves + 1 ; %pour sortir directement de la boucle
           close;
    end
    
end

