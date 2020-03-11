function validation = DataValidation(image_numbers, part, image_numbers_util, part_util, dat_pathname)
    % DATA_VALIDATION user validation to know if the data are good
    % plots data and depth filtered data and ask if there are good
    %
    % inputs:
    %   image_numbers: numbers of the data images
    %   part: number of particles in data images
    %   image_numbers_util: numbers of the filtered data images (depth filtered)
    %   part_util: number of particles in filtered data images (depth filtered)
    %   dat_pathname: abs filename of data
    %
    %outputs:
    %   validation: y/n, good/bad data
    %
    %% plot particules numbers along the sequence
    subplot(2,1,1);
    plot(image_numbers,part,'.');
    xlabel('image number');
    ylabel('number of particules');
    %% plot depth filtered particules numbers along the sequence
    subplot(2,1,2)
    plot(image_numbers_util,part_util,'.');
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