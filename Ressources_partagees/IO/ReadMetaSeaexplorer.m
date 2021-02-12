function [meta_data] = ReadMetaSeaexplorer(filepathgz)
%ReadMetaSeaexplorer read the metadata in the seaeplorer ccu file
%
% meta_data array is an num array (careful for <missing> values
% PLD_REALTIMECLOCK, NAV_DEPTH, NAV_LONGITUDE, NAV_LATITUDE
% PLD_REALTIMECLOCK is in num format
%
% inputs :
%   filepathgz : path/filename of gz file
%
% output :
%   meta_data : metadata array
%
filepath = gunzip(filepathgz);
meta_table = readtable(filepath{1}, 'FileType', 'text', 'Format', '%{dd/MM/uuuu HH:mm:ss.SSS}D %f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f');
meta_data = [datenum(meta_table.PLD_REALTIMECLOCK) meta_table.NAV_DEPTH meta_table.NAV_LONGITUDE meta_table.NAV_LATITUDE];
delete(filepath{1});
end