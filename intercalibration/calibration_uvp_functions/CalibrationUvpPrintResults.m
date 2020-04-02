%% UVP5 Results
% Picheral Lombard 2017/11

function CalibrationUvpPrintResults(process_params, ref_cast, adj_cast, aa_adj, expo_adj)
%CalibrationUvpPrintResults print ref and adj uvp parameters and results
%
%   inputs:
%       process_params : process parameters
%       ref_cast : struct storing computed variables from ref uvp
%       adj_cast : struct storing computed variables from adj uvp
%       aa_adj : aa parameters of size intercalibration of adj uvp
%       expo_adj : expo parameters of size intercalibration of adj uvp
%


disp('-------------------------------------------------------------------------');
disp(['Processing date     : ',datestr(now,31)])
disp('-------------------------------------------------------------------------');
disp(['Min ESD       [mm]  : ',num2str(process_params.esd_min)]);
disp(['Max ESD       [mm]  : ',num2str(process_params.esd_max)]);
disp(['Mnimisation start   : [',num2str(process_params.X0(1)),' ',num2str(process_params.X0(2)),']']);
disp(['Fit                 : ',char(process_params.fit_type)]);
disp(['EC factor           : ',(num2str(process_params.EC_factor))]);
disp(['EC                  : ',(num2str(process_params.Score))]);
disp(['Ratio (after adjust): ',(num2str(process_params.ratio_mean))]);
disp('-------------------------------------------------------------------------');
aa_data_ref = ref_cast.aa_data;
if contains(ref_cast.uvp,'uvp6'); aa_data_ref = round(aa_data_ref * 1000000);end  
disp(['Reference UVP       : ',char(ref_cast.uvp)]);
disp(['Light 1             : ',char(ref_cast.light1)]);
disp(['Light 2             : ',char(ref_cast.light2)]);
disp(['Reference folder    : ',char(ref_cast.project_folder(4:end))]);
if (strcmp(ref_cast.project_folder(4:7),'uvp5'))
    disp(['Reference profile   : ',char(ref_cast.histfile)]);
else
    disp(['Reference profile   : ',char(ref_cast.profilename)]);
end
disp(['Reference profile # : ',num2str(ref_cast.record)]);
disp(['Shutter             : ',num2str(ref_cast.ShutterSpeed)]);
disp(['Gain                : ',num2str(ref_cast.gain)]);
disp(['Threshold           : ',num2str(ref_cast.Thres)]);
disp(['Exposure            : ',num2str(ref_cast.Exposure)]);
disp(['SMBase              : ',num2str(ref_cast.SMBase)]);
disp(['Image volume [L]    : ',num2str(ref_cast.img_vol_data)]);
disp(['Pixel        [µm]   : ',num2str(ref_cast.pix)]);
disp(['Pixel Area   [µm²]  : ',num2str(ref_cast.pix^2)]);
disp(['Aa                  : ',num2str(aa_data_ref)]);
disp(['Exp                 : ',num2str(ref_cast.expo_data)]);  
disp('-------------------------------------------------------------------------');
if contains(adj_cast.uvp,'uvp6'); aa_adj = round(aa_adj * 1000000);end    
disp(['Adjusted UVP        : ',char(adj_cast.uvp)]);
disp(['Light 1             : ',char(adj_cast.light1)]);
disp(['Light 2             : ',char(adj_cast.light2)]);
disp(['Adjusted folder     : ',char(adj_cast.project_folder(4:end))]);
if (strcmp(adj_cast.project_folder(4:7),'uvp5'))
    disp(['Adjusted profile   : ',char(adj_cast.histfile)]);
else
    disp(['Adjusted profile   : ',char(adj_cast.profilename)]); 
end
disp(['Adjusted profile #  : ',num2str(adj_cast.record)]);
disp(['Shutter             : ',num2str(adj_cast.ShutterSpeed)]);
disp(['Gain                : ',num2str(adj_cast.gain)]);
disp(['Threshold           : ',num2str(adj_cast.Thres)]);
disp(['Exposure            : ',num2str(adj_cast.Exposure)]);
disp(['SMBase              : ',num2str(adj_cast.SMBase)]);
disp(['Image volume [L]    : ',num2str(adj_cast.img_vol_data)]);
disp(['Pixel        [µm]   : ',num2str(adj_cast.pix)]);
disp(['Pixel Area   [µm²]  : ',num2str(adj_cast.pix^2)]);
disp(['Aa                  : ',num2str(aa_adj)]);
disp(['Exp                 : ',num2str(expo_adj)]);  
disp('-------------------------------------------------------------------------');
end


