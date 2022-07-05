function [ref_cast, adj_cast] = uvp_cast_apres_intercalibrage(aa_ref,expo_ref,aa_adj,expo_adj)

%% Script Matlab : uvp_cast_apres_intercalibrage
%
%
% But : afficher les plot des données calibrés avec les incertitudes de
% l'uvp-étalon
%
% Blandine JACOB - 29 juin 2022

%%

addpath('C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\UVP_incertitudes\intercalibrage');
addpath('C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\UVP_incertitudes\intercalibrage\calibration_uvp_functions_to_modif');
addpath('C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\UVP_incertitudes\intercalibrage\fit');
%% Selection of reference instrument and data

path_ref = 'Y:\_UVP5_projets_intercalibrage\uvp5_archives_calibrages_utiles\sn203\2017\uvp5_sn203_intercalibrage_20171201';
[ref_base, ref_cast] = UvpOpenBase('Reference', path_ref);
[ref_base, ref_cast] = UvpGetConfig(ref_base, ref_cast, 'Reference');

%% Selection of instrument data to adjust

path_adj = 'Y:\_UVP5_projets_intercalibrage\uvp5_archives_calibrages_utiles\sn002\2017\uvp5_sn002_intercalibrage_20171201';
[adj_base, adj_cast] = UvpOpenBase('Adjusted',path_adj);
[adj_base, adj_cast] = UvpGetConfig(adj_base, adj_cast, 'Adjusted');

%% Calibration parameters

process_params = UvpGetUserProcessParams([ref_cast.uvp], adj_cast.uvp, adj_cast.pix);

%% Raw data 

% check and select the same depth range
[ref_cast.histopx, adj_cast.histopx, process_params.depth] = CalibrationUvpComputeDepthRange(ref_base.histopx,adj_base.histopx);

% process raw data variale for plot and fit
[ref_cast] = CalibrationUvpProcessRawData(process_params.esd_vect_ecotaxa, ref_cast);
[adj_cast] = CalibrationUvpProcessRawData(process_params.esd_vect_ecotaxa, adj_cast);

% cut variables from size range
ref_cast = CalibrationUvpAdaptToSizeRange(ref_cast, process_params.esd_min, process_params.esd_max);
adj_cast_uncut = adj_cast;
adj_cast = CalibrationUvpAdaptToSizeRange(adj_cast, process_params.esd_min, process_params.esd_max); 

[ref_cast] = CalibrationUvpProcessCalibratedData(process_params.esd_vect_ecotaxa, ref_cast, aa_ref, expo_ref);
ref_esd_calib_log = ref_cast.esd_calib_log;
ref_histo_mm2_vol_mean = ref_cast.histo_mm2_vol_mean;

[fitresult] = two_fits(ref_esd_calib_log,log(ref_histo_mm2_vol_mean),process_params.fit_type,1,log([1:numel(adj_cast.histo_mm2_vol_mean)].*(adj_cast.pix^2)),log(adj_cast.histo_mm2_vol_mean),process_params.Fit_range);  
[datahistref] = poly_from_fit(ref_esd_calib_log,fitresult,process_params.fit_type);

% process adj calibrated data
[adj_cast] = CalibrationUvpProcessCalibratedData(process_params.esd_vect_ecotaxa, adj_cast, aa_adj, expo_adj);
[fitresult] = two_fits(adj_cast.esd_calib_log,adj_cast.histo_mm2_vol_mean_log,process_params.fit_type,0,adj_cast.esd_calib_log,adj_cast.histo_mm2_vol_mean_log,process_params.fit_type);
[yresults_adj] = poly_from_fit(adj_cast.esd_calib_log,fitresult,process_params.fit_type);

[score_hist] = poly_from_fit(ref_esd_calib_log,fitresult,process_params.fit_type);
score = data_similarity_score(exp(score_hist), exp(datahistref));
