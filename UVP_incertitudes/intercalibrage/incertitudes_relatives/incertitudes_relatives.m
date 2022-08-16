% Script incertitudes relatives
%
% Script pour récupérer les incertitudes relatives des intercalibrages
% étudiés
%
% Fonction utilisée: calculs_incert_relatives
%
% Blandine Jacob - 28 Juillet 2022
%%

% sn002 from sn203

load('Z:\UVP_incertitudes\2_etude_intercalibrages\methode_monte_carlo\sn002_from_sn203\avec_esd_min=0.1\results\donnees_matlab\res_MC_propag_incert_spectre_taille.mat');
[incert_relatives_203, incert_relatives_002] = calculs_incert_relatives(ref_cast, adj_cast, u_esd_ref, u_esd_adj, u_area_mm2_calib_ref, u_area_mm2_calib_adj,ecart_type_ab_ref, ecart_type_ab_adj)

% sn201 from sn203
load('Z:\UVP_incertitudes\2_etude_intercalibrages\methode_monte_carlo\sn201_from_sn203\results\donnees_matlab\res_MC_propag_incert_spectre_taille.mat');
[incert_relatives_203_bis, incert_relatives_201, test] = calculs_incert_relatives(ref_cast, adj_cast, u_esd_ref, u_esd_adj, u_area_mm2_calib_ref, u_area_mm2_calib_adj,ecart_type_ab_ref, ecart_type_ab_adj)

% sn000008lp from sn002
load('Z:\UVP_incertitudes\2_etude_intercalibrages\methode_monte_carlo\sn000008lp_from_sn002\results\donnees_matlab\res_MC_propag_incert_spectre_taille.mat');
[incert_relatives_002_bis, incert_relatives_000008lp] = calculs_incert_relatives(ref_cast, adj_cast, u_esd_ref, u_esd_adj, u_area_mm2_calib_ref, u_area_mm2_calib_adj,ecart_type_ab_ref, ecart_type_ab_adj)

% enregistrement des résultats
%save('Z:\UVP_incertitudes\3_etude_incertitudes_relatives_produits_scientifiques\incertitudes_relatives\donnees_matlab\incertitudes_relatives.mat')