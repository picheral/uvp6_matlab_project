function [ref_cast, adj_cast] = uvp_cast_apres_intercalibrage(aa_ref,expo_ref,aa_adj,expo_adj,path_ref,path_adj)

%% fonction Matlab : uvp_cast_apres_intercalibrage
%
%
% But : créer les cast après intercalibrage
%
% Blandine JACOB - 29 juin 2022


%% Selection of reference instrument and data

[ref_base, ref_cast] = UvpOpenBase('Reference', path_ref);
[ref_base, ref_cast] = UvpGetConfig(ref_base, ref_cast, 'Reference');

%% Selection of instrument data to adjust

[adj_base, adj_cast] = UvpOpenBase('Adjusted',path_adj);
[adj_base, adj_cast] = UvpGetConfig(adj_base, adj_cast, 'Adjusted');

%% Calibration parameters

process_params = UvpGetUserProcessParams([ref_cast.uvp], adj_cast.uvp, adj_cast.pix,intercalibrage);

%% Raw data 

% check and select the same depth range
[ref_cast.histopx, adj_cast.histopx, process_params.depth] = CalibrationUvpComputeDepthRange(ref_base.histopx,adj_base.histopx);

% process raw data variale for plot and fit
[ref_cast] = CalibrationUvpProcessRawData(process_params.esd_vect_ecotaxa, ref_cast);
[adj_cast] = CalibrationUvpProcessRawData(process_params.esd_vect_ecotaxa, adj_cast);

% cut variables from size range
ref_cast = CalibrationUvpAdaptToSizeRange(ref_cast, process_params.esd_min, process_params.esd_max);
adj_cast = CalibrationUvpAdaptToSizeRange(adj_cast, process_params.esd_min, process_params.esd_max); 

% process ref calibrated data
[ref_cast] = CalibrationUvpProcessCalibratedData(process_params.esd_vect_ecotaxa, ref_cast, aa_ref, expo_ref);

% process adj calibrated data
[adj_cast] = CalibrationUvpProcessCalibratedData(process_params.esd_vect_ecotaxa, adj_cast, aa_adj, expo_adj);


