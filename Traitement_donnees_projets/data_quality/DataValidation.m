function validation = DataValidation(T, T_util, dat_pathname)
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