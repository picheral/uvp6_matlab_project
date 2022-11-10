function [meta_data] = ReadMetaFloat(filepathnc)
%ReadMetaFloat read the metadata in the float netcdf file
%
% meta_data array is an num array (careful for <missing> values
% time, depth*0, latitude, longitude
% time is in num format
%
% inputs :
%   filepathnc : path/filename of nc file
%
% output :
%   meta_data : metadata array
%

depth = ncread(filepathnc, 'PRES_ADJUSTED');

time = ncread(filepathnc, 'JULD');
t0 = datenum('1950-01-01T00:00:00', 'yyyy-mm-ddTHH:MM:SS');
time = t0 + time;

latitude = ncread(filepathnc, 'LATITUDE');
longitude = ncread(filepathnc, 'LONGITUDE');

time = depth*0 + time;
time(end) = time(end) + 30/60/24;
latitude = depth*0 + latitude;
longitude = depth*0 + longitude;

meta_data = [time, depth, latitude, longitude];

end