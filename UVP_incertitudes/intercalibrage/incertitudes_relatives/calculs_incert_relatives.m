function [incertitudes_relatives_ref, incertitudes_relatives_adj] = calculs_incert_relatives(ref_cast, adj_cast, u_esd_ref, u_esd_adj, u_area_mm2_calib_ref, u_area_mm2_calib_adj,ecart_type_ab_ref, ecart_type_ab_adj)


%% Fonction calculs_incert_relatives
%
% Fonction appelée par incertitudes_relatives.m
%
% Objectif : calculer les incertitudes relatives en pourcentage sur : la
%            taille esd, la taille en mm², les abondances par classe de taille
%         
% Input :
%       o	ref_cast : structure uvp étalon
%       o	adj_cast : structure uvp à ajuster
%       o	u_esd_ref : incertitudes absolues sur taille esd pour l'uvp étalon
%       o	u_esd_adj : idem pour uvp à ajuster
%       o	u_area_mm2_calib_ref: incertitudes absolues sur taille en mm² pour l'uvp étalon
%       o	u_area_mm2_calib_adj: idem pour uvp à ajuster
%       o	ecart_type_ab_ref : incertitudes absolues sur abondance par classe de taille pour l'uvp étalon
%       o	ecart_type_ab_adj : idem pour uvp à ajuster
%
% Output :
%
%       •	incertitudes_relatives_ref : structure contenant les incertitudes relatives (taille en mm esd, en mm2 et abondance par classe de de taille de l uvp étalon de l²intercalibrage étudié
%       •	incertitudes_relatives_adj : idem pour l uvp à ajuster

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
