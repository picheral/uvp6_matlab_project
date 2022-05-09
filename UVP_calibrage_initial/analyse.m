%% Script matlab analyse :
% à partir des points sélectionnés avec l'outil brush, analyse statistique
% des données et écriture dans la table des résultats si cela convient
%
% Fonctions : ana_stat
%
% Blandine Jacob - 9 mai
%% Analyse statistique des données - fonction ana_stat

results = ana_stat(to_analyze,name_work_folder);

%%  Ecriture de la table dans un fichier .dat

 answer = questdlg('Résultats conviennent?', 'Question','Oui', 'Non','Non');
switch answer
    case 'Oui'
       writetable(results,'resultats.dat','WriteMode','Append')
    case 'Non'
        close
end

