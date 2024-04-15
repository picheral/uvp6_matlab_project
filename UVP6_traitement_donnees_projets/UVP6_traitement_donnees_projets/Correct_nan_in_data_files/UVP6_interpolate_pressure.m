%% Interpolation of missing pressure values in data.txt files
% Picheral, 2021/11/13
% Correctes files impacted by a default of the pressure sensor
% The pressure is interpolated beetween existing data

clear all
close all
warning('on')

disp('------------------------------------------------------')
disp('--------- uvp6 interpolation of pressure -------------')
disp('------------------------------------------------------')


%% input data file
disp("Selection of the data file to calibrate")
[data_filename, data_folder] = uigetfile('*.txt','Select the data file to calibrate');
disp("Selected data file : " + data_folder + data_filename)
disp('------------------------------------------------------')
cd(data_folder);

%% Sauvegarde du fichier original
backup_data_filename = ['backup_',data_filename];
eval(['copyfile ' data_filename ' ' backup_data_filename]);

%% read HW and ACQ lines from data file
[HWline, line, ACQline, Taxoline] = Uvp6ReadMetalinesFromDatafile([data_folder, data_filename]);

%% read data lines from data file
[data, meta, taxo] = Uvp6DatafileToArray([data_folder, data_filename]);
meta = split(meta, ',');

%% read data lines from ref file
data_table = readtable([data_folder, data_filename],'Filetype','text','ReadVariableNames',0,'Delimiter',':');
data_data = table2array(data_table(:,2));
data_meta = table2array(data_table(:,1));
data_meta = split(data_meta, ',');
data_date_time = cell2mat(data_meta(:,1));
try
    data_datetime = datetime(data_date_time(:,1:19), 'InputFormat', 'yyyyMMdd-HHmmss-SSS');
    date_format = 'yyyyMMdd-HHmmss-SSS';
catch
    data_datetime = datetime(data_date_time(:,1:15), 'InputFormat', 'yyyyMMdd-HHmmss');
    date_format = 'yyyyMMdd-HHmmss';
end
data_depth = str2double(data_meta(:,2));

%% Interpolation
aa = isnan(data_depth);
% interp_data_depth = interp1(data_datetime(aa),data_depth(aa),data_datetime);
interp_data_depth = fillmissing(data_depth,'linear','SamplePoints',data_datetime);

%% Figure
fig1 = figure('numbertitle','off','name',data_filename,'Position',[10 50 500 500]);

% Interpolated
plot(data_datetime,-data_depth,'b.')
hold on
plot(data_datetime(aa),-interp_data_depth(aa),'r.')
titre = data_filename;
titre = replace(titre,'_',' ');
title(titre);

% Enregistrement figure
print(fig1,data_filename(1:end-4),'-dpng')

%% Enregistrement du fichier data.txt
disp("replacing data file")
CompletedWithDepth_file = fopen([data_folder, data_filename],'w');
% write HW and ACQ lines
fprintf(CompletedWithDepth_file,'%s\n',HWline);
fprintf(CompletedWithDepth_file,'%s\n',line);
fprintf(CompletedWithDepth_file,'%s\n',ACQline);

% add new depth
for line_nb = 1:size(meta,1)
    meta(line_nb,2) = {num2str(interp_data_depth(line_nb))};
end

meta = join(meta,',');
data_table_with_depth = join([meta,data],':');
for line_nb = 1:size(data_table_with_depth,1)
    fprintf(CompletedWithDepth_file,'%s\n',line);
    fprintf(CompletedWithDepth_file,'%s\n',string(data_table_with_depth(line_nb)));
end
fprintf(CompletedWithDepth_file,'%s\n',line);
disp("Modified file : " + fopen(CompletedWithDepth_file))
fclose(CompletedWithDepth_file);
fclose('all');
disp('------------------------------------------------------')

%% Fin

