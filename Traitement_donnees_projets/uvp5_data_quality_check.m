%% plot the number of particules of all images of all datfiles of a uvp5 disk
% and compute a quality indicator of the sequences
% Catalano, 26/02/2020


disp("c'est partiii !!!!!!!!!!!")
disk = upper(input('Disk to analyse (ex: U) ', 's'));
filelist = dir([disk, ':\*intercalibrage*\results\*_datfile.txt']);
%filelist = dir('U:\*203*intercalibrage*\results\*_datfile.txt');
%idx = ismember({filelist.folder}, {'U:\uvp5_sn203_intercalibrage_20180122\results'});
%filelist = filelist(~idx);
% quality check is the matrix with all quality parameters to be saved
quality_check = cell(length(filelist),6);
for i = 1:length(filelist)
    dat_pathname = fullfile(filelist(i).folder,filelist(i).name);
    try
        %% compute quality parameters
        [movmean_mean, movstd_mean, pks, locs, movstd_norm] = particules_number_check(dat_pathname);
        % quality_score = 0 if OK, =1 if NOK
        % score trust is based on manual study of 203_intercalibrage (in %)
        quality_score = 0;
        score_trust = 0.95;
        %% quality score std
        % from 200 classes histo of moving std
        % if more than 1 peak, there are more than one population
        % if one peak located>50, it may be the second peak (the first has
        % not been seen)
        % if no peak, seen has not good
        quality_score_std = 0;
        if length(pks)>1 || (length(pks) == 1 && locs(1)>50) || isempty(pks)
            quality_score_std = 1;
            quality_score = 1;
            score_trust = 0.15;
        end
        %% quality score fit
        % normalised moving std (by linear fit)
        % threshold 1.2 is a good filter
        quality_score_fit = 0;
        if movstd_norm > 1.2
            quality_score_fit = 1;
            quality_score = 1;
            if quality_score_std
                score_trust = 0.9;
            else
                score_trust = 0.3;
            end
        end
        quality_check(i,:) = {dat_pathname, length(pks), quality_score_std, quality_score_fit, quality_score, score_trust};
    catch
        warning(['unable to analyse file ', dat_pathname]);
        quality_check(i,:) = {dat_pathname, -1, -1, -1, 1, 1};
    end
end
% save quality check matrix
writecell(quality_check, 'U:\quality_check.csv');

    
    
function [movmean_mean, movstd_mean, pks, locs, movstd_norm] = particules_number_check(datfile)
    %% load data from files
    disp(['Analysing   ', datfile])
    T = readtable(datfile,'Filetype','text','ReadVariableNames',0,'Delimiter',';');
    %% take images under 10m depth, unless there is no depth
    T_deep = T(T{:,3}>100, :);
    if isempty(T_deep)
        T_util = T;
    else
        T_util = T_deep;
    end
    part_nb = T_util{:, 15};
    %% moving stats
    window_size = 5;
    movmean_mean = mean(movmean(part_nb,window_size));
    mov_std = movstd(part_nb,window_size);
    movstd_mean = mean(mov_std);
    % looking for 2 populations
    % 0.04714 comming from linear fit of good sequences
    % movstd_mean = 0.04714 * movmean_mean
    movstd_norm = movstd_mean./(0.04714*movmean_mean);
    %% looking for 2 populations of particules count
    mov_std_hist = histcounts(mov_std, 200)/length(mov_std);
    [pks,locs] = findpeaks(mov_std_hist, 'MinPeakHeight',1e-3, 'MinPeakDistance',50);
    %% plot particules numbers along the sequence
    subplot(2,1,1);
    plot(T{:,1},T{:,15},'.');
    xlabel('image number');
    ylabel('number of particules');
    %% plot actual particules numbers along the sequence
    subplot(2,1,2)
    plot(T_util{:,1},T_util{:,15},'.');
    xlabel('used image number');
    ylabel('number of particules');
    %% plot moving std repartition
    %{
    subplot(3,1,3)
    plot(mov_std_hist);
    str = {['pks: ', mat2str(pks, 2)], ['locs: ', mat2str(locs)]};
    annotation('textbox',[.2 .5 .3 .3],'String',str,'FitBoxToText','on');
    xlabel('mov std class');
    ylabel('nb of data points');
    %}
    %% save plot
    sgtitle(regexprep(datfile, {'\\', '\_'}, {'\\\\', '\\\_'}));
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.1, 0.9, 0.9]);
    saveas(gcf,[datfile(1:end-4), '_quality_plot.png']);
    savefig(gcf,[datfile(1:end-4), '_quality_plot.fig']);
end







