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
t.Var4 = [];

%% compute variables
% auto detection and counting of the rising edges of each signal
ch0_rises = risetime(t.Channel0, 'StateLevels', [1,3.5]);
[ch1_rises, ch1_rises_LT, ch1_rises_UT]  = risetime(t.Channel1);
[ch2_rises, ch2_rises_LT, ch2_rises_UT]  = risetime(t.Channel2);
ch0_nb_pulses = length(ch0_rises);
ch1_nb_pulses = length(ch1_rises);
ch2_nb_pulses = length(ch2_rises);
ch1_miss_rate = (ch0_nb_pulses - ch1_nb_pulses) / ch0_nb_pulses;
ch2_miss_rate = (ch0_nb_pulses - ch2_nb_pulses) / ch0_nb_pulses;
ch1_i_trig = int16(ch1_rises_LT(2));
ch2_i_trig = int16(ch2_rises_LT(2));

aa_1 = intersect(find(t.Channel0 >3.5), find(t.Channel1 < 1));
aa_2 = intersect(find(t.Channel0 >3.5), find(t.Channel2 < 1));

%%
save([filename(1:end-4), '.mat'])
clear ch0_rises ch1_rises ch1_rises_LT ch1_rises_UT ch2_rises ch2_rises_LT ch2_rises_UT 

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

clear levels histogram binlevels

%% Verrine 1 missing flashes
disp(['Missing flash for verrine 1 : ' num2str(ch1_miss_rate*100) '% (' num2str(ch1_nb_pulses) '/' num2str(ch0_nb_pulses) ')'])

% find cases with a >3.5V trigger and no signal in the verrine (<1)
aa = aa_1;

% In order to check if there are cases with some voltage in the trigger and
% nothing in the verrine
plot(t.Channel0, t.Channel1, '+')
title('Verrine 1 compared to the trigger')
saveas(gcf, [filename(1:end-4), '_Ver1Trig.png'])
close

if ~isempty(aa) && ch1_miss_rate ~= 0
    figure
    subplot(3,1,1)
    stem(aa, ones(length(aa),1), '+')
    xlim([0 length(t.Channel0)])
    xlabel('time indice')
    title(['Missing flashes : '  num2str(ch1_miss_rate*100) '% (' num2str(ch1_nb_pulses) '/' num2str(ch0_nb_pulses) ')'])
    
    subplot(3,1,2)
    yyaxis left
    plot(t.Channel0(aa(2)-50:aa(2)+50), 'g')
    ylim([0, 4.5])
    hold on
    yyaxis right
    plot(t.Channel1(aa(2)-50:aa(2)+50), 'r-')
    plot(t.Channel2(aa(2)-50:aa(2)+50), 'b-')
    ylim([-2, 12])
    legend('trigger', 'verrine 1', 'verrine2')
    title('Example of a missing flash')
    
    subplot(3,1,3)
    yyaxis left
    plot(t.Channel0(ch1_i_trig-50:ch1_i_trig+50), 'g')
    ylim([0, 4.5])
    hold on
    yyaxis right
    plot(t.Channel1(ch1_i_trig-50:ch1_i_trig+50), 'r-')
    plot(t.Channel2(ch1_i_trig-50:ch1_i_trig+50), 'b-')
    ylim([-2, 12])
    legend('trigger', 'verrine 1', 'verrine2')
    title('Example of a good flash')
    
    saveas(gcf, [filename(1:end-4), '_Ver1Flashes.png'])
    close
end

clear aa_1

%% Verrine 2 missing flashes
disp(['Missing flash for verrine 2 : ' num2str(ch2_miss_rate*100) '% (' num2str(ch2_nb_pulses) '/' num2str(ch0_nb_pulses) ')'])

% find cases with a >3.5V trigger and no signal in the verrine (<1)
aa = aa_2;

% In order to check if there are cases with some voltage in the trigger and
% nothing in the verrine
plot(t.Channel0, t.Channel2, '+')
title('Verrine 2 compared to the trigger')
saveas(gcf, [filename(1:end-4), '_Ver2Trig.png'])
close

if ~isempty(aa) && ch2_miss_rate ~= 0
    figure
    subplot(3,1,1)
    stem(aa, ones(length(aa),1), '+')
    xlim([0 length(t.Channel0)])
    xlabel('time indice')
    title(['Missing flashes : '  num2str(ch2_miss_rate*100) '% (' num2str(ch2_nb_pulses) '/' num2str(ch0_nb_pulses) ')'])
    
    subplot(3,1,2)
    yyaxis left
    plot(t.Channel0(aa(2)-50:aa(2)+50), 'g')
    ylim([0, 4.5])
    hold on
    yyaxis right
    plot(t.Channel1(aa(2)-50:aa(2)+50), 'r-')
    plot(t.Channel2(aa(2)-50:aa(2)+50), 'b-')
    ylim([-2, 12])
    legend('trigger', 'verrine 1', 'verrine2')
    title('Example of a missing flash')
    
    subplot(3,1,3)
    yyaxis left
    plot(t.Channel0(ch2_i_trig-50:ch2_i_trig+50), 'g')
    ylim([0, 4.5])
    hold on
    yyaxis right
    plot(t.Channel1(ch2_i_trig-50:ch2_i_trig+50), 'r-')
    plot(t.Channel2(ch2_i_trig-50:ch2_i_trig+50), 'b-')
    ylim([-2, 12])
    legend('trigger', 'verrine 1', 'verrine2')
    title('Example of a good flash')
    
    saveas(gcf, [filename(1:end-4), '_Ver2Flashes.png'])
    close
end

clear aa_2
