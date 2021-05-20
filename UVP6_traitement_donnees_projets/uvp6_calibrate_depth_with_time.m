%% Calibrate the depth in data file with time
% Read the data text file from uvp6 and a time reference data file
% Replacing depth non-information in uvp6 data file by depth from time
% uvp6 reference data file, based on the data time.
% 
% If the time is not present: linear interpolation and extrapolation
% 
% Save the new file to [...]_with_depth.txt or replace the last data file
% camille catalano 01/2020

clear all
close all
warning('on')

disp('------------------------------------------------------')
disp('--------- uvp6 timed depth calibrator ----------------')
disp('------------------------------------------------------')

%% input data file
disp("Selection of the data file to calibrate")
[data_filename, data_folder] = uigetfile('*.txt','Select the data file to calibrate');
disp("Selected data file : " + data_folder + data_filename)
data_file = fopen([data_folder, data_filename]);
disp('------------------------------------------------------')

%% input reference file
disp("Selection of the reference data file")
[ref_filename, ref_folder] = uigetfile('*.txt','Select the reference data file');
disp("Selected reference file : " + ref_folder + ref_filename)
disp('------------------------------------------------------')

%% read HW and ACQ lines from data file
HWline = fgetl(data_file);
line = fgetl(data_file);
ACQline = fgetl(data_file);
fclose(data_file);

%% read data lines from data file
data_table = readtable([data_folder, data_filename],'Filetype','text','ReadVariableNames',0,'Delimiter',':');
data = table2array(data_table(:,2));
meta = table2array(data_table(:,1));
meta = split(meta, ',');

%% read data lines from ref file
ref_table = readtable([ref_folder, ref_filename],'Filetype','text','ReadVariableNames',0,'Delimiter',':');
ref_data = table2array(ref_table(:,2));
ref_meta = table2array(ref_table(:,1));
ref_meta = split(ref_meta, ',');
ref_date_time = cell2mat(ref_meta(:,1));
ref_datetime = datetime(ref_date_time(:,1:15), 'InputFormat', 'yyyyMMdd-HHmmss');
ref_depth = str2double(ref_meta(:,2));

%% replace data file or create a new one
create_new_file = input('Create a new file ? (y/n)(default=n) ', 's');
if create_new_file == 'y'
    disp("creating a new file")
    new_file = [data_folder, data_filename(1:end-4), '_WithDepth.txt'];
    WithDepth_file = fopen(new_file,'w');
else
    disp("replacing data file")
    WithDepth_file = fopen([data_folder, data_filename],'w');
end
disp('------------------------------------------------------')

%% write HW and ACQ lines
fprintf(WithDepth_file,'%s\n',HWline);
fprintf(WithDepth_file,'%s\n',line);
fprintf(WithDepth_file,'%s\n',ACQline);

%% find ref depth for each data time
disp("looking for depth information...")
for line_nb = 1:size(meta,1)
    date_time = cell2mat(meta(line_nb,1));
    data_datetime = datetime(date_time(1:15), 'InputFormat', 'yyyyMMdd-HHmmss');
    % interpolation and extrapolation of depth based on date time
    [ref_datetime_unique, unique_index] = unique(ref_datetime);
    depth = interp1(ref_datetime_unique, ref_depth(unique_index), data_datetime, 'linear','extrap');
    % test if extrapoltation gave negative depth
    if depth<0
        warning("Depth extrapolation gave a negative value")
    end
    meta(line_nb,2) = {num2str(depth)};
end
    

%% write data lines in file
disp("writing new data file with depth...")
meta = join(meta,',');
data_table_with_depth = join([meta,data],':');
for line_nb = 1:size(data_table_with_depth,1)
    fprintf(WithDepth_file,'%s\n',line);
    fprintf(WithDepth_file,'%s\n',string(data_table_with_depth(line_nb)));
end
fprintf(WithDepth_file,'%s\n',line);
disp("Modified file : " + fopen(WithDepth_file))
fclose(WithDepth_file);
disp('------------------------------------------------------')



