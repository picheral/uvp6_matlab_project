%% Change the metaline format of a data.txt from 2022 to old one
% Save the data.txt to [...]_2022format.txt
% Read the data text file from uvp6
% Change the hwconf line and the acq line :
% add parameters to fit the old format
% Save new file
%
% WARNING : does not work with taxo
%
% camille catalano 05/2022

clear all
close all
warning('on')

disp('------------------------------------------------------')
disp('---------- uvp6 data.txt downgrader  -----------------')
disp('------------------------------------------------------')

%% input data file
disp("Selection of the data file to downgrade")
[data_filename, data_folder] = uigetfile('*.txt','Select the data file to downgrade');
disp("Selected data file : " + data_folder + data_filename)
disp('------------------------------------------------------')


%% read HW and ACQ lines from data file
[HWline, line, ACQline, ~] = Uvp6ReadMetalinesFromDatafile([data_folder, data_filename]);

%% read data lines from data file
[data, meta] = Uvp6DatafileToArray([data_folder, data_filename]);

%% Save old file and create new one
disp('Save old file and create new one')
rename = fullfile(data_folder, [data_filename(1:end-4) '_2022format.txt']);
[~] = movefile(fullfile(data_folder, data_filename), rename, 'f');
old_standard_file = fopen(fullfile(data_folder, data_filename), 'w');
disp('------------------------------------------------------')

%% Compute new hwline and new acqline
disp('Computing new meta lines')
HWline = split(HWline, ',');
new_HWline = {HWline{1:7} '0' HWline{8:13} '193.49.112.100' HWline{14:end}}';
new_HWline = join(new_HWline, ',');
ACQline = split(ACQline, ',');
new_ACQline = {ACQline{1:5} '1' ACQline{6:9} '10' ACQline{10:16} '0' ACQline{17:end}}';
new_ACQline = join(new_ACQline, ',');
disp('------------------------------------------------------')


%% write HW and ACQ lines
disp('writing new file')
fprintf(old_standard_file,'%s\n',string(new_HWline));
fprintf(old_standard_file,'%s\n',line);
fprintf(old_standard_file,'%s\n',string(new_ACQline));

    

%% write data lines in file
data_table = join([meta,data],':');
for line_nb = 1:size(data_table,1)
    fprintf(old_standard_file,'%s\n',line);
    fprintf(old_standard_file,'%s\n',string(data_table(line_nb)));
end
fprintf(old_standard_file,'%s\n',line);
disp("Modified file with old standard : " + fullfile(data_folder, data_filename))
disp("Old file with 2022 standard : " + rename)
fclose(old_standard_file);
disp('------------------------------------------------------')


disp('end of process')
disp('------------------------------------------------------')