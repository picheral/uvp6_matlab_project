function [time_data, depth_data, raw_nb, black_nb, image_status] = Uvp6ReadDataFromDattable(meta_table, data_table)
% read data (prof, time, black, raw,...) from table from uvp6 dat file
%
% time_data is in num format
%
% meta_table and data_table must be cell array with each cell is a line
% T = readtable(path,'Filetype','text','ReadVariableNames',0,'Delimiter',':');
% data = table2array(T(:,2));
% meta = table2array(T(:,1));
%
%   input:
%       meta_table : meta cell array
%       data_table : data cell array
%
%   outputs:
%       time_data, prof_data, image_status as num vectors
%       black_nb, raw_nb as vectorsx900
%

%% read data of the sequence    
%Initialisation of the variables updated for each line of the text
%file / each image
[n,m]=size(data_table);
depth_data =     NaN*zeros(n,1);
time_data =     NaN*zeros(n,1);
black_nb =      NaN*zeros(n,900);
raw_nb =        NaN*zeros(n,900);
image_status =  NaN*zeros(n,1);

% -------- Boucle sur les lignes (images) --------------
% h is the number of the line
% n is the max number of lines
% for each image / each text file line
% overexposed = 1
% black = 2
% data = 3

for h=1:n
    if h/500==floor(h/500)
        disp(num2str(h))
    end

    % -------- VECTEURS METADATA -------
    C = strsplit(meta_table{h},{','});
    time_data(h) = datenum(datetime(char(C(1)),'InputFormat','yyyyMMdd-HHmmss'));
    depth_data(h) =  str2double(C{2});
    Flag = str2double(C{4});

    % --------- VECTEURS DATA -------------
    if isempty(strfind(data_table{h},'OVER')) && isempty(strfind(data_table{h},'EMPTY'))
        % -------- DATA ------------
        % cast the data line in nb_classx4 numerical matrix
        temp_matrix = str2num(data_table{h}); %#ok<ST2NM>
        % limit to class of 900 pixels wide objects
        % ------------ Ligne de zeros -----------------------
        line = zeros(1,900);
        [o,p]=size(temp_matrix);
        for k=1:o
            if temp_matrix(k,1)<=900
                line(temp_matrix(k,1)) = temp_matrix(k,2);
            end
        end
        seen_classes_nb = length(line);

        if Flag == 1
            raw_nb(h,:) = 0;
            raw_nb(h,1:seen_classes_nb) = line;
            image_status(h) = 3;
        else
            black_nb(h,:) = 0;
            black_nb(h,1:seen_classes_nb) = line;
            image_status(h) = 2;
        end
    elseif ~isempty(strfind(data_table{h},'OVER'))
        % if the line is overexposed
        image_status(h) = 1;
    elseif ~isempty(strfind(data_table{h},'EMPTY'))
        if Flag == 1
            raw_nb(h,:) = 0;
            image_status(h) = 3;
        else
            black_nb(h,:) = 0;
            image_status(h) = 2;
        end
    end
end


end

