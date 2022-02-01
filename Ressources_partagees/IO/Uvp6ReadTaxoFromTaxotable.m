function [taxo_ab, taxo_vol, taxo_grey] = Uvp6ReadTaxoFromTaxotable(meta, data, taxo)
% read data (prof, time, taxo,...) from table from uvp6 dat file
% Picheral 2021
%
% meta data and taxo must be cell array with each cell is a line
% Issued from Uvp6DatafileToArray function
%
% vol and grey are sum from all objects
%
% remove overexposed and black data
%
%   input:
%       meta : meta cell array
%       data : LPM data cell array
%       taxo : TAXO data cell array
%   outputs:
%       taxo_ab = [depth,time, flash_tag,ab....];(N cat_number)
%       taxo_vol = [depth,time, flash_tag,vol....];(N cat_number)
%       taxo_grey = [depth,time, flash_tag,grey....];(N cat_number)
%       time_data is in num format

%% read data of the sequence
taxo_ab_temp = [];
taxo_vol_temp = [];
taxo_grey_temp = [];
cat_number = 40;         % MAX 40 categories

% -------- Boucle sur les lignes (images) --------------
for h=1: numel(data)
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
    
    ab_line = zeros(1,cat_number);
    vol_line = zeros(1,cat_number);
    grey_line = zeros(1,cat_number);
    
    % --------- VECTEURS DATA -------------
    if isempty(strfind(data{h},'OVER')) && isempty(strfind(data{h},'EMPTY')) && flash_flag == 1
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
            taxo_reshaped = reshape(taxo_matrix_data,[3,object_number]);
            % ------------ Loop sur categories ---------------
            for i = 1:cat_number
                aa = find(taxo_reshaped(1,:) == i-1);
                if ~isempty(aa)
                    ab_line(i) = numel(aa);
                    vol_line(i) = sum(taxo_reshaped(2,aa));
                    grey_line(i) = sum(taxo_reshaped(3,aa));
                end
            end
        end
    end
    % -------------- Concatenation -------------------
    taxo_ab_temp(h,:) = [depth_data, time_data, flash_flag, ab_line];
    taxo_vol_temp(h,:) = [depth_data, time_data, flash_flag, vol_line];
    taxo_grey_temp(h,:) = [depth_data, time_data, flash_flag, grey_line];
end

%% ----------- Remove "BLACK" images (flag = 0) ---------------
aa = taxo_ab_temp(:,3) == 1;
taxo_ab = taxo_ab_temp(aa,:);
taxo_vol = taxo_vol_temp(aa,:);
taxo_grey = taxo_grey_temp(aa,:);





