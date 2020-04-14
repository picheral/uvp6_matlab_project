% mean de casts de différents instruments uvp6
% Camille Catalano, LOV, 2020/04

function [uvp_base_mean] = Uvp6MeanInstruBases(uvp_bases)
% Uvp6MeanInstruBases compute the mean of different uvp_bases through the sum of
% histopx
%
%   histopx is the sum of the different histopx
%   volimg0 is the mean of the volumes of the different instruments
%   the number of images is the sum, weighted by the vol/volmean
%   mean_prof is weighted by the nb of images and volimg
%   
%
%   inputs:
%       uvp_bases : list of uvp_base of uvp6 instruments
%
%   outputs:
%       uvp_base_mean : uvp_base with mean of the different inpu uvp_bases
%

%% mean volume image
base_nb = length(uvp_bases);
vol_mean = 0;
for i = 1:base_nb
    vol_mean = vol_mean + uvp_bases(i).img_vol_data;
end
vol_mean = vol_mean / base_nb;


%% HISTOPX sum for uvp6
uvp_base_mean = uvp_bases(1);
raw_folder = char(uvp_bases(1).raw_folder);
profilename = ['sum_',char(uvp_bases(1).profilename{1}(17:end))];
pvmtype = char(uvp_bases(1).pvmtype);
light = char(uvp_bases(1).light);
histopx_sum = uvp_bases(1).histopx;
histopx_sum(:,2) = histopx_sum(:,2).*histopx_sum(:,4);
histopx_sum(:,5:end) = histopx_sum(:,5:end);
images_tot = histopx_sum(:,4);
for i = 2 : base_nb
    raw_folder = [raw_folder ,'_', char(uvp_bases(i).raw_folder)];
    profilename = [profilename ,'_', char(uvp_bases(i).profilename{1}(17:end))];
    pvmtype = [pvmtype, '_', char(uvp_bases(i).pvmtype)];
    light = [light, '_', char(uvp_bases(i).light)];
    histopx_to_add = uvp_bases(i).histopx;
    [histopx_sum, histopx_to_add, ~] = CalibrationUvpComputeDepthRange(histopx_sum, histopx_to_add);
    histopx_sum(:,5:end) = histopx_sum(:,5:end) + histopx_to_add(:,5:end);
    histopx_sum(:,2) = histopx_sum(:,2) + histopx_to_add(:,2).*histopx_to_add(:,4)*uvp_bases(i).volimg0;
    histopx_sum(:,3:4) = histopx_sum(:,3:4) + histopx_to_add(:,3:4)*uvp_bases(i).volimg0;
    images_tot = images_tot + histopx_to_add(:,4);
    vol_mean = vol_mean + uvp_bases(i).volimg0;
end
histopx_sum(:,2) = histopx_sum(:,2) ./ images_tot(:,4) ./ vol_mean;
histopx_sum(:,3:4) = histopx_sum(:,3/4) ./ vol_mean;
histopx_sum(:,5:end) = histopx_sum(:,5:end);
uvp_base_mean.histopx = histopx_sum;
uvp_base_mean.raw_folder = {raw_folder};
uvp_base_mean.profilename = {profilename};
uvp_base_mean.pvmtype = {pvmtype};
uvp_base_mean.light = {light};
uvp_base_mean.volimg0 = vol_mean / base_nb;
uvp_base_mean.raw_histopx = [];
uvp_base_mean.raw_black = [];
uvp_base_mean.histnb = [];
uvp_base_mean.histnbred = [];
uvp_base_mean.histbv =[];
uvp_base_mean.histbvred = [];


end
