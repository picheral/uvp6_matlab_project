%% Change the metaline format of a data.txt from 2022 to old one
% Save the data.txt to [...]_2022format.txt
% Read the data text file from uvp6
% Delete all taxo lines
% Change the hwconf line and the acq line :
% add parameters to fit the old format
% Save new file
%
% uvp6 version = 24/02/2022
%
% Work for all data.txt in a raw folder of a project
%
% camille catalano 12/2024

clear all
close all
warning('on')

disp('------------------------------------------------------')
disp('------- uvp6 data.txt project downgrader  ------------')
disp('------------------------------------------------------')



disp('------------------------------------------------------')
disp('>> Select the UVP project directory');
project_path = uigetdir('', 'Select the UVP project directory');

data_files = dir([project_path, '\raw\**\*data.txt']);


disp('------------------------------------------------------')
disp(string(length(data_files)) + " files to processed")
disp('------------------------------------------------------')

for i=1:length(data_files)
    From2022formatToOldUVPData(data_files(i).folder, data_files(i).name)
end

disp('------------------------------------------------------')


disp('end of process')
disp('------------------------------------------------------')







