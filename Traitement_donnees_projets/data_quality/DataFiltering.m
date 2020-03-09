function [data_filtered, movmean_window, threshold_offset] = DataFiltering(T, T_util, dat_pathname)
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


