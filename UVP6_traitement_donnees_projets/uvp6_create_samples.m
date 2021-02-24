<<<<<<< HEAD
%% Create the sample file of a project
% Create the sample file for all sequences
% the meta data are extracted from the sequence and a nav file located in
% the doc folder of the project
% 
% use Mapping Toolbox 
%
% camille catalano 11/2020

clear all
close all
warning('on')

disp('------------------------------------------------------')
disp('------------- uvp6 sample creator --------------------')
disp('------------------------------------------------------')
disp('')
disp('WARNING : Work only for seaexplorer project')
disp('')


%% inputs and its QC
% select the project
disp('Select UVP project folder ')
project_folder = uigetdir('',['Select UVP project folder']);
disp('---------------------------------------------------------------')
disp(['Project folder : ', project_folder])
disp('---------------------------------------------------------------')

% detection seaexplorer in name
if ~contains(project_folder, 'sea')
    warning('Only seaexplorer project are supported')
    error('ERROR : the project is not a seaexplorer project')
end

% detection meta in doc
meta_data_folder_type = 'SEA';
list_in_doc = dir(fullfile(project_folder, 'doc', [meta_data_folder_type '*']));
if isempty(list_in_doc)
    error('ERROR : No metadata folder found in \doc')
else
    meta_data_folder = fullfile(list_in_doc(1).folder, list_in_doc(1).name);
    % if it is not a dir, try to unzip it
    if ~list_in_doc(1).isdir
        gunzip(meta_data_folder, list_in_doc(1).folder);
        meta_data_folder = fullfile(list_in_doc(1).folder, list_in_doc(1).name(1:end-4));
    end
    disp(['Vector meta data folder : ', list_in_doc(1).name])
    seaexplorer_sn = list_in_doc(1).name(4:6);
end

% detection if sample file already exist
list_in_meta = dir(fullfile(project_folder, 'meta', '*.txt'));
if ~isempty(list_in_meta)
    warning('There is already a meta data file in \meta. IT WILL BE ERASED')
    erased_old_meta = input('Continue ? ([n]/y) ','s');
    if isempty(erased_old_meta) || erased_old_meta == 'n'
        error('ERROR : Process has been aborted')
    end
    delete(fullfile(project_folder, 'meta', '*'));
end
disp('---------------------------------------------------------------')


%% get cruise info
% seaexplorer dependant
cruise_file = fullfile(project_folder, 'config', 'cruise_info.txt');
fid = fopen(cruise_file);
tline = fgetl(fid);
tline = fgetl(fid);
cruise = tline(7:end);
fclose(fid);


%% get meta data from dat file
% list of sequences: without "UsedForMerged"
list_of_sequences = dir(fullfile(project_folder, 'raw', '20*'));
idx = cellfun('isempty',regexp({list_of_sequences.name}, 'UsedForMerge'));
list_of_sequences = list_of_sequences(idx);

