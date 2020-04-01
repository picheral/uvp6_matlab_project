%% UVP5 calibration settings & analyses
% Picheral Lombard 2017/11
% Updated 2019/06/11

function [uvp_cast] = CalibrationUvpProcessRawData(esd_vect_ecotaxa, uvp_cast)

% ----------------- used variables  ---------------------------------------
pix = uvp_cast.pix;
img_vol_data = uvp_cast.img_vol_data;
aa_data = uvp_cast.aa_data;
expo_data = uvp_cast.expo_data;
histopx=uvp_cast.histopx;


%% raw data vectors
% take only the part counts
histo_px = histopx(:,5:end);

% volume observed normalisation
histo_mm2 = histo_px./(pix^2);
nb_img=histopx(:,4);
vol_ech=img_vol_data*nb_img;
vol_ech=vol_ech*ones(1,size(histo_mm2,2));
histo_mm2_vol=histo_mm2./vol_ech;

% ESD size vectors
pixsize = [1:size(histo_px,2)-4];
histo_ab = (histo_px./vol_ech);
esd_x = 2*(((pix^2)*(pixsize)./pi).^0.5);
norm_vect = [];
for i=1:numel(esd_x)-1
    norm_vect(i) = esd_x(i+1) - esd_x(i);  
end

% calibrated ESD size vectors
if strcmp(uvp_cast.label, 'ref')
    esd_calib = 2*((aa_data*(pixsize.^expo_data)./pi).^0.5);
    esd_calib_all = 2*((aa_data*([1:500].^expo_data)./pi).^0.5);
    esd_calib_log = log(esd_calib);
    area_mm2_calib = aa_data*(pixsize.^expo_data);
    norm_vect_calib = [];
    for i=1:numel(esd_calib)-1
        norm_vect_calib(i) = esd_calib(i+1) - esd_calib(i);  
    end
end


%% abundance vectors
% --------- depth average vectors -----------------------------------------
histo_ab_mean = nanmean(histo_ab);
histo_ab_mean_red = histo_ab_mean(1:numel(esd_x));
histo_mm2_vol_mean = nanmean(histo_mm2_vol);
histo_mm2_vol_mean_red = histo_mm2_vol_mean;
if strcmp(uvp_cast.label, 'ref')
    histo_mm2_vol_mean_red = histo_mm2_vol_mean_red(1:numel(esd_calib));
else
    histo_mm2_vol_mean_red = histo_mm2_vol_mean_red(1:numel(esd_x));
end    
histo_mm2_vol_mean_red_log = log(histo_mm2_vol_mean_red);

% -------- Vecteurs finaux d'abondances -----------------------------------
esd_x = esd_x(1:end-1);
histo_ab_mean_red_norm = histo_ab_mean_red(1:end-1)./norm_vect;
if strcmp(uvp_cast.label, 'ref')
    histo_ab_mean_red_norm_calib = histo_ab_mean_red(1:end-1)./norm_vect_calib;
end

% -------- Vecteurs finaux par classe -------------------------------------
[ab_vect_ecotaxa]= sum_ab_classe(esd_x,esd_vect_ecotaxa,histo_ab_mean_red);


%% FUNCTION RETURNS
% ----------- return computed variables  ----------------------------------
uvp_cast.pixsize = pixsize;
uvp_cast.vol_ech = vol_ech;
uvp_cast.esd_x = esd_x;
uvp_cast.norm_vect = norm_vect;
uvp_cast.histopx = histopx;
uvp_cast.histo_mm2 = histo_mm2;
uvp_cast.histo_mm2_vol_mean = histo_mm2_vol_mean;
uvp_cast.histo_mm2_vol_mean_red_log = histo_mm2_vol_mean_red_log;
uvp_cast.histo_ab = histo_ab;
uvp_cast.histo_ab_mean_red = histo_ab_mean_red;
uvp_cast.histo_ab_mean_red_norm = histo_ab_mean_red_norm;
uvp_cast.ab_vect_ecotaxa = ab_vect_ecotaxa;
if strcmp(uvp_cast.label, 'ref')
    uvp_cast.esd_calib = esd_calib;
    uvp_cast.esd_calib_log = esd_calib_log;
    uvp_cast.esd_calib_all = esd_calib_all;
    uvp_cast.area_mm2_calib = area_mm2_calib;
    uvp_cast.norm_vect_calib = norm_vect_calib;
    uvp_cast.histo_ab_mean_red_norm_calib = histo_ab_mean_red_norm_calib;
end


end

