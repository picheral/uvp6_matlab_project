%% Script : UvpPlotCalibratedData plots calibrated data, fit and spectrum
%
%   inputs:
%       process_params : struct of process parameters
%       ref_cast : struct storing computed variables from ref uvp
%       adj_cast : struct storing computed variables from adj uvp
%       datahistref : fited ref abundance
%       yresults_adj : fited adj calibrated abundance
%       ref_esd_calib_log : log de l'esd calibré de ref ou mean ref
%       ecart_type_ab : écart-type de l'abondance, après propagation des
%       incertitudes
%
% Inspiré de CalibrationUvpPlotCalibratedData (copié et nettoyé pour garder ce qui m'intéresse est même plus exact)
%
% Modifié le 01 Juillet 2022
%
%%

% Aa et expo de référence du calibrage inital 
aa_ref = 0.0036 ;
expo_ref = 1.149 ; 

%Aa et expo ajusté de l'intercalibrage
aa_adj = 0.010262 ;
expo_adj = 1.1785 ;

% chargement des données correspondant aux aa et exp de l'intercalibrage
[ref_cast, adj_cast] = uvp_cast_apres_intercalibrage(aa_ref,expo_ref,aa_adj,expo_adj);

% chargement des matrice de (Aa,exp) résultats des simu Monte-Carlo
load('Z:\UVP_incertitudes\Partie_II\res_MC.mat')
% chargement des scores des optimisations des simulations Monte-Carlo pour
% l'intercalibrage
load('Z:\UVP_incertitudes\Partie_II\score_optim_intercalibrage_MC.mat')

% chargement des histogrammes brutes de comptage des particules
pixsize_ref = [1:size(ref_cast.histopx,2)];
pixsize_adj = [1:size(adj_cast.histopx,2)];

%%
% ------------------------- pour l'uvp-sn203 -----------------------------%

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
[ecart_type_ab_ref] = incertitudes_classe_de_taille(matrice_classes_ref);

% ------------------------ pour l'uvp5-sn002 -----------------------------%

% on enlève les simulations pour lesquelles les optimisations n'avaient pas
% abouties
to_remove=[];
for i=1:length(score)
    if score(i)>0.02
        to_remove = [to_remove ; i];
    end
end
couple_Aa_exp_adj(:,to_remove)=[];

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
[ecart_type_ab_adj] = incertitudes_classe_de_taille(matrice_classes_adj);

% calcul des fits
[fitresult_ref] = two_fits(ref_cast.esd_calib_log,log(ref_cast.histo_mm2_vol_mean),'poly6',1,log([1:numel(adj_cast.histo_mm2_vol_mean)].*(adj_cast.pix^2)),log(adj_cast.histo_mm2_vol_mean),'poly6');  
[fitresult_adj] = two_fits(adj_cast.esd_calib_log,adj_cast.histo_mm2_vol_mean_log,'poly6',0,adj_cast.esd_calib_log,adj_cast.histo_mm2_vol_mean_log,'poly6');
[yresults_adj] = poly_from_fit(adj_cast.esd_calib_log,fitresult_adj,'poly6');
[datahistref] = poly_from_fit(ref_cast.esd_calib_log,fitresult_ref,'poly6');

%% plot des spectres

fig2 = figure('name','ADJUSTED data','Position',[700 50 1500 600]);
% ------------------- Abundance VS area ----------------------------------
subplot(1,3,1)
errorbar(ref_cast.area_mm2_calib,ref_cast.histo_mm2_vol_mean,[],[],1.96*u_area_mm2_calib_ref,1.96*u_area_mm2_calib_ref,'ro')
%loglog(ref_cast.area_mm2_calib,ref_cast.histo_mm2_vol_mean,'ro');
set(gca, 'XScale','log', 'YScale','log')
hold on
%errorbar(adj_cast.area_mm2_calib, adj_cast.histo_mm2_vol_mean,1.96*u_area_mm2_calib_adj,'horizontal','g+')
set(gca, 'XScale','log', 'YScale','log')
loglog(adj_cast.area_mm2_calib,adj_cast.histo_mm2_vol_mean,'g+');
hold on

axis([0.001 2 0.01 1000000]);
xlabel('AREA [mm²]','fontsize',12);
ylabel('ABUNDANCES [#/mm²/L]','fontsize',12);
title(['CALIBRATED DATA'],'fontsize',14);
legend(ref_cast.uvp,adj_cast.uvp);


% ------------------- abundance VS esd -----------------------------------
subplot(1,3,2)

%loglog(exp(ref_cast.esd_calib_log),exp(datahistref),'r-');
errorbar(exp(ref_cast.esd_calib_log),exp(datahistref),1.96*u_esd_ref,'horizontal','r-')
set(gca, 'XScale','log', 'YScale','log')
hold on
%errorbar(exp(adj_cast.esd_calib_log),exp(yresults_adj),1.96*u_esd_adj,'horizontal','g--')
loglog(exp(adj_cast.esd_calib_log),exp(yresults_adj),'g--');
set(gca, 'XScale','log', 'YScale','log')

legend(ref_cast.uvp,adj_cast.uvp);
axis([0.05 2 0.01 1000000]);
xlabel('ESD [mm]','fontsize',12);
ylabel('ABUNDANCES [#/L]','fontsize',12);
title(['CALIBRATED FIT'],'fontsize',14);


%------------------- Abundance VS esd class -----------------------------

% % particles class plot
% subplot(1,3,3)
% errorbar(ref_cast.calib_esd_vect_ecotaxa, (ecart_type_ab_ref'),'ro')
% set(gca, 'XScale','linear', 'YScale','log')
% %semilogy(ref_cast.calib_esd_vect_ecotaxa,'ro');
% hold on
% errorbar(adj_cast.calib_esd_vect_ecotaxa, ecart_type_ab_adj,'go')
% %semilogy(adj_cast.calib_esd_vect_ecotaxa,'go');
% set(gca, 'XScale','linear', 'YScale','log')
% 
% legend(ref_cast.uvp,adj_cast.uvp);
% title(['CALIBRATED DATA'],'fontsize',14);
% xlabel('ESD CLASS [#]','fontsize',12);
% ylabel('ABUNDANCE [#/L]','fontsize',12);
% axis([0 15 0.01 50000]);


