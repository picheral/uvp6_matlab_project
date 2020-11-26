function [meta_data] = ReadMetaSeaexplorer(filepathgz)
%ReadMetaSeaexplorer read the metadata in the seaeplorer ccu file
%
% meta_data array is a string array (careful for <missing> values
% PLD_REALTIMECLOCK, NAV_DEPTH, NAV_LONGITUDE, NAV_LATITUDE
%
% inputs :
%   filepathgz : path/filename of gz file
%
% output :
%   meta_data : metadata array
%
filepath = gunzip(filepathgz);
filepath = gunzip('C:\uvp6_sn000003lp_20201109_seaexplorer_002\doc\SEA002_480_20201117\ccu\logs\sea002.480.pld1.raw.2.gz');
meta_table = readtable(filepath{1}, 'FileType', 'text');
meta_data = [string(datestr(meta_table.PLD_REALTIMECLOCK, 'yyyymmdd-HHMMSS')) meta_table.NAV_DEPTH meta_table.NAV_LONGITUDE meta_table.NAV_LATITUDE];
delete(filepath{1});
end