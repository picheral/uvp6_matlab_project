%% UVP5 calibration settings & analyses
% Picheral Lombard 2017/11


function [process_params, ref_cast, adj_cast, yresults_adj] = calibration_uvp_settings_b(process_params, ref_cast, adj_cast, datahistref, aa_adj, expo_adj)


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
depth = process_params.depth;

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


%% FUNCTION RETURNS
% ----------- return computed variables  ----------------------------------
ref_cast.esd_calib_log = ref_esd_calib_log;
adj_cast.histo_mm2_vol_mean = adj_histo_mm2_vol_mean;
adj_cast.esd_calib = adj_esd_calib;
adj_cast.esd_calib_log = adj_esd_calib_log;
adj_cast.area_mm2_calib = adj_area_mm2_calib;
adj_cast.histo_mm2_vol_mean = adj_histo_mm2_vol_mean;
adj_cast.histo_ab = adj_histo_ab;
process_params.Score = Score;
process_params.ratio_mean = ratio_mean;
end



