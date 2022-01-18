function [park_taxo_table, ascent_taxo_table] = Uvp6ReadTaxoFromFloatTaxoCSV(taxo_csv_fullpath)
% read data (prof, time, taxo,...) from a taxo csv file from a cts5float
% data. It returns data for parking and data for ascent
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
data_raw = readmatrix(taxo_csv_fullpath, 'OutputType', 'char', 'Delimiter', ',', 'NumHeaderLines', 1);
ascent_indice = find(contains(data_raw,'[ASCENT]'));

if isempty(ascent_indice)
    park_taxo_table = [];
    ascent_taxo_table = data_raw;
else
    park_taxo_table = data_raw(1:ascent_indice-1,:);
    ascent_taxo_table = data_raw(ascent_indice+2:end, :);
end




