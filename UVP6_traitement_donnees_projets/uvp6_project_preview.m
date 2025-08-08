%% Make a preview of a uvp6 project showing pres-pix1-pix2/time graph
% Read all the data.txt (not used for merged)
% Extract datetime, pres, pix1, pix2
% Make one matlab graph with the variables
% The graph is saved in the result folder of the project
%
% uvp6 version = 2021 & 2022-RE
%
%
% camille catalano 04/2025

clear all
close all
warning('on')

%% Select the UVP project and detect the files
disp('------------------------------------------------------')
disp('>> Select the UVP project directory');
project_path = uigetdir('', 'Select the UVP project directory');


% list the data.txt files without UsedForMerge
data_files = dir([project_path, '\raw\**\*data.txt']);
data_files = struct2table(data_files);
data_files = regexpi(fullfile(data_files.folder, data_files.name), '^((?!UsedForMerge).)*$', 'match');
data_files = [data_files{:}];
%data_files = dir([project_path, '\raw\**\*data.txt']);

disp('------------------------------------------------------')
disp(string(length(data_files)) + " data files found for the preview")
disp('------------------------------------------------------')


%% Read the data files
%loop on the data.txt files
datetime_project = [];
depth_project = [];
pix1_project = [];
pix2_project = [];
for i=1:length(data_files)
    [data, meta, taxo] = Uvp6DatafileToArray(data_files{i}); % Read file and collect data table
    [time_data, depth_data, raw_nb, black_nb, raw_grey, image_status] = Uvp6ReadDataFromDattable(meta, data); % from data table to time-depth-part data
    datetime_project = [datetime_project; datetime(time_data, 'ConvertFrom', 'datenum')];
    depth_project = [depth_project; depth_data];
    pix1_project = [pix1_project; raw_nb(:,1)];
    pix2_project = [pix2_project; raw_nb(:,2)];
end


%% Plot the figures
%plot the figure with dot
fig_dot = figure;
yyaxis left
title(project_path, 'Interpreter', "none")
plot(datetime_project, depth_project, '.b')
xlabel('Time')
ylabel('Depth')
set(gca, 'YDir', 'reverse')
hold on
yyaxis right
ylabel('particles count 1 & 2 pix')
plot(datetime_project, pix1_project, 'g')
hold on
plot(datetime_project, pix2_project, 'g')

%plot the figure with cross
fig_cross = figure;
yyaxis left
title(project_path, 'Interpreter', "none")
plot(datetime_project, depth_project, '+b')
xlabel('Time')
ylabel('Depth')
set(gca, 'YDir', 'reverse')
hold on
yyaxis right
ylabel('particles count 1 & 2 pix')
plot(datetime_project, pix1_project, 'g')
hold on
plot(datetime_project, pix2_project, 'g')


%% Save the figures
results_path = fullfile(project_path, 'results');
if not(isfolder(results_path))
   status = mkdir(results_path);
end
savefig_path_dot = fullfile(results_path, [char(datetime('now', 'Format', 'yyyyMMdd')), '_preview_figure_dot']);
savefig(savefig_path_dot);
savefig_path_cross = fullfile(results_path, [char(datetime('now', 'Format', 'yyyyMMdd')), '_preview_figure_cross']);
savefig(savefig_path_cross);
disp('------------------------------------------------------')
disp("Figure saved in " + string(savefig_path_dot))
disp("Figure saved in " + string(savefig_path_cross))
disp('------------------------------------------------------')


disp('------------------------------------------------------')
disp('The end folks')
disp('------------------------------------------------------')






