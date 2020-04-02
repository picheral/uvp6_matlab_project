function CalibrationUvpPlotCalibratedData(process_params, ref_cast, adj_cast, datahistref, yresults_adj)
%CalibrationUvpPlotCalibratedData plots calibrated data, fit and spectrum
%

% ----------------- used variables  ---------------------------------------
results_dir_ref = ref_cast.results_dir;
uvp_ref = ref_cast.uvp;
ref_esd_calib = ref_cast.esd_calib;
ref_esd_calib_log = ref_cast.esd_calib_log;
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


fig2 = figure('name','ADJUSTED data','Position',[700 50 1500 600]);
%% ------------------- part a ----------------------------------------------
subplot(1,4,1)
loglog((ref_area_mm2_calib),ref_histo_mm2_vol_mean,'ro');
hold on
loglog(adj_area_mm2_calib,(adj_histo_mm2_vol_mean),'go');
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
xlabel('CALIBRATED AREA [mm²]','fontsize',12);
ylabel('ABUNDANCES [#/mm²/L]','fontsize',12);
title(['CALIBRATED DATA'],'fontsize',14);

%% ------------------- part b ----------------------------------------------
subplot(1,4,2)
loglog(exp(ref_esd_calib_log),exp(datahistref),'r-');
hold on
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
xlabel('CALIBRATED ESD [mm]','fontsize',12);
ylabel('ABUNDANCES [#/L]','fontsize',12);
title(['FINAL ADJUSTMENTS'],'fontsize',14);

%% ------------- Part c --------------------------------------------------
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
% particles class plot
subplot(1,4,3)
semilogy(ref_calib_vect_ecotaxa,'ro');
hold on
semilogy(adj_calib_vect_ecotaxa,'go');
legend(uvp_ref,uvp_adj);
title(['CALIBRATED DATA'],'fontsize',14);
xlabel('CALIBRATED ESD CLASS [#]','fontsize',12);
ylabel('ABUNDANCE [#/L]','fontsize',12);
axis([0 15 0.01 50000]);

%% -------------- Part d ----------------------------------
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
title('local calibrated spectrum slope');
xlabel('spectrum slope [#/L/mm]','fontsize',12);
ylabel('depth [m]','fontsize',12);
legend(uvp_ref,uvp_adj);

%% ---------------------- Save figure --------------------------------------
orient tall
titre = ['CALIBRATED_data_' char(ref_profilename)];
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[results_dir_ref,'\',datestr(now,30),'_',char(titre)]);

end

