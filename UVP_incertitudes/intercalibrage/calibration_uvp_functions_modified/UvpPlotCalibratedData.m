function CalibrationUvpPlotCalibratedData(process_params, ref_cast, adj_cast, datahistref, yresults_adj, ref_esd_calib_log)
%CalibrationUvpPlotCalibratedData plots calibrated data, fit and spectrum
%
%   inputs:
%       process_params : struct of process parameters
%       ref_cast : struct storing computed variables from ref uvp
%       adj_cast : struct storing computed variables from adj uvp
%       datahistref : fited ref abundance
%       yresults_adj : fited adj calibrated abundance
%       ref_esd_calib_log : log de l'esd calibré de ref ou mean ref
%

%% ----------------- used variables  ---------------------------------------


results_dir_ref = ref_cast.results_dir;
uvp_ref = ref_cast.uvp;
ref_esd_calib = ref_cast.esd_calib;
%ref_esd_calib_log = ref_cast.esd_calib_log;
ref_area_mm2_calib = ref_cast.area_mm2_calib;
ref_histo_mm2_vol_mean = ref_cast.histo_mm2_vol_mean;
ref_profilename = ref_cast.profilename;
ref_calib_vect_ecotaxa = ref_cast.calib_esd_vect_ecotaxa;
ref_histo_ab_red_log = ref_cast.histo_ab_red_log;

uvp_adj = adj_cast.uvp;
adj_esd_calib = adj_cast.esd_calib;
adj_esd_calib_log = adj_cast.esd_calib_log;
adj_area_mm2_calib = adj_cast.area_mm2_calib;
adj_histo_mm2_vol_mean = adj_cast.histo_mm2_vol_mean;
adj_calib_vect_ecotaxa = adj_cast.calib_esd_vect_ecotaxa;
adj_histo_ab_red_log = adj_cast.histo_ab_red_log;

depth = process_params.depth;
histopx_ref  = ref_cast.histopx;
pixsize_ref = [1:size(histopx_ref,2)];
histopx_adj = adj_cast.histopx ;
pixsize_adj = [1:size(histopx_adj,2)];

% Aa et expo de référence du calibrage inital 
aa_ref = 0.0036 ;
expo_ref = 1.149 ; 

%Aa et expo ajusté de l'intercalibrage
aa_adj = 0.010262 ;
expo_adj = 1.1785 ;

% incertitude élargie à 95% (écart-type ou covariance multiplié par 1.96) -
% obtenue avec Monte-Carlo
u_Aa_ref = 0.00356;
u_expo_ref = 0.121 ;
delta_Aa_expo_ref = 0.00021 ;
df_dAa_ref = pixsize_ref.^expo_ref;
df_dexpo_ref = aa_ref.*log(pixsize_ref).*(pixsize_ref.^expo_ref);
dfdf_dexpodAa_ref = log(pixsize_ref).*(pixsize_ref.^expo_ref);

u_Aa_adj = 0.0086 ;
u_expo_adj = 0.1705 ;
delta_Aa_expo_adj = 0.00053 ;
df_dAa_adj= pixsize_adj.^expo_adj;
df_dexpo_adj = aa_ref.*log(pixsize_adj).*(pixsize_adj.^expo_adj);
dfdf_dexpodAa_adj = log(pixsize_adj).*(pixsize_adj.^expo_adj);

% incertitude sur area_mm_2_calib_ref
u_area_mm2_calib_ref = (sqrt(((df_dAa_ref.^2).*(u_Aa_ref.^2))+((df_dexpo_ref.^2).*(u_expo_ref.^2))+(2.*(dfdf_dexpodAa_ref).*(delta_Aa_expo_ref))))./2;

% incertitude sur area_mm_2_calib_adj
u_area_mm2_calib_adj = (sqrt(((df_dAa_adj.^2).*(u_Aa_adj.^2))+((df_dexpo_adj.^2).*(u_expo_adj.^2))+(2.*(dfdf_dexpodAa_adj).*(delta_Aa_expo_adj))))./2;

% incertitude sur la taille esd ref
df_dsm_ref = 1./sqrt(pi.*ref_area_mm2_calib);
u_esd_ref = (df_dsm_ref .* u_area_mm2_calib_ref)./2 ;

% incertitude sur la taille esd adj
df_dsm_adj = 1./sqrt(pi.*adj_area_mm2_calib);
u_esd_adj = (df_dsm_adj .* u_area_mm2_calib_adj)./2 ;

