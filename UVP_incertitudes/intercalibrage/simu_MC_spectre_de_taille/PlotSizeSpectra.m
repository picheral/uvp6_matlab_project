%% Script : PlotSizeSpectra - plots calibrated data, fit and spectrum
%
% Objectif: tracer les spectres de taille avec les barres d'incertitudes ou
% les enveloppes, sur le spectre de référence, ajusté, ou les deux
%
%
% Blandine Jacob - le 08 Juillet 2022
%
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

%% Choix des options de tracé des incertitudes 

option_plot_incertitudes = input('Barres d erreurs ou enveloppes d incertitudes? B pour barres/E pour enveloppes: ');

option = input('Enveloppe ou barres d incertitudes sur uvp étalon/à ajuster/les deux? ref/adj/both: ');
if isempty(option)
    option = 'both';
end

%% plot des spectres

fig2 = figure('name','ADJUSTED data','Position',[700 50 1500 600]);
% ------------------- Abundance VS area ----------------------------------
subplot(1,3,1)

loglog(ref_cast.area_mm2_calib,ref_cast.histo_mm2_vol_mean,'ro');
hold on
loglog(adj_cast.area_mm2_calib,adj_cast.histo_mm2_vol_mean,'go')

switch option_plot_incertitudes
    % barres d'erreurs
    case 'B'
        switch option
        case 'ref'
            hold on
            errorbar(ref_cast.area_mm2_calib,ref_cast.histo_mm2_vol_mean,[],[],1.96*u_area_mm2_calib_ref,1.96*u_area_mm2_calib_ref,'ro')
        case 'adj'
            hold on
            errorbar(adj_cast.area_mm2_calib, adj_cast.histo_mm2_vol_mean,1.96*u_area_mm2_calib_adj,'horizontal','g+')
        case 'both'
            hold on
            errorbar(ref_cast.area_mm2_calib,ref_cast.histo_mm2_vol_mean,[],[],1.96*u_area_mm2_calib_ref,1.96*u_area_mm2_calib_ref,'ro')
            hold on
            errorbar(adj_cast.area_mm2_calib, adj_cast.histo_mm2_vol_mean,1.96*u_area_mm2_calib_adj,'horizontal','g+')
        end
    case 'E'
        %enveloppes d'incertitudes
        switch option
            case 'ref'
                hold on
                plot(ref_cast.area_mm2_calib + 1.96*u_area_mm2_calib_ref, ref_cast.histo_mm2_vol_mean,'r-.');
                hold on
                plot(ref_cast.area_mm2_calib - 1.96*u_area_mm2_calib_ref,ref_cast.histo_mm2_vol_mean,'r-.');
            case 'adj'
                hold on
                plot(adj_cast.area_mm2_calib + 1.96*u_area_mm2_calib_adj, adj_cast.histo_mm2_vol_mean,'g-.');
                hold on
                plot(adj_cast.area_mm2_calib - 1.96*u_area_mm2_calib_adj,adj_cast.histo_mm2_vol_mean,'g-.');
            case 'both'
                hold on
                plot(ref_cast.area_mm2_calib + 1.96*u_area_mm2_calib_ref, ref_cast.histo_mm2_vol_mean,'r-.');
                hold on
                plot(ref_cast.area_mm2_calib - 1.96*u_area_mm2_calib_ref,ref_cast.histo_mm2_vol_mean,'r-.');
                hold on
                plot(adj_cast.area_mm2_calib + 1.96*u_area_mm2_calib_adj, adj_cast.histo_mm2_vol_mean,'g-.');
                hold on
                plot(adj_cast.area_mm2_calib - 1.96*u_area_mm2_calib_adj, adj_cast.histo_mm2_vol_mean,'g-.');
        end
end

set(gca, 'XScale','log', 'YScale','log')
axis([0.001 2 0.01 1000000]);
xlabel('AREA [mm²]','fontsize',12);
ylabel('ABUNDANCES [#/mm²/L]','fontsize',12);
title(['CALIBRATED DATA'],'fontsize',14);
legend(ref_cast.uvp,adj_cast.uvp);


% ------------------- abundance VS esd -----------------------------------
subplot(1,3,2)

loglog(exp(ref_cast.esd_calib_log),exp(datahistref),'r-');
hold on
loglog(exp(adj_cast.esd_calib_log),exp(yresults_adj),'g-');

switch option_plot_incertitudes
    % barres d'erreurs
    case 'B'
        switch option
        case 'ref'
            hold on
            errorbar(exp(ref_cast.esd_calib_log),exp(datahistref),1.96*u_esd_ref,'horizontal','r-')
        case 'adj'
            hold on
            errorbar(exp(adj_cast.esd_calib_log),exp(yresults_adj),1.96*u_esd_adj,'horizontal','g--')
        case 'both'
            hold on
            errorbar(exp(ref_cast.esd_calib_log),exp(datahistref),1.96*u_esd_ref,'horizontal','r-')
            hold on
            errorbar(exp(adj_cast.esd_calib_log),exp(yresults_adj),1.96*u_esd_adj,'horizontal','g--')
        end
    case 'E'
        %enveloppes d'incertitudes
        switch option
            case 'ref'
                hold on
                loglog(exp(ref_cast.esd_calib_log) + 1.96*u_esd_ref, exp(datahistref),'r-.');
                hold on
                loglog(exp(ref_cast.esd_calib_log) -1.96*u_esd_ref,exp(datahistref),'r-.');
            case 'adj'
                hold on
                loglog(exp(adj_cast.esd_calib_log) + 1.96*u_esd_adj,exp(yresults_adj),'g-.');
                hold on
                loglog(exp(adj_cast.esd_calib_log) - 1.96*u_esd_adj, exp(yresults_adj),'g-.');
            case 'both'
                hold on
                loglog(exp(ref_cast.esd_calib_log) + 1.96*u_esd_ref, exp(datahistref),'r-.');
                hold on
                loglog(exp(ref_cast.esd_calib_log) -1.96*u_esd_ref,exp(datahistref),'r-.');
                hold on
                loglog(exp(adj_cast.esd_calib_log) + 1.96*u_esd_adj,exp(yresults_adj),'g-.');
                hold on
                loglog(exp(adj_cast.esd_calib_log) - 1.96*u_esd_adj, exp(yresults_adj),'g-.');
        end
end


set(gca, 'XScale','log', 'YScale','log')
legend(ref_cast.uvp,adj_cast.uvp);
axis([0.05 2 0.01 1000000]);
xlabel('ESD [mm]','fontsize',12);
ylabel('ABUNDANCES [#/L]','fontsize',12);
title(['CALIBRATED FIT'],'fontsize',14);


%------------------- Abundance VS esd class -----------------------------

% % particles class plot
subplot(1,3,3)
errorbar(ref_cast.calib_esd_vect_ecotaxa, ecart_type_ab_ref','ro')
set(gca, 'XScale','linear', 'YScale','log')
%semilogy(ref_cast.calib_esd_vect_ecotaxa,'ro');
hold on
%errorbar(adj_cast.calib_esd_vect_ecotaxa, ecart_type_ab_adj','go')
semilogy(adj_cast.calib_esd_vect_ecotaxa,'go');

set(gca, 'XScale','linear', 'YScale','log')

legend(ref_cast.uvp,adj_cast.uvp);
title(['CALIBRATED DATA'],'fontsize',14);
xlabel('ESD CLASS [#]','fontsize',12);
ylabel('ABUNDANCE [#/L]','fontsize',12);
axis([0 15 0.01 50000]);


