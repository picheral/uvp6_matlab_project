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
fprintf('APPLY data filtering \n');
fprintf('----------------------------------------------------------- \n');


% Ecriture du bru filtré des objets de la zone
% About removing inside a rectangle
% - If you want to remove particles inside a rectangle, you need to define their coordinates in the triangle_xx, triangle_yy variables with this pattern: (OBS: you can rename triangle prefix by polygon ou rect)
% triangle = [p1, p2, p3, p4, p1]
% 
% For example, for the rectangle 
% p1=(10, 10) ----------------- p4=(50, 10)
% -----| ...................... |
% -----| ...................... |
% -----| ...................... |
% p2=(10, 60)  ------------------ p3=(50, 60)
% 
% triangle_xx = [10 10 50 50 10]
% triangle_yy = [10 60 60 10 10]
fprintf('=========================================================== \n');
fprintf('FILTERING BRU files \n');
shape_xx = [1 1 139 139 1];
shape_yy = [415 661 661 415 415];
xlsfile = 'header.xls';
s7_filter_bru_files(project_name,xlsfile,shape_xx,shape_yy)

%% Verifier que les fichiers sont bien corrigés
% Chargement des fichiers BRU et creation mat
fprintf('=========================================================== \n');
fprintf('MAT file creation from BRU files \n');
s0_load_bruFiles_fast(project_name)

% Ajout des metadata image à partir du DAT
fprintf('=========================================================== \n');
fprintf('ADDING METADATA in MAT files \n');
s1_load_dat_Files_fast(project_name)

% Checking that the BRU files have been well filtered
fprintf('=========================================================== \n');
fprintf('PLOTTING CHARTS TO check that the impacted zone is empty \n');
s5_heatmap_rois_indat_size_nfilter_bounder(project_name,'control')
fprintf('Check the fig or png files \n');

% Filter vignettes in sub-folders
fprintf('=========================================================== \n');
fprintf('FILTERING THE VIGNETTES FROM THE impacted zone \n');
th_area = 79;
s2_filter_vignettes(project_name,xlsfile,th_area)

fprintf('=========================================================== \n');
fprintf('----------------------------------------------------------- \n');
fprintf('END of the PROCESS for UVP5 artefacts filtering \n');
fprintf('----------------------------------------------------------- \n');
fprintf('=========================================================== \n');








