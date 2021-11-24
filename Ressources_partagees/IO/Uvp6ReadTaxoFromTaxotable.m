function [taxo_table] = Uvp6ReadTaxoFromTaxotable(meta, data, taxo)
% read data (prof, time, taxo,...) from table from uvp6 dat file
% Picheral 2021
%
% time_data is in num format
%
% meta and taxo must be cell array with each cell is a line
% T = readtable(path,'Filetype','text','ReadVariableNames',0,'Delimiter',':');
% data = table2array(T(:,2));
% meta = table2array(T(:,1));
%
%   input:
%       meta : meta cell array
%       data : LPM data cell array
%       taxo : TAXO data cell array
%   outputs:
%       taxo_table : [depth,time, flach_tag,ab,... size,.... grey] (50 cat)

%% read data of the sequence
taxo_table_process = [];
cat_number = 50;         % MAX 50 categories

% -------- Boucle sur les lignes (images) --------------
for h=1:n
    %   Affichage progression
    if h/500==floor(h/500)
        disp(num2str(h))
    end
    
    % -------- VECTEURS METADATA -------
    C = strsplit(meta{h},{','});
    date_time = char(C(1));
    try
        time_data = datenum(datetime(date_time(1:19),'InputFormat','yyyyMMdd-HHmmss-SSS'));
    catch
        time_data = datenum(datetime(date_time(1:15),'InputFormat','yyyyMMdd-HHmmss'));
    end
    depth_data =  str2double(C{2});
    flash_flag = str2double(C{4}); % 1 : ON, 0 : OFF
    
    ab_line = zeros(1,50);
    size_line = nan*zeros(1,50);
    grey_line = nan*zeros(1,50);
    
    % --------- VECTEURS DATA -------------
    if isempty(strfind(data{h},'OVER')) && isempty(strfind(data{h},'EMPTY')) && flash_flag == 1)
        % -------- DATA ------------
        % cast the data line in nb_classx4 numerical matrix
        data_matrix = str2num(data{h}); %#ok<ST2NM>
        
        
        % --------- VECTEUR TAXO --------------
        % if 'TAXO:0;' no object to be identified in the image
        % else :
        % Taxo:nn,id,size,grey,id,size,grey,id,size,grey,id,size,grey;
        % nn : number of object classified in the image
        taxo_matrix = str2num(taxo{h}); %#ok<ST2NM>
        
        if taxo_matrix(1) > 0
            % -------- Contains identified objects -----------
            object_number = taxo_matrix(1);
            taxo_matrix_data = taxo_matrix(2:end);
            taxo = reshape(taxo_matrix_data,[3,object_number]);
            % ------------ Loop sur categories ---------------
            for i = 1:cat_number
                aa = find(taxo(1,:) == i);
                if ~isempty(aa)
                    ab_line(i) = numel(aa);
                    size_line(i) = mean(taxo(2,aa));
                    grey_line(i) = mean(taxo(3,aa));
                end
            end
        end
        
        % -------------- Concatenation -------------------
        taxo_table_process(h) = [depth_data, time_data, flash_flag, ab_line, size_line, grey_line];
    end
end

%% ----------- Remove "BLACK" images ---------------
aa = taxo_table_process(:,3) == 1;
taxo_table = taxo_table_process(aa,:);





