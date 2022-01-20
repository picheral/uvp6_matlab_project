function [taxo_ab_rs232 ,taxo_vo_rs232,taxo_grey_rs232,lpm_ab_rs232,lpm_grey_rs232] = Uvp6Rs232fileToArray(uvp6_rs232_filename)
% Reads the Teraterm log files "FromUVP"

% The file has been restricted to the time range of the data.txt

% inputs
% uvp6_rs232_filename : path and filename
% time_start : starting time (datenum)
% time_end   : ending time (datenum)

% outputs
% taxo_rs232  :  taxo data
% data_rs232  :  lpm data

% settings
cat_number = 40;         % MAX 40 categories

%% Lecture des données dans le fichier séparées par ","
data_table = readtable(uvp6_rs232_filename,'Filetype','text','ReadVariableNames',0,'Delimiter',']');
[a b] =size(data_table);

%% Data construction in the time range
data = table2array(data_table(:,2));

%% Data construction in the time range
taxo_ab_rs232 = [];
taxo_vo_rs232 = [];
taxo_grey_rs232 = [];
lpm_ab_rs232 = [];
lpm_grey_rs232 = [];
index = 1;
for h = 1 : a - 1
    taxo_txt = char(data(h));
    lpm_txt = char(data(h+1));
    
    % detection ligne taxo hors black
    if contains(taxo_txt,'TAXO_DATA') && contains(lpm_txt,'LPM_DATA') 
                
        % construction des vecteurs
        ab_line = zeros(1,cat_number);
        vo_line = zeros(1,cat_number);
        grey_line = nan *  zeros(1,cat_number);
        
        % TAXO
        ff = strfind(taxo_txt,',');        if numel(ff) > 1
            % au moins un objet classé
            nb_img_taxo = str2num(taxo_txt(ff(1)+1:ff(2)-1));
            taxo = taxo_txt(ff(2)+1:end-1);
            taxo_num = str2num(taxo);
        else
            % pas d'objet classé
            nb_img = str2num(taxo_txt(ff(1)+1:end-1));
            taxo_num = [];
        end
        
        if ~isempty(taxo_num)
            % cas nb_img > 0 et objets identifiés
            taxo_reshaped = reshape(taxo_num,[3,numel(taxo_num)/3]);
            
            % ------------ Loop sur categories ---------------
            for i = 1:cat_number
                aa = find(taxo_reshaped(1,:) == i);
                if ~isempty(aa)
                    ab_line(i) = numel(aa);
                    vo_line(i) = sum(taxo_reshaped(2,aa));
                    grey_line(i) = sum(taxo_reshaped(3,aa));
                end
            end
        end
            
        % LPM      
        ff = strfind(lpm_txt,',');
        depth_data = str2num(lpm_txt(ff(1)+1:ff(2)-1));
        date = lpm_txt(ff(2)+1:ff(3)-1);
        time = lpm_txt(ff(3)+1:ff(4)-1);
        nb_img_lpm = str2num(lpm_txt(ff(4)+1:ff(5)-1));
        lpm = lpm_txt(ff(6)+1:end-1);
        lpm_num = str2num(lpm);
        
        time_data = datenum(datetime([date,'-',time],'InputFormat','yyyyMMdd-HHmmss'));
        
        % -------------- Concatenation -------------------
        taxo_ab_rs232(index,:) = [depth_data, time_data, nb_img_taxo, ab_line];
        taxo_vo_rs232(index,:) = [depth_data, time_data, nb_img_taxo, vo_line];
        taxo_grey_rs232(index,:) = [depth_data, time_data, nb_img_taxo, grey_line];
        lpm_ab_rs232(index,:) = [depth_data, time_data, nb_img_lpm, lpm_num(1:18)];
        lpm_grey_rs232(index,:) = [depth_data, time_data, nb_img_lpm, lpm_num(19:end)];
        
        index = index + 1;
        
    end

end

