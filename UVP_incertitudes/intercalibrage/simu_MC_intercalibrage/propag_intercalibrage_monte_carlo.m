%% Script Matlab : propag_intercalibrage_monte_carlo
%
%
% But : propager les incertitudes à travers un intercalibrage 
%
% Fichier inspiré/modifié à partir du Live script
% 'uvp_calibration_report_of_XXXXXXXX_from_XXXXXXXX_YYYYMMDD.mlx'
% 
% Blandine JACOB - 24 juin 2022

%% ajouter les path des dossiers contenant les fonctions utiles

tic

% Ce code tournant sur Marie, ce script et les fonctions qu'il utilise ont
% été copiés sur le serveur. Les fonctions et fit utile au script sont
% accessibles grâce au addpath
%
% addpath('calibration_uvp_functions_to_modif');
% addpath('fit');

%% sélection de l'intercalibrage à étudier
% en cas d'un nouvel intercalibrage étudié, ajouter des options à switch, et modifier la boucle while

generation = input('Génération UVP à ajuster?  5/6: '); 

while  (strcmp(generation,'5') || strcmp(generation,'6')) == 0
     generation = input('Mauvaise réponse: ne pas oublier de mettre  deux apostrophes autour du numéro. Génération UVP à ajuster? 5/6: ');
end

if strcmp(generation,'5')
     intercalibrage = input('quel UVP est étudié? sn002/sn201: ');
    
    while  (strcmp(intercalibrage,'sn002') || strcmp(intercalibrage,'sn201')) == 0
         intercalibrage = input('Mauvaise réponse: quel UVP est étudié? sn002/sn201: ');
    end
end
%% Selection of reference instrument and data

switch generation
    case '6'
        path_ref = fullfile('/','remote','complex','piqv','plankton_ro','uvp_reglages','_UVP5_projets_intercalibrage','uvp5_archives_calibrages_utiles','sn002','2020','uvp5_sn002_intercalibrage_20200128');
    case'5'
        switch intercalibrage
            case 'sn002'
                path_ref = fullfile('/','remote','complex','piqv','plankton_ro','uvp_reglages','_UVP5_projets_intercalibrage','uvp5_archives_calibrages_utiles','sn203','2017','uvp5_sn203_intercalibrage_20171201');
            case 'sn201'
                path_ref = fullfile('/','remote','complex','piqv','plankton_ro','uvp_reglages','_UVP5_projets_intercalibrage','uvp5_archives_calibrages_utiles','sn203','2016','uvp5_sn203_intercalibrage_20160404');
        end 
end  
[ref_base, ref_cast] = UvpOpenBase('Reference', path_ref);
[ref_base, ref_cast] = UvpGetConfig(ref_base, ref_cast, 'Reference');

%% Selection of instrument data to adjust
switch generation
    case '6'
        path_adj = fullfile('/','remote','complex','piqv','plankton_ro','uvp_reglages','_UVP6_projets_intercalibrage','Etalons','000008LP','2020','uvp6_sn000008lp_20200130_20200221_intercalibrage');
    case '5'
        switch intercalibrage
            case 'sn002'
                path_adj = fullfile('/','remote','complex','piqv','plankton_ro','uvp_reglages','_UVP5_projets_intercalibrage','uvp5_archives_calibrages_utiles','sn002','2017','uvp5_sn002_intercalibrage_20171201');
            case 'sn201'
                path_adj = fullfile('/','remote','complex','piqv','plankton_ro','uvp_reglages','_UVP5_projets_intercalibrage','uvp5_archives_calibrages_utiles','sn201','2016','uvp5_sn201_intercalibrage_20160404');
        end 
end
[adj_base, adj_cast] = UvpOpenBase('Adjusted',path_adj);
[adj_base, adj_cast] = UvpGetConfig(adj_base, adj_cast, 'Adjusted');

%% Calibration parameters

