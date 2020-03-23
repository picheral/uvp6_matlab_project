function validation = DataValidation(listecor, dat_pathname)
% function validation = DataValidation(image_numbers, part, image_numbers_util, part_util, dat_pathname)
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
%     subplot(1,2,1);
%     plot(image_numbers,part,'.');
%     xlabel('image number');
%     ylabel('number of particules');

    %% plot depth filtered particules numbers along the sequence
    subplot(1,2,1)
    plot(listecor(:,4),-listecor(:,2),'b.');

    %% Ajout moyenne mobile
    hold on
    plot(movavg(listecor(:,4),'linear',40),-listecor(:,2),'c-', 'LineWidth', 2);
    
    % Formattage du graph
    xlabel(['TOTAL number of particles from ',num2str(numel(listecor(:,1))),' images']);
    ylabel('Pressure');  
 
    sgtitle(regexprep(dat_pathname, {'\\', '\_'}, {'\\\\', '\\\_'}));
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.1, 0.9, 0.9]);
    
    % Filtrage par flag
    subplot(1,2,2) 
    aa= find(listecor(:,3)==1);
    plot(listecor(aa,4),-listecor(aa,2),'b.');

    %% Ajout moyenne mobile
    hold on
    plot(movavg(listecor(aa,4),'linear',40),-listecor(aa,2),'r-''LineWidth', 2);
    
    % Formattage du graph
    xlabel(['TOTAL number of particles from ',num2str(numel(aa)),' images (Descent ONLY)']);
    ylabel('Pressure');  
    
    %% user validation
    validation = input('Is the data good ? ([y]/n) ', 's');
    if not(strcmp(validation, 'n'))
        validation = 'y';
    end
end