% get metadata from each sequence data file
disp('Get data from all sequences...')
seq_nb_max = length(list_of_sequences);
aa_list = zeros(1, seq_nb_max);
exp_list = zeros(1, seq_nb_max);
volimage_list = zeros(1, seq_nb_max);
pixelsize_list = zeros(1, seq_nb_max);
start_idx_list = zeros(1, seq_nb_max);
end_idx_list = zeros(1, seq_nb_max);
start_time_list = zeros(1, seq_nb_max);
profile_type_list = strings(1, seq_nb_max);
for seq_nb = 1:seq_nb_max
    % get hw conf data
    seq_dat_file = fullfile(list_of_sequences(seq_nb).folder, list_of_sequences(seq_nb).name, [list_of_sequences(seq_nb).name, '_data.txt']);
    fid = fopen(seq_dat_file);
    tline = fgetl(fid);
    hw_line = strsplit(tline,{','});
    [sn,day,light,shutter,threshold,volume,gain,pixel,Aa,Exp] = Uvp6ReadMetadataFromhwline(hw_line);
    fclose(fid);
    
    % volimage;aa;exp,pixelsize
    aa_list(seq_nb) = Aa/1000000;
    exp_list(seq_nb) = Exp;
    volimage_list(seq_nb) = volume;
    pixelsize_list(seq_nb) = pixel;
    
    % read data from dat file
    T = readtable(seq_dat_file,'Filetype','text','ReadVariableNames',0,'Delimiter',':');
    data = table2array(T(:,2));
    meta = table2array(T(:,1));
    [time_data, depth_data, raw_nb, black_nb, image_status] = Uvp6ReadDataFromDattable(meta, data);
    black_nb = [depth_data time_data black_nb];
    I = isnan(black_nb(:,3));
    black_nb(I,:) = [];
    
    % detection of ascent profile
    if depth_data(end) < depth_data(1)
        profile_type = 'a';
        black_nb = flip(black_nb);
    else
        profile_type = 'd';
    end
    profile_type_list(seq_nb) = profile_type;
    
    % detection auto first image by using default method
    % test if black 1pix is all 0
    if any(black_nb(:,3))
        fisrt_black = black_nb(:,3);
    else
        first_black = black_nb(:,4);
    end
    % detection auto first image by using default method
    [Zusable] = UsableDepthLimit(black_nb(:,1), first_black);

    % datetime first image
    if isnan(Zusable)
        start_idx_list(seq_nb) = nan; % uvpapp is in python and start at index 0 for the image number
        end_idx_list(seq_nb) = nan;
        start_time_list(seq_nb) = time_data(1);
    else
        Zusable_idx = find(depth_data>=Zusable);
        start_idx_list(seq_nb) = Zusable_idx(1) - 1; % uvpapp is in python and start at index 0 for the image number
        end_idx_list(seq_nb) = Zusable_idx(end) - 1;
        start_time_list(seq_nb) = time_data(Zusable_idx(1));
    end
    
    
    disp(['Sequence ' list_of_sequences(seq_nb).name ' done.'])
end
disp('---------------------------------------------------------------')




%% get lat-lon from vector meta data
% seaeplorer dependant
% go through meta files and look for start time of sequences
% assume that sequences AND meta files are chronologicaly ordered
disp('Process the vector meta data....')
% get list of raw.gz meta files
list_of_vector_meta = dir(fullfile(meta_data_folder, 'ccu', 'logs', '*raw*'));
% reorder the list of file to have ...8,9,10,11... and not ...1,100,101,...
[~, idx] = sort( str2double( regexp( {list_of_vector_meta.name}, '\d+(?=\.gz)', 'match', 'once' )));
list_of_vector_meta = list_of_vector_meta(idx);
% prepare the for
meta_folder_ccu = list_of_vector_meta(1).folder;
lon_list = zeros(1, seq_nb_max);
lat_list = zeros(1, seq_nb_max);
yo_list = zeros(1, seq_nb_max);
% sequence number with found meta data
seq_nb = 1;

