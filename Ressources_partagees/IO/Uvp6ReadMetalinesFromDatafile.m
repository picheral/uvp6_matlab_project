function [hw_line, empty_line, acq_line] = Uvp6ReadMetalinesFromDatafile(file_path)
% read meta data lines from data files
% file_path = [data_folder, data_filename];
%
% Catalano, 2021/06/08

% open files
data_file = fopen(file_path);

% read HW and ACQ lines from data file
hw_line = fgetl(data_file);
acq_line = fgetl(data_file);
if isempty(acq_line)
    empty_line = acq_line;
    acq_line = fgetl(data_file);
else
    empty_line = fgetl(data_file);
    if ~isempty(empty_line)
        disp('WARNING : no empty line found in dat file')
    end
end

% close files
fclose(data_file);

end

