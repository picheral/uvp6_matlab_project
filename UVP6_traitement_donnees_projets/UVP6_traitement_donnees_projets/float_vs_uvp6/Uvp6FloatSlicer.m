function uvp6_slices = Uvp6FloatSlicer(uvp6_array, park_flag, fake_flag, pressure_limits_slices, pressure_size_slices)
% Concatenate uvp6_array into depth slices as float
% Catalano 2022
%
% The concatenation is made by sum of the values
%
%   input:
%       uvp6_array : num array (depth, time, image_nb, value_i,...)
%       park_flag : 1 for parking data, 0 else
%       fake_flag : 1 for fake data, 0 else
%       pressure_limits_slices : pressure limits for slices config [1000
%       500 100]
%       pressure_size_slices : pressure size of float slices [20 20 10 5]
%
%   outputs:
%       uvp6_slices : num array (depth_mean, time_0, image_nb,
%       sum_value_i,...)


if park_flag
    if fake_flag
        slice_size = 2;
    else
        slice_size = 20;
    end
    uvp6_slices = zeros(size(uvp6_array,1)/slice_size , size(uvp6_array,2));
    % sum of blocks of length slice_size
    uvp6_slices(:,1:2) = uvp6_array(1:slice_size:end,1:2);
    tmp = sum(reshape(uvp6_array, slice_size, size(uvp6_array,2), size(uvp6_array,1)/slice_size), 1);
    tmp = reshape(tmp, size(uvp6_array,1)/slice_size, size(uvp6_array,2));
    uvp6_slices(:,3:end) = tmp(:,3:end);
else
    uvp6_slices = zeros(1,size(uvp6_array,2));
    uvp6_slices(1,:) = uvp6_array(1,:);
    slice_size = pressure_size_slices(1);
    if uvp6_array(1,1) < pressure_limits_slices(3)
        slice_size = pressure_size_slices(4);
    elseif uvp6_array(1,1) < pressure_limits_slices(2)
        slice_size = pressure_size_slices(3);
    elseif uvp6_array(1,1) < pressure_limits_slices(1)
        slice_size = pressure_size_slices(2);
    end
    for i=2:size(uvp6_array,1)
        if uvp6_array(i,1) > uvp6_slices(end,1) - slice_size
            uvp6_slices(end,3:end) = uvp6_slices(end,3:end) + uvp6_array(i,3:end);        
        else
            %uvp6_slices(end,1) = uvp6_slices(end,1) - slice_size/2;
            uvp6_slices = [uvp6_slices; uvp6_array(i,:)];
        end
        if uvp6_slices(end,1) < pressure_limits_slices(3)
            slice_size = pressure_size_slices(4);
        elseif uvp6_slices(end,1) < pressure_limits_slices(2)
            slice_size = pressure_size_slices(3);
        elseif uvp6_slices(end,1) < pressure_limits_slices(1)
            slice_size = pressure_size_slices(2);
        end
    end
end
end