% find lat-lon with interpolation between two surfacing
% out of use since udpate of sea002 15/02/2021
% the glider makes its own interpolation
%{
for meta_nb = 1:length(list_of_vector_meta)
    % read metadata from file
    % need the file where the seq ends and the next file (for start and end
    % coordinates)
    meta_1 = ReadMetaSeaexplorer(fullfile(meta_folder_ccu, list_of_vector_meta(meta_nb).name));
    meta_2 = ReadMetaSeaexplorer(fullfile(meta_folder_ccu, list_of_vector_meta(meta_nb+1).name));
    right_meta = 1;
    % while it is a useful meta data file compared to the datetime of the
    % sequence
    while right_meta == 1 && seq_nb <= seq_nb_max
        time_to_find = start_time_list(seq_nb);
        % check that the datetime of the sequence IS in the file
        % if not, go to the next meta data file
        if (time_to_find >= meta_1(1,1)) && (time_to_find <= meta_1(end,1))
           disp(['Vector meta data for ' list_of_sequences(seq_nb).name ' found'])
           % look for the datetime of first image in the meta data file
           aa =  find(meta_1(:,1) <= time_to_find);
           lon_start = meta_1(aa(end),3);
           lat_start = meta_1(aa(end),4);
           % find the first meta data line with the same lat-lon
           aa_start_lon = find(meta_1(:,3) == lon_start);
           aa_start_lat = find(meta_1(:,4) == lat_start);
           time_start = meta_1(max(aa_start_lon(1), aa_start_lat(1)), 1);
           
           % find the last meta data line with the same lat-lon
           if (meta_1(end,3) ~= lon_start) || (meta_1(end,4) ~= lat_start)
               % in same file if latlon(end) is different:
               time_end_index = min(aa_start_lon(end), aa_start_lat(end)) + 1;
               time_end = meta_1(time_end_index, 1);
               lon_end = meta_1(time_end_index, 3);
               lat_end = meta_1(time_end_index, 4);
           else
               % in next file if latlon(end) is the same
               aa_end_lon = find(meta_2(:,3) == lon_start);
               aa_end_lat = find(meta_2(:,4) == lat_start);
               time_end_index = min(aa_end_lon(end), aa_end_lat(end)) + 1;
               time_end = meta_2(time_end_index, 1);
               lon_end = meta_2(time_end_index, 3);
               lat_end = meta_2(time_end_index, 4);
           end
           
           % interp lat and lon between start time and end time
           lon_start = ConvertLatLonSeaexplorer(lon_start);
           lat_start = ConvertLatLonSeaexplorer(lat_start);
           lon_end = ConvertLatLonSeaexplorer(lon_end);
           lat_end = ConvertLatLonSeaexplorer(lat_end);
           lon_list(seq_nb) = interp1([time_start,time_end], [lon_start, lon_end], time_to_find);
           lat_list(seq_nb) = interp1([time_start,time_end], [lat_start, lat_end], time_to_find);
           yo_list(seq_nb) = str2double(list_of_vector_meta(meta_nb).name(21:end-3));
           seq_nb = seq_nb + 1;
        else
            right_meta = 0;
        end
    end
    if seq_nb > seq_nb_max
        break
    end
end
%}

% find lat-lon directly with time first image
% assume lat-lon is interpolated by the glider
for meta_nb = 1:length(list_of_vector_meta)
    % read metadata from file
    meta = ReadMetaSeaexplorer(fullfile(meta_folder_ccu, list_of_vector_meta(meta_nb).name));
    right_meta = 1;
    % while it is a useful meta data file compared to the datetime of the
    % sequence
    while right_meta == 1 && seq_nb <= seq_nb_max
        time_to_find = start_time_list(seq_nb);
        % check that the datetime of the sequence IS in the file
        % if not, go to the next meta data file
        if (time_to_find >= meta(1,1)) && (time_to_find <= meta(end,1))
           aa =  find(meta(:,1) <= time_to_find);
           disp(['Vector meta data for ' list_of_sequences(seq_nb).name ' found'])
           lon_list(seq_nb) = ConvertLatLonSeaexplorer(meta(aa(end), 3));
           lat_list(seq_nb) = ConvertLatLonSeaexplorer(meta(aa(end), 4));
           yo_list(seq_nb) = str2double(list_of_vector_meta(meta_nb).name(21:end-3));
           seq_nb = seq_nb + 1;
        else
            right_meta = 0;
        end
    end
    if seq_nb > seq_nb_max
        break
    end
end
disp('---------------------------------------------------------------')


%% sample file writing
disp('Creating the sample file...')
% file creation
samples_filename = regexp(project_folder, filesep, 'split');
samples_filename = [samples_filename{1,end}(1:5) 'header' samples_filename{1,end}(5:end)];
sample_filename = fullfile(project_folder, 'meta', [samples_filename, '.txt']);
sample_file = fopen(sample_filename,'w');
    
