%% Change the metaline format of a data.txt from 2022 to old one
% Save the data.txt to [...]_2022format.txt
% Read the data text file from uvp6
% Delete all taxo lines
% Change the hwconf line and the acq line :
% add parameters to fit the old format
% Save new file
%
%
% camille catalano 05/2022

clear all
close all
warning('on')

disp('------------------------------------------------------')
disp('---------- uvp6 data.txt downgrader  -----------------')
disp('------------------------------------------------------')

%% input data file
disp("Selection of the data file to downgrade")
[data_filename, data_folder] = uigetfile('*.txt','Select the data file to downgrade');
disp("Selected data file : " + data_folder + data_filename)
disp('------------------------------------------------------')

From2022formatToOldUVPData(data_folder, data_filename)

disp('------------------------------------------------------')


disp('end of process')
disp('------------------------------------------------------')







