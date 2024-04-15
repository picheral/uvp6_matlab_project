function uvp6_lpm_ab_class = Uvp6ClassDispatcher(Aa, Exp, esd_classes, uvp6_lpm_ab)
% Dispatch the lpm abundance into calibrated size classes
% Catalano 2022
%
%
%   input:
%       Aa : Aa in float
%       Exp : Exp in float
%       esd_classes : array of float (esd limits of classes)
%       uvp6_lpm_ab : pix num array (depth, time, image_nb, value_i,...) 
%
%   outputs:
%       uvp6_lpm_ab_class : calibrated num array (depth, time, image_nb, value_i,...) 
%

% build pixel class vector
pixsize = [1:size(uvp6_lpm_ab(:,4:end),2)];
esd_calib = 2*((Aa*(pixsize.^Exp)./pi).^0.5);

% build calib class vector
uvp6_lpm_ab_class = zeros(size(uvp6_lpm_ab(:,4:end),1), size(esd_classes,2));

for i=1:size(uvp6_lpm_ab(:,4:end),1)
    uvp6_lpm_ab_class(i,:) = sum_ab_classe(esd_calib, esd_classes, uvp6_lpm_ab(i,4:end));
end
uvp6_lpm_ab_class = [uvp6_lpm_ab(:,1:3) uvp6_lpm_ab_class];


end








