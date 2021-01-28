%% UVP5 Results
% Picheral Lombard 2017/11

function CalibrationUvpPrintResults(process_params, ref_cast_list, adj_cast, aa_adj, expo_adj, people)
%CalibrationUvpPrintResults print ref and adj uvp parameters and results
%
%   inputs:
%       process_params : process parameters
%       ref_cast_list : list of struct storing computed variables from ref uvp
%       adj_cast : struct storing computed variables from adj uvp
%       aa_adj : aa parameters of size intercalibration of adj uvp
%       expo_adj : expo parameters of size intercalibration of adj uvp
%

% process params
disp('-------------------------------------------------------------------------');
disp(['Processing date     : ',datestr(now,31)])
disp(['Processing operator : ',char(people)]);
disp('-------------------------------------------------------------------------');
disp(['Nb of reference uvps: ',num2str(length(ref_cast_list))]);
disp(['Min raw ESD   [mm]  : ',num2str(process_params.esd_min)]);
disp(['Max raw ESD   [mm]  : ',num2str(process_params.esd_max)]);
disp(['Mnimisation start   : [',num2str(process_params.X0(1)),' ',num2str(process_params.X0(2)),']']);
disp(['Fit                 : ',char(process_params.fit_type)]);
disp(['Ratio (after adjust): ',(num2str(process_params.ratio_mean))]);
%disp(['EC factor           : ',(num2str(process_params.EC_factor))]);
if contains(adj_cast.uvp,'uvp6'); aa_adj = round(aa_adj * 1000000);end 
disp(['EC (score)          : ',(num2str(process_params.Score))]);
disp(['Aa adjusted         : ',num2str(aa_adj)]);
disp(['Exp adjusted        : ',num2str(expo_adj)]); 
if strcmp(process_params.set_aa_exp, 'y')
    if contains(adj_cast.uvp,'uvp6'); process_params.users_aa = round(process_params.users_aa * 1000000);end    
    disp(['Set EC (score)      : ',(num2str(process_params.Score_set))]);
    disp(['Set Aa              : ',num2str(process_params.users_aa)]);
    disp(['Set Exp             : ',num2str(process_params.users_exp)]); 
end
disp('-------------------------------------------------------------------------');

% ref uvp
for i = 1:length(ref_cast_list)
    aa_data_ref = ref_cast_list(i).aa_data;
    if contains(ref_cast_list(i).uvp,'uvp6'); aa_data_ref = round(aa_data_ref * 1000000);end  
    disp(['Reference UVP       : ',char(ref_cast_list(i).uvp)]);
    disp(['Light 1             : ',char(ref_cast_list(i).light1)]);
    disp(['Light 2             : ',char(ref_cast_list(i).light2)]);
    disp(['Reference folder    : ',char(ref_cast_list(i).project_folder(4:end))]);
    if (strcmp(ref_cast_list(i).project_folder(4:7),'uvp5'))
        disp(['Reference profile   : ',char(ref_cast_list(i).histfile)]);
    else
        disp(['Reference profile   : ',char(ref_cast_list(i).profilename)]);
    end
    disp(['Reference profile # : ',num2str(ref_cast_list(i).record)]);
    disp(['Observed volume [L] : ', num2str(sum(ref_cast_list(i).vol_ech(:,1), 'all'))]);
    disp(['Shutter             : ',num2str(ref_cast_list(i).ShutterSpeed)]);
    disp(['Gain                : ',num2str(ref_cast_list(i).gain)]);
    disp(['Threshold           : ',num2str(ref_cast_list(i).Thres)]);
    disp(['Exposure            : ',num2str(ref_cast_list(i).Exposure)]);
    disp(['SMBase              : ',num2str(ref_cast_list(i).SMBase)]);
    disp(['Image volume [L]    : ',num2str(ref_cast_list(i).img_vol_data)]);
    disp(['Pixel         [mm]  : ',num2str(ref_cast_list(i).pix)]);
    disp(['Pixel Area    [mm²] : ',num2str(ref_cast_list(i).pix^2)]);
    disp(['Aa                  : ',num2str(aa_data_ref)]);
    disp(['Exp                 : ',num2str(ref_cast_list(i).expo_data)]);
    disp('-------------------------------------------------------------------------');
end

% adj uvp   
disp(['Adjusted UVP        : ',char(adj_cast.uvp)]);
disp(['Light 1             : ',char(adj_cast.light1)]);
disp(['Light 2             : ',char(adj_cast.light2)]);
disp(['Adjusted folder     : ',char(adj_cast.project_folder(4:end))]);
if (strcmp(adj_cast.project_folder(4:7),'uvp5'))
disp(['Adjusted profile    : ',char(adj_cast.histfile)]);
else
disp(['Adjusted profile    : ',char(adj_cast.profilename)]);
end
disp(['Adjusted profile #  : ',num2str(adj_cast.record)]);
disp(['Observed volume [L] : ', num2str(sum(adj_cast.vol_ech(:,1), 'all'))]);
disp(['Shutter             : ',num2str(adj_cast.ShutterSpeed)]);
disp(['Gain                : ',num2str(adj_cast.gain)]);
disp(['Threshold           : ',num2str(adj_cast.Thres)]);
disp(['Exposure            : ',num2str(adj_cast.Exposure)]);
disp(['SMBase              : ',num2str(adj_cast.SMBase)]);
disp(['Image volume [L]    : ',num2str(adj_cast.img_vol_data)]);
disp(['Pixel        [mm]   : ',num2str(adj_cast.pix)]);
disp(['Pixel Area   [mm²]  : ',num2str(adj_cast.pix^2)]);
if strcmp(process_params.set_aa_exp, 'y')
disp(['Aa                  : ',num2str(process_params.users_aa)]);
disp(['Exp                 : ',num2str(process_params.users_exp)]);  
else
    disp(['Aa                  : ',num2str(aa_adj)]);
    disp(['Exp                 : ',num2str(expo_adj)]); 
end
disp('-------------------------------------------------------------------------');
end


