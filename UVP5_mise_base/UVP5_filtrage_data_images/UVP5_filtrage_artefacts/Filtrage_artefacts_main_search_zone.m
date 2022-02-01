%% Script general de filtrage artefacts dans images
% Leandro Ticlio et Marc Picheral
% To REDO the full operation, copy the BRU files from the WORK folders into
% the Results folder

clc
clear all
close all

project_folder_ref = uigetdir('', 'Select UVP5 project directory ');

fprintf('=========================================================== \n');
fprintf('----------------------------------------------------------- \n');
fprintf('GENERAL PROCESS for UVP5 artefacts filtering \n');
fprintf('SEARCH impacted zone \n');
fprintf('----------------------------------------------------------- \n');

%% Initial process
% Chargement des fichiers BRU et creation mat
fprintf('=========================================================== \n');
fprintf('MAT file creation from BRU files \n');
s0_load_bruFiles_fast(project_name)

% Ajout des metadata image à partir du DAT
fprintf('=========================================================== \n');
fprintf('ADDING METADATA in MAT files \n');
s1_load_dat_Files_fast(project_name)

% Detection zone to remove
fprintf('=========================================================== \n');
fprintf('PLOTTING CHARTS TO DETECT impacted zone \n');
s5_heatmap_rois_indat_size_nfilter_bounder(project_name,'initial')

fprintf('=========================================================== \n');
fprintf('Set the shape_xx and shape_yy vectors to adapt the zone to remove from the observations in the fig files (map_filter folder) \n');
fprintf('Modify the volume in the header file and the uvp5_configuration_data.txt file \n');
fprintf('Create the header.xls file in the meta folder by adding a last column for the min object size \n');
fprintf('The tool is paused \nPress Enter to continue when ready\n');

fprintf('=========================================================== \n');
fprintf('----------------------------------------------------------- \n');
fprintf('END of SEARCH impacted zone for UVP5 artefacts filtering \n');
fprintf('----------------------------------------------------------- \n');
fprintf('=========================================================== \n');