% add header
line = ['cruise;ship;filename;profileid;'...
    'bottomdepth;ctdrosettefilename;latitude;longitude;'...
    'firstimage;volimage;aa;exp;'...
    'dn;winddir;windspeed;seastate;'...
    'nebuloussness;comment;endimg;yoyo;'...
    'stationid;sampletype;integrationtime;argoid;'...
    'pixelsize;sampledatetime'];
fprintf(sample_file,'%s\n',line);

% write samples lines
% one sample by sequence
for seq_nb = 1:seq_nb_max
    % lat format
    lat_deg = fix(lat_list(seq_nb));
    lat_min = fix(rem(lat_list(seq_nb),1)*60);
    lat_sec = rem(rem(lat_list(seq_nb),1)*60,1)*60;
    lat = [num2str(lat_deg) '°' num2str(lat_min) ' ' num2str(lat_sec, '%02.f')];
    % lon format
    lon_deg = fix(lon_list(seq_nb));
    lon_min = fix(rem(lon_list(seq_nb),1)*60);
    lon_sec = rem(rem(lon_list(seq_nb),1)*60,1)*60;
    lon = [num2str(lon_deg) '°' num2str(lon_min) ' ' num2str(lon_sec, '%02.f')];
    % line to write
    seq_line = [cruise ';' ['Seaeplorer_' seaexplorer_sn] ';' list_of_sequences(seq_nb).name ';' ['Yo_' num2str(yo_list(seq_nb)) char(profile_type_list(seq_nb))] ';'...
        '' ';' num2str(yo_list(seq_nb)) ';' lat ';' lon ';'...
        num2str(start_idx_list(seq_nb)) ';' num2str(volimage_list(seq_nb)) ';' num2str(aa_list(seq_nb)) ';' num2str(exp_list(seq_nb)) ';'...
        '' ';' '' ';' '' ';' '' ';'...
        '' ';' '' ';' num2str(end_idx_list(seq_nb)) ';' '' ';' ...
        ['Yo_' num2str(yo_list(seq_nb)) char(profile_type_list(seq_nb))] ';' 'P' ';' '' ';' '' ';'...
        num2str(pixelsize_list(seq_nb)) ';' datestr(start_time_list(seq_nb), 'yyyymmdd-HHMMss')];
    fprintf(sample_file, '%s\n', seq_line);
end
fclose(sample_file);
disp(['Sample file created : ' sample_filename])
disp('------------------------------------------------------')
disp('end of process')
disp('------------------------------------------------------')

=======
%% Create the sample file of a project
% Create the sample file for all sequences
% the meta data are extracted from the sequence and a nav file located in
% the doc folder of the project
% 
% use Mapping Toolbox 
%
% camille catalano 11/2020

clear all
close all
warning('on')

disp('------------------------------------------------------')
disp('------------- uvp6 sample creator --------------------')
disp('------------------------------------------------------')
disp('')
disp('WARNING : Work only for seaexplorer project')
disp('')


%% inputs and its QC
% select the project
disp('Select UVP project folder ')
project_folder = uigetdir('',['Select UVP project folder']);
disp('---------------------------------------------------------------')
disp(['Project folder : ', project_folder])
disp('---------------------------------------------------------------')

% detection seaexplorer in name
if ~contains(project_folder, 'seaexplorer')
    warning('Only seaexplorer project are supported')
    error('ERROR : the project is not a seaexplorer project')
end

% detection meta in doc
meta_data_folder_type = 'SEA';
list_in_doc = dir(fullfile(project_folder, 'doc', [meta_data_folder_type '*']));
if isempty(list_in_doc)
    error('ERROR : No metadata folder found in \doc')
