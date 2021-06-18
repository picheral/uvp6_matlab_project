function [meta_data] = ReadMetaSeaglider(filepathnc)
%ReadMetaSeaglider read the metadata in the seaglider netcdf file
%
% meta_data array is an num array (careful for <missing> values
% time, depth, longitude, latitude
% time is in num format
%
% inputs :
%   filepathnc : path/filename of nc file
%
% output :
%   meta_data : metadata array
%

time = ncread(filepathnc, 'time');
depth = ncread(filepathnc, 'depth');
try
    latitude = ncread(filepathnc, 'latitude');
    longitude = ncread(filepathnc, 'longitude');
catch
    warning(['No lat-lon in file ' filepathnc]);
    latitude = time*0;
    longitude = time*0;
end

meta_data = [time, depth, latitude, longitude];

end