function From2022formatToOldUVPData(data_folder, data_filename)
%From2022formattoOldUVPData copy the UVP6 data file and modify the hwconf
%and acqconf line to fit the 2021 format. The original data.txt is archived.
%
% The new file is copied in the same folder of the original file.
%
% inputs :
%   data_folder : path of the folder where the file is
%   data_filename : name of the data file to modify
%
%
    %% read HW and ACQ lines from data file
    [HWline, line, ACQline, ~] = Uvp6ReadMetalinesFromDatafile(fullfile(data_folder, data_filename));

    %% read data lines from data file
    [data, meta] = Uvp6DatafileToArray(fullfile(data_folder, data_filename));

    %% Save old file and create new one
    disp('Save old file and create new one')
    rename = fullfile(data_folder, [data_filename(1:end-4) '_2022format.txt']);
    [~] = movefile(fullfile(data_folder, data_filename), rename, 'f');
    old_standard_file = fopen(fullfile(data_folder, data_filename), 'w');
    disp('------------------------------------------------------')

    %% Compute new hwline and new acqline
    disp('Computing new meta lines')
    HWline = split(HWline, ',');
    new_HWline = {HWline{1:7} '0' HWline{8:13} '193.49.112.100' HWline{14:end}}';
    new_HWline = join(new_HWline, ',');
    ACQline = split(ACQline, ',');
    new_ACQline = {ACQline{1:5} '1' ACQline{6:9} '10' ACQline{10:16} '0' ACQline{17:end}}';
    new_ACQline = join(new_ACQline, ',');
    disp('------------------------------------------------------')

    %% write HW and ACQ lines
    disp('writing new file')
    fprintf(old_standard_file,'%s\n',string(new_HWline));
    fprintf(old_standard_file,'%s\n',line);
    fprintf(old_standard_file,'%s\n',string(new_ACQline));

    %% write data lines in file
    data_table = join([meta,data],':');
    for line_nb = 1:size(data_table,1)
        fprintf(old_standard_file,'%s\n',line);
        fprintf(old_standard_file,'%s\n',string(data_table(line_nb)));
    end
    fprintf(old_standard_file,'%s\n',line);
    disp("Modified file with old standard : " + fullfile(data_folder, data_filename))
    disp("Old file with 2022 standard : " + rename)
    fclose(old_standard_file);
end

