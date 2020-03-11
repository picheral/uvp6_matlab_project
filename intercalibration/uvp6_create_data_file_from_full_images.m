%% Analyse full images from UVP6 profile and create DATA.txt files
% to detect best threshold to fit with "gold" UVP
% Creates DATA files for different thresholds
% Data will be analysed with specific tools
% Uses png images converted by imageconverter.txt
% Picheral Marc 07/2019

clear all
close all

warning('off','all')

disp('------------------------------------------------------')
disp('--------------- START PROCESS ------------------------')
disp('------------------------------------------------------')
disp('------------------- OPTIONS --------------------------')

%% Choix du projet
disp('Select PROJECT folder ')
folder = uigetdir('', 'Select PROJECT Folder ');
disp('---------------------------------------------------------------')
disp(['Folder : ',char(folder)])
disp('---------------------------------------------------------------')

% ----- RAW folder -----------------------------
raw_folder = [folder,'\raw\'];
results_folder = [folder,'\results\'];

%% Settings
% depth range
zmin = input('Min depth for all profiles (default = 100) ? ');
if isempty(zmin);zmin = 100; end

zmax = input('Max depth for all profiles (default = max) ? ');
if isempty(zmax);zmax = 100000; end

% gamme threshold selon fonction de transfert
mat_thres = input('Input threshold matrix (log1:1 = [17:1:28] = default, log1:2 = [10:5:30]) ');
if isempty(mat_thres); mat_thres = [17:1:28]; end

% create threshold in txt format for dealing with files and folders
threstxt = strings(numel(mat_thres),1);
for j = 1 :numel(mat_thres)
    % correction noms fichiers et repertoires
    threshold = mat_thres(j);
    if threshold > 9 && threshold < 100
        threstxt(j) = ['0',num2str(threshold)];
    elseif  threshold > 0 && threshold < 100
        threstxt(j) = ['00',num2str(threshold)];
    else
        threstxt(j) = num2str(threshold);
    end
end
threstxt = char(threstxt);


%% Boucle sur les sequences sources de RAW
% ------ Liste des répertoires séquence --------
cd(raw_folder);
seq = dir([cd '\20200221-09*']);
N_seq = size(seq,1);

for i = 1 : N_seq
    % test de la longueur des noms de repertoire pour éviter de partir d'une séquence fille
    if size(seq(i).name,2) == 15
        % affichage du nom de la sequence
        disp('---------------------------------------------------------------')
        disp(['Sequence : ',seq(i).name])
        % Ouverture des fichiers data pour lecture des trames HW et ACQ
        path = [raw_folder,seq(i).name,'\',seq(i).name, '_data.txt'];
        fid = fopen(path);
        % ----------------- Ligne HW and ACQ -----------------
        HWline = fgetl(fid);
        line = fgetl(fid);
        ACQline = fgetl(fid);
        fclose(fid);
        
        %% Boucle sur les lignes du fichier DATA
        disp('----------------- Reading DATA file --------------------------')
        
        % Table des metadata et data
        T = readtable(path,'Filetype','text','ReadVariableNames',0,'Delimiter',':');
        data = table2array(T(:,2));
        meta = table2array(T(:,1));
        [n,m]=size(data);        
        
        % détection h pour zmin et zmax
        % h est le "numéro" d'images
        % La sequence sélectionnée sera la DESCENTE du profil
        % Obligation de parcourir tout le fichier dans le cas où zmax>max_prof,
        % car il faut détecter la profondeur max en faisant attention aux
        % yoyo
        hstart = 1;
        hend = 1;
        max_prof_data = -10;
        for h=1:n
            C = strsplit(meta{h},{','});
            prof_data =  str2double(C{2});
            if (prof_data <= zmin) && (h <= hstart+1)
                hstart = h;
            end
            if (prof_data <= zmax) && (prof_data > max_prof_data)
                hend = h;
                max_prof_data = prof_data;
            elseif (prof_data > zmax)
                break
            end
        end
        
        % loop on each lines of data file
        show_first_image_name = 1;
        % creation of threshold data array
        data_lines_nb = hend - hstart + 1;
        data_txt_threshold = strings(numel(mat_thres),data_lines_nb);
        % h est le "numéro" de ligne de data, donc d'images, dans le
        % fichier original
        % index est le numero de ligne dans le nouveau fichier
        index = 0;
        for h=hstart:hend
            index = index + 1;
            % progression
            if h/100==floor(h/100)
                disp("image index : " + num2str(h))
            end
            % -------- METADATA -------
            C = strsplit(meta{h},{','});
            time = C{1};
            prof_data =  C{2};
            temp_data = C{3};
            Flag = C{4};
            
            % creation du nom d'image (fichier image à ouvrir et analyser)
            img_name = [time,'.png'];
            % Test if file exist (and look in subdirectories as well)
            filelist = dir(fullfile([raw_folder,seq(i).name],'\**\',img_name));
            if ~isempty(filelist)
                % abs path filename
                imgfile_pathname = [filelist.folder, '\',filelist.name];
                % --------- DATA -------------
                if isempty(strfind(data{h},'OVER'))
                    % ouverture image
                    img = imread(imgfile_pathname);
                    % affichage du nom de la première image
                    if show_first_image_name == 1
                        disp(['First image : ',img_name])
                        show_first_image_name = 0;
                    end
                    
                    % boucle sur les seuils de segmentation
                    for j = 1 :numel(mat_thres)
                        % ATTENTION ! DANGER !
                        % DANS MATLAB >=
                        % DANS UVP6 >
                        % segmentation
                        % 2020/05/10, correction threshold pour fitter avec HW conf et code embarqué
                        seuil_seg = mat_thres(j) + 1;
                        img_bw = imbinarize(img,seuil_seg/256); % Tableau de la dimension d'une image 2056x2464 contenant des 0 et des 1 pour chaque pixel
                        
                        % extraction des mesures AREA et GREY
                        objects = regionprops(img_bw, img,{'Area','PixelValues'});
                        % Image dim : 2056 x 2464 pixels
                        
                        if ~isempty(objects)
                            % il y a au moins UN objet
                            % construction vecteur metadata
                            data_line = [time,',',prof_data,',',temp_data,',',Flag,':'];
                            % ----------- Vecteurs ------------------------------------
                            area = cat(1,objects.Area);
                            mean_px = NaN * zeros(numel(area),1);
                            
                            % ------------ Gris moyen par objet -----------------------
                            for m = 1 : numel(area)
                                mean_px(m) = mean(objects(m).PixelValues);
                            end
                            
                            % construction des vecteurs data, boucle sur les valeurs d'area
                            area_min = min(area);
                            area_max = max(area);
                            for a = area_min:area_max
                                aa = find(area == a);
                                % si au moins un objet
                                if ~isempty(aa)
                                    nb_area = numel(aa);
                                    grey_area = mean(mean_px(aa));
                                    std_area = std(mean_px(aa));
                                    data_line = [data_line,num2str(a),',',num2str(nb_area),',',num2str(grey_area),',',num2str(std_area),';'];
                                    
                                end
                            end
                        else
                            % aucun objet dans l'image
                            data_line = [time,',',prof_data,',',temp_data,',',Flag,':EMPTY_IMAGE;'];
                        end
                        
                        % ajout dans la matrice du threshold
                        data_txt_threshold(j,index) = data_line;
                    end
                end
            end
        end
        disp('----------------- end of DATA file ----------------------')
        
        
        %% sauvegarde des différents fichiers DATA
        for j = 1 :numel(mat_thres)
            %% Creation de N répertoires et N fichiers correspondant aux N valeurs de seuil
            disp(['Recording ',seq(i).name,'_',threstxt(j),'_data.txt'])
            
            % correction noms fichiers et repertoires
            subfolder = [raw_folder,seq(i).name,'_',threstxt(j),'\'];
            mkdir(subfolder);
            
            % Creation des fichiers DATA pour chaque valeur de Threshold
            cd(subfolder);
            fid_uvp = fopen([seq(i).name,'_',threstxt(j),'_data.txt'],'w');
            
            % update the threshold of the HW line
            % the threshold is at the 19th position in the line
            thres_HWline = split(HWline,',');
            thres_HWline(19) = {num2str(mat_thres(j))};
            thres_HWline = string(join(thres_HWline,','));
            
            % Copie des lignes HW et ACQ dans ces fichiers DATA            
            fprintf(fid_uvp,'%s\n',thres_HWline);
            fprintf(fid_uvp,'%s\n',line);
            fprintf(fid_uvp,'%s\n',ACQline);
            
            
            %% save data files            
            % écriture du fichier DATA (pour chaque valeur de Threshold)            
            % écriture matrice dans fichiers DATA            
            % boucle sur les lignes
            for m = 1:data_lines_nb
                fprintf(fid_uvp,'%s\n',line);
                fprintf(fid_uvp,'%s\n',data_txt_threshold(j,m));
            end
            
            % Fermeture du fichier
            fclose(fid_uvp);
            
        end
    end
end
cd(folder);

disp('------------------------ END of PROCESS ----------------------')



