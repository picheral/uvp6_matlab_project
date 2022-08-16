%% Script : UvpCalibratedData prepare data for plots calibrated data, fit and spectrum
%
% But : préparer le traçage des spectres et calculer les incertitudes sur les données
% 
% 
% Fonctions utilisées dans ce script:   
%          uvp_cast_apres_intercalibrage: qui calcule les cast après
%                                          intercalibrage
%          esd_class_MC : qui calcule la répartition en classes de taille
%                         des particules pour chaque itération Monte-Carlo
%                                                   
%
% Inspiré de CalibrationUvpPlotCalibratedData (copié et nettoyé pour garder ce qui m'intéresse est même plus exact)
%
% Modifié le 01 Juillet 2022
%
%%

generation = input('Génération UVP à ajuster? 5/6: ');

while  (strcmp(generation,'5') || strcmp(generation,'6')) == 0
     generation = input('Mauvaise réponse: génération UVP à ajuster? 5/6: ');
end

if strcmp(generation,'6')
    intercalibrage = 'sn000008lp';
    aa_ref = 0.010262 ;
    expo_ref = 1.1785 ;
    aa_adj = 0.002368 ;
    expo_adj =1.1349 ;
    poly = 'poly3'; %pour les fit
    path_ref = 'Y:\_UVP5_projets_intercalibrage\uvp5_archives_calibrages_utiles\sn002\2020\uvp5_sn002_intercalibrage_20200128';
    path_adj = 'Y:\_UVP6_projets_intercalibrage\Etalons\000008LP\2020\uvp6_sn000008lp_20200130_20200221_intercalibrage';
else 
    intercalibrage = input('quel UVP est étudié? sn002/sn201: ');
    
    while  (strcmp(intercalibrage,'sn002') || strcmp(intercalibrage,'sn201')) == 0
         intercalibrage = input('Mauvaise réponse: quel UVP est étudié? sn002/sn201: ');
    end
    if strcmp(intercalibrage,'sn002')
        aa_ref =  0.0036 ;
        expo_ref = 1.149 ;
        aa_adj = 0.010262 ;
        expo_adj = 1.1785 ;
        poly = 'poly6'; %pour les fit
        path_ref = 'Y:\_UVP5_projets_intercalibrage\uvp5_archives_calibrages_utiles\sn203\2017\uvp5_sn203_intercalibrage_20171201';
        path_adj = 'Y:\_UVP5_projets_intercalibrage\uvp5_archives_calibrages_utiles\sn002\2017\uvp5_sn002_intercalibrage_20171201';
    else %uvp5-sn201 donc
        aa_ref =  0.0036 ;
        expo_ref = 1.149 ;
        aa_adj = 0.0036191 ;
        expo_adj = 1.1154 ;
        poly = 'poly6'; 
        path_ref = 'Y:\_UVP5_projets_intercalibrage\uvp5_archives_calibrages_utiles\sn203\2016\uvp5_sn203_intercalibrage_20160404';
        path_adj = 'Y:\_UVP5_projets_intercalibrage\uvp5_archives_calibrages_utiles\sn201\2016\uvp5_sn201_intercalibrage_20160404';
    end
end

% chargement des données correspondant aux aa et exp de l'intercalibrage
[ref_cast, adj_cast] = uvp_cast_apres_intercalibrage(aa_ref,expo_ref,aa_adj,expo_adj,path_ref,path_adj);

%%

% chargement des matrice de (Aa,exp) résultats des simus Monte-Carlo et des scores des optimisations des simulations Monte-Carlo pour l'intercalibrage
%!!!!!------------------------- attention chemin en dur ------------------------!!!!!

switch generation
    case '6'
        load('Z:\UVP_incertitudes\2_etude_intercalibrages\methode_monte_carlo\sn000008lp_from_sn002\results\donnees_matlab\MC_params_aa_exp_ref_adj.mat');
    case '5'
        switch intercalibrage
            case 'sn002'
                load('Z:\UVP_incertitudes\2_etude_intercalibrages\methode_monte_carlo\sn002_from_sn203\avec_esd_min=0.1\results\donnees_matlab\MC_params_aa_exp_ref_adj_sans_valeurs_aberrantes.mat')
            case 'sn201'
                load('Z:\UVP_incertitudes\2_etude_intercalibrages\methode_monte_carlo\sn201_from_sn203\results\donnees_matlab\MC_params_aa_exp_ref_adj.mat')
        end
end

% chargement des histogrammes brutes de comptage des particules
pixsize_ref = [1:size(ref_cast.histopx,2)];
pixsize_adj = [1:size(adj_cast.histopx,2)];

%%
% ------------------------- pour l'uvp étalon -----------------------------%

% calcul Monte-Carlo de l'aire en mm² et de la taille ESD en mm des particules
area_mm2_calib_ref =zeros(length(couple_Aa_exp_ref), length(pixsize_ref));
esd_calib_ref =zeros(length(couple_Aa_exp_ref), length(pixsize_ref));

for i=1:length(couple_Aa_exp_ref)
    area_mm2_calib_ref(i,:) = couple_Aa_exp_ref(1,i)*(pixsize_ref.^couple_Aa_exp_ref(2,i));
    esd_calib_ref(i,:) = 2*((couple_Aa_exp_ref(1,i)*(pixsize_ref.^couple_Aa_exp_ref(2,i))./pi).^0.5);
end

% récupération classes de taille uvp_ref Monte-Carlo
[matrice_classes_ref] =  esd_class_MC(ref_cast,couple_Aa_exp_ref);

% incertitude sur area_mm_2_calib_ref
u_area_mm2_calib_ref = std(area_mm2_calib_ref);

% incertitude sur u_esd_ref
u_esd_ref = std(esd_calib_ref) ;

% incertitude sur les classes de taille
ecart_type_ab_ref = zeros(width(matrice_classes_ref),1);
for i=1:width(matrice_classes_ref)
    x = matrice_classes_ref(:,i);
    ecart_type_ab_ref(i)=std(x);
end



%%

% ------------------------ pour l'uvp à ajuster -----------------------------%


% calcul Monte-Carlo de l'aire en mm² et de la taille ESD en mm des particules
area_mm2_calib_adj =zeros(length(couple_Aa_exp_adj), length(pixsize_adj));
esd_calib_adj =zeros(length(couple_Aa_exp_adj), length(pixsize_adj));

for i=1:length(couple_Aa_exp_adj)
    area_mm2_calib_adj(i,:) = couple_Aa_exp_adj(1,i)*(pixsize_adj.^couple_Aa_exp_adj(2,i));
    esd_calib_adj(i,:) = 2*((couple_Aa_exp_adj(1,i)*(pixsize_adj.^couple_Aa_exp_adj(2,i))./pi).^0.5);
end

% récupération classes de taille uvp_adj Monte-Carlo
[matrice_classes_adj] =  esd_class_MC(adj_cast,couple_Aa_exp_adj);

% incertitude sur area_mm_2_calib_adj
u_area_mm2_calib_adj = std(area_mm2_calib_adj);

% incertitude sur la taille esd adj
u_esd_adj = std(esd_calib_adj);

% incertitude sur les classes de taille uvp_adj
ecart_type_ab_adj = zeros(width(matrice_classes_adj),1);
for i=1:width(matrice_classes_adj)
    x = matrice_classes_adj(:,i);
    ecart_type_ab_adj(i)=std(x);
end



%% Calcul des fits

[fitresult_ref] = create_two_fits(ref_cast.esd_calib_log,log(ref_cast.histo_mm2_vol_mean),poly,0,log([1:numel(adj_cast.histo_mm2_vol_mean)].*(adj_cast.pix^2)),log(adj_cast.histo_mm2_vol_mean),poly);  
[fitresult_adj] = create_two_fits(adj_cast.esd_calib_log,adj_cast.histo_mm2_vol_mean_log,poly,0,adj_cast.esd_calib_log,adj_cast.histo_mm2_vol_mean_log,poly);
[yresults_adj] = poly_from_fit(adj_cast.esd_calib_log,fitresult_adj,poly);
[datahistref] = poly_from_fit(ref_cast.esd_calib_log,fitresult_ref,poly);