switch generation
    case '5'
        % min of size range        
        esd_min = 0.1 ;
        % max of size range
        esd_max = 1.5 ;
        % degree of the polynome to fit
        Fit_data=6 ;
    case '6'
        Fit_data=3;
        esd_min=0.4;
        esd_max=1.1;
end
process_params = UvpGetUserProcessParams(adj_cast.pix, esd_min, esd_max, Fit_data);

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

% ------ Téléchargement des couples(Aa,exp) de l'étalon ------- %

switch ref_cast.uvp
    case 'uvp5-sn203'
       couples_etalons =load(fullfile('/','remote','complex','piqv','plankton_ro','uvp_dvlpt','UVP_incertitudes','2_etude_intercalibrages','methode_monte_carlo','codes','couples_params_etalons','couple_Aa_exp_sn203'));
    case 'uvp5-sn002'
       couples_etalons = load(fullfile('/','remote','complex','piqv','plankton_ro','uvp_dvlpt','UVP_incertitudes','2_etude_intercalibrages','methode_monte_carlo','codes','couples_params_etalons','couple_Aa_exp_sn002'));
end

couple_Aa_exp_ref = couples_etalons.couple_Aa_exp;
aa_adj = zeros(length(couple_Aa_exp_ref),1);
expo_adj = zeros(length(couple_Aa_exp_ref),1);
score = zeros(length(couple_Aa_exp_ref),1);

for i=1:length(couple_Aa_exp_ref)

    aa_ref = couple_Aa_exp_ref(1,i) ;
    expo_ref = couple_Aa_exp_ref(2,i);

    % Compute reference calib data
    [ref_cast] = CalibrationUvpProcessCalibratedData(process_params.esd_vect_ecotaxa, ref_cast, aa_ref, expo_ref);
    ref_esd_calib_log = ref_cast.esd_calib_log;
    ref_histo_mm2_vol_mean = ref_cast.histo_mm2_vol_mean;
        
    %% Fit graphs
    % Fit of each abundance spectra.
    % 
    % The fits are used for the adjustement through the optimization of the calibration 
    % parameters.
    
    [fitresult] = create_two_fits(ref_esd_calib_log,log(ref_histo_mm2_vol_mean),process_params.fit_type,1,log([1:numel(adj_cast.histo_mm2_vol_mean)].*(adj_cast.pix^2)),log(adj_cast.histo_mm2_vol_mean),process_params.Fit_range);  
    [datahistref] = poly_from_fit(ref_esd_calib_log,fitresult,process_params.fit_type);
    
    % optimisation of aa and exp for adj
    objective_function = @(x)histofunction7_new(x,datahistref, adj_cast.pixsize, adj_cast.histo_mm2_vol_mean, ref_esd_calib_log, process_params.fit_type);
    [X,feval]=fminsearch(objective_function,process_params.X0);
    aa_adj(i) = X(1);
    expo_adj(i) = X(2);
    
    % process adj calibrated data
    [adj_cast] = CalibrationUvpProcessCalibratedData(process_params.esd_vect_ecotaxa, adj_cast, aa_adj(i), expo_adj(i));
    [fitresult] = create_two_fits(adj_cast.esd_calib_log,adj_cast.histo_mm2_vol_mean_log,process_params.fit_type,0,adj_cast.esd_calib_log,adj_cast.histo_mm2_vol_mean_log,process_params.fit_type);
    [yresults_adj] = poly_from_fit(adj_cast.esd_calib_log,fitresult,process_params.fit_type);

    [score_hist] = poly_from_fit(ref_esd_calib_log,fitresult,process_params.fit_type);
    score(i) = data_similarity_score(exp(score_hist), exp(datahistref));
    
end


couple_Aa_exp_adj = [aa_adj  expo_adj];
couple_Aa_exp_adj = couple_Aa_exp_adj';

save(fullfile('/','remote','complex','home','bjacob','MC_params_aa_exp_ref_adj'),'couple_Aa_exp_adj','couple_Aa_exp_ref');
save(fullfile('/','remote','complex','home','bjacob','score_optim_intercalibrage_MC'),'score');

temps = toc