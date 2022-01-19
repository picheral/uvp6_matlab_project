function [lpm_ab, lpm_grey] = Uvp6ReadLpmFromFloatLpm(lpm_table)
% Convert float lpm data in num arrays : ab, grey
% Catalano 2022
%
% lpm must be cell array with each cell is a line
% Issued from Uvp6ReadLpmFromFloatLpmTaxoCSV function
%
%
%   input:
%       lpm_table : lpm data cell array (time, pressure, image_nb, temp,
%       ab,...,grey...)
%
%   outputs:
%       lpm_ab = [depth,time,image_nb,ab....];(N cat_number)
%       lpm_grey = [depth,time,image_nb,grey....];(N cat_number)
%       time_data is in num format

time = cellfun(@(x) datetime(x,'InputFormat', 'yyyy-MM-dd HH:mm:ss'), lpm_table(:,1));
time = datenum(time);

lpm_array = cellfun(@str2num, lpm_table(:,2:end));

class_number = 18;
lpm_ab = [lpm_array(:,1) time lpm_array(:,2) lpm_array(:,3) lpm_array(:,4:class_number+3)];
lpm_grey = [lpm_array(:,1) time lpm_array(:,2) lpm_array(:,3) lpm_array(:,class_number+4:end)];

end








