%% Create the sample file of a project
% Create the sample file for all sequences
% the meta data are extracted from the sequence and a nav file located in
% the doc folder of the project
% 
% camille catalano 11/2020

clear all
close all
warning('on')

disp('------------------------------------------------------')
disp('------------- uvp6 sample creator --------------------')
disp('------------------------------------------------------')
disp('')
disp('WARNING : Work only for seaexplorer project')
disp('')


%% inputs and its QC
% select the project
disp('Select UVP project folder ')
project_folder = uigetdir('',['Select UVP project folder']);
disp('---------------------------------------------------------------')
disp(['Project folder : ', project_folder])
disp('---------------------------------------------------------------')

% detection seaexplorer in name
if ~contains(project_folder, 'seaexplorer')
    warning('Only seaexplorer project are supported')
    error('ERROR : the project is not a seaexplorer project')
end

% detection meta in doc
meta_data_folder_type = 'SEA';
list_in_doc = dir(fullfile(project_folder, 'doc', [meta_data_folder_type '*']));
if isempty(list_in_doc)
    error('ERROR : No metadata folder found in \doc')
else
    meta_data_folder = fullfile(list_in_doc(1).folder, list_in_doc(1).name);
    % if it is not a dir, try to unzip it
    if ~list_in_doc(1).isdir
        gunzip(meta_data_folder, list_in_doc(1).folder);
        meta_data_folder = fullfile(list_in_doc(1).folder, list_in_doc(1).name(1:end-4));
    end
end

% detection if sample file already exist
list_in_meta = dir(fullfile(project_folder, '\meta\*.txt'));
if ~isempty(list_in_meta)
    warning('There is already a meta data file in \meta. IT WILL BE ERASED')
    erased_old_meta = input('Continue ? ([n]/y) ','s');
    if isempty(erased_old_meta) || erased_old_meta == 'n'
        error('ERROR : Process has been aborted')
    end
    delete(fullfile(project_folder, '\meta\*'));
end
disp('---------------------------------------------------------------')


%% get meta data from dat file
% list of sequences: without "UsedForMerged"
list_of_sequences = dir(fullfile(project_folder, 'raw', '20*'));
idx = cellfun('isempty',regexp({list_of_sequences.name}, 'UsedForMerge'));
list_of_sequences = list_of_sequences(idx);

% volimage;aa;exp,pixelsize
% detection auto first image
% datetime first image


%% get lat-lon from vector meta data
% parcourir les sequences en ouvrant les meta data petit à petit
% a chaque datetime first image, on get les metadata



%% sample file writing
% creation fichier
% add header
% write lines



disp('------------------------------------------------------')

