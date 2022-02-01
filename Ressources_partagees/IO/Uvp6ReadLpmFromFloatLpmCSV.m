function [park_lpm_table, ascent_lpm_table, surface_lpm_table] = Uvp6ReadLpmFromFloatLpmCSV(lpm_csv_fullpath)
% read data (prof, time, lpm,...) from a lpm csv file from a cts5float
% data. It returns data for parking, data for ascent and data for surface
% Catalano 2021
%
% time_data is in num format
%
%
%   input:
%       taxo_csv_fullpath : fullpath to the taxo csv file
%   outputs:
%       park_taxo_table : [depth, time, ab,... size,.... grey] (50 cat)
%       ascent_taxo_table : [depth, time, ab,... size,.... grey] (50 cat)
%
%

%% read data
data_raw = readmatrix(lpm_csv_fullpath, 'OutputType', 'char', 'Delimiter', ',', 'NumHeaderLines', 1);
ascent_indice = find(contains(data_raw,'[ASCENT]'));
surface_indice = find(contains(data_raw,'(RW)'));

if isempty(ascent_indice)
    park_lpm_table = [];
    ascent_i_1 = 1;
else
    park_lpm_table = data_raw(1:ascent_indice-1,:);
    ascent_i_1 = ascent_indice + 2;
end
if isempty(surface_indice)
    ascent_i_2 = length(data_raw);
    surface_lpm_table = [];
else
    ascent_i_2 = surface_indice - 1;
    surface_lpm_table = data_raw(surface_indice+1:end, :);
end
    
ascent_lpm_table = data_raw(ascent_i_1:ascent_i_2, :);

end


