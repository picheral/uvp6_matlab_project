function uvp6_lpm_ab_cal = Uvp6ClassDispatcher(hw_line, uvp6_lpm_ab)
% Dispatch the lpm abundance into calibrated size classes
% Catalano 2022
%
%
%   input:
%       hw_line : string of the hw line
%       uvp6_lpm_ab : pix num array (depth, time, image_nb, value_i,...) 
%
%   outputs:
%       uvp6_lpm_ab_cal : calibrated num array (depth, time, image_nb, value_i,...) 
%

hw_array = strsplit(hw_line, ',');
hw_array(end) = {hw_array{end}(1:end-1)};

esd_classes = str2double(hw_array(26:end));
Aa = str2double(hw_array{19});
Exp = str2double(hw_array{20});

% build pixel class vector
pixsize = [1:size(uvp6_lpm_ab(:,4:end),2)];
esd_calib = 2*((Aa*(pixsize.^Exp)./pi).^0.5);

% build calib class vector
uvp6_lpm_ab_cal = zeros(size(uvp6_lpm_ab(:,4:end),1), size(esd_classes,2)-1);

for i=1:size(uvp6_lpm_ab(:,4:end),1)
    uvp6_lpm_ab_cal(i,:) = sum_ab_classe(esd_calib, esd_classes, uvp6_lpm_ab(i,4:end));
end
uvp6_lpm_ab_cal = [uvp6_lpm_ab(:,1:3) uvp6_lpm_ab_cal];


end








