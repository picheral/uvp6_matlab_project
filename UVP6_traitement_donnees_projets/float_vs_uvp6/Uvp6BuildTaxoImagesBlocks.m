function [taxo_ab_block, taxo_vol_block, taxo_grey_block] = Uvp6BuildTaxoImagesBlocks(taxo_ab, taxo_vol, taxo_grey)
% Build taxo arrays with blocks of images
% Catalano 2022
%
% WARNING : number of images in blocks are fixed
% 2 <100m
% 1 >100m
% taxo arrays issued from Uvp6ReadTaxoFromTaxotable
%
%
%   input:
%       taxo_ab = [depth,time,image_nb,ab....];(N cat_number)
%       taxo_vol = [depth,time,image_nb,vol....];(N cat_number)
%       taxo_grey = [depth,time,image_nb,grey....];(N cat_number)
%   outputs:
%       taxo_ab_block = [depth,time,image_nb,ab....];(N cat_number)
%       taxo_vol_block = [depth,time,image_nb,vol....];(N cat_number)
%       taxo_grey_block = [depth,time,image_nb,grey....];(N cat_number)
%       time_data is in num format

objects_nb_max = 25;
pressure_limits = [6000 100 -2]; % IMPORTANT : from depth to surface
images_nb_blocks = [1 2]; % IMPORTANT : corresponding to pressure_limits

taxo_ab_block = [];
taxo_vol_block = [];
taxo_grey_block = [];

for i=1:size(images_nb_blocks,2) % go throught the different config
    aa = find(taxo_ab(:,1) < pressure_limits(i) & taxo_ab(:,1) >= pressure_limits(i+1)); % select data from pressure of this config
    if isempty(aa)
        continue
    end
    taxo_ab_tmp = taxo_ab(aa,:);
    taxo_vol_tmp = taxo_vol(aa,:);
    taxo_grey_tmp = taxo_grey(aa,:);
    if images_nb_blocks(i) == 1 % if one image in the block, it is easy
        taxo_ab_block = [taxo_ab_block taxo_ab_tmp];
        taxo_vol_block = [taxo_vol_block taxo_vol_tmp];
        taxo_grey_block = [taxo_grey_block taxo_grey_tmp];
    else % if more than one image
        for j=1:images_nb_blocks(i):size(taxo_ab_tmp,1) % go through first line of each block
            taxo_ab_block(end+1,:) = taxo_ab_tmp(j,:); % first line is taken
            taxo_vol_block(end+1,:) = taxo_vol_tmp(j,:);
            taxo_grey_block(end+1,:) = taxo_grey_tmp(j,:);
            objects_nb = sum(taxo_ab_block(end,4:end)); % nb of objects in first line
            for t=1:images_nb_blocks(i)-1
                objects_nb = objects_nb + sum(taxo_ab_tmp(j+t,4:end)); % nb of objects for lines
                if objects_nb > objects_nb_max % test if too much objects
                    break
                else
                    taxo_ab_block(end,4:end) = taxo_ab_block(end,4:end) + taxo_ab_tmp(j+t,4:end); % adding the line
                    taxo_vol_block(end,4:end) = taxo_vol_block(end,4:end) + taxo_vol_tmp(j+t,4:end);
                    taxo_grey_block(end,4:end) = taxo_grey_block(end,4:end) + taxo_grey_tmp(j+t,4:end);
                end
            end
        end
    end
end








