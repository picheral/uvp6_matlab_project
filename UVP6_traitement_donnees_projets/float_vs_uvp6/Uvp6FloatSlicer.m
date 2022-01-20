function uvp6_slices = Uvp6FloatSlicer(uvp6_array)
% Concatenate uvp6_array into depth slices as float
% Catalano 2022
%
% The concatenation is made by sum of the values
%
%   input:
%       uvp6_array : num array (depth, time, image_nb, value_i,...) 
%
%   outputs:
%       uvp6_slices : num array (depth_mean, time_0, image_nb,
%       sum_value_i,...)

uvp6_slices = zeros(1,size(uvp6_array,2));
uvp6_slices(1,:) = uvp6_array(1,:);
slice_size = 20;
for i=2:size(uvp6_array,1)
    if uvp6_array(i,1) > uvp6_slices(end,1) - slice_size
        uvp6_slices(end,3:end) = uvp6_slices(end,3:end) + uvp6_array(i,3:end);        
    else
        uvp6_slices(end,1) = uvp6_slices(end,1) - slice_size/2;
        uvp6_slices = [uvp6_slices; uvp6_array(i,:)];
    end
    if uvp6_slices(end,1) < 100
        slice_size = 5;
    elseif uvp6_slices(end,1) < 500
        slice_size = 10;
    end
end

end








