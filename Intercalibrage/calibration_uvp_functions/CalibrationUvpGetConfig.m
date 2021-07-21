% Catalano 2020/04

function[uvp_base, uvp_cast] = CalibrationUvpGetConfig(uvp_base, uvp_cast, type)
%CalibrationUvpGetConfig read and save config parameters from base
%
%   inputs:
%       uvp_base : data base (struct)
%       uvp_cast : struct storing cast variables
%       type : "Reference" or "Adjusted"
%
%   outputs:
%       uvp_base : data base (struct)
%       uvp_cast : struct storing cast variables
%

if (strcmp(uvp_cast.project_folder(4:7),'uvp5'))
    % Reading uvp5_configuration_data.txt REF
    uvp_cast.histfile = uvp_base.histfile;

    filename=[uvp_cast.project_folder,'\config\uvp5_settings\uvp5_configuration_data.txt'];
    [ uvp_cast.aa_data,uvp_cast.expo_data,uvp_cast.img_vol_data,uvp_cast.pix,uvp_cast.light1,uvp_cast.light2] = read_uvp5_configuration_data( filename ,'data' );
    % Reading *.hdr REF

    filename=[uvp_cast.project_folder,'\raw\HDR',char(uvp_cast.histfile),'\HDR',char(uvp_cast.histfile),'.hdr'];
    [ a,b,c,d,l1,l2,uvp_cast.gain,uvp_cast.Thres,uvp_cast.Exposure,uvp_cast.ShutterSpeed,uvp_cast.SMBase] = read_uvp5_configuration_data( filename , 'hdr');

    % -------------- Checks --------------------------------------------------
    if strcmp(type,'Reference') && (uvp_base.a0 ~= uvp_cast.aa_data || uvp_base.exp0 ~= uvp_cast.expo_data || uvp_base.volimg0 ~= uvp_cast.img_vol_data)
        disp('The calibration parameters of the reference UVP are not the same in the data base and in the configuration file. Check them !!! ');
        disp('Configuration_data');
        disp(['Image volume [L]    : ',num2str(uvp_cast.img_vol_data)]);
        disp(['Aa                  : ',num2str(uvp_cast.aa_data)]);
        disp(['Exp                 : ',num2str(uvp_cast.expo_data)]);
        disp('BASE');
        disp(['Image volume [L]    : ',num2str(uvp_base.volimg0)]);
        disp(['Aa                  : ',num2str(uvp_base.a0)]);
        disp(['Exp                 : ',num2str(uvp_base.exp0)]);
        uvp_cast.img_vol_data = uvp_base.volimg0;
        uvp_cast.aa_data = uvp_base.a0;
        uvp_cast.expo_data = uvp_base.exp0;
    elseif strcmp(type, 'Adjusted') && (uvp_base.volimg0 ~= uvp_cast.img_vol_data)
        disp('The image volume of the adjusted UVP is not the same in the data base and in the configuration file. Check the file !!! ');
        disp('Configuration_data');
        disp(['Image volume [L]    : ',num2str(uvp_cast.img_vol_data)]);
        disp('BASE');
        disp(['Image volume [L]    : ',num2str(uvp_base.volimg0)]);
        uvp_cast.img_vol_data = uvp_base.volimg0;
    else
        disp('All metadata of the profile are OK.')
    end
else
    % Reading data from UVP6 base
    uvp_cast.aa_data = uvp_base.a0/1000000;
    uvp_cast.expo_data = uvp_base.exp0;
    uvp_cast.img_vol_data = uvp_base.volimg0;
    uvp_cast.pix = uvp_base.pixel_size;
    uvp_cast.gain = uvp_base.gain;
    uvp_cast.Thres = uvp_base.threshold;
    uvp_cast.Exposure = uvp_base.shutter;
    uvp_cast.ShutterSpeed = uvp_base.shutter;
    uvp_cast.SMBase    = 1;
    uvp_cast.light1 = uvp_base.light;
    uvp_cast.light2 = '';
    uvp_cast.profilename = uvp_base.profilename;
end

end