fig2 = figure('name','ADJUSTED data','Position',[700 50 1500 600]);
%% ------------------- Abundance VS area ----------------------------------
subplot(1,3,1)
errorbar(ref_area_mm2_calib,ref_histo_mm2_vol_mean,[],[],u_area_mm2_calib_ref,u_area_mm2_calib_ref,'ro')
set(gca, 'XScale','log', 'YScale','log')
hold on
%errorbar(adj_area_mm2_calib, adj_histo_mm2_vol_mean,u_area_mm2_calib_adj,'horizontal','g+')
loglog(adj_area_mm2_calib,adj_histo_mm2_vol_mean,'g+');
hold on
if strcmp(uvp_ref,'uvp5-sn203')
    % -------------- AJout limites sur graphes si ref = sn203 -----------------
%     aa_ref_min = exp(-5.974);
%     expo_ref_min = 1.071;
%     aa_ref_max = exp(-5.3);
%     expo_ref_max = 1.203;
%     ref_esd_calib_minx = log(2*((aa_ref_min*(pixsize_ref.^expo_ref_min)./pi).^0.5));
%     [fitresult] = createFit1_minimisation_uvp(ref_esd_calib_minx,ref_histo_mm2_vol_mean_log,0,Fit_range);
%     [min_calib] = Process_data(ref_esd_calib_minx,fitresult,Fit_range);
%     ref_esd_calib_maxx = log(2*((aa_ref_max*(pixsize_ref.^expo_ref_max)./pi).^0.5));
%     [fitresult] = createFit1_minimisation_uvp(ref_esd_calib_maxx,ref_histo_mm2_vol_mean_log,0,Fit_range);
%     [max_calib] = Process_data(ref_esd_calib_maxx,fitresult,Fit_range);
%     
%     hold on
%     loglog(exp(ref_esd_calib_minx),exp(min_calib),'k--');
%     hold on
%     loglog(exp(ref_esd_calib_maxx),exp(max_calib),'k--');  
%     legend(uvp_ref,uvp_adj,'ref range');
else
    legend(uvp_ref,uvp_adj);
end
axis([0.001 2 0.01 1000000]);
xlabel('AREA [mm²]','fontsize',12);
ylabel('ABUNDANCES [#/mm²/L]','fontsize',12);
title(['CALIBRATED DATA'],'fontsize',14);


%% ------------------- abundance VS esd -----------------------------------
subplot(1,3,2)
loglog(exp(ref_esd_calib_log),exp(datahistref),'r-');
errorbar(exp(ref_esd_calib_log),exp(datahistref),u_esd_ref,'horizontal','r-')
set(gca, 'XScale','log', 'YScale','log')
hold on
%errorbar(exp(adj_esd_calib_log),exp(yresults_adj),u_esd_adj,'horizontal','g--')
loglog(exp(adj_esd_calib_log),exp(yresults_adj),'g--');
if strcmp(uvp_ref,'uvp5-sn203')
%     % -------------- AJout limites sur graphes si ref = sn203 -----------------
%     aa_ref_min = exp(-5.974);
%     expo_ref_min = 1.071;
%     aa_ref_max = exp(-5.3);
%     expo_ref_max = 1.203;
%     ref_esd_calib_minx = log(2*((aa_ref_min*(pixsize_ref.^expo_ref_min)./pi).^0.5));
%     [fitresult] = createFit1_minimisation_uvp(ref_esd_calib_minx,ref_histo_mm2_vol_mean_log,0,Fit_range);
%     [min_calib] = Process_data(ref_esd_calib_minx,fitresult,Fit_range);
%     ref_esd_calib_maxx = log(2*((aa_ref_max*(pixsize_ref.^expo_ref_max)./pi).^0.5));
%     [fitresult] = createFit1_minimisation_uvp(ref_esd_calib_maxx,ref_histo_mm2_vol_mean_log,0,Fit_range);
%     [max_calib] = Process_data(ref_esd_calib_maxx,fitresult,Fit_range);
%     
%     hold on
%     loglog(exp(ref_esd_calib_minx),exp(min_calib),'k--');
%     hold on
%     loglog(exp(ref_esd_calib_maxx),exp(max_calib),'k--');
else
    legend('reference fit','adjusted fit','ref range');
