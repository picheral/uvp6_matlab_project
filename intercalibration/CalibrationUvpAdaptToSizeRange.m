function [uvp_cast] = CalibrationUvpAdaptToSizeRange(uvp_cast, esd_min, esd_max)
%CalibrationUvpAdaptToRange Adapt to pix size range the variables of uvp
%cast
%   The variables are not the same if uvp_cast is 'ref' or 'adj'

% -------------- Range ----------------------------------------------------
Smin_mm = pi * (esd_min/2)^2;
Smin_px = ceil(Smin_mm/(uvp_cast.pix^2));

Smax_mm = pi * (esd_max/2)^2;
Smax_px = round(Smax_mm/(uvp_cast.pix^2));


% ------------- Adapt variables to range ----------------------------------
uvp_cast.histopx = uvp_cast.histopx(:,Smin_px:Smax_px);
uvp_cast.histo_mm2 = uvp_cast.histo_mm2(:,Smin_px:Smax_px);
uvp_cast.histo_mm2_vol_mean = uvp_cast.histo_mm2_vol_mean(:,Smin_px:Smax_px);
uvp_cast.vol_ech = uvp_cast.vol_ech(:,Smin_px:Smax_px);
uvp_cast.histo_ab = uvp_cast.histo_ab(:,Smin_px:Smax_px);
uvp_cast.histo_ab_mean_red = uvp_cast.histo_ab_mean_red(:,Smin_px:Smax_px);
uvp_cast.histo_ab_mean_red_norm = uvp_cast.histo_ab_mean_red_norm(:,Smin_px:Smax_px-1);
uvp_cast.esd_x = uvp_cast.esd_x(Smin_px : Smax_px - 1); % -1 because we already put out the last element
uvp_cast.norm_vect = uvp_cast.norm_vect(Smin_px : Smax_px);
uvp_cast.pixsize = uvp_cast.pixsize(Smin_px : Smax_px);

% only for ref (already calibrated values)
if strcmp(uvp_cast.label, 'ref')
    uvp_cast.histo_ab_mean_red_norm_calib = uvp_cast.histo_ab_mean_red_norm_calib(:,Smin_px:Smax_px-1);
    uvp_cast.norm_vect_calib = uvp_cast.norm_vect_calib(Smin_px : Smax_px);
    uvp_cast.esd_calib = uvp_cast.esd_calib(Smin_px : Smax_px);
    uvp_cast.esd_calib_log = uvp_cast.esd_calib_log(Smin_px : Smax_px);
    uvp_cast.esd_calib_all = uvp_cast.esd_calib_all(Smin_px : Smax_px);
    uvp_cast.area_mm2_calib = uvp_cast.area_mm2_calib(Smin_px : Smax_px);
end

uvp_cast.Smin_px = Smin_px;
uvp_cast.Smax_px = Smax_px;

end

