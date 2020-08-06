%% *UVP5 missing flashes visualization*

clear all
close all

disp('Version 2020/08/04')

disp("Selection of the data file to visualize...")
[data_filename, data_folder] = uigetfile('*.mat','Select the data file to visualize');
disp('')
disp(['Selected file : ' data_filename])

filename = [data_folder, data_filename];
load(filename);


%% Verrine 1 missing flashes
disp(['Missing flash for verrine 1 : ' num2str(ch1_miss_rate*100) '% (' num2str(length(ch1_rises)) '/' num2str(length(ch0_rises)) ')'])

% find cases with a >3.5V trigger and no signal in the verrine (<1)
aa = intersect(find(t.Channel0 >3.5), find(t.Channel1 < 1));


if ~isempty(aa)
    for i=1:length(aa)
        k = figure;
        yyaxis left
        plot(t.Channel0(aa(i)-50:aa(i)+50), 'g')
        ylim([0, 4.5])
        hold on
        yyaxis right
        plot(t.Channel1(aa(i)-50:aa(i)+50), 'r-')
        plot(t.Channel2(aa(i)-50:aa(i)+50), 'b-')
        ylim([-2, 12])
        legend('trigger', 'verrine 1', 'verrine2')
        title('Example of a missing flash')
        uiwait(k);
    end
end


%% Verrine 2 missing flashes
disp(['Missing flash for verrine 2 : ' num2str(ch2_miss_rate*100) '% (' num2str(length(ch2_rises)) '/' num2str(length(ch0_rises)) ')'])

% find cases with a >3.5V trigger and no signal in the verrine (<1)
aa = intersect(find(t.Channel0 >3.5), find(t.Channel2 < 1));


if ~isempty(aa)
    for i=1:length(aa)
        k=figure;
        yyaxis left
        plot(t.Channel0(aa(i)-50:aa(i)+50), 'g')
        ylim([0, 4.5])
        hold on
        yyaxis right
        plot(t.Channel1(aa(i)-50:aa(i)+50), 'r-')
        plot(t.Channel2(aa(i)-50:aa(i)+50), 'b-')
        ylim([-2, 12])
        legend('trigger', 'verrine 1', 'verrine2')
        title('Example of a missing flash')
        uiwait(k);
    end
end

