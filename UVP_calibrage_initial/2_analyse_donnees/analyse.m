%% Script matlab analyse :
%
% But : à partir des graphiques d'aires et de trajectoires du obtenu avec
%       le scrip main.m, des points ont été sélectionnés avec l'outil brush. 
%       Ce script effectue l'analyse statistique de ces données et l'écriture dans la table des résultats si cela convient
%
% Fonction : ana_stat
%
% Blandine Jacob - 9 mai 2022

%% Analyse statistique des données - fonction ana_stat

results = ana_stat(to_analyze,name_work_folder)

%%  Ecriture de la table dans un fichier .dat dans le dossier analyse_donnees

answer = questdlg('Résultats conviennent?', 'Question','Oui', 'Non','Non');
switch answer
    case 'Oui'
       writetable(results,'C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\UVP_calibrage_initial\3_creation_fit\resultats.dat','WriteMode','Append')
    case 'Non'
        
end

close all ;