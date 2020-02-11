%% Mise en matrice des données des objets d'images UVP6 acquises en Livecamera
% Fonctionne dans l'architecture projet
% objets, leur coordonnées x et y dans l'image, l'aire en pixel et le niveau
% de gris moyen des pixels
% Date : 19/04/2019

close all
clear all

%% --------- PROJECT FOLDER -------------------
disp('------------------- START -------------------------------------')
disp('Select PROJECT folder ')
folder = uigetdir('Select PROJECT Folder ');
disp('---------------------------------------------------------------')
disp(['Folder : ',char(folder)])
disp('---------------------------------------------------------------')

% ----------------- RAW folder -----------------------------
raw_folder = [folder,'\raw\'];
results_folder = [folder,'\results\'];
doc_folder = [folder,'\doc\'];
filename = folder(4:end);

%Threshold to count pixel < threshold as background
seuil = 2;
threshold = input('Input threshold for segmentation (CR for 2) ');
if isempty(threshold); threshold = seuil; end

% ---------------- CAS "s" : analyse -----------------
% ---------------- CAS "c" : creation de matrices ----
option = input('Process separately or combine by gain value (s/c)','s');
if isempty(option); option = 's'; end

% ------------------- Liste des répertoires ----------------
list_seq = dir(raw_folder);

% ------------------- Valeurs de gain ----------------------
gain_values = [8:30];

if strcmp(option,'s')
    %------------- Boucle sur répertoires ---------------
    for k = 3:numel(list_seq)
        data_final = [];
        if list_seq(k).isdir == 1
            cd([list_seq(k).folder,'\',list_seq(k).name,'\']);
            disp('---------------------------------------------------------------')
            disp(['Sequence ',list_seq(k).name])
            % ------------- Liste des images -------------------
%             im_list = dir('save*.png');
            im_list = dir('2020*.png');
             
            
            
            
            
            
            
            if ~isempty(im_list)
                % --------- Si au moins une image --------------
                base = [];
                disp(['Processing image 1 / ',num2str(numel(im_list))])
                % ------------- Boucle sur les images -----------------------
                for i=1:numel(im_list)
                    if i/50==floor(i/50)
                        disp(['Processing image ',num2str(i),' / ',num2str(numel(im_list))])
                    end
                    %Read the image, switch it to black and white with the preset threshold
                    img = imread(im_list(i).name);
                    img_bw = im2bw(img,threshold/256); % Tableau de la dimension d'une image 2056x2464 contenant des 0 et des 1 pour chaque pixel
                    objects = regionprops(img_bw, img,{'Area','Centroid','PixelValues'});
                    %             disp(['Processing ' im_list(i).name '...'])
                    % Image dim : 2056 x 2464 pixels
                    
                    % ----------- Vecteurs ------------------------------------
                    area = cat(1,objects.Area);
                    centroids = cat(1,objects.Centroid);
                    mean_px = NaN * zeros(numel(area),1);
                    
                    % ------------ Gris moyen par objet -----------------------
                    for m = 1 : numel(area)
                        mean_px(m) = mean(objects(m).PixelValues);
                    end
                    
                    % ------------ Matrice image ------------------------------
                    data_img = [i*ones(numel(area),1) centroids area mean_px];
                    
                    % ------------ Objets supérieurs à 2 pixels ---------------
                    aa = area > 2;
                    data_final = [data_final ;data_img(aa,:)];
                end
            end
        end
        
        disp('------------- SAVING data -----------------------------------')
        eval(['save ',results_folder,'data_',filename(6:10),'_s',num2str(threshold),'_',list_seq(k).name ,'.mat data_final'])
    end
else
    % ----------------- Boucle sur les valeurs de gain --------------------
    for m = 1:numel(gain_values)
        disp('---------------------------------------------------------------')
        if gain_values(m) < 10
            gain = ['g0',num2str(gain_values(m))];
        else
            gain = ['g',num2str(gain_values(m))];
        end
        
        data_final = [];
        %------------- Boucle sur répertoires ---------------
        for k = 3:numel(list_seq)
            if contains(list_seq(k).name,gain,'IgnoreCase',true)
                cd([list_seq(k).folder,'\',list_seq(k).name,'\']);
                disp(['Sequence ',list_seq(k).name])
                % ------------- Liste des images -------------------
                im_list = dir('save*.png');
                if ~isempty(im_list)
                    % --------- Si au moins une image --------------
                    base = [];
                    disp(['Processing image 1 / ',num2str(numel(im_list))])
                    % ------------- Boucle sur les images -----------------------
                    for i=1:numel(im_list)
                        if i/50==floor(i/50)
                            disp(['Processing image ',num2str(i),' / ',num2str(numel(im_list))])
                        end
                        %Read the image, switch it to black and white with the preset threshold
                        img = imread(im_list(i).name);
                        img_bw = im2bw(img,threshold/256); % Tableau de la dimension d'une image 2056x2464 contenant des 0 et des 1 pour chaque pixel
                        objects = regionprops(img_bw, img,{'Area','Centroid','PixelValues'});
                        %             disp(['Processing ' im_list(i).name '...'])
                        % Image dim : 2056 x 2464 pixels
                        
                        % ----------- Vecteurs ------------------------------------
                        area = cat(1,objects.Area);
                        centroids = cat(1,objects.Centroid);
                        mean_px = NaN * zeros(numel(area),1);
                        
                        % ------------ Gris moyen par objet -----------------------
                        for m = 1 : numel(area)
                            mean_px(m) = mean(objects(m).PixelValues);
                        end
                        
                        % ------------ Matrice image ------------------------------
                        data_img = [i*ones(numel(area),1) centroids area mean_px];
                        
                        % ------------ Objets supérieurs à 2 pixels ---------------
                        aa = area > 2;
                        data_final = [data_final ;data_img(aa,:)];
                    end
                end
                
                disp('---------------------------------------------------------------')
                
            end
        end
        if ~isempty(data_final)
            disp('------------- SAVING data -----------------------------------')
            eval(['save ',results_folder,'data_',filename(6:10),'_s',num2str(threshold),'_',gain ,'.mat data_final'])
        end
    end
    
end
disp('------------- END of PROCESS -----------------------------------')