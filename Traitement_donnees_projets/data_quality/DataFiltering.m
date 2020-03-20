function [im_filtered, part_filtered, movmean_window, threshold_percent] = DataFiltering(image_numbers, part, image_numbers_util, part_util, dat_pathname)
    % DATA_FILTERING tool to manually delete bad data points
    % plots data and depth filtered data with the filter limits and bad
    % data points.
    % the user can tune parameters to get best filtering.
    % plots are saved in png.
    %
    % inputs:
    %   image_numbers: numbers of the data images
    %   part: number of particles in data images
    %   image_numbers_util: numbers of the filtered data images (depth filtered)
    %   part_util: number of particles in filtered data images (depth filtered)
    %   dat_pathname: abs filename of data
    %
    %outputs:
    %   data_filtered: new data table without bad data points
    %   movmean_window: window of moving average used by filter
    %   threshold_offset: offset substract to movmean to get filtering
    %   threshold
    %
    movmean_window = 50;
    threshold_percent = 0.5;
    filter_is_good = 'n';
    disp('bad data points are under the moving average minus an offset')
    while not(strcmp(filter_is_good, 'y'))
        %% params entry
        movmean_window_entry = input(['Enter moving mean window [', num2str(movmean_window), '] ']);
        if ~isempty(movmean_window_entry)
            movmean_window = movmean_window_entry;
        end
        threshold_offset_entry = input(['Enter percent of moving mean for threshold [', num2str(threshold_percent), '] ']);
        if ~isempty(threshold_offset_entry)
            threshold_percent = threshold_offset_entry/100;
        end
        %% moving stats and filter data
        % raw data
        mov_mean = movmean(part, movmean_window);
        part_filtered = part(part>threshold_percent*mov_mean);
        im_filtered = image_numbers(part>threshold_percent*mov_mean);
        part_filtered_rejected = part(part<=threshold_percent*mov_mean);
        im_filtered_rejected = image_numbers(part<=threshold_percent*mov_mean);
        % filtered data
        mov_mean_util = movmean(part_util, movmean_window);
        part_util_filtered = part_util(part_util>threshold_percent*mov_mean_util);
        im_util_filtered = image_numbers(part_util>threshold_percent*mov_mean_util);
        part_util_filtered_rejected = part_util(part_util<=threshold_percent*mov_mean_util);
        im_util_filtered_rejected = image_numbers_util(part_util<=threshold_percent*mov_mean_util);
        %% plots
        % all data plot
        clf;
        subplot(2,1,1);
        plot(im_filtered,part_filtered,'+b');
        hold on
        plot(im_filtered_rejected,part_filtered_rejected,'+r');
        hold on
        plot(image_numbers, threshold_percent*mov_mean,'--g');
        str = {['movmean_window: ', num2str(movmean_window)], ['threshold_percent: ', num2str(threshold_percent)], ['bad data points: ', num2str(length(part_filtered_rejected))]};
        annotation('textbox' ,[.07 .69 .3 .3], 'String', regexprep(str, {'\_'}, {'\\\_'}), 'FitBoxToText', 'on');
        xlabel('image number');
        ylabel('number of particules');
        title('all data');
        % depth filtered plot
        subplot(2,1,2);
        plot(im_util_filtered,part_util_filtered,'+b');
        hold on
        plot(im_util_filtered_rejected,part_util_filtered_rejected,'+r');
        hold on
        plot(image_numbers_util, threshold_percent*mov_mean_util,'--g');
        str = {['movmean_window: ', num2str(movmean_window)], ['threshold_offset: ', num2str(threshold_percent)], ['bad data points: ', num2str(length(part_util_filtered_rejected))]};
        annotation('textbox', [.07 .23 .3 .3], 'String', regexprep(str, {'\_'}, {'\\\_'}), 'FitBoxToText', 'on');
        xlabel('image number');
        ylabel('number of particules');
        title('depth filtered data');
        % figure params
        sgtitle(regexprep(dat_pathname, {'\\', '\_'}, {'\\\\', '\\\_'}));
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.1, 0.9, 0.9]);
        %% user filter validation
        % default is no
        filter_is_good = input('Are you satisfied with the filter ? ([n]/y) ', 's');
        disp('------------------------------------------------')
    end
    saveas(gcf,[dat_pathname(1:end-4), '_filtering.png']);
    savefig(gcf,[dat_pathname(1:end-4), '_filtering.fig']);
end


