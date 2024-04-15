%% Change the metaline format of some data.txt from 2023 to old one
% Save the data.txt to [...]_2023format.txt
% Read the data text file from uvp6
% Change the hwconf line and the acq line :
% add parameters to fit the old format
% Save new file
%
% Work for all data.txt in a raw folder of a project
%
% WARNING : does not work with taxo
%
% camille catalano 03/2024

clear all
close all
warning('on')

disp('------------------------------------------------------')
disp('>> Select the UVP project directory');
project_path = uigetdir('', 'Select the UVP project directory');
%project_path = 'X:\uvp6_sn000238lp\uvp6_sn000238lp_2024_anerisvilanova';

data_files = dir([project_path, '\raw\**\*data.txt']);

disp('------------------------------------------------------')
disp(string(length(data_files)) + " files to processed")
disp('------------------------------------------------------')

for i=1:length(data_files)
    From2023formatToOldUVPData(data_files(i).folder, data_files(i).name)
end

disp('------------------------------------------------------')
disp('All files processed')
disp('------------------------------------------------------')