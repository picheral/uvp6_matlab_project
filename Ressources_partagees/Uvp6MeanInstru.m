% mean de casts de différents instruments uvp6
% Camille Catalano, LOV, 2020/04

function [uvp_cast_mean] = Uvp6MeanInstru(uvp_casts)
% Uvp6MeanInstru mae the mean of different uvp_casts through the sum of
% histopx
%
%   histopx is the sum of the different histopx
%   volimg0 is the mean of the volumes of the different instruments
%   the number of images is the sum, weighted by the vol/volmean
%   mean_prof is weighted by the nb of images and volimg
%   
%
%   inputs:
%       uvp_casts : list of uvp_cast of uvp6 instrument
%
%   outputs:
%       uvp_cast_mean : uvp_cast with mean of the different input uvp_casts
%

cast_nb = length(uvp_casts);
vol_mean = 0;
for i = 1:cast_nb
    vol_mean = vol_mean + uvp_casts(i).img_vol_data;
end
vol_mean = vol_mean / cast_nb;


%% HISTOPX sum for uvp6
base_size = length(base);
base(base_size+i) = base(samples_nb(1)+i-1);
threshold = base(samples_nb(1)+i-1).threshold;
raw_folder = char(base(samples_nb(1)+i-1).raw_folder);
profilename = ['sum_',char(base(samples_nb(1)+i-1).profilename{1}(17:end))];
pvmtype = char(base(samples_nb(1)+i-1).pvmtype);
histopx_sum = base(samples_nb(1)+i-1).histopx;
histopx_sum(:,2) = histopx_sum(:,2).*histopx_sum(:,4);
histopx_sum(:,5:end) = histopx_sum(:,5:end);
images_tot = histopx_sum(:,4);
for j = 2 : cast_nb
    raw_folder = [raw_folder ,'_', char(base(samples_nb(j)+i-1).raw_folder)];
    profilename = [profilename ,'_', char(base(samples_nb(j)+i-1).profilename{1}(17:end))];
    pvmtype = [pvmtype, '_', char(base(sample_nb(j)+i-1).pvmtype)];
    histopx_to_add = base(samples_nb(j)+i-1).histopx;
    [histopx_sum, histopx_to_add, ~] = CalibrationUvpComputeDepthRange(histopx_sum, histopx_to_add);
    histopx_sum(:,5:end) = histopx_sum(:,5:end) + histopx_to_add(:,5:end);
    histopx_sum(:,2) = histopx_sum(:,2) + histopx_to_add(:,2).*histopx_to_add(:,4)*base(samples(j)+i-1).volimg0;
    histopx_sum(:,3:4) = histopx_sum(:,3:4) + histopx_to_add(:,3:4)*base(samples(j)+i-1).volimg0;
    images_tot = images_tot + histopx_to_add(:,4);
end
histopx_sum(:,2) = histopx_sum(:,2) ./ images_tot(:,4) ./ vol_mean;
histopx_sum(:,3:4) = histopx_sum(:,3/4) ./ vol_mean;
histopx_sum(:,5:end) = histopx_sum(:,5:end);
base(base_size+i).histopx = histopx_sum;
base(base_size+i).raw_folder = {raw_folder};
base(base_size+i).profilename = {profilename};
base(base_size+i).pvmtype = {pvmtype};
base(base_size+i).img_vol_data = vol_mean;
base(base_size+i).raw_histopx = [];
base(base_size+i).raw_black = [];
base(base_size+i).histnb = [];
base(base_size+i).histnbred = [];
base(base_size+i).histbv =[];
base(base_size+i).histbvred = [];


end