else
    meta_data_folder = fullfile(list_in_doc(1).folder, list_in_doc(1).name);
    % if it is not a dir, try to unzip it
    if ~list_in_doc(1).isdir
        gunzip(meta_data_folder, list_in_doc(1).folder);
        meta_data_folder = fullfile(list_in_doc(1).folder, list_in_doc(1).name(1:end-4));
    end
    disp(['Vector meta data folder : ', list_in_doc(1).name])
    seaexplorer_sn = list_in_doc(1).name(4:6);
end

% detection if sample file already exist
list_in_meta = dir(fullfile(project_folder, 'meta', '*.txt'));
if ~isempty(list_in_meta)
    warning('There is already a meta data file in \meta. IT WILL BE ERASED')
    erased_old_meta = input('Continue ? ([n]/y) ','s');
    if isempty(erased_old_meta) || erased_old_meta == 'n'
        error('ERROR : Process has been aborted')
    end
    delete(fullfile(project_folder, 'meta', '*'));
end
disp('---------------------------------------------------------------')


%% get cruise info
% seaexplorer dependant
cruise_file = fullfile(project_folder, 'config', 'cruise_info.txt');
fid = fopen(cruise_file);
tline = fgetl(fid);
tline = fgetl(fid);
cruise = tline(7:end);
fclose(fid);


%% get meta data from dat file
% list of sequences: without "UsedForMerged"
list_of_sequences = dir(fullfile(project_folder, 'raw', '20*'));
idx = cellfun('isempty',regexp({list_of_sequences.name}, 'UsedForMerge'));
list_of_sequences = list_of_sequences(idx);

% get metadata from each sequence data file
disp('Get data from all sequences...')
seq_nb_max = length(list_of_sequences);
aa_list = zeros(1, seq_nb_max);
exp_list = zeros(1, seq_nb_max);
volimage_list = zeros(1, seq_nb_max);
pixelsize_list = zeros(1, seq_nb_max);
start_idx_list = zeros(1, seq_nb_max);
end_idx_list = zeros(1, seq_nb_max);
start_time_list = zeros(1, seq_nb_max);
profile_type_list = strings(1, seq_nb_max);
for seq_nb = 1:seq_nb_max
    % get hw conf data
    seq_dat_file = fullfile(list_of_sequences(seq_nb).folder, list_of_sequences(seq_nb).name, [list_of_sequences(seq_nb).name, '_data.txt']);
    fid = fopen(seq_dat_file);
    tline = fgetl(fid);
    hw_line = strsplit(tline,{','});
    [sn,day,light,shutter,threshold,volume,gain,pixel,Aa,Exp] = Uvp6ReadMetadataFromhwline(hw_line);
    fclose(fid);
    
    % volimage;aa;exp,pixelsize
    aa_list(seq_nb) = Aa/1000000;
    exp_list(seq_nb) = Exp;
    volimage_list(seq_nb) = volume;
    pixelsize_list(seq_nb) = pixel;
    
    % read data from dat file
    T = readtable(seq_dat_file,'Filetype','text','ReadVariableNames',0,'Delimiter',':');
    data = table2array(T(:,2));
    meta = table2array(T(:,1));
    [time_data, depth_data, raw_nb, black_nb, image_status] = Uvp6ReadDataFromDattable(meta, data);
    black_nb = [depth_data time_data black_nb];
    I = isnan(black_nb(:,3));
    black_nb(I,:) = [];
    
    % detection of ascent profile
    if depth_data(end) < depth_data(1)
        profile_type = 'a';
        black_nb = flip(black_nb);
    else
        profile_type = 'd';
    end
    profile_type_list(seq_nb) = profile_type;
    
    % detection auto first image by using default method
    % test if black 1pix is all 0
    if any(black_nb(:,3))
        fisrt_black = black_nb(:,3);
    else
        first_black = black_nb(:,4);
    end
    % detection auto first image by using default method
    [Zusable] = UsableDepthLimit(black_nb(:,1), first_black);

    % datetime first image
    if isnan(Zusable)
        start_idx_list(seq_nb) = nan; % uvpapp is in python and start at index 0 for the image number
        end_idx_list(seq_nb) = nan;
        start_time_list(seq_nb) = time_data(1);
    else
        Zusable_idx = find(depth_data>=Zusable);
        start_idx_list(seq_nb) = Zusable_idx(1) - 1; % uvpapp is in python and start at index 0 for the image number
        end_idx_list(seq_nb) = Zusable_idx(end) - 1;
        start_time_list(seq_nb) = time_data(Zusable_idx(1));
    end
    
    
    disp(['Sequence ' list_of_sequences(seq_nb).name ' done.'])
