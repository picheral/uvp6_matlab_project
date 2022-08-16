function [incertitudes_relatives_ref, incertitudes_relatives_adj,test] = calculs_incert_relatives(ref_cast, adj_cast, u_esd_ref, u_esd_adj, u_area_mm2_calib_ref, u_area_mm2_calib_adj,ecart_type_ab_ref, ecart_type_ab_adj)


%% Fonction calculs_incert_relatives
%
% Objectif : calculer les incertitudes relatives en pourcentage sur : la
%            taille esd, la taille en mm², les abondances par classe de taille
%         
% Blandine Jacob - juillet 2022
%%

% ref

incertitudes_relatives_ref.esd = 100*u_esd_ref./ref_cast.esd_calib ; %en pourcentage
incertitudes_relatives_ref.area= 100*u_area_mm2_calib_ref./ref_cast.area_mm2_calib;
incertitudes_relatives_ref.esd_class = 100*ecart_type_ab_ref'./ref_cast.calib_esd_vect_ecotaxa ;



% adj

incertitudes_relatives_adj.esd = 100*u_esd_adj./adj_cast.esd_calib ;
incertitudes_relatives_adj.area = 100*u_area_mm2_calib_adj./adj_cast.area_mm2_calib;
incertitudes_relatives_adj.esd_class = 100*ecart_type_ab_adj'./adj_cast.calib_esd_vect_ecotaxa;
%%

esd_vect_ecotaxa = [0.0403 0.0508 0.064 0.0806 0.102 0.128 0.161 0.203 0.256 0.323 0.406 0.512 0.645 0.813 1.020 1.290 1.630 2.050 2.580];
esd_calib = 2*((adj_cast.aa_data*(adj_cast.pixsize.^adj_cast.expo_data)./pi).^0.5);

histo_ab_mean = nanmean(adj_cast.histo_ab); 
histo_ab_mean_red = histo_ab_mean(1:numel(esd_calib));

[calib_vect_ecotaxa]= sum_ab_classe(esd_calib, esd_vect_ecotaxa, histo_ab_mean_red)


test = 100*ecart_type_ab_adj'./calib_vect_ecotaxa;
