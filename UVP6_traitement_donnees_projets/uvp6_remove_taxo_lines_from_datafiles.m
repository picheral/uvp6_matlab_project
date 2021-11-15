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
seq = dir([raw_folder '\2*']);

%% Boucle sur les sequences
for i=1:size(seq,1)
    seq_folder = [raw_folder,seq(i).name];
    cd(seq_folder)
    data_filename = [seq(i).name '_data.txt'];
    disp(data_filename)
    
    % Copie de sauvegarde
    backup_data_filename = ['backup_',data_filename];
    eval(['copyfile ' data_filename ' ' backup_data_filename]);
    
    % Ouverture fichiers
    source_file = fopen(data_filename,'r');
    corrected_file = fopen('cor_','w');
    
    % Ecriture dans fichier sans les lignes taxo
    tline = fgetl(source_file);
    if strncmp(tline,'HW_CONF',7)
        fprintf(fid,'%s\n','[PID]');
    
    % Fermeture des fichiers et renommage
    
    disp('---------------------------------------------------------------')

end
disp('------------------------------------------------------')