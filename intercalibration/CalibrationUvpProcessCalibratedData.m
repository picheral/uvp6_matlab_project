%% UVP5 calibration settings & analyses
% from Picheral Lombard 2017/11


function [uvp_cast] = CalibrationUvpProcessCalibratedData(esd_vect_ecotaxa, uvp_cast, aa, expo)


% ----------------- used variables  ---------------------------------------
pixsize = uvp_cast.pixsize;
vol_ech = uvp_cast.vol_ech;
histo_mm2 = uvp_cast.histo_mm2;
histo_ab = uvp_cast.histo_ab;
histo_ab_mean_red = uvp_cast.histo_ab_mean_red;


%% CALIBRATED DATA
% ---------------- calibrated vectors -------------------------------------
esd_calib = 2*((aa*(pixsize.^expo)./pi).^0.5);
esd_calib_all = 2*((aa*([1:500].^expo)./pi).^0.5);
esd_calib_log = log(esd_calib);
area_mm2_calib = aa*(pixsize.^expo);

norm_vect_calib = [];
for i=1:numel(esd_calib)-1
    norm_vect_calib(i) = esd_calib(i+1) - esd_calib(i);  
end


histo_ab_mean_red_norm_calib = histo_ab_mean_red(1:end-1)./norm_vect_calib;
histo_ab_red_log = log(histo_ab(:,1:numel(esd_calib)));
histo_mm2_vol_mean = nanmean(histo_mm2./vol_ech);
histo_mm2_vol_mean = histo_mm2_vol_mean(1:numel(esd_calib));
histo_mm2_vol_mean_log = log(histo_mm2_vol_mean);

% ---------- Vecteurs finaux par classe -----------------------------------
histo_ab_mean = nanmean(histo_ab);
[calib_vect_ecotaxa]= sum_ab_classe(esd_calib,esd_vect_ecotaxa,histo_ab_mean(1:numel(esd_calib)));



%% FUNCTION RETURNS
% ----------- return computed variables  ----------------------------------
uvp_cast.esd_calib = esd_calib;
uvp_cast.esd_calib_log = esd_calib_log;
uvp_cast.area_mm2_calib = area_mm2_calib;
uvp_cast.histo_mm2_vol_mean = histo_mm2_vol_mean;
uvp_cast.histo_mm2_vol_mean_log = histo_mm2_vol_mean_log;
uvp_cast.calib_esd_vect_ecotaxa = calib_vect_ecotaxa;
uvp_cast.histo_ab_red_log = histo_ab_red_log;

end



