function uvp6_lpm_grey_class = Uvp6ClassDispatcherGrey(Aa, Exp, esd_classes, uvp6_lpm_grey)
% Dispatch the lpm grey level into calibrated size classes
% Catalano 2022
%
% grey level is an average modified by the area
%
%   input:
%       Aa : Aa in float
%       Exp : Exp in float
%       esd_classes : array of float (esd limits of classes)
%       uvp6_lpm_grey : pix num array (depth, time, image_nb, value_i,...)
%
%   outputs:
%       uvp6_lpm_grey_class : calibrated num array (depth, time, image_nb, value_i,...) 
%

% build pixel class vector
pixsize = [1:size(uvp6_lpm_grey(:,4:end),2)];
esd_calib = 2*((Aa*(pixsize.^Exp)./pi).^0.5);

% build calib class vector
uvp6_lpm_grey_class = zeros(size(uvp6_lpm_grey(:,4:end),1), size(esd_classes,2));

%{
for i=1:size(uvp6_lpm_grey(:,4:end),1)
    uvp6_lpm_grey_class(i,:) = sum_ab_classe(esd_calib, esd_classes, uvp6_lpm_grey(i,4:end));
end
%}


for i=1:size(uvp6_lpm_grey(:,4:end),1)
    ab_vect_source = uvp6_lpm_grey(i,4:end) .* pixsize;
    %%
    ab_vect_final = [];
    for j=1:numel(esd_classes)-1
        aa = find(esd_calib >= esd_classes(j) & esd_calib < esd_classes(j+1) & ab_vect_source ~= 0);
        ab_vect_final(j) = sum(ab_vect_source(aa)) / sum(pixsize(aa));
    end
    aa = find(esd_calib >= esd_classes(j+1) & ab_vect_source ~= 0);
    ab_vect_final(j+1) = sum(ab_vect_source(aa)) / sum(pixsize(aa));
    %%
    uvp6_lpm_grey_class(i,:) = ab_vect_final;
end


uvp6_lpm_grey_class = [uvp6_lpm_grey(:,1:3) uvp6_lpm_grey_class];


end








