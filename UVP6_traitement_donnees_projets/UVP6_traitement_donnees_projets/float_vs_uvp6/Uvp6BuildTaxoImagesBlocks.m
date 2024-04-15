function [taxo_ab_block, taxo_vol_block, taxo_grey_block] = Uvp6BuildTaxoImagesBlocks(taxo_ab, taxo_vol, taxo_grey, pressure_limits, images_nb_blocks)
% Build taxo arrays with blocks of images
% Catalano 2022
%
% WARNING : number of images in blocks are from depth to surface
% 2 <100m
% 1 >100m
% taxo arrays issued from Uvp6ReadTaxoFromTaxotable
%
%
%   input:
%       taxo_ab = [depth,time,image_nb,ab....];(N cat_number)
%       taxo_vol = [depth,time,image_nb,vol....];(N cat_number)
%       taxo_grey = [depth,time,image_nb,grey....];(N cat_number)
%       pressure_limits = [float float float ...]; (M limits)
%       images_nb_blocks = [int int ...]; (M-1 nb of images in blocks)
%   outputs:
%       taxo_ab_block = [depth,time,image_nb,ab....];(N cat_number)
%       taxo_vol_block = [depth,time,image_nb,vol....];(N cat_number)
%       taxo_grey_block = [depth,time,image_nb,grey....];(N cat_number)
%       time_data is in num format

objects_nb_max = 25;

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
        taxo_ab_block = [taxo_ab_block; taxo_ab_tmp];
        taxo_vol_block = [taxo_vol_block; taxo_vol_tmp];
        taxo_grey_block = [taxo_grey_block; taxo_grey_tmp];
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
                    taxo_ab_block(end,3:end) = taxo_ab_block(end,3:end) + taxo_ab_tmp(j+t,3:end); % adding the line
                    taxo_vol_block(end,3:end) = taxo_vol_block(end,3:end) + taxo_vol_tmp(j+t,3:end);
                    taxo_grey_block(end,3:end) = taxo_grey_block(end,3:end) + taxo_grey_tmp(j+t,3:end);
                end
            end
        end
    end
end








