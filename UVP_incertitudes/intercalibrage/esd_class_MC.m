%% Script Matlab : esd_class_MC
%
%
% But : récupérer les classes de tailles pour les 10^5 simu monte Carlo
% afin de visualiser les distributions et récupérer les écarts types
%
% Blandine JACOB - 1er juillet 2022


%%

addpath(' C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\Ressources_partagees')
addpath('C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\Intercalibrage\calibration_uvp_functions')
load('Z:\UVP_incertitudes\Partie_II\monte-carlo\results\raw\MC_propag_incert.mat')
matrice_classes=[];

for i=1:length(aa_adj)
      
    pixsize = adj_cast.pixsize;

    esd_calib = 2*((aa_adj(i)*(pixsize.^expo_adj(i))./pi).^0.5);
    
    histo_ab_mean = nanmean(adj_cast.histo_ab);
    
    histo_ab_mean_red = histo_ab_mean(1:numel(esd_calib));

    [calib_vect_ecotaxa]= sum_ab_classe(esd_calib,process_params.esd_vect_ecotaxa,adj_cast.histo_ab);

    matrice_classes = [matrice_classes ; calib_vect_ecotaxa];

end

[ecart_type_ab] = classe_de_taille_et_incertitudes(score, matrice_classes)
