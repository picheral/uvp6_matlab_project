function [lon_list, lat_list, yo_list] = GetMetaFromVectorMetaFile(vector_type, meta_data_folder, start_time_list, list_of_sequences)
%GetMetaFromVectorMetaFile get latitude, longitude and yo number
%corresponding to the sequences
%
%
% inputs :
%   vector_type : 'SeaExplorer' or 'SeaGlider'
%   meta_data_folder : full path to vector meta folder
%   start_time_list : list of sequences start time
%   list_of_sequences : dir of sequences folder
%
% output :
%   lon_list : vector of longitude
%   lat_list : vector of latitude
%   yo_list : list of yo nb
%

% get list of meta files
if strcmp(vector_type, 'SeaExplorer')
    % raw.gz for seaexplorer
    list_of_vector_meta = dir(fullfile(meta_data_folder, 'ccu', 'logs', '*raw*'));
    % reorder the list of file to have ...8,9,10,11... and not ...1,100,101,...
    [~, idx] = sort( str2double( regexp( {list_of_vector_meta.name}, '\d+(?=\.gz)', 'match', 'once' )));
    list_of_vector_meta = list_of_vector_meta(idx);
    meta_folder_ccu = list_of_vector_meta(1).folder;
elseif strcmp(vector_type, 'SeaGlider')
    % nc for seaglider
    list_of_vector_meta = dir(fullfile(meta_data_folder, '*.nc'));
    meta_folder_sg = list_of_vector_meta(1).folder;
end

seq_nb_max = length(list_of_sequences);
lon_list = zeros(1, seq_nb_max);
lat_list = zeros(1, seq_nb_max);
yo_list = zeros(1, seq_nb_max);
% sequence number with found meta data
seq_nb = 1;

% find lat-lon directly with time first image
% assume lat-lon is interpolated by the glider
for meta_nb = 1:length(list_of_vector_meta)
    % read metadata from file
    if strcmp(vector_type, 'SeaExplorer')
        meta = ReadMetaSeaexplorer(fullfile(meta_folder_ccu, list_of_vector_meta(meta_nb).name));
    elseif strcmp(vector_type, 'SeaGlider')
        meta = ReadMetaSeaglider(fullfile(meta_folder_sg, list_of_vector_meta(meta_nb).name));
    end
    right_meta = 1;
    % while it is a useful meta data file compared to the datetime of the
    % sequence
    while right_meta == 1 && seq_nb <= seq_nb_max
        time_to_find = start_time_list(seq_nb);
        % check that the datetime of the sequence IS in the file
        % if not, go to the next meta data file
        if (time_to_find >= meta(1,1)) && (time_to_find <= meta(end,1))
           aa =  find(meta(:,1) <= time_to_find);
           disp(['Vector meta data for ' list_of_sequences(seq_nb).name ' found'])
           if strcmp(vector_type, 'SeaExplorer')
               lat_list(seq_nb) = ConvertLatLonSeaexplorer(meta(aa(end), 3));
               lon_list(seq_nb) = ConvertLatLonSeaexplorer(meta(aa(end), 4));
               yo_list(seq_nb) = str2double(list_of_vector_meta(meta_nb).name(21:end-3));
           elseif strcmp(vector_type, 'SeaGlider')
               lat_list(seq_nb) = meta(aa(end), 3);
               lon_list(seq_nb) = meta(aa(end), 4);
               yo_list(seq_nb) = str2double(list_of_vector_meta(meta_nb).name(5:8));
           end
           seq_nb = seq_nb + 1;
        elseif (time_to_find < meta(1,1))
            seq_nb = seq_nb + 1;
        else
            right_meta = 0;
        end
    end
    if seq_nb > seq_nb_max
        break
    end
end



end