%% UVP5 calibration settings & analyses
% Picheral Lombard 2017/11


function [process_params, ref_cast, adj_cast] = calibration_uvp_settings_b(process_params, ref_cast, adj_cast, datahistref, aa_adj, expo_adj)


% ----------------- used variables  ---------------------------------------
results_dir_ref = ref_cast.results_dir;
uvp_ref = ref_cast.uvp;
pix_ref = ref_cast.pix;
ref_esd_calib = ref_cast.esd_calib;
ref_esd_calib_log = ref_cast.esd_calib_log;
ref_area_mm2_calib = ref_cast.area_mm2_calib;
ref_histo_mm2_vol_mean = ref_cast.histo_mm2_vol_mean;
ref_histo_ab = ref_cast.histo_ab;
ref_profilename = ref_cast.profilename;
depth = ref_cast.depth;

project_folder_adj = adj_cast.project_folder;
uvp_adj = adj_cast.uvp;
pix_adj = adj_cast.pix;
pixsize_adj = adj_cast.pixsize;
adj_vol_ech = adj_cast.vol_ech;
adj_histo_mm2 = adj_cast.histo_mm2;
adj_histo_mm2_vol_mean = adj_cast.histo_mm2_vol_mean;
adj_histo_ab = adj_cast.histo_ab;

fit_type = process_params.fit_type;
esd_vect_ecotaxa = process_params.esd_vect_ecotaxa;

%% FIT
ref_histo_mm2_vol_mean_log = log(ref_histo_mm2_vol_mean);
% ----------- FIT on ADJUSTED ---------------------------------------------
adj_esd_calib = 2*((aa_adj*(pixsize_adj.^expo_adj)./pi).^0.5);
adj_area_mm2_calib = aa_adj*(pixsize_adj.^expo_adj);
adj_esd_calib_log = log(adj_esd_calib);

% adj_vol_ech = img_vol_data_adj;

adj_histo_mm2_vol_mean = nanmean(adj_histo_mm2./adj_vol_ech);
adj_histo_mm2_vol_mean = adj_histo_mm2_vol_mean(1:numel(adj_esd_calib));
adj_histo_mm2_vol_mean_log = log(adj_histo_mm2_vol_mean);
ref_esd_calib_log = log(ref_esd_calib);

[fitresult] = create_two_fits(adj_esd_calib_log,adj_histo_mm2_vol_mean_log,fit_type,0,adj_esd_calib_log,adj_histo_mm2_vol_mean_log,fit_type);
[yresults_adj] = poly_from_fit(adj_esd_calib_log,fitresult,fit_type);

%% SCORE
% -------------- Pour calcul Score final -----------------------------
[score_hist] = poly_from_fit(ref_esd_calib_log,fitresult,fit_type);
% data_score_old=((abs(score_hist-datahistref)./(datahistref + 4).^EC_factor).^2);
%data_score = (abs(exp(score_hist)-exp(datahistref))./(exp(datahistref))).^2;
%Score=nansum(data_score);
Score = data_similarity_score(exp(score_hist), exp(datahistref));

% -------------- Ratio ne fonctionne ici QUE si mêmes tailles pixels ----
if pix_ref == pix_adj
    ratio = yresults_adj./datahistref;
    ratio_mean = nanmean(ratio);
else
    ratio_mean = 1;
    ratio = 1;
end


%% FIGURES
fig2 = figure('name','ADJUSTED data','Position',[700 50 1500 600]);
% ------------------- part a ----------------------------------------------
subplot(1,4,1)
loglog((ref_area_mm2_calib),ref_histo_mm2_vol_mean,'ro');
hold on
loglog(adj_area_mm2_calib,(adj_histo_mm2_vol_mean),'go');
hold on
% loglog(exp(x_new_log),exp(datahistref),'b-');
% hold on
% loglog(exp(camsm_adj_log),exp(yresults_adj),'c--');
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
% axis([0.05 2 0.01 10000000]);
axis([0.001 2 0.01 1000000]);
xlabel('CALIBRATED AREA [mm²]','fontsize',12);
ylabel('ABUNDANCES [#/mm²/L]','fontsize',12);
title(['CALIBRATED DATA'],'fontsize',14);

% ------------------- part b ----------------------------------------------
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

% ------------- Part c --------------------------------------------------
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
% Vecteurs finaux par classe
ref_histo_ab_mean = nanmean(ref_histo_ab);
adj_histo_ab_mean = nanmean(adj_histo_ab);
[ref_calib_vect_ecotaxa]= sum_ab_classe(ref_esd_calib,esd_vect_ecotaxa,ref_histo_ab_mean(1:numel(ref_esd_calib)));
[adj_calib_vect_ecotaxa]= sum_ab_classe(adj_esd_calib,esd_vect_ecotaxa,adj_histo_ab_mean(1:numel(adj_esd_calib)));
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

% -------------- Part d ----------------------------------
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
ref_histo_ab_red_log = log(ref_histo_ab(:,1:numel(ref_esd_calib)));
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
adj_histo_ab_red_log = log(adj_histo_ab(:,1:numel(adj_esd_calib)));
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

% ---------------------- Save figure --------------------------------------
orient tall
titre = ['CALIBRATED_data_' char(ref_profilename)];
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[results_dir_ref,'\',datestr(now,30),'_',char(titre)]);


%% MINIMISATION space
results=[];
AAs=[];
expss=[];
if (strcmp(project_folder_adj(4:7),'uvp5'))
    mini_min = 0.0005;
    mini_max = 0.010;
    maxe = 1.5;
else  
    mini_min = 0.0002;
    mini_max = 0.010;   
    maxe = 1.7;
end

for i=mini_min:0.0005:mini_max
    result=[];
    aas=[];
    exps=[];
    for j=1:0.025:maxe
        X2=[i j];
        res=histofunction7_new(X2,datahistref, pixsize_adj, adj_histo_mm2_vol_mean, ref_esd_calib_log, fit_type);
        if (isinf(res)|| res < 0); res = NaN; end
        result=[result res];
        aas=[aas i];
        exps=[exps j];
    end
    results=[results;result];
    AAs=[AAs;aas];
    expss=[expss;exps];
end
%% Figure minimisation
fig3 = figure('name','Minimisation','Position',[250 50 400 400]);
figure(fig3);
pcolor(AAs,expss,log(results))
shading flat
xlabel('Aa','fontsize',16);
ylabel('exp','fontsize',16);
colormap(jet(256))
h=colorbar;
h.Label.String = 'Log (Sum of least square)';
figure(fig3);
hold on
plot(aa_adj,expo_adj,'mo');
hold on
plot(aa_adj,expo_adj,'m+');
title(['Minimisation landscape'],'fontsize',14);
orient tall
% ---------------------- Save figure --------------------------------------
titre = ['Minimisation_landscape_' char(ref_profilename)];
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[results_dir_ref,'\',datestr(now,30),'_',char(titre)]);


%% FUNCTION RETURNS
% ----------- return computed variables  ----------------------------------
ref_cast.esd_calib_log = ref_esd_calib_log;
adj_cast.histo_mm2_vol_mean = adj_histo_mm2_vol_mean;
process_params.Score = Score;
process_params.ratio_mean = ratio_mean;
end



