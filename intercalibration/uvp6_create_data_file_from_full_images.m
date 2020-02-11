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



%% Boucle sur les sequences sources de RAW
% ------ Liste des répertoires séquence --------
cd(raw_folder);
seq = dir([cd '\2*']);
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
        % ----------------- Ligne HW -----------------
        HWline = fgetl(fid);
        line = fgetl(fid);
        ACQline = fgetl(fid);
        
        
        %% Creation de N répertoires correspondant aux N valeurs de seuil
        for j = 1 :numel(mat_thres)
            % correction noms fichiers et repertoires
            threshold = mat_thres(j);
            if threshold > 9 && threshold < 100
                threstxt = ['0',num2str(threshold)];
            elseif  threshold > 0 && threshold < 100
                threstxt = ['00',num2str(threshold)];
            else
                threstxt = num2str(threshold);
            end
            
            subfolder = [raw_folder,seq(i).name,'_',num2str(threstxt),'\'];
            mkdir(subfolder);
            
            
            % Creation des fichiers DATA pour chaque valeur de Threshold
            cd(subfolder);
            fid_uvp = fopen([seq(i).name,'_',num2str(threstxt),'_data.txt'],'w');
            
            % update the threshold of the HW line
            % the threshold is at the 19th position in the line
            thres_HWline = split(HWline,',');
            thres_HWline(19) = {num2str(threshold)};
            thres_HWline = string(join(thres_HWline,','));
            
            % Copie des lignes HW et ACQ dans ces fichiers DATA            
            fprintf(fid_uvp,'%s\r',thres_HWline);
            fprintf(fid_uvp,'%s\r',line);
            fprintf(fid_uvp,'%s\r',ACQline);
            
            % Fermeture du fichier
            fclose(fid_uvp);
            
            % matrice vide
            %             data_txt_threstxt = [];
            eval(['data_txt_',threstxt,' = {};']);
            
        end
        fclose(fid);
        
        % Table des metadata et data
        T = readtable(path,'Filetype','text','ReadVariableNames',0,'Delimiter',':');
        data = table2array(T(:,2));
        meta = table2array(T(:,1));
        [n,m]=size(data);
              
        %% Boucle sur les lignes du fichier DATA
        disp('----------------- Reading DATA file --------------------------')
        
        
        % détection h pour zmin et zmax
        % h est le numéro d'images
        % la sequence sélectionnée sera la DESCENTE du profil
        hstart = 1;
        hend = 1;
        max_prof_data = -10;
        for h=1:n
            C = strsplit(meta{h},{','});
            time = char(C(1));
            %             time_datenum = datenum(datetime(char(C(1)),'InputFormat','yyyyMMdd-HHmmss'));
            prof_data =  str2num(C{2});
            if (prof_data <= zmin) && (h <= hstart+1)
                hstart = h;
            end
            if (prof_data <= zmax) && (prof_data > max_prof_data)
                hend = h;
                max_prof_data = prof_data;
            elseif (prof_data > zmax)
                break
            end
            last_prof_data = prof_data;
        end
        
        deb = 1;
        index = 0;
        for h=hstart:hend
            index = index+1;
            % progression
            if h/100==floor(h/100)
                disp("image index : " + num2str(h))
            end
            % -------- METADATA -------
            C = strsplit(meta{h},{','});
            time = char(C(1));
            %             time_datenum = datenum(datetime(char(C(1)),'InputFormat','yyyyMMdd-HHmmss'));
            prof_data =  str2num(C{2}); %#ok<*ST2NM>
            temp_data = str2num(C{3});
            Flag = str2num(C{4});
            
            % Dans la gamme de profondeurs
            
            %             if prof_data > zmin && prof_data < zmax
            % creation du nom d'image (fichier image à ouvrir et analyser)
            img_name = [time,'.png'];
            % Test if file exist (and look in subdirectories as well)
            filelist = dir(fullfile([raw_folder,seq(i).name],'\**\',img_name));
            if ~isempty(filelist)                
                % abs path filename
                imgfile_pathname = [filelist.folder, '\',filelist.name];
                % --------- DATA -------------
                if isempty(findstr('OVER',data{h})) %&& isempty(findstr('EMPTY',data{h}))
                    % ouverture image
                    img = imread(imgfile_pathname);
                    % affichage du nom de la première image
                    if deb == 1
                        disp(['First image : ',img_name])
                        deb = 0;
                    end
                    
                    % boucle sur les seuils de segmentation
                    
                    for j = 1 :numel(mat_thres)
                        threshold = mat_thres(j);
                        % DANS MATLAB >=
                        % DANS UVP6 >
                        
                        % Formattage de la valeur de threshold pour affichage 
                        if threshold > 9 && threshold < 100
                            threstxt = ['0',num2str(threshold)];
                        elseif  threshold > 0 && threshold < 100
                            threstxt = ['00',num2str(threshold)];
                        else
                            threstxt = num2str(threshold);
                        end
                        
                        % segmentation
                        % 2020/05/10, correction threshold pour fitter avec HW conf et code embarqué
                        seuil_seg = threshold + 1;
                       
                        img_bw = im2bw(img,seuil_seg/256); % Tableau de la dimension d'une image 2056x2464 contenant des 0 et des 1 pour chaque pixel
                        
                        % extraction des mesures AREA et GREY
                        objects = regionprops(img_bw, img,{'Area','PixelValues'});
                        %             disp(['Processing ' im_list(i).name '...'])
                        % Image dim : 2056 x 2464 pixels
                        
                        % construction vecteur metadata
                        data_line = [time,',',num2str(prof_data),',',num2str(temp_data),',',num2str(Flag),':'];
                        
                        if ~isempty(objects)
                            % il y a au moins UN objet
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
                            data_line = [time,',',num2str(prof_data),',',num2str(temp_data),',',num2str(Flag),':EMPTY_IMAGE;'];
                        end
                        
                        % ajout dans la matrice du threshold
                        eval(['data_txt_',threstxt,'(index) = {data_line};']);
                        
                    end
                end
                %                 end
            end
        end
        disp('----------------- end of DATA file ----------------------')
        
        %% sauvegarde des différents fichiers DATA
        for j = 1 :numel(mat_thres)
            % correction noms fichiers et repertoires
            threshold = mat_thres(j);
            if threshold > 9 && threshold < 100
                threstxt = ['0',num2str(threshold)];
            elseif  threshold > 0 && threshold < 100
                threstxt = ['00',num2str(threshold)];
            else
                threstxt = num2str(threshold);
            end
            disp(['Recording ',seq(i).name,'_',num2str(threstxt),'_data.txt'])
            
            subfolder = [raw_folder,seq(i).name,'_',num2str(threstxt),'\'];
            
            % écriture du fichier DATA (pour chaque valeur de Threshold)
            cd(subfolder);
            fid_uvp = fopen([seq(i).name,'_',num2str(threstxt),'_data.txt'],'a');
            
            % écriture matrice dans fichiers DATA
            eval(['matrice = data_txt_',threstxt,';'])
            
            % boucle sur les lignes
            for m = 1:size(matrice,2)
                fprintf(fid_uvp,'%s\r',line);
                fprintf(fid_uvp,'%s\r',char(matrice{m}));
                
                %                 disp(matrice{m})
            end
            
            % Fermeture du fichier
            fclose(fid_uvp);
            
        end
        %         pause
    end
end
cd(folder);

disp('------------------------ END of PROCESS ----------------------')




