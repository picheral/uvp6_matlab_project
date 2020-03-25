%% UVP5 Results
% Picheral Lombard 2017/11

function Calibration_uvp_results
global  project_folder_adj project_folder_ref pixel_min esd_max fit_type...
    EC_factor pix_ref pix_adj X0 rec_ref rec_adj base_ref base_adj aa_data_ref...
    expo_data_ref img_vol_data_ref img_vol_data_adj aa_adj expo_adj...
    uvp_ref uvp_adj Score gain_adj Thres_adj Exposure_adj...
    shutter_adj ShutterSpeed_adj SMBase_adj gain_ref Thres_ref Exposure_ref...
    ShutterSpeed_ref SMBase_ref light1_adj light2_adj light1_ref light2_ref...
    Smin_px_adj Smin_px_ref esd_min ratio_mean
disp('-------------------------------------------------------------------------');
disp(['Processing date     : ',datestr(now,31)])
disp('-------------------------------------------------------------------------');
disp(['Min ESD       [mm]  : ',num2str(esd_min)]);
disp(['Max ESD       [mm]  : ',num2str(esd_max)]);
disp(['Mnimisation start   : [',num2str(X0(1)),' ',num2str(X0(2)),']']);
disp(['Fit                 : ',char(fit_type)]);
disp(['EC factor           : ',(num2str(EC_factor))]);
disp(['EC                  : ',(num2str(Score))]);
disp(['Ratio (after adjust): ',(num2str(ratio_mean))]);
disp('-------------------------------------------------------------------------');
if contains(uvp_ref,'uvp6'); aa_data_ref = round(aa_data_ref * 1000000);end  
disp(['Reference UVP       : ',char(uvp_ref)]);
disp(['Light 1             : ',char(light1_ref)]);
disp(['Light 2             : ',char(light2_ref)]);
disp(['Reference folder    : ',char(project_folder_ref(4:end))]);
if (strcmp(project_folder_ref(4:7),'uvp5'))
    disp(['Reference profile   : ',char(base_ref(rec_ref).histfile)]);
else
    disp(['Reference profile   : ',char(base_ref(rec_ref).profilename)]);
end
disp(['Reference profile # : ',num2str(rec_ref)]);
disp(['Shutter             : ',num2str(ShutterSpeed_ref)]);
disp(['Gain                : ',num2str(gain_ref)]);
disp(['Threshold           : ',num2str(Thres_ref)]);
disp(['Exposure            : ',num2str(Exposure_ref)]);
disp(['SMBase              : ',num2str(SMBase_ref)]);
disp(['Image volume [L]    : ',num2str(img_vol_data_ref)]);
disp(['Pixel        [µm]   : ',num2str(pix_ref)]);
disp(['Pixel Area   [µm²]  : ',num2str(pix_ref^2)]);
disp(['Aa                  : ',num2str(aa_data_ref)]);
disp(['Exp                 : ',num2str(expo_data_ref)]);  
disp('-------------------------------------------------------------------------');
if contains(uvp_adj,'uvp6'); aa_adj = round(aa_adj * 1000000);end    
disp(['Adjusted UVP        : ',char(uvp_adj)]);
disp(['Light 1             : ',char(light1_adj)]);
disp(['Light 2             : ',char(light2_adj)]);
disp(['Adjusted folder     : ',char(project_folder_adj(4:end))]);
if (strcmp(project_folder_adj(4:7),'uvp5'))
    disp(['Adjusted profile   : ',char(base_adj(rec_adj).histfile)]);
else
    disp(['Adjusted profile   : ',char(base_adj(rec_adj).profilename)]); 
end
disp(['Adjusted profile #  : ',num2str(rec_adj)]);
disp(['Shutter             : ',num2str(ShutterSpeed_adj)]);
disp(['Gain                : ',num2str(gain_adj)]);
disp(['Threshold           : ',num2str(Thres_adj)]);
disp(['Exposure            : ',num2str(Exposure_adj)]);
disp(['SMBase              : ',num2str(SMBase_adj)]);
disp(['Image volume [L]    : ',num2str(img_vol_data_adj)]);
disp(['Pixel        [µm]   : ',num2str(pix_adj)]);
disp(['Pixel Area   [µm²]  : ',num2str(pix_adj^2)]);
disp(['Aa                  : ',num2str(aa_adj)]);
disp(['Exp                 : ',num2str(expo_adj)]);  
disp('-------------------------------------------------------------------------');