end
legend(uvp_ref,uvp_adj);
axis([0.05 2 0.01 1000000]);
xlabel('ESD [mm]','fontsize',12);
ylabel('ABUNDANCES [#/L]','fontsize',12);
title(['CALIBRATED FIT'],'fontsize',14);


%% ------------------- Abundance VS esd class -----------------------------
% subplot(1,4,3)
% loglog((ref_area_mm2_calib),(Score));
% legend('Score');
% miny = min([(Score) (abs(score_hist-datahistref))]);
% maxy = max([(Score) (abs(score_hist-datahistref))]);
% axis([0.05 2 floor(miny) ceil(maxy)]);
% xlabel('CALIBRATED AREA [mm²]','fontsize',12);
% ylabel('Adjustment difference [relative]','fontsize',12);
% title(['CONTROL'],'fontsize',14);

% ------------- Part c --------------------------------------------------
%% ------!!! NE MARCHE PAS POUR LE MOMENT !!!-------

% histo_ab_mean = nanmean(ref_cast.histo_ab);
% borne_sup_esd_class = sum_ab_classe(exp(ref_esd_calib_log)+u_esd_ref, process_params.esd_vect_ecotaxa, histo_ab_mean(1:numel(exp(ref_esd_calib_log))));
% borne_inf_esd_class = sum_ab_classe(exp(ref_esd_calib_log)-u_esd_ref, process_params.esd_vect_ecotaxa, histo_ab_mean(1:numel(exp(ref_esd_calib_log))));
%%
% particles class plot
subplot(1,3,3)
semilogy(ref_calib_vect_ecotaxa,'ro');
% errorbar(ref_calib_vect_ecotaxa, u_esd_ref, 'horizontal','ro')
% set(gca, 'XScale','linear', 'YScale','log')
% hold on
% semilogy(borne_sup_esd_class,'b-x')
% hold on
% semilogy(borne_inf_esd_class,'b-+')
hold on
semilogy(adj_calib_vect_ecotaxa,'go');
legend(uvp_ref,uvp_adj);
title(['CALIBRATED DATA'],'fontsize',14);
xlabel('ESD CLASS [#]','fontsize',12);
ylabel('ABUNDANCE [#/L]','fontsize',12);
axis([0 15 0.01 50000]);


%% -------------- spectrum slope aong the depth ---------------------------
% subplot(1,4,4)
% semilogx(ref_area_mm2_calib,ratio);
% xlabel('CALIBRATED AREA [mm²]','fontsize',12);
% ylabel('RATIO','fontsize',12);
% axis([0.05 2 0.5 2]);
% set(gca,'xscale','log');
% % set(gca,'yscale','log');
% title(['Ratio of fit / reference (mean = ',num2str(nanmean(ratio)),')']);

% -------------- Part d ----------------------------------
% compute local spectrum slope
%{
affine_fit = fittype({'x'});
ref_local_spectr_slope = zeros(size(ref_histo_ab_red_log,1),1);
for i=1:length(ref_local_spectr_slope)
    % delete -inf values from log
    x = ref_esd_calib';
    y = ref_histo_ab_red_log(i,:)';
    aa = find(y == -Inf);
    x(aa) = [];
    y(aa) = [];
    p = fit(x,y,affine_fit);
    ref_local_spectr_slope(i) = p.a;
end
adj_local_spectr_slope = zeros(size(adj_histo_ab_red_log,1),1);
for i=1:length(adj_local_spectr_slope)
    % delete -inf values from log
    x = adj_esd_calib';
    y = adj_histo_ab_red_log(i,:)';
    aa = find(y == -Inf);
    x(aa) = [];
    y(aa) = [];
    p = fit(x,y,affine_fit);
    adj_local_spectr_slope(i) = p.a;
end
% plot spectrum slop along the depth
subplot(1,4,4)
plot(ref_local_spectr_slope,-depth,'r');
hold on
plot(adj_local_spectr_slope,-depth,'g');
title('SPECTRUM SLOPE','fontsize',14);
xlabel('SLOPE [#/L/mm]','fontsize',12);
ylabel('DEPTH [db]','fontsize',12);
legend(uvp_ref,uvp_adj);
%}


%% ---------------------- Save figure --------------------------------------
% orient tall
% titre = ['CALIBRATED_data_' char(ref_profilename)];
% set(gcf,'PaperPositionMode','auto')
% print(gcf,'-dpng',[results_dir_ref,'\',datestr(now,30),'_',char(titre)]);



