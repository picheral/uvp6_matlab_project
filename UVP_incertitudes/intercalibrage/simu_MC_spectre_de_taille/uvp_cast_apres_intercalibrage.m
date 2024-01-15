function [ref_cast, adj_cast] = uvp_cast_apres_intercalibrage(aa_ref,expo_ref,aa_adj,expo_adj,path_ref,path_adj,esd_min,esd_max,Fit_data)

%% fonction Matlab : uvp_cast_apres_intercalibrage
%
%
% But : mettre à jour les cast après intercalibrage. Fonction appelée par
% UvpCalibratedDataAndUncertainties
%
% Input:
%       o	aa_ref : valeur de Aa de l’uvp étalon
%       o	expo_ref : valeur de exp de lµuvp étalon
%       o	aa_adj : valeur de Aa de l'uvp à ajuster
%       o	expo_adj : valeur de exp de l'uvp à ajuster
%       o	path_ref : chemin en dur vers le dossier de l'intercalibrage étudié correspondant à l'uvp étalon 
%       o	path_adj : chemin en dur vers le dossier de l'intercalibrage étudié correspondant à l'uvp à ajuster 
%       o	esd_min : borne inférieure esd (en mm) sur lequel le fit est réalisé entre deux spectres
%       o	esd_max : borne supérieure esd (en mm) sur lequel le fit est réalisé entre deux spectres
%       o	Fit_data : degré du polynôme utilisé pour le fit entre les spectres
%
%
% Output:
%       •	ref_cast : structure de l uvp étalon updaté
%       •	adj_cast : structure de l'uvp à ajuster updaté
%
% Blandine JACOB - 29 juin 2022


%% Selection of reference instrument and data

[ref_base, ref_cast] = UvpOpenBase('Reference', path_ref);
[ref_base, ref_cast] = CalibrationUvpGetConfig(ref_base, ref_cast, 'Reference',0);

%% Selection of instrument data to adjust

[adj_base, adj_cast] = UvpOpenBase('Adjusted',path_adj);
[adj_base, adj_cast] = CalibrationUvpGetConfig(adj_base, adj_cast, 'Adjusted',0);

%% Calibration parameters

process_params = UvpGetUserProcessParams(adj_cast.pix,esd_min,esd_max,Fit_data);

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


