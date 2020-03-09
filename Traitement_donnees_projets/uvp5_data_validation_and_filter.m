%% script to manually validate uvp5 sequence and filter bad data points
% Catalano, 03/03/2020

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
    validation = data_validation(T, T_util, dat_pathname);
    %% filtering of bad data points
    if validation == 'n'
        % filtering
        disp('------------------------------------------------')
        disp('Filtering of bad data points...')
        [data_filtered, movmean_window, threshold_offset] = data_filtering(T, T_util, dat_pathname);
        disp(['movmean_window = ', num2str(movmean_window)])
        disp(['threshold_offset = ', num2str(threshold_offset)])
        disp([height(T) - height(data_filtered), ' points has been rejected'])
        % save new dat file
        
        disp('filtered data file in')
        % save params
        data_validation_filtering(i,:) = {dat_pathname, datestr(now), validation, movmean_window, threshold_offset};
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
data_validation_filtering_file = 'U:\data_validation.csv';
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






function validation = data_validation(T, T_util, dat_pathname)
    % DATA_VALIDATION user validation to know if the data are good
    % plots data and depth filtered data and ask if there are good
    %
    % inputs:
    %   T: data
    %   T_util: already filtered data (depth filtered)
    %   dat_pathname: abs filename of data
    %
    %outputs:
    %   validation: y/n, good/bad data
    %
    %% plot particules numbers along the sequence
    subplot(2,1,1);
    plot(T{:,1},T{:,15},'.');
    xlabel('image number');
    ylabel('number of particules');
    %% plot depth filtered particules numbers along the sequence
    subplot(2,1,2)
    plot(T_util{:,1},T_util{:,15},'.');
    xlabel('depth filtered image number');
    ylabel('number of particules');
    sgtitle(regexprep(dat_pathname, {'\\', '\_'}, {'\\\\', '\\\_'}));
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.1, 0.9, 0.9]);
    %% user validation
    validation = input('Is the data good ? ([y]/n) ', 's');
    if isempty(validation)
        validation = 'y';
    end
end



function [data_filtered, movmean_window, threshold_offset] = data_filtering(T, T_util, dat_pathname)
    % DATA_FILTERING tool to manually delete bad data points
    % plots data and depth filtered data with the filter limits and bad
    % data points.
    % the user can tune parameters to get best filtering.
    % plots are saved in png.
    %
    % inputs:
    %   T: data
    %   T_util: already filtered data (depth filtered)
    %   dat_pathname: abs filename of data
    %
    %outputs:
    %   data_filtered: new data table without bad data points
    %   movmean_window: window of moving average used by filter
    %   threshold_offset: offset substract to movmean to get filtering
    %   threshold
    %
    movmean_window = 50;
    threshold_offset = 1000;
    filter_is_good = 'n';
    disp('bad data points are under the moving average minus an offset')
    while filter_is_good == 'n'
        %% params entry
        movmean_window_entry = input(['Enter moving mean window [', num2str(movmean_window), '] ']);
        if ~isempty(movmean_window_entry)
            movmean_window = movmean_window_entry;
        end
        threshold_offset_entry = input(['Enter threshold offset [', num2str(threshold_offset), '] ']);
        if ~isempty(threshold_offset_entry)
            threshold_offset = threshold_offset_entry;
        end
        %% moving stats and filter data
        mov_mean = movmean(T{:,15}, movmean_window);
        data_filtered = T(T.Var15>mov_mean-threshold_offset,:);
        data_filtered_rejected = T(T.Var15<=mov_mean-threshold_offset,:);
        mov_mean = movmean(T_util{:,15}, movmean_window);
        data_filtered_util = T_util(T_util.Var15>mov_mean-threshold_offset,:);
        data_filtered_util_rejected = T_util(T_util.Var15<=mov_mean-threshold_offset,:);
        %% plots
        % all data plot
        clf;
        subplot(2,1,1);
        plot(data_filtered{:,1},data_filtered{:,15},'+b');
        hold on
        plot(data_filtered_rejected{:,1},data_filtered_rejected{:,15},'+r');
        hold on
        plot(T_util{:,1}, mov_mean - threshold_offset,'--g');
        str = {['movmean_window: ', num2str(movmean_window)], ['threshold_offset: ', num2str(threshold_offset)], ['bad data points: ', num2str(height(data_filtered_rejected))]};
        annotation('textbox' ,[.07 .69 .3 .3], 'String', regexprep(str, {'\_'}, {'\\\_'}), 'FitBoxToText', 'on');
        xlabel('image number');
        ylabel('number of particules');
        title('all data');
        % depth filtered plot
        subplot(2,1,2);
        plot(data_filtered_util{:,1},data_filtered_util{:,15},'+b');
        hold on
        plot(data_filtered_util_rejected{:,1},data_filtered_util_rejected{:,15},'+r');
        hold on
        plot(T_util{:,1}, mov_mean - threshold_offset,'--g');
        str = {['movmean_window: ', num2str(movmean_window)], ['threshold_offset: ', num2str(threshold_offset)], ['bad data points: ', num2str(height(data_filtered_util_rejected))]};
        annotation('textbox', [.07 .23 .3 .3], 'String', regexprep(str, {'\_'}, {'\\\_'}), 'FitBoxToText', 'on');
        xlabel('image number');
        ylabel('number of particules');
        title('depth filtered data');
        % figure params
        sgtitle(regexprep(dat_pathname, {'\\', '\_'}, {'\\\\', '\\\_'}));
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.1, 0.9, 0.9]);
        %% user filter validation
        filter_is_good = input('Are you satisfied with the filter ? ([n]/y) ', 's');
        if isempty(filter_is_good)
            filter_is_good = 'n';
        end
        disp('------------------------------------------------')
    end
    saveas(gcf,[dat_pathname(1:end-4), '_filtering.png']);
end