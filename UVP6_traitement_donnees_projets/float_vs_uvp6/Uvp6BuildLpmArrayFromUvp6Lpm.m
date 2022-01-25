function [uvp6_lpm_array] = Uvp6BuildLpmArrayFromUvp6Lpm(time_array, depth_array, data_array)
% Convert uvp6 data in num arrays : ab or grey
% Catalano 2022
%
% data is in num array but separated from time and depth
% Issued from Uvp6ReadDataFromDattable function
%
%
%   input:
%       time_array : time vector in num format
%       depth_array : depth vector in num format
%       data_array : data array with NaN lines
%
%   outputs:
%       uvp6_lpm_array = [depth,time,image_nb,class_nb....]
%

aa = find(isnan(data_array(:,1)));
time_array(aa) = [];
depth_array(aa) = [];
data_array(aa,:) = [];

uvp6_lpm_array = [depth_array time_array time_array.*0+1 data_array];

end








