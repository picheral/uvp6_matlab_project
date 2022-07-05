function [matrice_classes] = esd_class_MC(uvp_cast,couple_Aa_exp)

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

pixsize = uvp_cast.pixsize;
aa_ref = couple_Aa_exp(1,:);
expo_ref = couple_Aa_exp(2,:);

for i=1:length(aa_ref)
      

    esd_calib = 2*((aa_ref(i)*(pixsize.^expo_ref(i))./pi).^0.5);

    histo_ab_mean = nanmean(uvp_cast.histo_ab);
    
    histo_ab_mean_red = histo_ab_mean(1:numel(esd_calib));

    [calib_vect_ecotaxa]= sum_ab_classe(esd_calib,process_params.esd_vect_ecotaxa, histo_ab_mean_red);

    matrice_classes = [matrice_classes ; calib_vect_ecotaxa];

end

