function [blk_ab] = Uvp6BuildBlackArrayFromFloatBlk(blk_table)
% Convert float black data in num arrays
% Catalano 2022
%
% blk must be cell array with each cell is a line
% Issued from Uvp6ReadLpmFromFloatLpmTaxoCSV function
%
%
%   input:
%       blk_table : blk data cell array (time, pressure, image_nb, temp,
%       ab,...)
%
%   outputs:
%       blk_ab = [depth,time,image_nb,ab....];(N cat_number)
%       time_data is in num format

time = cellfun(@(x) datetime(x,'InputFormat', 'yyyy-MM-dd HH:mm:ss'), blk_table(:,1));
time = datenum(time);

blk_array = cellfun(@str2num, blk_table(:,2:end));

class_number = 5;
blk_ab = [blk_array(:,1) time blk_array(:,2) blk_array(:,3) blk_array(:,4:class_number+3)];

end








