%% Script Matlab : propag_intercalibrage_monte_carlo
%
%
% But : propager les incertitudes à travers un intercalibrage (le sn203
% vers le sn002)
% Fichier inspiré/modifié à partir du Live script
% 'uvp_calibration_report_of_XXXXXXXX_from_XXXXXXXX_YYYYMMDD.mlx'
% 
% Blandine JACOB - 24 juin 2022
%%
tic
addpath('C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\UVP_incertitudes\intercalibrage');
addpath('C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\UVP_incertitudes\intercalibrage\calibration_uvp_functions_to_modif');
addpath('C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\UVP_incertitudes\intercalibrage\fit');
%% Selection of reference instrument and data

path_ref = 'Y:\_UVP5_projets_intercalibrage\uvp5_archives_calibrages_utiles\uvp5_sn203_intercalibrage_20171201';
[ref_base, ref_cast] = UvpOpenBase('Reference', path_ref);
[ref_base, ref_cast] = UvpGetConfig(ref_base, ref_cast, 'Reference');

%% Selection of instrument data to adjust

path_adj = 'Y:\_UVP5_projets_intercalibrage\uvp5_archives_calibrages_utiles\uvp5_sn002_intercalibrage_20171201';
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

load('couple_Aa_exp.mat');
aa_adj = zeros(length(couple_Aa_exp),1);
expo_adj = zeros(length(couple_Aa_exp),1);
score = zeros(length(couple_Aa_exp),1);

for i=1:length(couple_Aa_exp)

    aa_ref = couple_Aa_exp(1,i) ;
    expo_ref = couple_Aa_exp(2,i);

    % Compute reference calib data
    [ref_cast] = CalibrationUvpProcessCalibratedData(process_params.esd_vect_ecotaxa, ref_cast, aa_ref, expo_ref);
    ref_esd_calib_log = ref_cast.esd_calib_log;
    ref_histo_mm2_vol_mean = ref_cast.histo_mm2_vol_mean;
        
    %% Fit graphs
    % Fit of each abundance spectra.
    % 
    % The fits are used for the adjustement through the optimization of the calibration 
    % parameters.
    
    [fitresult] = two_fits(ref_esd_calib_log,log(ref_histo_mm2_vol_mean),process_params.fit_type,1,log([1:numel(adj_cast.histo_mm2_vol_mean)].*(adj_cast.pix^2)),log(adj_cast.histo_mm2_vol_mean),process_params.Fit_range);  
    [datahistref] = poly_from_fit(ref_esd_calib_log,fitresult,process_params.fit_type);
    
    % optimisation of aa and exp for adj
    objective_function = @(x)histofunction7_new(x,datahistref, adj_cast.pixsize, adj_cast.histo_mm2_vol_mean, ref_esd_calib_log, process_params.fit_type);
    [X,feval]=fminsearch(objective_function,process_params.X0);
    aa_adj(i) = X(1);
    expo_adj(i) = X(2);
    
    % process adj calibrated data
    [adj_cast] = CalibrationUvpProcessCalibratedData(process_params.esd_vect_ecotaxa, adj_cast, aa_adj(i), expo_adj(i));
    [fitresult] = two_fits(adj_cast.esd_calib_log,adj_cast.histo_mm2_vol_mean_log,process_params.fit_type,0,adj_cast.esd_calib_log,adj_cast.histo_mm2_vol_mean_log,process_params.fit_type);
    [yresults_adj] = poly_from_fit(adj_cast.esd_calib_log,fitresult,process_params.fit_type);

    [score_hist] = poly_from_fit(ref_esd_calib_log,fitresult,process_params.fit_type);
    score(i) = data_similarity_score(exp(score_hist), exp(datahistref));
    
end

toc