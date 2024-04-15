function [pathCTDfile] = CreateCTDfloatfileFromCSV(project_folder, CSVfilename, sample_name)
%CreateCTDfloatfileFromCSV Write a CTD file in the CTD folder of a project
% from the float CTD csv file
%
% Float CTD csv file must be placed into the doc folder of the project
%
%
% inputs :
%   project_folder : full path of the project
%   CSVfilename : filename of the CSV file
%   sample_name : name of the sample to make the file name
%
% output :
%   pathCTDfile : full path to the new CTD file(s)
%

%% creation of the ctd table
column_names = {'chloro fluo [mg chl m-3]', 'conductivity [ms cm-1]',...
    'cpar [%]' ,'depth [m]' ,'fcdom [ppb qse]' ,...
    'in situ density anomaly [kg m-3]' ,'nitrate [umol l-1]',...
    'oxygen [umol kg-1]', 'oxygen [ml l-1]', 'par [umol m-2 s-1]',...
    'potential density anomaly [kg m-3]', 'potential temperature [degc]',...
    'practical salinity [psu]', 'pressure [db]', 'qc flag',...
    'spar [umol m-2 s-1]', 'temperature [degc]', 'time [yyyymmddhhmmssmmm]'};

pathCSVfile = fullfile(project_folder, 'doc', CSVfilename);

ctd_data = readtable(pathCSVfile, 'Delimiter', ',');

ctd_table = array2table(NaN(height(ctd_data), length(column_names)));
ctd_table.Properties.VariableNames = column_names;

time = datetime(ctd_data.Var1, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
ctd_table.("time [yyyymmddhhmmssmmm]") = datestr(time, 'yyyymmddHHMMSSFFF');

ctd_table.("pressure [db]") = ctd_data.Var2;
ctd_table.("temperature [degc]") = ctd_data.Var3;
ctd_table.("practical salinity [psu]") = ctd_data.Var4;

%delete empty rows ((AW), RW, etc...)
toDelete = isnan(ctd_table.("pressure [db]"));
ctd_table(toDelete,:) = [];

%% write ctd file
pathfilename = fullfile(project_folder, 'CTDdata', sample_name);
% write in Latin1
feature('DefaultCharacterSet', 'Latin1');
writetable(ctd_table, pathfilename, 'Delimiter', 'tab');
feature('DefaultCharacterSet', 'UTF8');
% renaming
pathCTDfile = strcat(char(pathfilename), ".ctd");
movefile([pathfilename, '.txt'], pathCTDfile);


end