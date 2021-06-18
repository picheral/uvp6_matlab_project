function [meta_data_folder, vector_sn] = DetectionVectorMetaFile(project_folder, vector_type)
%DetectionVectorMetaFile detect if there is a meta data file from the
%vector in the project
%
%
% inputs :
%   project_folder : full path of the project
%   vector_type : 'SeaExplorer' or 'SeaGlider'
%
% output :
%   meta_data_folder : full path of metadata vector folder
%   vector_sn : vector name and sn
%
if strcmp(vector_type, 'SeaExplorer')
    list_in_doc = dir(fullfile(project_folder, 'doc', 'SEA*'));
    if isempty(list_in_doc)
        error('ERROR : No metadata folder found in \doc')
    end
    vector = 'Seaeplorer_';
elseif strcmp(vector_type, 'SeaGlider')
    list_in_doc = dir(fullfile(project_folder, 'CTDdata', 'SG*'));
    if isempty(list_in_doc)
        error('ERROR : No metadata folder found in \CTDdata')
    end
    vector = 'SeaGlider_';
end


meta_data_folder = fullfile(list_in_doc(1).folder, list_in_doc(1).name);
% if it is not a dir, try to unzip it
if ~list_in_doc(1).isdir
    gunzip(meta_data_folder, list_in_doc(1).folder);
    meta_data_folder = fullfile(list_in_doc(1).folder, list_in_doc(1).name(1:end-4));
end

disp(['Vector meta data folder : ', list_in_doc(1).name])

vector_sn = [vector list_in_doc(1).name(4:6)];

end