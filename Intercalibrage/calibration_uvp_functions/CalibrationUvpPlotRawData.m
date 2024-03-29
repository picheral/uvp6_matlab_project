%% UVP5 calibration settings & analyses
% from Picheral Lombard 2017/11 / 2019/06/11
% Updated 2020/03/31

function CalibrationUvpPlotRawData(process_params, ref_cast, adj_cast,close_fig)
% CalibrationUvpPlotRawData different plots to compare calibrated ref data
% and raw data to adjust
%
%   inputs:
%       process_params : struct of process parameters
%       ref_cast : struct storing computed variables from ref uvp
%       adj_cast : struct storing computed variables from adj uvp
%


%% ----------------- used variables  ---------------------------------------
results_dir_ref = ref_cast.results_dir;
uvp_ref = ref_cast.uvp;
pix_ref = ref_cast.pix;
ref_esd_x = ref_cast.esd_x;
ref_histo_mm2_vol_mean = ref_cast.histo_mm2_vol_mean;
ref_histo_ab_mean_red_norm = ref_cast.histo_ab_mean_red_norm;
ref_ab_vect_ecotaxa = ref_cast.ab_vect_ecotaxa;
histopx_ref = ref_cast.histopx;
volumeimage_ref = ref_cast.img_vol_data;

uvp_adj = adj_cast.uvp;
pix_adj = adj_cast.pix;
adj_esd_x = adj_cast.esd_x;
adj_histo_mm2_vol_mean = adj_cast.histo_mm2_vol_mean;
adj_histo_ab_mean_red_norm = adj_cast.histo_ab_mean_red_norm;
adj_ab_vect_ecotaxa = adj_cast.ab_vect_ecotaxa;
histopx_adj = adj_cast.histopx;
volumeimage_adj = adj_cast.img_vol_data;

esd_min = process_params.esd_min;
esd_max = process_params.esd_max;
esd_vect_ecotaxa = process_params.esd_vect_ecotaxa;

    

%% PLOTS
fig1 = figure('name','RAW data','Position',[50 50 1500 600]);


%% ------------------- Abundance VS area ----------------------------------
subplot(1,4,1)
loglog([1:numel(ref_histo_mm2_vol_mean)].*(pix_ref^2),ref_histo_mm2_vol_mean,'ro')
hold on
loglog([1:numel(adj_histo_mm2_vol_mean)].*(pix_adj^2),adj_histo_mm2_vol_mean,'g+');
hold on
xline(pi*(esd_min/2)^2, '--b');
xline(pi*(esd_max/2)^2, '--b');
legend(uvp_ref,uvp_adj);
title(['RAW DATA (normalized/pxarea)'],'fontsize',14);
xlabel('AREA [mm�]','fontsize',12);
ylabel('ABUNDANCE [#/mm�/L]','fontsize',12);
axis([0.005 2 0.01 1000000]);
set(gca,'xscale','log');
set(gca,'yscale','log');


%% ------------------- abundance VS esd -----------------------------------
subplot(1,4,2)
loglog(ref_esd_x,ref_histo_ab_mean_red_norm,'ro');
hold on
loglog(adj_esd_x,adj_histo_ab_mean_red_norm,'g+');
hold on
xline(esd_min, '--b');
xline(esd_max, '--b');
legend(uvp_ref,uvp_adj);
title(['RAW DATA (normalized/esd)'],'fontsize',14);
xlabel('ESD [mm]','fontsize',12);
ylabel('NORMALIZED ABUNDANCE [rel]','fontsize',12);
axis([0.05 2 0.01 1000000]);
set(gca,'xscale','log');
set(gca,'yscale','log');


%% ------------------- Abundance VS esd class -----------------------------
subplot(1,4,3)
semilogy(ref_ab_vect_ecotaxa,'ro');
hold on
semilogy(adj_ab_vect_ecotaxa,'g+');
hold on
% find first and last class in the esd range
class_max = 1;
class_min = 1;
for i=1:length(esd_vect_ecotaxa)
    if esd_max >= esd_vect_ecotaxa(i)
        class_max = i;
    end
    if esd_min >= esd_vect_ecotaxa(i)
        class_min = i;
    end
end
xline(class_min, '--b');
xline(class_max, '--b');
legend(uvp_ref,uvp_adj);
title(['RAW DATA [per class]'],'fontsize',14);
xlabel('ESD CLASS [#]','fontsize',12);
ylabel('ABUNDANCE [#/L]','fontsize',12);
axis([0 15 0.01 50000]);
set(gca,'yscale','log');


%% ------------------- depth part count profiles ---------------------------
% Profiles matching check
subplot(1,4,4)
semilogx((histopx_ref(:,6)+histopx_ref(:,7))./histopx_ref(:,4)/volumeimage_ref, -histopx_ref(:,1), 'r');
hold on
semilogx((histopx_adj(:,6)+histopx_adj(:,7))./histopx_adj(:,4)/volumeimage_adj, -histopx_adj(:,1), 'g');
legend(uvp_ref,uvp_adj);
title(['COUNTS'],'fontsize',14);
xlabel('COUNTS [sum of 2 & 3 px]','fontsize',12);
ylabel('DEPTH [db]','fontsize',12);


%% ---------------------- Save figure -------------------------------------
orient tall
titre = ['RAW_data_' char(ref_cast.profilename)];
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[results_dir_ref,'\',datestr(now,30),'_',char(titre)]);
if close_fig == 1
    close(fig1);
end


end

