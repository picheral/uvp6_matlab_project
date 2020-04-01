%% UVP5 calibration settings & analyses
% from Picheral Lombard 2017/11


function [process_params, adj_cast, yresults_adj] = CalibrationUvpProcessCalibratedData(process_params, ref_cast, adj_cast, datahistref, aa_adj, expo_adj)


% ----------------- used variables  ---------------------------------------
pix_ref = ref_cast.pix;
ref_esd_calib_log = ref_cast.esd_calib_log;

pix_adj = adj_cast.pix;
pixsize_adj = adj_cast.pixsize;
adj_vol_ech = adj_cast.vol_ech;
adj_histo_mm2 = adj_cast.histo_mm2;

fit_type = process_params.fit_type;


%% CALIBRATED DATA
% ----------- calibrated vectors for adj ----------------------------------
adj_esd_calib = 2*((aa_adj*(pixsize_adj.^expo_adj)./pi).^0.5);
adj_area_mm2_calib = aa_adj*(pixsize_adj.^expo_adj);
adj_esd_calib_log = log(adj_esd_calib);

adj_histo_mm2_vol_mean = nanmean(adj_histo_mm2./adj_vol_ech);
adj_histo_mm2_vol_mean = adj_histo_mm2_vol_mean(1:numel(adj_esd_calib));
adj_histo_mm2_vol_mean_log = log(adj_histo_mm2_vol_mean);

% ---------- fit on calibrated data ---------------------------------------
[fitresult] = create_two_fits(adj_esd_calib_log,adj_histo_mm2_vol_mean_log,fit_type,0,adj_esd_calib_log,adj_histo_mm2_vol_mean_log,fit_type);
[yresults_adj] = poly_from_fit(adj_esd_calib_log,fitresult,fit_type);

%% RATIO
% -------------- Ratio ne fonctionne ici QUE si mêmes tailles pixels ------
if pix_ref == pix_adj
    ratio = yresults_adj./datahistref;
    ratio_mean = nanmean(ratio);
else
    ratio_mean = 1;
    ratio = 1;
end


%% SCORE
% -------------- Pour calcul Score final -----------------------------
[score_hist] = poly_from_fit(ref_esd_calib_log,fitresult,fit_type);
Score = data_similarity_score(exp(score_hist), exp(datahistref));


%% FUNCTION RETURNS
% ----------- return computed variables  ----------------------------------
adj_cast.histo_mm2_vol_mean = adj_histo_mm2_vol_mean;
adj_cast.esd_calib = adj_esd_calib;
adj_cast.esd_calib_log = adj_esd_calib_log;
adj_cast.area_mm2_calib = adj_area_mm2_calib;
adj_cast.histo_mm2_vol_mean = adj_histo_mm2_vol_mean;
process_params.Score = Score;
process_params.ratio_mean = ratio_mean;
end



