%% UVP6 Concatener multiples fichiers DATA
% Correction des trames 'AWI' avant flag "eclairage"
% Picheral 2019/12/20

clear all
close all

disp('------------------- START CONCATENATION FICHIERS DATA UVP6 --------------')

% ----------- Choix du repertoire contenant les séquences -------------
disp('Select the folder containing all sequences folders to concatenate ')
folder = uigetdir('Select Folder ');

cd(folder);

% ----------- Choix du repertoire Projet -------------
disp('Select the project folder ')
folder_root = uigetdir('Select Folder ');
% folder_store = uigetdir('Select Folder ');

% ------ Liste des répertoires séquence --------
seq = dir([cd '\2*']);
N_seq = size(seq,1);

% ----------- Boucle sur les séquences ------------
j= 1;
while j < N_seq+1
    disp('---------------------------------------------------------------')
    txt = [seq(j).name,'_data.txt'];
    disp(txt);
    
    % path is the path for the text file stored in each sequence folder
    path = [folder,'\',seq(j).name '\' txt];
    fid = fopen(path);

    tline_hw = fgetl(fid);
    tline_cr = fgetl(fid);
    tline_acq = fgetl(fid);
    tline_cr = fgetl(fid);
    
        
    % ---- premiere sequence : creationn fichier final et folder data ---------
    if j == 1
        % ---------- Folder data --------------
        folder_store = [folder_root,'\',seq(j).name];
        mkdir(folder_store);
        % ---------- Fichier data -------------
        fid_uvp = fopen([folder_store,'\',seq(j).name,'_data.txt'],'w');
        fprintf(fid_uvp,'%s\n',tline_hw);
        fprintf(fid_uvp,'%s\n',tline_cr);
        fprintf(fid_uvp,'%s\n',tline_acq);
        fprintf(fid_uvp,'%s\n',tline_cr);
    end

    % ----------- Ajout des données dans la séquence globale ---
    while ~feof(fid)
        tline = fgetl(fid);
        % ---------------- Correction trame data pour flag (AWI) ---------------
        % NOK :
        % tline = '20180811-205804,45.22,2.50:1,2468,3.8,1.4;2,291,3.7,1.3;3,143,4.0,1.5';
        % OK :
        % tline = '20190724-123644,93.47,28.63,1:1,830,40.6,11.4;2,54,47.0,16.0;3,10,56.9,21.8'
        % ---------------- Cas 'nan' ----------------------------------
        flag = 0;
%         if ~isempty(tline)                   
        ee = strfind(tline,'nan');
        if isempty(ee)
            tt = 2;
            % ------------- Recherche du second '.' ------------------------
            aa = find(tline == '.');
            % ------------- Recherche ':' qui suit -------------------------
            bb = find(tline(aa(tt):end)== ':');
            % ------------- Composition de la ligne ------------------------
            tline_cor = [tline(1:aa(2)+ bb(1) - 2),',1',tline(aa(2)+ bb(1) - 1:end)];
            fprintf(fid_uvp,'%s\n',tline_cor);
            flag = 1;
        else
            disp(tline)
        end
        tline = fgetl(fid);
        if flag == 1
            % -------------ligne vide -------------------------------------           
            fprintf(fid_uvp,'%s\n',tline);
        end
    end
    
    % ------------------- Déplacement des vignettes ---------------
    list_vig = dir([folder,'\',seq(j).name '\*.vig']);
    if numel(list_vig) > 0  
        mkdir([folder_store,'\',num2str(j)]);
        for kk = 1 : numel(list_vig)
            source = [list_vig(kk).folder,'\',list_vig(kk).name];
            destination = [folder_store,'\',num2str(j),'\',list_vig(kk).name];
            movefile(source,destination);
        end
    end
    
    j = j+1;
end

% ----------- Fermeture du ficher global --------------
fclose(fid_uvp);

% ----------- FIN ------------------------------------------
disp('------------------- END CONCATENATION FICHIERS DATA UVP6 --------------')