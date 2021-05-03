%% UVP6 analyse d'images tomographie pour etude stabilité/voltage
% Picheral, 2021/05/02

clear all
close all
clc
scrsz = get(0,'ScreenSize');
warning('OFF');

% Setiings
segmentation = 50;
angle_limit = 2;
figure_plot = 0;     % Figure de contrôle pour chaque image
volt_list = [10 12 15 18 21 24 27];

% Size calibration (voir protocole tomographie)
long = input('Enter the number of pixels for 200mm ');
pixel = 200/long;

IV_folder = uigetdir([],'Select Intensity_voltage folder');

% liste des répertoires
temp_list = dir([IV_folder]);

data = [];

% Boucle sur les répertoires "temperature"
for m = 3 : size(temp_list,1)
    rep_temp = temp_list(m).name;
    temperature = str2num(rep_temp(1:2));
    disp(rep_temp)
    
    % Si repertoire relatif à une temperature, boucle sur les verrines
    if strcmp(rep_temp(4:end), 'degree')
        light_list = dir([temp_list(m).folder,'\',temp_list(m).name]);
        
        % Boucle sur les verrines
        for j = 3:numel(light_list)
            img_dir = [temp_list(m).folder,'\',temp_list(m).name,'\',light_list(j).name];
            ligh_number = str2num(light_list(j).name(1:6));
            img_list = dir([img_dir,'\save*.png']);
            cd(img_dir)
            disp(img_dir)
            
            % Boucle sur les images
            for k = 1 : numel(img_list)
                voltage = volt_list(k);
                
                % Chargement de l'image
                img_origin = imread(img_list(k).name);
                
                % Mise en forme pour que le code d'analyse fonctionne
                img_rot = imrotate(img_origin,90);
                img_black = 0 * img_rot;
                img_rot = img_rot(205:end-204,:);
                img = imrotate(img_black,90);
                img(:,205:end-204) = img_rot;
                %                 imshow(img);
                
                % Calculs sur l'image
                [max_h_profile_i,angle_deg,thick_left,thick_right,mean_left,mean_right,Intensity] = UVP6_measurements_light(img,segmentation,angle_limit,pixel,figure_plot);
                mean_thick = mean([(thick_right),thick_left]);
                mean_int = mean([(mean_right),mean((mean_left))]);
                
                data_vect = [ligh_number,temperature,voltage,mean_thick,mean_int,max_h_profile_i,angle_deg,thick_left,thick_right,mean_left,mean_right,Intensity'];
                
                % Matrice data
                data = [data;data_vect];
                
            end
        end
    end
end

%% Sauvegarde data
cd(IV_folder)
save data.mat data

var_names = {'ligh_number';'temperature';'voltage';'mean_thick';'mean_int';'max_h_profile_i';'angle_deg';'thick_left';'thick_right';'mean_left';'mean_right'};   
T = array2table(data(:,1:11));
T.Properties.VariableNames = var_names;
writetable(T,'data.txt','delimiter',';');

%% PLots stabilite temperature pour chaque verrine
% Liste des lights
light_list = unique(data(:,1));
% Liste des temperatures
temp_list = unique(data(:,2));

% Boucle sur les lights
for i = 1 : numel(light_list)
    aa = find(data(:,1) == light_list(i));
    data_ver = data(aa,:);
    
    fig = figure('name','Raw image','Position',[50 50 900 450]);
    % Plot I = f(T)
    subplot(1,2,1)
    % Boucle sur les voltages
    for j = 1 : numel(volt_list)
        bb = find(data_ver(:,3) == volt_list(j));
        mean_int_plot = mean([data_ver(bb,10) data_ver(bb,11)],2);
        plot(temp_list,mean_int_plot);
        hold on
    end
    xlabel('Temperature [°C]');
    ylabel('Intensity mean [0-255]');
    legend('10 volt' ,'12 volt','15 volt','18 volt', '21 volt', '24 volt', '27 volt','Location','northwest');
    title(['Temperature stability light ',num2str(light_list(i)),'VE+']);
    ylim([26 32]);
    
    % Plot Thickness = f(T)
    subplot(1,2,2)
    % Boucle sur les voltages
    for j = 1 : numel(volt_list)
        bb = find(data_ver(:,3) == volt_list(j));
        mean_int_plot = mean([data_ver(bb,8) data_ver(bb,9)],2);
        plot(temp_list,mean_int_plot);
        hold on
    end
    xlabel('Temperature [°C]');
    ylabel('Thickness mean [mm]');
    legend('10 volt' ,'12 volt','15 volt','18 volt', '21 volt', '24 volt', '27 volt','Location','northwest');
    title(['Temperature stability light ',num2str(light_list(i)),'VE+']);
    ylim([20 25]);
    
    % ---------------------- Save figure --------------------------------------
    orient tall
    set(gcf,'PaperPositionMode','auto');
    titre = ['Temperature stability_00000',num2str(light_list(i)),'VE+'];
    print(gcf,'-dpng',titre);
end