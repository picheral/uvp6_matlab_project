%% UVP6 analyse d'images tomographie pour etude intensité / shutter
% Picheral, 2021/05/02

clear all
close all
clc
scrsz = get(0,'ScreenSize');
warning('OFF');

% Setiings
segmentation = 70;
angle_limit = 2;
figure_plot = 0;     % Figure de contrôle pour chaque image
index = 6;
shutter = [ 16 31 62 125 250 500 1000 2000 4000];
gain =  [30 24 18 12 6 0 0 0 0];

% Size calibration (voir protocole tomographie)
long = input('Enter the number of pixels for 200mm ');
pixel = 200/long;

PS_folder = uigetdir([],'Select puissance_shutter');

% liste des répertoires
light_list = dir([PS_folder]);

data = [];

% Boucle sur les répertoires "verrines"
for m = 3 : size(light_list,1)
    light_dir = light_list(m).name;
    
    % Si repertoire relatif à une verrines
    if strcmp(light_list(m).name(7:8), 'VE')
        
        ligh_number = str2num(light_list(m).name(1:6));
        img_list = dir([light_list(m).folder,'\',light_dir,'\save*.png']);
        
        % Boucle sur les images (shutter/gain)
        for k = 1 : numel(img_list)
            img_shutter =   shutter(k);
            img_gain =      gain(k);
            disp(img_list(k).name)
            
            % Chargement de l'image
            img_origin = imread([light_list(m).folder,'\',light_dir,'\',img_list(k).name]);
            
            % Mise en forme pour que le code d'analyse fonctionne
            img_rot = imrotate(img_origin,90);
            img_black = 0 * img_rot;
            img_rot = img_rot(205:end-204,:);
            img = imrotate(img_black,90);
            img(:,205:end-204) = img_rot;
            %                 imshow(img);
            
            % Calculs sur l'image
            [max_h_profile_i,angle_deg,thick_left,thick_right,mean_left,mean_right,Intensity] = UVP6MeasurementsLight(img,segmentation,angle_limit,pixel,figure_plot,index);
            mean_thick = mean([(thick_right),thick_left]);
            mean_int = mean([(mean_right),mean((mean_left))]);
            
            % Correction de l'intensite en fonction du gain
            if img_gain == 6
                mean_left = mean_left/2;
                mean_right = mean_right/2;
            elseif img_gain == 12
                mean_left = mean_left/4;
                mean_right = mean_right/4;
            elseif img_gain == 18
                mean_left = mean_left/8;
                mean_right = mean_right/8;
            elseif img_gain == 24
                mean_left = mean_left/16;
                mean_right = mean_right/16;
            elseif img_gain == 30
                mean_left = mean_left/32;
                mean_right = mean_right/32;
            end
            
            data_vect = [ligh_number,img_shutter,img_gain,mean_thick,mean_int,max_h_profile_i,angle_deg,thick_left,thick_right,mean_left,mean_right,Intensity'];
            
            % Matrice data
            data = [data;data_vect];
            
            
        end
    end
end

%% Sauvegarde data
cd(PS_folder)
save data.mat data

var_names = {'ligh_number';'img_shutter';'img_gain';'mean_thick';'mean_int';'max_h_profile_i';'angle_deg';'thick_left';'thick_right';'mean_left';'mean_right'};
T = array2table(data(:,1:11));
T.Properties.VariableNames = var_names;
writetable(T,'data.txt','delimiter',';');

%% PLots stabilite temperature pour chaque verrine
fig = figure('name','Plots','Position',[50 50 900 450]);
plot(data(:,2),data(:,10),'g+');
hold on
plot(data(:,2),data(:,11),'r+');
hold on
plot(data(:,2),mean([data(:,10) data(:,11)],2),'ko');

 xlabel('Shutter [µS]');
    ylabel('Intensity [0-255]');
    legend('left' ,'right','mean','Location','northwest');
    title(['Intensity linearity of light ',num2str(ligh_number),'VE+']);
    xlim([0 4000]);
    
    
    % ---------------------- Save figure --------------------------------------
    orient tall
    set(gcf,'PaperPositionMode','auto');
    titre = ['Intensity_linearity_shutter_00000',num2str(ligh_number),'VE+'];
    print(gcf,'-dpng',titre);