end
disp('---------------------------------------------------------------')




%% get lat-lon from vector meta data
% seaeplorer dependant
% go through meta files and look for start time of sequences
% assume that sequences AND meta files are chronologicaly ordered
disp('Process the vector meta data....')
% get list of raw.gz meta files
list_of_vector_meta = dir(fullfile(meta_data_folder, 'ccu', 'logs', '*raw*'));
% reorder the list of file to have ...8,9,10,11... and not ...1,100,101,...
[~, idx] = sort( str2double( regexp( {list_of_vector_meta.name}, '\d+(?=\.gz)', 'match', 'once' )));
list_of_vector_meta = list_of_vector_meta(idx);
% prepare the for
meta_folder_ccu = list_of_vector_meta(1).folder;
lon_list = zeros(1, seq_nb_max);
lat_list = zeros(1, seq_nb_max);
yo_list = zeros(1, seq_nb_max);
% sequence number with found meta data
seq_nb = 1;
for meta_nb = 1:length(list_of_vector_meta)
    % read metadata from file
    % need the file where the seq ends and the next file (for start and end
    % coordinates)
    meta_1 = ReadMetaSeaexplorer(fullfile(meta_folder_ccu, list_of_vector_meta(meta_nb).name));
    meta_2 = ReadMetaSeaexplorer(fullfile(meta_folder_ccu, list_of_vector_meta(meta_nb+1).name));
    right_meta = 1;
    % while it is a useful meta data file compared to the datetime of the
    % sequence
    while right_meta == 1 && seq_nb <= seq_nb_max
        time_to_find = start_time_list(seq_nb);
        % check that the datetime of the sequence IS in the file
        % if not, go to the next meta data file
        if (time_to_find >= meta_1(1,1)) && (time_to_find <= meta_1(end,1))
           disp(['Vector meta data for ' list_of_sequences(seq_nb).name ' found'])
           % look for the datetime of first image in the meta data file
           aa =  find(meta_1(:,1) <= time_to_find);
           lon_start = meta_1(aa(end),3);
           lat_start = meta_1(aa(end),4);
           % find the first meta data line with the same lat-lon
           aa_start_lon = find(meta_1(:,3) == lon_start);
           aa_start_lat = find(meta_1(:,4) == lat_start);
           time_start = meta_1(max(aa_start_lon(1), aa_start_lat(1)), 1);
           
           % find the last meta data line with the same lat-lon
           if (meta_1(end,3) ~= lon_start) && (meta_1(end,4) ~= lat_start)
               % in same file if latlon(end) is different:
               time_end_index = min(aa_start_lon(end), aa_start_lat(end)) + 1;
               time_end = meta_1(time_end_index, 1);
               lon_end = meta_1(time_end_index, 3);
               lat_end = meta_1(time_end_index, 4);
           else
               % in next file if latlon(end) is the same
               aa_end_lon = find(meta_2(:,3) == lon_start);
               aa_end_lat = find(meta_2(:,4) == lat_start);
               time_end_index = min(aa_end_lon(end), aa_end_lat(end)) + 1;
               time_end = meta_2(time_end_index, 1);
               lon_end = meta_2(time_end_index, 3);
               lat_end = meta_2(time_end_index, 4);
           end
           
           % interp lat and lon between start time and end time
           lon_start = ConvertLatLonSeaexplorer(lon_start);
           lat_start = ConvertLatLonSeaexplorer(lat_start);
           lon_end = ConvertLatLonSeaexplorer(lon_end);
           lat_end = ConvertLatLonSeaexplorer(lat_end);
           lon_list(seq_nb) = interp1([time_start,time_end], [lon_start, lon_end], time_to_find);
           lat_list(seq_nb) = interp1([time_start,time_end], [lat_start, lat_end], time_to_find);
           yo_list(seq_nb) = str2double(list_of_vector_meta(meta_nb).name(21:end-3));
           seq_nb = seq_nb + 1;
        else
            right_meta = 0;
        end
    end
    if seq_nb > seq_nb_max
        break
    end
