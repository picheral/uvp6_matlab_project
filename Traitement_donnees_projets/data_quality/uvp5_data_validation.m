%% script to manually validate uvp5 sequence and filter bad data points
% Catalano, 03/03/2020

disp('--------------------------------------------------------------------------------')
disp('--------------------------------------------------------------------------------')
disp('---- Welcome to the uvp5 sequence validation and data points filter program ----')
disp('--------------------------------------------------------------------------------')
disp('your personnal stats doing this task will not be used by some secret laboratory for a creepy human experiment, trust me')
disp('--------------------------------------------------------------------------------')
disp('--------------------------------------------------------------------------------')
disp('SIMPLIER VERSION to only validate based on csv filelist')

%{
filelist_comp = dir('U:\*\results\*_datfile.txt');
interesting_dates = ['20160100','20160100','20171200','20120900','20120900','20121000','20181200','20160100','20130100','20180600','20160200','20160200','20180400','20130900','20160200','20160300','20161200','20140600','20140600','20160100','20160900','20160500','20180600','20180100','20180100','20180100','20161200','20161200','20161200','20180600','20180400','20180300','20180600','20180600','20180200','20180100','20180100','20181000','20181200','20181200','20181200','20190100'];
interesting_sn = [
interesting_ref= [
filelist = cell(1,1);
for i= 1:length(filelist_comp)
    dat_pathname = fullfile(filelist_comp(i,1).folder, filelist_comp(i,1).name);
    for j=1:length(interesting_dates)
        if contains(dat_pathanme, interesting_dates(j))
            filelist(end+1,1) = {dat_pathname};
        end
    end
end
filelist = filelist(2:end);
files_nb = length(filelist);
%}

filelist_comp = dir('U:\*\results\*_datfile.txt');
filelist = cell(length(filelist_comp),1);
for i= 1:length(filelist_comp)
    dat_pathname = fullfile(filelist_comp(i,1).folder, filelist_comp(i,1).name);
    filelist(i,1) = {dat_pathname};
end
files_nb = length(filelist);


%filelist = readtable('Z:\UVP5\Tables_intercalibrages\manual_validation_list.csv',  'ReadVariableNames', 0);
%files_nb = height(filelist);


% data_validation_filtering is the matrix saving validation for each file
% validation = y if OK, =n if NOK
data_validation_filtering = cell(files_nb,3);



%% loop on files
%for i = 1:length(data_validation_filtering)
for i = 1:3
    %% load data from files
    dat_pathname = string(filelist{i,1});
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
    disp(['Analysing   ', dat_pathname])
    try
        T = readtable(dat_pathname,'Filetype','text','ReadVariableNames',0,'Delimiter',';');
    catch
        continue
    end
    %% take images under 10m depth, unless there is no depth
    disp('depth filter : 10m')
    T_deep = T(T{:,3}>100, :);
    if isempty(T_deep)
        T_util = T;
    else
        T_util = T_deep;
    end
    %% data validation
    disp('------------------------------------------------')
    disp('Validation of the data...')
    validation = DataValidation(T{:,1}, T{:,15}, T_util{:,1}, T_util{:,15}, dat_pathname);
    %% filtering of bad data points
    if validation == 'n'
        data_validation_filtering(i,:) = {dat_pathname, datestr(now), validation};
    else
        disp('------------------------------------------------')
        disp('Data are good. NO data filter has been applied')
        data_validation_filtering(i,:) = {dat_pathname, datestr(now), validation};
    end
    clf;
end
close;

%% save/update sumary file
disp('--------------------------------------------------------------------------------')
data_validation_filtering_file = 'Z:\UVP5\Tables_intercalibrages\manual_validation.csv';
if isfile(data_validation_filtering_file)
    %% update summary file
    updated_data_validation_filtering = table2cell(readtable(data_validation_filtering_file));
    for i=1:length(data_validation_filtering)
        if ~isempty(data_validation_filtering{i,1})
            % look for already present data
            already_present_data = find(strcmp(updated_data_validation_filtering(:,1), data_validation_filtering{i,1}));
            if isempty(already_present_data)
                % if no already present data, add to the end
                updated_data_validation_filtering(end+1,:) = data_validation_filtering(i,:);
            else
                % if already present data, replace
                updated_data_validation_filtering(already_present_data,:) = data_validation_filtering(i,:);
            end
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


