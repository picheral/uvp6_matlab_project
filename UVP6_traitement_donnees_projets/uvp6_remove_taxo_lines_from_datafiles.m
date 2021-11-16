%% Remove taxo lines from data.txt files
% To be run before importation in UVPapp
% Picheral, 2021/11

clear all
close all
warning('off')

disp('---------------------------------------------------------------')
disp('------------------- REMOVE TAXO from data.txt -----------------')
disp('Select PROJECT folder ')
folder = uigetdir('', 'Select PROJECT Folder ');
disp('---------------------------------------------------------------')
disp(['Folder : ',char(folder)])
disp('---------------------------------------------------------------')

%% Liste des sequences
raw_folder = [folder,'\raw\'];
cd(raw_folder)
seq = dir([raw_folder ]);%'\20211101-045640']);
% seq = dir([raw_folder '\20211114-230530']);

%% Boucle sur les sequences
for i=3:size(seq,1)
    data_folder = [raw_folder,seq(i).name,'\'];
    
    cd(data_folder)
    %     data_filename = ['20211101-045640_data.txt'];
    %     data_filename = ['20211114-230530_data.txt'];
    data_filename = [seq(i).name '_data.txt'];
    disp(data_filename)
    
    % Copie de sauvegarde
    backup_data_filename = ['backup_',data_filename];
    eval(['copyfile ' data_filename ' ' backup_data_filename]);
    
    %% read data lines from data file
    [data, meta, taxo] = Uvp6DatafileToArray([data_folder, 'backup_', data_filename]);
    
    if ~isempty(meta)
        %% read HW and ACQ lines from data file
        [HWline, Empty_line, ACQline, Taxoline] = Uvp6ReadMetalinesFromDatafile([data_folder, 'backup_', data_filename]);

        % Ecriture dans fichier sans les lignes taxo
        corr_data_file = fopen([data_filename],'w');
        fprintf(corr_data_file,'%s\n',char(HWline));
        fprintf(corr_data_file,'%s\n',char(Empty_line));
        fprintf(corr_data_file,'%s\n',char(ACQline));
        
        for k = 1 : size(data,1) - 1
            fprintf(corr_data_file,'%s\n',char(Empty_line));
            fprintf(corr_data_file,'%s\n',[char(meta(k)),':',char(data(k))]);
        end
        
        % Fermeture des fichiers et renommage
        fclose(corr_data_file);
    end
    disp('---------------------------------------------------------------')
    
end
disp('------------------------------------------------------')