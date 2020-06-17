%% Routine de filtrage des fichiers d'un projet UVP5
% permet de créer les fichiers nécessaires à l'importation des données
% filtrées pour les problèmes d'éclairage
% picheral, 2020/06/04

% ----------------------------------------------------------------------------
% lors de l'import dans EcoPart, l'app. lit en premier le sample_datfile.txt dans results_dir
% on modifie donc ce fichier à partir du fichier du work qui ne sera jamais modifié
% ----------------------------------------------------------------------------


clear all
close all
disp('------------------------------------------------------------------------')
disp('------------------ START FILTERING DATFILES ----------------------------')
disp('------------------------------------------------------------------------')
disp('The sample_datfile.txt from the work folder is the source and will NEVER')
disp('be modified.')
disp('The filtered sample_datfile.txt file is saved in the results folder for')
disp('later importation in EcoPart.')
disp('All figures and a resulting matlab base are saved in the results folder.')
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
manual_filter = input('Batch process of all samples using default settings or Manual checking ([b]/m) ? ','s');
if isempty(manual_filter); manual_filter = 'b';end
if strcmp(manual_filter,'m')
    manual_filter = input('Select each sample to process of process all ([a]/s) ? ','s');
    if isempty(manual_filter); manual_filter = 'a';end
end
process_calib = input('Aquarium experiment ([n]/y) ? ','s');
if isempty(process_calib);  process_calib = 'n'; end

% -------------------- Selection m�thode et param�tres par d�faut ----------------
method = input('Select filtration method ([jo]/f) ? ','s');
if isempty(method);method = 'jo';end

if strcmp(method,'c')
    mult =1;
    movmean_window = 25;
    threshold_percent = 0.8;
elseif strcmp(method,'jo')
    mult = 0.5; % multiplier of the quantile under which points are considered outliers
    movmean_window = 16;
    threshold_percent = 0.50;
end

if manual_filter ~= 's'
    mult_entry = input(['Enter multiplier of the quantile under which points are considered outliers [', num2str(mult), '] ']);
    if isempty(mult_entry);    mult_entry = mult;end
    
    movmean_window_entry = input(['Enter moving mean window [', num2str(movmean_window), '] ']);
    if isempty(movmean_window_entry); movmean_window_entry = movmean_window;end
    
    threshold_percent_entry = input(['Enter percent of moving mean for threshold [', num2str(threshold_percent*100), '] ']);
    if isempty(threshold_percent_entry); threshold_percent_entry = threshold_percent;end
    threshold_percent_entry = threshold_percent_entry/100;
else
    mult_entry = mult;
    movmean_window_entry = movmean_window;
    threshold_percent_entry = threshold_percent;
end

%% repertoires
results_dir = [project_folder_ref,'\results\'];
meta_dir = [project_folder_ref,'\meta\'];
base_new = ['baseuvp5_',project_name,'_filtered'];
work_dir = [project_folder_ref,'\work\'];
depth_offset = 1.2;

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
if isfile([results_dir,'baseuvp5_',project_name,'_filtered'])
    % if base filtered exists, it is loaded
    toto=['load ',results_dir,base_new,'.mat;'];
    eval(toto);
    base = base_new;
else
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
end

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
        disp('--------------- PROCESSING DATFILES ------------------------------------');
        for fichier=fichier_deb:fichier_fin
            sample_dir = [work_dir,base(fichier).profilename,'\'];
            disp('------------------------------------------------------------------------');
            disp([num2str(fichier),'/',num2str(fichier_fin),' : loading ',sample_dir,char(base(fichier).profilename), '_datfile.txt'])
            % on charge toujours le fichier à partir du répertoire du sample dans
            % work car ce fichier n'est jamais modifié (fichier original à chaque
            % utilisation de l'outil)
            [Imagelist, Pressure, Temp_interne Peltier Temp_cam Flag Part listecor liste] = uvp5_main_process_2014_load_datfile(base,fichier,sample_dir,depth_offset,process_calib);
            base(fichier).datfile.image = Imagelist;
            base(fichier).datfile.pressure = Pressure/10;
            base(fichier).datfile.temp_interne = Temp_interne;
            base(fichier).datfile.peltier = Peltier;
            base(fichier).datfile.temp_cam = Temp_cam;
            
            % ---------------- Filtrage ----------------------
            % utilise les données chargées ci-dessus
            [im_filtered, part_util_filtered_rejected, movmean_window, threshold_percent, mult] = DataFiltering(listecor,results_dir,base(fichier).profilename,manual_filter,mult_entry,movmean_window_entry,threshold_percent_entry,method);
%             disp(['Movmean_window = ', num2str(movmean_window)])
%             disp(['Threshold_percent = ', num2str(threshold_percent*100)])
            disp(['Number of images from 1st and zmax              = ',num2str(size(listecor,1))])
            dd = find(listecor(:,3) == 1);
            disp(['Number of descent images                        = ',num2str(numel(dd))])
            disp(['Number of rejected images (from descent only)   = ',num2str(numel(part_util_filtered_rejected))])
            disp(['Number of good images (from descent only)       = ',num2str(numel(im_filtered))])
            disp(['Percentage of good images (from descent only)   = ',num2str((100*(numel(dd)-numel(part_util_filtered_rejected))/numel(listecor(:,1))),3)])
            base(fichier).tot_rejected_img = numel(part_util_filtered_rejected);
            base(fichier).tot_utilized_img = numel(im_filtered);
            base(fichier).filter_movmean = movmean_window;
            base(fichier).filter_threshold_percent = threshold_percent*100;
            base(fichier).mult = mult;
            base(fichier).rejected_img = part_util_filtered_rejected;
            base(fichier).filtered_img = im_filtered;
            
            % enregistrement dans results_dir du fichier datfile.txt corrigé
            disp('Saving filtered datfile !')
            file_s = [sample_dir,char(base(fichier).profilename), '_datfile.txt'];
            file_f = [results_dir,char(base(fichier).profilename), '_datfile.txt'];
            write_filtered_datfile(file_s,file_f,im_filtered,0);           
        end
    end
end

%% Enregistrement de la base contenant les données issues du filtrage
disp('------------------------------------------------------------------------');
disp('Saving database, WAIT !');
cd(results_dir);
toto=[base_new,'= base;'];
eval(toto);
toto=['save ',base_new,'.mat ',base_new,];
eval(toto);

disp('------------------ END -------------------------------------------------');

