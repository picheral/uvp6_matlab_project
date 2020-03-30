%% UVP5 Results
% Picheral Lombard 2017/11

function Calibration_uvp_results(process_params, ref_cast, adj_cast, ref_base, adj_base, aa_adj, expo_adj)

project_folder_ref = ref_cast.project_folder;
rec_ref = ref_cast.record;
uvp_ref = ref_cast.uvp;
pix_ref = ref_cast.pix;
img_vol_data_ref = ref_cast.img_vol_data;
Smin_px_ref = ref_cast.Smin_px;
aa_data_ref = ref_cast.aa_data;
expo_data_ref = ref_cast.expo_data;
gain_ref = ref_cast.gain;
Thres_ref = ref_cast.Thres;
Exposure_ref = ref_cast.Exposure;
ShutterSpeed_ref = ref_cast.ShutterSpeed;
SMBase_ref = ref_cast.SMBase;
light1_ref = ref_cast.light1;
light2_ref = ref_cast.light2;

project_folder_adj = adj_cast.project_folder;
rec_adj = adj_cast.record;
uvp_adj = adj_cast.uvp;
pix_adj = adj_cast.pix;
img_vol_data_adj = adj_cast.img_vol_data;
Smin_px_adj = adj_cast.Smin_px;
gain_adj = adj_cast.gain;
Thres_adj = adj_cast.Thres;
Exposure_adj = adj_cast.Exposure;
ShutterSpeed_adj = adj_cast.ShutterSpeed;
SMBase_adj = adj_cast.SMBase;
light1_adj = adj_cast.light1;
light2_adj = adj_cast.light2;

esd_min = process_params.esd_min;
esd_max = process_params.esd_max;
fit_type = process_params.fit_type;
EC_factor = process_params.EC_factor;
X0 = process_params.X0;
Score = process_params.Score;
ratio_mean = process_params.ratio_mean;

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
    disp(['Reference profile   : ',char(ref_base.histfile)]);
else
    disp(['Reference profile   : ',char(ref_base.profilename)]);
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
    disp(['Adjusted profile   : ',char(adj_base.histfile)]);
else
    disp(['Adjusted profile   : ',char(adj_base.profilename)]); 
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