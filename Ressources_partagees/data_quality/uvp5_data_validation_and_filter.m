%% script to manually validate uvp5 sequence and filter bad data points
% Catalano, 03/03/2020
clear all
disp('--------------------------------------------------------------------------------')
disp('--------------------------------------------------------------------------------')
disp('---- Welcome to the uvp5 sequence validation and data points filter program ----')
disp('--------------------------------------------------------------------------------')
disp('your personnal stats doing this task will not be used by some secret laboratory for a creepy human experiment, trust me')
disp('--------------------------------------------------------------------------------')
disp('--------------------------------------------------------------------------------')
disp('Select PROJECT folder ')
folder = uigetdir('', 'Select PROJECT Folder ');
filelist = dir([folder, '\results\*_datfile.txt']);
%disk = upper(input('Enter the disk to analyse (ex: U) ', 's'));
%filelist = dir([disk, ':\uvp5_sn203_intercalibrage_20160510\results\*_datfile.txt']);
% data_validation_filtering is the matrix saving validation for each file
% validation = y if OK, =n if NOK
data_validation_filtering = cell(length(filelist),5);
%% loop on files
for i = 1:length(filelist)
    %% load data from files
    dat_pathname = fullfile(filelist(i).folder,filelist(i).name);
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
    disp(['Analysing   ', dat_pathname])
    try
        T = readtable(dat_pathname,'Filetype','text','ReadVariableNames',0,'Delimiter',';');
    catch
        warning(['unable to analyse file ', dat_pathname]);
        data_validation_filtering(i,:) = {dat_pathname, datestr(now), 'n', 0, 0};
    end   
    %% creation listecor
    Pressure = table2array(T(:,3));
    Flag = ones(size(Pressure));
    Imagelist  = table2array(T(:,1));
    Part = table2array(T(:,15)); 
    listecor = [ Imagelist Pressure/10 Flag Part ];
    % path
    aa = split(dat_pathname,'\');
    results_dir = [char(aa(1)),'\',char(aa(2)),'\',char(aa(3)),'\'];
    profilename = char(aa(end));
    profilename = profilename(1:end-4);
    %     %% take images under 10m depth, unless there is no depth
    %     disp('depth filter : 10m')
    %     T_deep = T(T{:,3}>100, :);
    %     if isempty(T_deep)
    %         T_util = T;
    %     else
    %         T_util = T_deep;
    %     end
    %
    %% data validation
    disp('------------------------------------------------')
    disp('Validation of the data...')
    %     validation = DataValidation(T{:,1}, T{:,15}, T_util{:,1}, T_util{:,15}, dat_pathname);
    validation = DataValidation(listecor, results_dir, profilename);
    %% filtering of bad data points
    if validation == 'n'
        % filtering
        disp('------------------------------------------------')
        disp('Filtering of bad data points FROM THE ENTIRE DATFILE')
        %         [im_filtered, part_filtered, movmean_window, threshold_percent] = DataFiltering(T{:,1}, T{:,15}, T_util{:,1}, T_util{:,15}, dat_pathname);    
        [im_filtered, part_util_filtered_rejected, movmean_window, threshold_percent] = DataFiltering(listecor, results_dir, profilename,'m');
        disp(['Movmean_window = ', num2str(movmean_window)])
        disp(['Threshold_percent = ', num2str(threshold_percent*100)])
        disp(['Total of images from 1st and zmax = ',num2str(size(listecor,1))])
        dd = find(listecor(:,3) == 1);
        disp(['Total of descent images = ',num2str(numel(dd))])
        disp(['Total number of un-rejected images = ',num2str(numel(im_filtered))])
        disp(['Number of rejected images = ',num2str(numel(part_util_filtered_rejected))])
        disp(['Percentage of un-rejected images = ',num2str((100*(numel(dd)-numel(part_util_filtered_rejected))/numel(listecor(:,1))),3)])
        disp(['Percentage of rejected images = ',num2str(100*numel(part_util_filtered_rejected)/numel(listecor(:,1)),3)]);
        % disp(['movmean_window = ', num2str(movmean_window)])
        %         disp(['threshold_percent = ', num2str(threshold_percent*100)])
        %         disp([height(T) - length(part_filtered), ' points has been rejected'])
        % save new dat file
        %         disp('filtered data file in')
        % save params
        data_validation_filtering(i,:) = {dat_pathname, datestr(now), validation, movmean_window, threshold_percent};
        %% -------------- Ecriture d'un DATFILE filtre des images retirées ------------------
        write_filtered_datfile(dat_pathname,[results_dir, profilename,'_filtered.txt'],im_filtered,image);     
    else
        disp('------------------------------------------------')
        disp('Data are good. NO data filter has been applied')
        data_validation_filtering(i,:) = {dat_pathname, datestr(now), validation, 0, 0};
    end
    clf;
end
close;

%% save/update sumary file
disp('--------------------------------------------------------------------------------')
data_validation_filtering_file = [results_dir,'data_validation.csv'];
if isfile(data_validation_filtering_file)
    %% update summary file
    updated_data_validation_filtering = table2cell(readtable(data_validation_filtering_file));
    for i=1:length(data_validation_filtering)
        % look for already present data
        already_present_data = find(strcmp(updated_data_validation_filtering(:,1), data_validation_filtering(i,1)));
        if isempty(already_present_data)
            % if no already present data, add to the end
            updated_data_validation_filtering(end+1,:) = data_validation_filtering(i,:);
        else
            % if already present data, replace
            updated_data_validation_filtering(already_present_data,:) = data_validation_filtering(i,:);
        end
    end
else
    % create new summary matrix
    updated_data_validation_filtering = data_validation_filtering;
end

%% save quality check matrix
disp(['Summary of the program saved in ', data_validation_filtering_file])
writecell(updated_data_validation_filtering, data_validation_filtering_file);
disp('--------------------------------------------------------------------------------')
disp('--------------------------------------------------------------------------------')
disp('End of the sequence validation and data points filter program')
disp('--------------------------------------------------------------------------------')
disp('--------------------------------------------------------------------------------')



