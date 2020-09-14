%% *UVP5 verrines test*

clear all
close all

disp('Version 2020/08/04')

disp("Selection of the data file to analyse...")
[data_filename, data_folder] = uigetfile('*.csv','Select the data file to analyse');
disp('')
disp(['Analysed file : ' data_filename])

% read the data
% the table has 3 columns (= 3 channels)
% channel 0 is for the trigger
% channel 1 and 2 for the verrines
filename = [data_folder, data_filename];
t = readtable(filename);
t.Var4_1 = [];

% auto detection and counting of the rising edges of each signal
[ch0_rises, ch0_rises_LT, ch0_rises_UT, ch0_rises_ll, ch0_rises_ul] = risetime(t.Channel0, 'StateLevels', [1,3.5]);
[ch1_rises, ch1_rises_LT, ch1_rises_UT]  = risetime(t.Channel1);
[ch2_rises, ch2_rises_LT, ch2_rises_UT]  = risetime(t.Channel2);
ch1_miss_rate = (length(ch0_rises) - length(ch1_rises)) / length(ch0_rises);
ch2_miss_rate = (length(ch0_rises) - length(ch2_rises)) / length(ch0_rises);


%% Trigger
% statelevels give automatically the levels
% and the histogram of the measurement data points for Channel0
[levels, histogram, binlevels] = statelevels(t.Channel0);
semilogy(binlevels, histogram)
xlabel('voltage')
ylabel('count')
title('Measurement distribution for the trigger')
saveas(gcf, [filename(1:end-4), '_trig.png'])
close


%% Verrine 1 missing flashes
disp(['Missing flash for verrine 1 : ' num2str(ch1_miss_rate*100) '% (' num2str(length(ch1_rises)) '/' num2str(length(ch0_rises)) ')'])

% find cases with a >3.5V trigger and no signal in the verrine (<1)
aa = intersect(find(t.Channel0 >3.5), find(t.Channel1 < 1));

% In order to check if there are cases with some voltage in the trigger and
% nothing in the verrine
plot(t.Channel0, t.Channel1, '+')
title('Verrine 1 compared to the trigger')
saveas(gcf, [filename(1:end-4), '_Ver1Trig.png'])
close

if ~isempty(aa)
    figure
    subplot(3,1,1)
    stem(aa, ones(length(aa)), '+')
    xlim([0 length(t.Channel0)])
    xlabel('time indice')
    title(['Missing flashes : '  num2str(ch1_miss_rate*100) '% (' num2str(length(ch1_rises)) '/' num2str(length(ch0_rises)) ')'])
    
    subplot(3,1,2)
    yyaxis left
    plot(t.Channel0(aa(1)-50:aa(1)+50), 'g')
    ylim([0, 4.5])
    hold on
    yyaxis right
    plot(t.Channel1(aa(1)-50:aa(1)+50), 'r-')
    plot(t.Channel2(aa(1)-50:aa(1)+50), 'b-')
    ylim([-2, 12])
    legend('trigger', 'verrine 1', 'verrine2')
    title('Example of a missing flash')
    
    subplot(3,1,3)
    i_trig = int16(ch2_rises_LT(2));
    yyaxis left
    plot(t.Channel0(i_trig-50:i_trig+50), 'g')
    ylim([0, 4.5])
    hold on
    yyaxis right
    plot(t.Channel1(i_trig-50:i_trig+50), 'r-')
    plot(t.Channel2(i_trig-50:i_trig+50), 'b-')
    ylim([-2, 12])
    legend('trigger', 'verrine 1', 'verrine2')
    title('Example of a good flash')
    
    saveas(gcf, [filename(1:end-4), '_Ver1Flashes.png'])
    close
end


%% Verrine 2 missing flashes
disp(['Missing flash for verrine 2 : ' num2str(ch2_miss_rate*100) '% (' num2str(length(ch2_rises)) '/' num2str(length(ch0_rises)) ')'])

% find cases with a >3.5V trigger and no signal in the verrine (<1)
aa = intersect(find(t.Channel0 >3.5), find(t.Channel2 < 1));

% In order to check if there are cases with some voltage in the trigger and
% nothing in the verrine
plot(t.Channel0, t.Channel2, '+')
title('Verrine 2 compared to the trigger')
saveas(gcf, [filename(1:end-4), '_Ver2Trig.png'])
close

if ~isempty(aa)
    figure
    subplot(3,1,1)
    stem(aa, ones(length(aa)), '+')
    xlim([0 length(t.Channel0)])
    xlabel('time indice')
    title(['Missing flashes : '  num2str(ch2_miss_rate*100) '% (' num2str(length(ch2_rises)) '/' num2str(length(ch0_rises)) ')'])
    
    subplot(3,1,2)
    yyaxis left
    plot(t.Channel0(aa(1)-50:aa(1)+50), 'g')
    ylim([0, 4.5])
    hold on
    yyaxis right
    plot(t.Channel1(aa(1)-50:aa(1)+50), 'r-')
    plot(t.Channel2(aa(1)-50:aa(1)+50), 'b-')
    ylim([-2, 12])
    legend('trigger', 'verrine 1', 'verrine2')
    title('Example of a missing flash')
    
    subplot(3,1,3)
    i_trig = int16(ch2_rises_LT(2));
    yyaxis left
    plot(t.Channel0(i_trig-50:i_trig+50), 'g')
    ylim([0, 4.5])
    hold on
    yyaxis right
    plot(t.Channel1(i_trig-50:i_trig+50), 'r-')
    plot(t.Channel2(i_trig-50:i_trig+50), 'b-')
    ylim([-2, 12])
    legend('trigger', 'verrine 1', 'verrine2')
    title('Example of a good flash')
    
    saveas(gcf, [filename(1:end-4), '_Ver2Flashes.png'])
    close
end


%%
save([filename(1:end-4), '.mat'])