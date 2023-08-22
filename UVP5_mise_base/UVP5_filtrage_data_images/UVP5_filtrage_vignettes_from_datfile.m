%% Routine de filtrage des fichiers d'un projet UVP5
% permet de tagger à 2 les vignettes du work issues d'une image qui manque (filtrée) dans le DATFILE
% met à jour le PID du work
% impose d'utiliser Zooprocess (create tables ou update metadata) pour propager aux TSV
% filtrées pour les problèmes d'éclairage
% picheral, 2020/11/30

clear all
close all
global Image_name

disp('------------------------------------------------------------------------')
disp('------------------ START FILTERING vignettes ---------------------------')
disp('------------------------------------------------------------------------')
disp('The sample_datfile.txt from the results folder is the source.')
disp('The PID files must contain the Rawvig field (raw vignette name)')
disp('The Tag is set to 2 if the image is not in the datfile.')
disp('------------------------------------------------------------------------')

%% Choix du projet
selectprojet = 0;
while (selectprojet == 0)
    %    disp(['>> Select UVP ',char(type),' project directory']);
    project_folder_ref = uigetdir('V:\',['Select UVP5 root project directory']);
    if strcmp(project_folder_ref(4:6),'uvp')
        selectprojet = 1;
    else
        disp(['Selected project ' project_folder_ref ' is not correct. ']);
    end
end
project_name = project_folder_ref(9:end);

%% option principale
manual_filter = input('Select each sample to process or process all ([a]/s) ? ','s');
if isempty(manual_filter); manual_filter = 'a';end

%% repertoires
meta_dir = [project_folder_ref,'\meta\'];
docs_dir = [project_folder_ref,'\docs\'];
results_dir = [project_folder_ref,'\results\'];
work_dir = [project_folder_ref,'\work\'];
depth_offset = 1.2;
process_calib = 'n';

%% Existence du fichier header
if isfolder(meta_dir)
    disp([meta_dir,' folder exists.']);
    % Existence d'un fichier entete
    meta_file = ['uvp5_header_',project_name,'.txt'];
    meta = exist([meta_dir,meta_file]);                 % 2 si OK
    if meta == 2; disp([meta_file,' exists.']);
    else
        disp([meta_file,' DOES NOT exist !!!!!!!.']);
    end
else
    disp(['No ',meta_dir,' folder. You MUST fill metadata and process profiles in Zooprocess ! ']);
end

%% test if filtered database exists
% if isfile([results_dir,'baseuvp5_',project_name,'_filtered.mat'])
%     % if base filtered exists, it is loaded
%     toto=['load ',results_dir,base_new,'.mat;'];
%     eval(toto);
%     eval(['base = ',base_new,';']);
%     disp(['Previous database ','baseuvp5_',project_name,'_filtered',' loaded'])
%     recover_settings = input('Recover settings from previous process if exist ([y]/n) ? ','s');
%     if isempty(recover_settings); recover_settings = 'y';end
% else
    % lecture des metadata et creation base
    meta_file = ['uvp5_header_',project_name,'.txt'];
    fid=fopen([meta_dir,meta_file]);
    base = [];
    compteur = 0;
    while 1                     % loop on the number of lines of the file
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        % Suppression ligne d'entete
        if compteur > 0
            %     disp(tline);
            dotcom=findstr(tline,';');  % find the dotcoma index
            base(compteur).filename = tline(dotcom(2)+1:dotcom(3)-1);
            base(compteur).profilename = tline(dotcom(3)+1:dotcom(4)-1);
            base(compteur).firstimage = str2num(tline(dotcom(8)+1:dotcom(9)-1));
            base(compteur).lastimage = str2num(tline(dotcom(18)+1:dotcom(19)-1));
        end
        compteur = compteur +1;
    end
    fclose(fid);
% end

%% Main process
process = 1;
while process == 1
    if strcmp(manual_filter,'s')
        % sample per sample, affichage liste des samples
        disp('-------------------- SELECT SAMPLE NUMBER ------------------------------');
        for fichier=1:numel(base)
            disp([base(fichier).filename,'  ',base(fichier).profilename,' : ',num2str(fichier)])
        end
        disp('------------------------------------------------------------------------');
        sample = input('Input sample number (9999 to end) ? ');
        if sample == 9999; process = 0; end
        fichier_deb = sample;
        fichier_fin = sample;
    else
        % process all samples
        fichier_deb = 1;
        fichier_fin = numel(base);
        process = 0;
        sample = 1;
    end
    
    %% Boucle sur les fichiers à traiter
    % Filtrage et enregistrement fichier résultant après archivage original
    
    if sample ~= 9999
        disp('------------------------------------------------------------------------');
        disp('--------------- PROCESSING VIGNETTES -----------------------------------');
        for fichier=fichier_deb:fichier_fin
            % ---------- Chargement DATFILE du RESULTS --------------------
            % on charge toujours le fichier à partir du répertoire Results où sont sauvegardés les fichiers filtrés
            disp('------------------------------------------------------------------------');
            disp([num2str(fichier),'/',num2str(fichier_fin),' : loading filtered ',results_dir,char(base(fichier).profilename), '_datfile.txt'])
            [Imagelist, Pressure, Temp_interne, Peltier, Temp_cam, Flag, Part, listecor] = uvp5_main_process_2014_load_datfile(base,fichier,results_dir,depth_offset,process_calib);
            base(fichier).datfile.image = Imagelist;
            
            % --------- Déplacement du PID dans docs ------------------------            
            file_f = [work_dir,base(fichier).profilename,'\',base(fichier).profilename,'_dat1.pid'];
            file_s = [docs_dir, char(base(fichier).profilename),'_dat1_source.pid'];
            
            cd([work_dir,base(fichier).profilename,'\']);
            eval(['copyfile ', char(base(fichier).profilename), '_dat1.pid ', docs_dir, ';'])
            cd(docs_dir)
            eval(['movefile ', char(base(fichier).profilename), '_dat1.pid ', char(base(fichier).profilename), '_dat1_source.pid ', ';'])           
            
            
            % --------- Chargement PID du DOCS, modification et écriture dans WORK ----------------------------
            fid_s = fopen(file_s);
            
            % fichier filtre
            fid_f = fopen(file_f,'w');
            
            % ------- Recherche [Data] et copie section LOG ----------
            index = 1;
            while 1
                tline = fgetl(fid_s);
                % disp(tline);                
                if ~ischar(tline); disp('EOF'); break; end
                if strcmp(tline,'[Data]'), break, end
                % ----------- Ecriture --------------
                fprintf(fid_f,'%s\n',char(tline));
                index = index + 1;
            end
            
            % --------- [Data] ------------------
            fprintf(fid_f,'%s\n',char(tline));
            
            % ------ Position Rawvig -----------
            tline = fgetl(fid_s);
            % aa= sum(tline == ';');
            dotcom = findstr(tline,';');
            texte = tline(dotcom(end)+1:end);
            
            % --------- Entete -------------------
            fprintf(fid_f,'%s\n',char(tline));
            vig = 0;
            removed_vig = 0;
            while 1
                tline = fgetl(fid_s);
                if ~ischar(tline); break;end                
                dotcom = findstr(tline,';');
                rawimg = tline(dotcom(end-1)+1:dotcom(end)-6);
                % --------- Test présence dans ImageList ---------------
                aa = strcmp(Image_name,rawimg);
%                 aa = strcmp(Image_name,"20191103131930_632");
%                 sum(aa)
                                
                if sum(aa) >0 
                    % ----------- IN Imagelist --------------
%                     new_line = tline;
                    new_line = [tline(1:dotcom(end)),'1'];
                else
                    % ----------- NOT in ImageList ----------
                    new_line = [tline(1:dotcom(end)),'2'];
%                     disp([ 'filtered ',new_line])
                    removed_vig = removed_vig +1;
                end
                fprintf(fid_f,'%s\n',char(new_line));      
                vig = vig+1;
            end
            disp(['Removed vignettes : ',num2str(removed_vig),' / ',num2str(vig)])
            %% --------------- Fermeture des fichiers -------------
            fclose(fid_s);
            fclose(fid_f);
        end
    end
end
disp('------------------ END of filtering ------------------------------------');
disp('DO NOT FORGET TO CREATE the ECOTAXA TABLES in ZOOPROCESS ---------------');
disp('------------------------------------------------------------------------');

