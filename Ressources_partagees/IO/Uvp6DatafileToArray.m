function [data, meta] = Uvp6DatafileToArray(file_path)
% read data lines from data files
% file_path = [data_folder, data_filename];
%
% Catalano, 2021/06/08

data_table = readtable(file_path,'Filetype','text','ReadVariableNames',0,'Delimiter',':');
data = table2array(data_table(:,2));
meta = table2array(data_table(:,1));

end

