function [presence_pipette] = control_images(pathname)

% control_images(pathname)
%  
% Controle des images afin de déterminer si il y a présence d'une pipette
%
%  Données pour 'control_images' :
%       Input : 
%           pathname : dossier de travail 
%                   exemple : 'C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\UVP_calibrage_initial\HDR20160303091656'
%            
%               
%       Output:
%           presence_pipette : vecteur booléen : 0 = non ; 1 = oui
%    
% inspiré de Image Analyst - https://fr.mathworks.com/matlabcentral/answers/178746-conversion-of-bmp-to-jpg-images
%
% Blandine JACOB - 04 mai 2022
%%

% détermination du dossier où se trouve les images à contrôler
inputFolder = fullfile(pathname);
filePattern = fullfile(inputFolder, '*.bmp');

% Get list of all BMP files in input folder
bmpFiles = dir(filePattern);

% initialisation du vecteur de booléen presence_pipette
presence_pipette = zeros(length(bmpFiles),1);

figure;

% agrandissement des figures .
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

% Boucle sur les fichier .bmp  
for k = 1 : length(bmpFiles)

    % Lecture et affichage des fichiers  .bmp 
    baseFileName = bmpFiles(k).name;
    fullFileNameInput = fullfile(inputFolder, baseFileName);
    rgbImage = imread(fullFileNameInput);
    imshow(rgbImage);
    drawnow;
    
    %demande à l'utilisateur si la pipette est présente
    answer = questdlg('La pipette est-elle présente?', 'Question','Oui', 'Non','Non');
    switch answer
        case 'Oui'
            presence_pipette(k) = 1; 
        case 'Non'
            close
            break;  %sortie de boucle si la pipette n'est plus visible sur les photos   
    end

end