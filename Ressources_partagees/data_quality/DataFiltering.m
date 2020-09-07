function [im_util_filtered, part_util_filtered_rejected, movmean_window, threshold_percent, mult] = DataFiltering(listecor, results_dir, profilename,manual_filter,mult,movmean_window,threshold_percent,method)
% function [im_filtered, part_filtered, movmean_window, threshold_percent] = DataFiltering(image_numbers, part, image_numbers_util, part_util, dat_pathname)
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
%   threshold_percent: offset substract to movmean to get filtering
%   threshold
%

% ------------------ Vecteurs ------------------------
%     liste = [ Image(kk(1):gg(end)) Pressure(kk(1):gg(end))/10 Flag(kk(1):gg(end)) Part(kk(1):gg(end)) ];
%     image_numbers = listecor(:,1);
%     part = listecor(:,4);
%     press = listecor(:,2);
% ------------------- Données filtrées "descente" -------
aa = find(listecor(:,3)==1);
image_numbers_util = listecor(aa,1);
part_util = listecor(aa,4);
press_util = listecor(aa,2);

% -------------------- Toutes données -------------------
% image_numbers_util = listecor(:,1);
% part_util = listecor(:,4);
% press_util = listecor(:,2);

filter_is_good = 'n';
% disp('bad data points are under the moving average minus an offset')
while not(strcmp(filter_is_good, 'y'))
    %% ---------------------- plots ----------------
    fig = figure('numbertitle','off','name','Correction figure','Position',[10 200 1200 1200]);
    texte = [char(results_dir),char(profilename)];
    aa = find(texte == '_');
    if ~isempty(aa);    texte(aa) = "-";end
    
    subplot(2,2,1)
    semilogx(part_util,-press_util,'.b');
    hold on
    dd = find(listecor(:,3) == 1);
    ylabel('Pressure');
    xlabel('Abundance of LPM (Raw data from descent)');
    sgtitle(regexprep(texte, {'\\', '\_'}, {'\\\\', '\\\_'}));
    
    subplot(2,2,2)
    plot(part_util,-press_util,'.b');
    hold on
    dd = find(listecor(:,3) == 1);
    ylabel('Pressure');    
    xlabel('Abundance of LPM (Raw data from descent)');
    
    % ---------- Cas ajustage manuel ----------------------
    if manual_filter == 'm' || manual_filter == 'a' || manual_filter == 's'
        %% params entry
        mult_entry = input(['Enter multiplier [', num2str(mult), '] ']);
        if ~isempty(mult_entry)
            mult = mult_entry;
        end
        movmean_window_entry = input(['Enter moving mean window [', num2str(movmean_window), '] ']);
        if ~isempty(movmean_window_entry)
            movmean_window = movmean_window_entry;
        end
        threshold_percent_entry = input(['Enter percent of moving mean for threshold [', num2str(threshold_percent*100), '] ']);
        if ~isempty(threshold_percent_entry)
            threshold_percent = threshold_percent_entry/100;
        end
    end
    
    % ------- moyenne mobile ----------------------------------
    mov_mean_util = movmean(part_util, movmean_window);
    disp('WAIT for data processing !')
    if strcmp(method,'c')
        %% ------ moving stats and filter data (Camille/Fabien) --------
        part_util_filtered = part_util(part_util>threshold_percent*mov_mean_util);
        press_util_filtered = press_util(part_util>threshold_percent*mov_mean_util);
        im_util_filtered = image_numbers_util(part_util>threshold_percent*mov_mean_util);
        part_util_filtered_rejected = part_util(part_util<=threshold_percent*mov_mean_util);
        im_util_filtered_rejected = image_numbers_util(part_util<=threshold_percent*mov_mean_util);
        press_util_filtered_rejected = press_util(part_util<=threshold_percent*mov_mean_util);
    elseif strcmp(method,'jo')
        %% ----- methode JO Irisson ------------------------------------
        % prepare storage for the quantile
        n = size(part_util,1);
        q = nan(n,1);
        % compute the quantile in a moving window
        for i=1:n-movmean_window
            q(i) = quantile(mov_mean_util(i:(i+movmean_window)), threshold_percent);
        end
        part_util_filtered = part_util(part_util >= mult * q);
        press_util_filtered = press_util(part_util >= mult * q);
        im_util_filtered = image_numbers_util(part_util >= mult * q);
        part_util_filtered_rejected =            part_util(part_util < mult * q);
        im_util_filtered_rejected =     image_numbers_util(part_util < mult * q);
        press_util_filtered_rejected = press_util(part_util < mult * q);
    end
    
    % add results on plot
    subplot(2,2,3)
    semilogx(part_util_filtered,-press_util_filtered,'.g');
    hold on
    semilogx(part_util_filtered_rejected,-press_util_filtered_rejected,'.r');
    hold on
    %     plot(threshold_percent*mov_mean_util,-press_util_filtered,'--g');
    %     plot(threshold_percent*movmean(part_util,movmean_window),-press_util,'--g');
    
    %     str = {['movmean_window: ', num2str(movmean_window)], ['threshold_percent: ', num2str(threshold_percent*100)], ['bad data points: ', num2str(length(part_util_filtered_rejected))]};
    %     annotation('textbox', [.5 .23 .3 .3], 'String', regexprep(str, {'\_'}, {'\\\_'}), 'FitBoxToText', 'on');
    %     xlabel(['TOTAL number of particles from ',num2str(numel(aa)),' images']);
    dd = find(listecor(:,3) == 1);
    xlabel(['TOTAL abundance [RED = rejected images, GREEN = good images]']);
    
    subplot(2,2,4)
    plot(part_util_filtered,-press_util_filtered,'.g');
    hold on
    plot(part_util_filtered_rejected,-press_util_filtered_rejected,'.r');
    hold on
    %     plot(threshold_percent*mov_mean_util,-press_util_filtered,'--g');
    %     plot(threshold_percent*movmean(part_util,movmean_window),-press_util,'--g');
    
    %     str = {['movmean_window: ', num2str(movmean_window)], ['threshold_percent: ', num2str(threshold_percent*100)], ['bad data points: ', num2str(length(part_util_filtered_rejected))]};
    %     annotation('textbox', [.5 .23 .3 .3], 'String', regexprep(str, {'\_'}, {'\\\_'}), 'FitBoxToText', 'on');
    %     xlabel(['TOTAL number of particles from ',num2str(numel(aa)),' images']);
    dd = find(listecor(:,3) == 1);
    xlabel(['STATS : rejected : ',num2str(numel(part_util_filtered_rejected)),' / ',num2str(100-(100*(numel(dd)-numel(part_util_filtered_rejected))/numel(listecor(:,1))),2),' % [',num2str(mult),'-',num2str(movmean_window),'-',num2str(threshold_percent),']']);
    
    
    %% user filter validation
    if manual_filter == 'm' || manual_filter == 'a' || manual_filter == 's'
        % default is no
        filter_is_good = input('Are data OK now ? ([n]/y) ','s');
        disp('------------------------------------------------')
        
    else
        filter_is_good = 'y';
    end
    if strcmp(filter_is_good,'y')
        orient tall
        set(gcf,'PaperPositionMode','auto')
        saveas(fig,[results_dir,'/',char(profilename), '_filtering.png']);
        savefig(fig,[results_dir,'/',char(profilename), '_filtering.fig']);
    end
    close(fig)
end
end
