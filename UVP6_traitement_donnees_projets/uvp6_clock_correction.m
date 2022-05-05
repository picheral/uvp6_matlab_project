%% Correct the time of a data file and associated images
% Read the data text file from uvp6
% Correct the time of the file with an offset
% Rename all images in the folder
% 
% Save the new file to [...]_ClockCorrect.txt or replace the last data file
% camille catalano 03/2020

clear all
close all
warning('on')

disp('------------------------------------------------------')
disp('------------ uvp6 clock corrector --------------------')
disp('------------------------------------------------------')

%% input data file
disp("Selection of the data file to correct")
[data_filename, data_folder] = uigetfile('*.txt','Select the data file to correct');
disp("Selected data file : " + data_folder + data_filename)
disp('------------------------------------------------------')

%% time offset input
disp("Enter the time offset to apply (ex: 2)")
time_offset = input('Time offset (int in s)');
if ~isnumeric(time_offset) || isempty(time_offset) || time_offset == 0
    disp("Time offset is 0. There is nothing to do")
    return
end

%% read HW and ACQ lines from data file
[HWline, line, ACQline] = Uvp6ReadMetalinesFromDatafile([data_folder, data_filename]);

%% read data lines from data file
[data, meta] = Uvp6DatafileToArray([data_folder, data_filename]);
meta = split(meta, ',');

%% replace data file or create a new one
create_new_file = input('Create a new file ? (y/n)(default=n) ', 's');
if create_new_file == 'y'
    disp("creating a new file")
    new_file = [data_folder, data_filename(1:end-4), '_ClockCorrect.txt'];
    clock_correct_file = fopen(new_file,'w');
else
    disp("replacing data file")
    clock_correct_file = fopen([data_folder, data_filename],'w');
end
disp('------------------------------------------------------')


%% write HW and ACQ lines
fprintf(clock_correct_file,'%s\n',HWline);
fprintf(clock_correct_file,'%s\n',line);
fprintf(clock_correct_file,'%s\n',ACQline);

%% time correction in data file
disp("time correction...")
for line_nb = 1:size(meta,1)
    try
        data_datetime = datetime(cell2mat(meta(line_nb,1)), 'InputFormat', 'yyyyMMdd-HHmmss-SSS');
        date_format = 'yyyyMMdd-HHmmss-SSS';
    catch
        data_datetime = datetime(cell2mat(meta(line_nb,1)), 'InputFormat', 'yyyyMMdd-HHmmss');
        date_format = 'yyyyMMdd-HHmmss';
    end
    new_data_datetime = data_datetime + seconds(time_offset);
    meta(line_nb,1) = {char(new_data_datetime, date_format)};
end
    

%% write data lines in file
disp("writing new data file with corrected clock...")
meta = join(meta,',');
data_table_time_correct = join([meta,data],':');
for line_nb = 1:size(data_table_time_correct,1)
    fprintf(clock_correct_file,'%s\n',line);
    fprintf(clock_correct_file,'%s\n',string(data_table_time_correct(line_nb)));
end
fprintf(clock_correct_file,'%s\n',line);
disp("Modified file : " + fopen(clock_correct_file))
fclose(clock_correct_file);
disp('------------------------------------------------------')


%% rename all images
disp("rename all images in the directory...")
filelist = dir([data_folder, '**\*.png']);
if isempty(filelist)
    filelist = dir([data_folder, '**\*.vig']);
end
if isempty(filelist)
    disp("WARNING: No image found in the directory or subdirectories") 
else
    % test sign of time offset in order to not replace existing image
    if time_offset > 0
        for i=length(filelist):-1:1
            new_name = filelist(i).name;
            data_datetime = datetime(new_name(1:length(date_format)-2), 'InputFormat', date_format);
            new_data_datetime = data_datetime + seconds(time_offset);
            new_name(1:length(date_format)-2) = char(new_data_datetime, date_format)-2;
            movefile([filelist(i).folder, '\', filelist(i).name], [filelist(i).folder, '\', new_name]);
        end
    elseif time_offset < 0
        for i=1:length(filelist)
            new_name = filelist(i).name;
            data_datetime = datetime(new_name(1:length(date_format)), 'InputFormat', date_format);
            new_data_datetime = data_datetime + seconds(time_offset);
            new_name(1:length(date_format)) = char(new_data_datetime, date_format);
            movefile([filelist(i).folder, '\', filelist(i).name], [filelist(i).folder, '\', new_name]);
        end
    end
end
disp([num2str(length(filelist)), ' images has been renamed'])
disp('------------------------------------------------------')

