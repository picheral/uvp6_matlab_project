function [] = plot_and_save_histo_esd_class(matrice_classes)
%% Fonction plot_histo_esd_class 
%
% Objectif : tracer les histogrammes de chaque classe de taille et
% enregistrer les figures au format fig et jpg
%
% Input : matrice_classe :  une matrice de classe esd issus d'une simulation
%                           Monte-Carlo (10^5 x 19) et calculé dans le script UvpPlotCalibratedData à
%                           partir de la fonction esd_class_MC
% 
% Blandine Jacob - 5 juillet 2022
%%

for i=1:width(matrice_classes)
    h(i) = figure()
    if (matrice_classes(:,i))==zeros
        title(['Classe ', num2str(i),' vide'])
    else
        histogram(matrice_classes(:,i))
        title(['Classe ESD n°',num2str(i)])
        xlabel('Valeur')
        ylabel('Fréquence')
    end
end

% ----------------  !! penser à modifier le nom du fichier en fonction du nom de l'uvp !!---------------- %
savefig(h,'Classe_de_taille_ESD_uvp_sn002.fig')
close(h)
% ----------------  !! penser à modifier le nom du fichier en fonction du nom de l'uvp !!---------------- %
figs = openfig('Classe_de_taille_ESD_uvp_sn002.fig');

for i=1:length(figs)
    % ----------------  !! penser à modifier le nom du fichier en fonction du nom de l'uvp !!---------------- %
    saveas(figs(i),['Classe_de_taille_ESD_uvp_sn002_', num2str(i), '.jpg' ])
end

