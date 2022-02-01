%%
% *Calcul volume éclairages Octopus*
% Verrine VERTICALE avec normalisation intensité
% Pas de compensation du vignetage
% Picheral 2018/11/14


disp('--------------------------- START -------------------------------');
disp('---------------- NO correction for vigneting --------------------')
clear all; close all
warning('off');
image_x = 2464;
image_y = 2056;
% distance_axe_verrine_depoli_first_image = 70;
distance_inter_images = 20;
decalage_axe_verrine_axe_camera = 250;
segmentation = 14;
% pixel_size = 0.1156; % ( 275mm/2378px)
% seuil_net = 30;
% id_start = 10;
% seuil_vol_fixe = 20;

scrsz = get(0,'ScreenSize');
%% DATE analyse
%%
disp(datestr(now,31))
%% PEOPLE analyse
%%
people = input('Enter people first and last name (Marc Picheral) ','s');
if isempty(people); people = 'Marc Picheral'; end
disp(['Processing operator : ' char(people)]);
%% IMAGE DATA
%%
disp('Select folder containing the light images ' );
drive_root = uigetdir([],'Select light directory');
cd(char(drive_root));
%% Image acquisition date & light numbers
%%
% aa = findstr(drive_root,'\');
% date_vue = drive_root(aa(end-1)+1:aa(end)-1);year = date_vue(1:4);month = date_vue(5:6);day = date_vue(7:8);
% list_dir = dir(drive_root);lightsn = drive_root(aa(end)+1 : end);

lightsn = input('Input light number (XXX) ','s');
date = input('Enter date (YYYYMMDD) ','s');

%% ------------- Settings -------------

Lref_mm = 275;
% a : hauteur du centre du faisceau (1012)
% b : x fin flèche gauche (50)
% c : x fin flèche droite (1994)
% d : hauteur selectionnée (1000)
% disp('START LOADING IMAGES');
ax = input('Hauteur du centre du faisceau (930) ');
if isempty(ax); ax = 930; end
bx = input('Fin flèche gauche (54) ');
if isempty(bx); bx = 54; end
cx = input('Fin flèche droite (2430) ');
if isempty(cx); cx = 2430; end
dx = input('Hauteur sélectionnée (1000) ');
if isempty(dx); dx = 1000; end
Lref_mm = input(['Distance in mm beetween the two arrows : (',num2str(Lref_mm), ' mm) ']);
if isempty(Lref_mm);    Lref_mm = 275;  end
light_type = input(['Type of light (ve/ho) ? '],'s');
if isempty (light_type) ; light_type = 've'; end

orient = input('Long side along light (n/y) ? ','s');
if isempty(orient); orient = 'n';end

if strcmp(light_type,'ve'); longmms = 151;level = [-9:2:9];segmentation = 10;end
if strcmp(light_type,'ho');longmms = 180;level = [-10:2:10]; segmentation = 20;end
longmm = input(['Lenght of side parallel to light tube (default : ',num2str(longmms),' mm)  ']);
if isempty(longmm);    longmm = longmms;    end
% level = input('Image distances from center (default : [-10:2:10]) ');
% level = input('Image distances from center (default : [-9:2:9]) ');
% if isempty(level); level = [-10:2:10]; end
% if isempty(level); level = [-9:2:9]; end
% cor_img = input('Correction factor for the intensity (default = 1) ');
% if isempty(cor_img); cor_img = 1;end

Lref_pixels = cx-bx;
large = image_x*longmm/image_y;
px = Lref_mm/Lref_pixels;

% longueur en pixels pour la longueur image en mm correcpondante
longpx = longmm / px;

%% ----------- Chargement des images -------------
cd(drive_root);
list_img = dir('save*.png');
Centre = [];
index = 1;
Eclairage = [];
%% Boucle sur les images
for gg= 1:numel(list_img)%5:15
    % Ouverture image
    photo = ([drive_root,'\',list_img(gg).name]);
    if contains(char(photo),'save')
        disp([num2str(gg),' Processing ',char(photo)])
        [im,map] = imread(photo);
        
        % Crop
        %     aa = double(im(a-d/2:a+d/2,b:c));
        aa = (im(ax-dx/2:ax+dx/2,bx:cx));
        
        % Resize
        aa = imresize(aa, 10*(Lref_mm)/Lref_pixels);
        
        % Rotate
        im = imrotate(aa,90);
        
        % Moyenne des trois canaux RGB => img2
        %     im2 = mean(im,3);
        im2 = im;
        
        % Centrage de l'image, pas de traitement en rotation
        %     test=median(im2(:,:));
        test = mean(im2,1);
        M=max(test);
        h1=find(test>M/2);
        h2=find(test>M/3);
        centre=mean([(h1(1)+h2(2))/2,(h1(end)+h2(end))/2]);
        Centre = [Centre centre];
        
        %     disp(['Centre = ',num2str(centre)]);
        % Rognage de part et d'autre du faisceau centre
        %         im3=imcrop(im2,[round(centre-Lref_pixels/10),0,round(Lref_pixels/5),round(Lref_pixels)]);
        [Y X] = size(im2);
        im3=imcrop(im2,[round(centre-X/3),0,round(X*2/3),round(Y)]);
        [a,b]=size(im3);
        
        % Normalisation necessaire pour verrine VERTICALE
        im3_max = max(max(im3));
        im3_min = min(min(im3));
        
        im3_norm = (im3-im3_min).* (256/(double(im3_max) - double(im3_min)));
        
        %% Creation des bases
        % Image source
        Eclairage(index).pic=photo;
        % distance au centre en cm
        Eclairage(index).level=level(index);
        % image retaillee
        Eclairage(index).brut=im3;
        Eclairage(index).norm=im3_norm;
        Eclairage(index).centre=centre;
        Eclairage(index).matr_min = im3_min;
        Eclairage(index).matr_max = im3_max;
        index = index +1;
    end
    
end
Centre = mean(Centre);
%% Sauvegarde base

base = Eclairage;
save eclairage_base.mat Eclairage;
disp('--------------------- Database saved ------------------------');
%% Figure couleur des images
fig = figure('name','Figure normalisee','Position',[50 50 scrsz(3)/1.2 scrsz(4)/2-200]);
for gg=1:numel(base)
    subplot(1,numel(level),gg)
    %     imagesc(base(gg).median,[0 255])
    imagesc(base(gg).norm(round(Y/2- 10*longmm/2):round(Y/2+10*longmm/2),:),[0 255]);
    if gg == 3;    title(['Normalized images'],'fontsize',10);end
    if gg == 1;    ylabel('Image Width [mm x 10]','fontsize',10);end    
end

set (gcf,'PaperPosition',[0 0 70 30]);
saveas(fig,[char(drive_root),'\',char(light_type),char(lightsn),'_',char(date),'_tomographie_images.png']);

disp('--------------------- Figure saved ------------------------');

%% ---------------- Calcul volume ---------------------------
%% --------------- Boucle sur les images ----------------------
fig1 = figure('name','Eclairages Octopus profiles normalises ','Position',[50 50 scrsz(3)/1.2 scrsz(4)/2-200]);
img_width = [];
for gg=numel(base):-1:1
    img = base(gg).norm(round(Y/2 - 10*longmm/2):round(Y/2+10*longmm/2),:);
    data = [];
    centre_img = size(img,2)/2;
    % PLOT   
    subplot(1,numel(base),gg);
    for k=1:200:10*floor(size(img,1)/10)      
        aa = find( img(k,:) > segmentation);
        if isempty(aa)
            data = [data NaN];
        else
            ep = abs(aa(1)-aa(end))/10;
            data = [data ep];
            % centrage
            centre_faisceau = (aa(1)+aa(end))/2;
            decalage = round(centre_img - centre_faisceau);
            plot([20+decalage:size(img,2)-20+decalage],img(k,20:end-20),'k-');
            hold on
            plot([100 600],[segmentation segmentation],'r-');
        end
    end
    img_width(gg,:) = data;
    axis([100 600 0 250]);
    
    if numel(base) == 1
        ylabel('Normalized intensity and threshold ','fontsize',10);
    elseif gg == 4
        title('Intensity profiles) ','fontsize',10);
    end 
end

% Sauvegarde
set (gcf,'PaperPosition',[0 0 70 30]);
saveas(fig1, [char(drive_root),'\',char(light_type),char(lightsn),'_',char(date),'_tomographie_profiles.png']);

% Epaisseur moyenne globale
mean_thick = nanmean(nanmean(img_width));
disp(['Mean thickness = ',num2str( mean_thick,3),' mm']);

% Epaisseur moyenne sur l'axe optique (à 250mm)
mean_thick_center = nanmean(nanmean(img_width(6,:)));
disp(['Mean thickness (optical axe) = ',num2str( mean_thick_center,3),' mm']);

% Volume
volimg = mean_thick * longmm * large / 1000000;
disp(['Image volume = ',num2str(volimg,2),' Litre'])

% Mesure intensité dans l'image proche de l'axe optique (5)
img = base(5).brut(round(Y/2 - 10*longmm/2):round(Y/2+10*longmm/2),:);
[Y X] = size(img);
aa = find( img(round(Y/2),:) > segmentation);
img_crop = img(:,aa(1)+20:aa(end)-20);
intensity = mean(mean(img_crop));

disp(['Intensity (optical axe of camera) = ',num2str(intensity,3)])

% Enregistrement
fid_uvp = fopen([char(light_type),char(lightsn),'_',char(date),'_tomographie.txt'],'w');
fprintf(fid_uvp,'%s\r',['Date                        : ',char(date)]);
fprintf(fid_uvp,'%s\r',['Light reference             : ',char(light_type),char(lightsn)]);
fprintf(fid_uvp,'%s\r',['Mean thickness     [mm]     : ',num2str(mean_thick,3)]);
fprintf(fid_uvp,'%s\r',['Image volume       [L]      : ',num2str(volimg,2)]);
fprintf(fid_uvp,'%s\r',['Intensity (img 5)           : ',num2str(intensity,3)]);
% fprintf(fid_uvp,'%s\r',['PATH                        : ',char(drive_root)]);
fclose(fid_uvp);

disp('-------------------------- END -------------------------')