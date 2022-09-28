%% Script plot_histo_esd_class 
%
% Objectif : tracer les histogrammes de chaque classe de taille avec la moyenne et
% enregistrer les figures au format fig et jpg. Tracer le spectre de taille
% avec les classes esd en abscisse, et des incertitudes.
%
% Appel de la fonction plot_esd_class_with_uncertainties
%
% Blandine Jacob - 5 juillet 2022


%% Choix de l'intercalibrage étudié et téléchargement des matrices contenant les incertitudes. 
% Ces matrices sont issues de la fonction 'UvpCalibratedData'

generation = input('Génération UVP à ajuster? 5/6: ');

while  (strcmp(generation,'5') || strcmp(generation,'6')) == 0
     generation = input('Mauvaise réponse: génération UVP à ajuster? 5/6: ');
end

if strcmp(generation,'6')
    load('Z:\UVP_incertitudes\2_etude_intercalibrages\methode_monte_carlo\sn000008lp_from_sn002\results\donnees_matlab\res_MC_propag_incert_spectre_taille.mat')
else 
    intercalibrage = input('quel UVP est étudié? sn002/sn201: ');
    
    
    while  (strcmp(intercalibrage,'sn002') || strcmp(intercalibrage,'sn201')) == 0
         intercalibrage = input('Mauvaise réponse: quel UVP est étudié? sn002/sn201: ');
    end
    
    if strcmp(intercalibrage,'sn002')
        load('Z:\UVP_incertitudes\2_etude_intercalibrages\methode_monte_carlo\sn002_from_sn203\avec_esd_min=0.1\results\donnees_matlab\res_MC_propag_incert_spectre_taille.mat')

    else 
       load('Z:\UVP_incertitudes\2_etude_intercalibrages\methode_monte_carlo\sn201_from_sn203\results\donnees_matlab\res_MC_propag_incert_spectre_taille.mat');
    end
end
%% Questions aux utilisateurs

enregistrement = input('Enregistrer les histogrammes? oui/non: ');
type = input('tracer les histogrammes étalon ou instrument à ajuster ? ref/adj: ');

if strcmp(type,'ref')
    matrice_classes = matrice_classes_ref;
    ecart_type_ab = ecart_type_ab_ref ;
    uvp_cast = ref_cast ;
else 
    matrice_classes = matrice_classes_adj;
    ecart_type_ab = ecart_type_ab_adj ;
    uvp_cast = adj_cast ;
end


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
    savefig(h,'Classe_de_taille_ESD_',num2str(uvp_cast.uvp),'.fig');
    close(h)
    figs = openfig('Classe_de_taille_ESD_',num2str(uvp_cast.uvp),'.fig');
    
    for i=1:length(figs)
        saveas(figs(i),['Classe_de_taille_ESD_',num2str(uvp_cast.uvp),'_',num2str(i), '.jpg' ])
    end
end

%% Appel de la fonction plot_esd_class_with_uncertainties pour tracer le spectre de taille avec les classes ESD en abscisse

plot_esd_class_with_uncertainties(uvp_cast,matrice_classes, ecart_type_ab);