%% Vérification que les Id du projet sont bien dans la liste du mapping
% Picheral, 2017/03

function uvp5_main_process_2014_check_taxa(validated_dir,zoo_list_dir,grouping_file)

probleme = 0;

% -------------- Ouverture fichier grouping ---------------
norm_file = [zoo_list_dir,grouping_file];
if (exist(norm_file)==2);
    [numeric textid] = xlsread(norm_file);
end

% --------------- Ouverture liste du projet ---------------
filename = [validated_dir,'\category_list.txt'];
if exist(filename) == 2
    fid=fopen(filename);
    while 1                     % loop on the number of lines of the file
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        % ------------ Recherche dans le fichier de groupage ------
        aa = sum(strcmp(tline,textid(:,1)));
        if aa < 1
            % ------------ n'existe pas dans la liste -----------
            disp([tline,' is not referenced in ',grouping_file,'.xls. EDIT the file and restart the process !']);
            probleme = 1;
        end
    end
    fclose(fid);
end
if probleme == 1
    disp(['The application is paused ! You MUST complete the ',grouping_file,' file and restart the process !']);
    pause
end