end
disp('---------------------------------------------------------------')


%% sample file writing
disp('Creating the sample file...')
% file creation
samples_filename = regexp(project_folder, filesep, 'split');
samples_filename = [samples_filename{1,end}(1:5) 'header' samples_filename{1,end}(5:end)];
sample_filename = fullfile(project_folder, 'meta', [samples_filename, '.txt']);
sample_file = fopen(sample_filename,'w');
    
% add header
line = ['cruise;ship;filename;profileid;'...
    'bottomdepth;ctdrosettefilename;latitude;longitude;'...
    'firstimage;volimage;aa;exp;'...
    'dn;winddir;windspeed;seastate;'...
    'nebuloussness;comment;endimg;yoyo;'...
    'stationid;sampletype;integrationtime;argoid;'...
    'pixelsize;sampledatetime'];
fprintf(sample_file,'%s\n',line);

% write samples lines
% one sample by sequence
for seq_nb = 1:seq_nb_max
    % lat format
    lat_deg = fix(lat_list(seq_nb));
    lat_min = fix(rem(lat_list(seq_nb),1)*60);
    lat_sec = rem(rem(lat_list(seq_nb),1)*60,1)*60;
    lat = [num2str(lat_deg) '°' num2str(lat_min) ' ' num2str(lat_sec, '%02.f')];
    % lon format
    lon_deg = fix(lon_list(seq_nb));
    lon_min = fix(rem(lon_list(seq_nb),1)*60);
    lon_sec = rem(rem(lon_list(seq_nb),1)*60,1)*60;
    lon = [num2str(lon_deg) '°' num2str(lon_min) ' ' num2str(lon_sec, '%02.f')];
    % line to write
    seq_line = [cruise ';' ['Seaeplorer_' seaexplorer_sn] ';' list_of_sequences(seq_nb).name ';' ['Yo_' num2str(yo_list(seq_nb)) char(profile_type_list(seq_nb))] ';'...
        '' ';' num2str(yo_list(seq_nb)) ';' lat ';' lon ';'...
        num2str(start_idx_list(seq_nb)) ';' num2str(volimage_list(seq_nb)) ';' num2str(aa_list(seq_nb)) ';' num2str(exp_list(seq_nb)) ';'...
        '' ';' '' ';' '' ';' '' ';'...
        '' ';' '' ';' num2str(end_idx_list(seq_nb)) ';' '' ';' ...
        ['Yo_' num2str(yo_list(seq_nb)) char(profile_type_list(seq_nb))] ';' 'P' ';' '' ';' '' ';'...
        num2str(pixelsize_list(seq_nb)) ';' datestr(start_time_list(seq_nb), 'yyyymmdd-HHMMss')];
    fprintf(sample_file, '%s\n', seq_line);
end
fclose(sample_file);
disp(['Sample file created : ' sample_filename])
disp('------------------------------------------------------')
disp('end of process')
disp('------------------------------------------------------')

>>>>>>> 73dee85645716d5876b5f91c4ff3ead3abd6867e
