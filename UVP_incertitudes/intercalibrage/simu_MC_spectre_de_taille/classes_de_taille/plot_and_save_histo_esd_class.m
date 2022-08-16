function [] = plot_and_save_histo_esd_class(matrice_classes,ecart_type_ab,uvp_cast)

%% Fonction plot_histo_esd_class 
%
% Objectif : tracer les histogrammes de chaque classe de taille avec la moyenne et
% enregistrer les figures au format fig et jpg
%
% Input : matrice_classe :  une matrice de classe esd issus d'une simulation
%                           Monte-Carlo (10^5 x 19) et calculé dans le script UvpPlotCalibratedData à
%                           partir de la fonction esd_class_MC
%         ecart_type_ab : ecart-type des classes de taille grâce à la matrice_classe, calculé dans UvpPlotCalibratedData
%         uvp_cast : pour récupérer le nom de l'UVP
%
% Blandine Jacob - 5 juillet 2022
%% NB :
%
% Cette fonction n'est pas utilisée dans un script: j'importais directement
% les données matlab res_MC_propag_incert_spectre_taille.mat,
% puis j'appelais la fonction dans la fenêtre de commande afin de tracer les histogrammes
% (et potentiellement les enregistrer)
%
% Pour appeler la fonction:
%    matrice_classes : matrice_classe_ref ou matrice_classe_adj
%    ecart_type_ab :  ecart_type_ab_ref ou ecart_type_ab_adj 
%    uvp_cast : ref_cast ou adj_cast
%%

enregistrement = input('Enregistrer les histogrammes? oui/non: ');

%% Plot des histogrammes en fréquence des abondances par classe de taille
for i=1:width(matrice_classes)
    h(i) = figure();
    if (matrice_classes(:,i))==zeros
        title(['Classe ', num2str(i),' vide'])
        subtitle(uvp_cast.uvp)
    else
        histogram(matrice_classes(:,i))
        hold on
        line([mean(matrice_classes(:,i))+ecart_type_ab(i), mean(matrice_classes(:,i))+ecart_type_ab(i)], ylim, 'LineWidth', 2, 'Color', 'r');
        hold on
        line([mean(matrice_classes(:,i))-ecart_type_ab(i), mean(matrice_classes(:,i))-ecart_type_ab(i)], ylim, 'LineWidth', 2, 'Color', 'r');        
        hold on
        line([mean(matrice_classes(:,i)), mean(matrice_classes(:,i))], ylim, 'LineWidth', 2, 'Color', 'g');
        title(['Classe ESD n°',num2str(i)])
        subtitle(uvp_cast.uvp)
        xlabel('Valeur')
        ylabel('Fréquence')
    end
end

%% Enregistrement des histogrammes
% nb: ça s'enregistre dans le projet --> il faut ensuite les couper pour
% les stocker ailleurs

if strcmp(enregistrement,'oui')
    %----------------  !! penser à modifier le nom du fichier en fonction du nom de l'uvp !!---------------- %
    savefig(h,'Classe_de_taille_ESD_'num2str(uvp_cast.uvp),'.fig');
    close(h)
    %----------------  !! penser à modifier le nom du fichier en fonction du nom de l'uvp !!---------------- %
    figs = openfig('Classe_de_taille_ESD_',num2str(uvp_cast.uvp),'.fig');
    
    for i=1:length(figs)
        %----------------  !! penser à modifier le nom du fichier en fonction du nom de l'uvp !!---------------- %
        saveas(figs(i),['Classe_de_taille_ESD_',num2str(uvp_cast.uvp),'_',num2str(i), '.jpg' ])
    end
end
