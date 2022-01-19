function [taxo_ab, taxo_vol, taxo_grey] = Uvp6BuildTaxoArrayFromFloatTaxo(taxo_table)
% Convert float taxo data in num arrays : ab, size, grey
% Catalano 2021
%
% taxo must be cell array with each cell is a line
% Issued from Uvp6ReadTaxoFromFloatTaxoCSV function
%
%
%   input:
%       taxo_table : TAXO data cell array (time, pressure, image_nb, ab,
%       vol, grey,...)
%   outputs:
%       taxo_ab = [depth,time,image_nb,ab....];(N cat_number)
%       taxo_vol = [depth,time,image_nb,vol....];(N cat_number)
%       taxo_grey = [depth,time,image_nb,grey....];(N cat_number)
%       time_data is in num format

time = cellfun(@(x) datetime(x,'InputFormat', 'yyyy-MM-dd HH:mm:ss'), taxo_table(:,1));
time = datenum(time);

taxo_array = cellfun(@str2num, taxo_table(:,2:end));

taxo_ab = [taxo_array(:,1) time taxo_array(:,2) taxo_array(:,3:3:end)];
taxo_vol = [taxo_array(:,1) time taxo_array(:,2) taxo_array(:,4:3:end)];
taxo_grey = [taxo_array(:,1) time taxo_array(:,2) taxo_array(:,5:3:end)];








