function [uvp_cast] = CalibrationUvpAdaptToSizeRange(uvp_cast, esd_min, esd_max)
%CalibrationUvpAdaptToRange Adapt to pix size range the raw variables of uvp
%cast
%
%   inputs:
%       uvp_cast : struct storing computed variables
%       esd_min : min diameter size
%       esd_max : max diameter size
%
%   outputs:
%       uvp_cast : updated struct
%

%% -------------- Range ----------------------------------------------------
Smin_mm = pi * (esd_min/2)^2;
Smin_px = ceil(Smin_mm/(uvp_cast.pix^2));

Smax_mm = pi * (esd_max/2)^2;
Smax_px = round(Smax_mm/(uvp_cast.pix^2));

uvp_cast.Smin_px = Smin_px;
uvp_cast.Smax_px = Smax_px;


%% ------------- Adapt variables to range ----------------------------------
uvp_cast.pixsize = uvp_cast.pixsize(Smin_px : Smax_px);
uvp_cast.vol_ech = uvp_cast.vol_ech(:,Smin_px:Smax_px);
uvp_cast.esd_x = uvp_cast.esd_x(Smin_px : Smax_px - 1); % -1 because we already put out the last element

uvp_cast.histopx = uvp_cast.histopx(:,Smin_px:Smax_px);
uvp_cast.histo_mm2 = uvp_cast.histo_mm2(:,Smin_px:Smax_px);
uvp_cast.histo_mm2_vol_mean = uvp_cast.histo_mm2_vol_mean(:,Smin_px:Smax_px);
uvp_cast.histo_ab = uvp_cast.histo_ab(:,Smin_px:Smax_px);
uvp_cast.histo_ab_mean_red = uvp_cast.histo_ab_mean_red(:,Smin_px:Smax_px);
uvp_cast.histo_ab_mean_red_norm = uvp_cast.histo_ab_mean_red_norm(:,Smin_px:Smax_px-1);


end



