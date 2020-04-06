%% Code de test nettete UVP5 et UVP6
% créé le 22/08/2019 Marc Picheral

% laboratoire océanologique de villefranche sur mer
%
clear all
close all
clc
scrsz = get(0,'ScreenSize');
disp('---------------- START ------------------------ ');

%% ------------------- Mode selection ---------------------
option_sel = 'r';

% disp('Selectionner le répertoire dans lequel les images sont enregistrées. ');
dir_img = uigetdir('Select directory');
% dir_img = 'D:\Réglage_mtf\';


last_date= 0;
cd(dir_img);
fin = 0;
% ---- Choix d'afficher la figure de contrôle -----
plot_figure = 0;

% isotropic detector pixel spacing in mm, (i.e. pixel pitch).
isotropicpixelspacing = 0.00345;

% segmentation pour récuperer les centroides (ajuster manuellement)
seuil_segmentation = 0.3;

moyenne_coins_prev = 0;
moyenne_milieux_loins_prev = 0;
moyenne_milieux_proches_prev = 0;
centre_prev = 0;

% ---------- Base "acquisition" ------------------------------
base = [];
centre_vect = [];
index = 0;
% ---------------- Boucle infinie ----------------------------
max_centre = 0;
min_centre = 100;


% base_grey = dir([dir_img,'\save*.png']);

base_grey = dir(dir_img);
% ------- Boucle images ----------------
for m = 1 : numel(base_grey)
    
    % ------------- On ouvre la dernière image enregistrée par la caméra ----
    if ~isempty(strfind(base_grey(m).name,'.png')) || ~isempty(strfind(base_grey(m).name,'.tiff')) || ~isempty(strfind(base_grey(m).name,'.bmp'))
        %     if ~isempty(strfind(base_grey(end).name,'.png')) || ~isempty(strfind(base_grey(end).name,'.tiff'))
        index = index + 1;
        last_date = base_grey(m).datenum;
        Image_name = base_grey(m).name;
        base(index).Image_name = Image_name;
        Image_grey=imread(Image_name);
        
        % -------------- Recherche barycentres ----------------
        %           Image_bw=rgb2gray(Image_grey); %Make it grayscale
        Image_bw= im2bw(Image_grey,seuil_segmentation); %convertir l'image en binaire
        Image_bw = ~Image_bw; %inverser les couleurs noir-blanc pour faciliter le calcul
        %             imshow(Image_bw,[]);
        
        % -------------- Retrait objets touchant les bords --------
        Image_bw = imclearborder(Image_bw);
        
        data_image = regionprops(Image_bw); % structure contenant les mesures
        % ----------- mise en matrice --------------------------
        centroids = [cat(1, data_image.Centroid) [data_image.Area]'];
        
        % ------------ Selection des 9 plus gros objets ---------
        centroids = sortrows(centroids,-3);
        
        % ------------ Selection des 9 centroids de taille "correcte" ----------
        
        aa = find(centroids(:,3) > 4000) ;
        centroids = centroids(aa,:);
        bb = find(centroids(:,3) < 80000);
        centroids = centroids(bb,:);
        % ------------ Tri des centroids -------------------
        %            [ 123
        %             456
        %             789 ]
        
        centroids = sortrows(centroids,2);
        centroids_haut = sortrows(centroids(1:3,:),1);
        centroids_milieu = sortrows(centroids(4:6,:),1);
        centroids_bas = sortrows(centroids(7:9,:),1);
        centroids_trie = [centroids_haut;centroids_milieu;centroids_bas];
        base(index).centroids_trie = centroids_trie;
        
        % ------------- Figure de controle -------------------
        if plot_figure == 1
            fig_ctrl = figure('numbertitle','off','name',char(base(index).Image_name),'Position',[10 50 scrsz(3)/2.2 scrsz(4)-150]);
            scatter(centroids_trie(:,1),centroids_trie(:,2),'r+');
            for i= 1 : 9
                text(centroids_trie(i,1),centroids_trie(i,2),num2str(i),'FontSize',14);
            end
            pause;
            close(fig_ctrl);
        end
        
        % ------------------ Matrice des data pour l'image -----------------
        MTF_data = [];
        ESF_data = [];
        j=1;
        %                 for i=1: size(centroids_trie,1)
        for i=5:5
            %                 disp(['Centroid n° ',num2str(i)]);
            x_ligne=floor(centroids_trie (i,1));
            y_ligne=floor(centroids_trie(i,2));
            pas=floor(sqrt(centroids_trie(i,3)));
            
            % ------------- Selection rectangle ----------------
            cote_rectangle = 75;
            e_4 = [];
            nfreq_4 = [];
            
            for p = 1:4
                if p == 1
                    image_crop = double(Image_grey(y_ligne-cote_rectangle:y_ligne+cote_rectangle, x_ligne : x_ligne + pas));
                elseif p == 2
                    image_crop = double(Image_grey(y_ligne : y_ligne + pas, x_ligne - cote_rectangle : x_ligne + cote_rectangle));
                    image_crop = imrotate(image_crop,90);
                elseif p == 3
                    image_crop = double(Image_grey(y_ligne-cote_rectangle : y_ligne+cote_rectangle , x_ligne - pas: x_ligne ));
                    image_crop = imrotate(image_crop,180);
                elseif p == 4
                    image_crop = double(Image_grey(y_ligne -pas : y_ligne , x_ligne - cote_rectangle : x_ligne + cote_rectangle));
                    image_crop = imrotate(image_crop,270);
                end
                %                                                               figure(1);
                %                                                             imshow(image_crop,[]);
                %                                                             pause
                %                                                             close(figure(1))
                
                % ------------- Fonction de calcul -----------------
                %                 [resultats] = MTFscript_marc(image_crop,isotropicpixelspacing,plot_figure,seuil_segmentation);
                [e, nfreq, esf,freqval, sfrval] = sfrmat3_marc([Image_name, '_',num2str(i)],image_crop,isotropicpixelspacing,plot_figure);
                
                
                % -------------- Resultats pour l'image ------------
                MTF_data = [MTF_data;e   freqval'  sfrval'];
                esf = [esf ;NaN*ones(2000-numel(esf),1)];
                ESF_data = [ESF_data; esf'];
                eff(j)=e;
                %eff effcicacité d'echantillonnage pour toutes les ROI
                j=j+1;
            end
        end
        
        base(index).MTF_data = MTF_data;
        base(index).ESF_data = ESF_data;
        
        %% -------------------- Affichage TR de la tendance et des valeurs pour image totale ----------------
        %             results = [level threshold Resolution_smoothed Resolution_fit Resolution_raw];
        mtf_mean_data =[];
        %                 for m = 1:9
        for m = 1:1
            a = 1+ (m-1)*4;
            mtf_mean_data = [mtf_mean_data; mean(MTF_data(a:a+3,:))];
        end
        base(index).mtf_mean_data = mtf_mean_data;
        
        %                 moyenne_coins = round(mean(mtf_mean_data([1 3 7 9],3)));
        %                 moyenne_milieux_loins = round(mean(mtf_mean_data([2 8],3)));
        %                 moyenne_milieux_proches = round(mean(mtf_mean_data([4 6],3)));
        %                 centre = round(mtf_mean_data(5,3));
        centre = round(mtf_mean_data(1,3));
        
        %                 if  centre > centre_prev
        %                     disp(['NFREQ : ++++++ :',num2str(centre),' ',num2str(moyenne_milieux_proches),' ',num2str(moyenne_milieux_loins),' ',num2str(moyenne_coins)...
        %                         ' TOP center : ',num2str(round(MTF_data(2,3))),' BOTTOM center : ',num2str(round(MTF_data(8,3))),' Middle left : ',num2str(round(MTF_data(4,3))),' Middle right : ',num2str(round(MTF_data(6,3)))  ]);
        %                 elseif centre < centre_prev
        %                     disp(['NFREQ : ------ :',num2str(centre),' ',num2str(moyenne_milieux_proches),' ',num2str(moyenne_milieux_loins),' ',num2str(moyenne_coins)...
        %                         ' TOP center : ',num2str(round(MTF_data(2,3))),' BOTTOM center : ',num2str(round(MTF_data(8,3))),' Middle left : ',num2str(round(MTF_data(4,3))),' Middle right : ',num2str(round(MTF_data(6,3)))  ]);
        %                 else
        %                     disp(['NFREQ : ====== :',num2str(centre),' ',num2str(moyenne_milieux_proches),' ',num2str(moyenne_milieux_loins),' ',num2str(moyenne_coins)...
        %                         ' TOP center : ',num2str(round(MTF_data(2,3))),' BOTTOM center : ',num2str(round(MTF_data(8,3))),' Middle left : ',num2str(round(MTF_data(4,3))),' Middle right : ',num2str(round(MTF_data(6,3)))  ]);
        %                 end
        %                 moyenne_coins_prev = moyenne_coins;
        %                 moyenne_milieux_loins_prev = moyenne_milieux_loins;
        %                 moyenne_milieux_proches_prev = moyenne_milieux_proches;
        %                 centre_prev = centre;
        %                 disp(['NFREQ : ====== :',num2str(centre),' TOP : ',num2str(round(mtf_mean_data(2,3))),' BOTTOM : ',num2str(round(mtf_mean_data(8,3))),...
        %                     ' Left : ',num2str(round(mtf_mean_data(4,3))),' Right : ',num2str(round(mtf_mean_data(6,3)))  ]);
        %
        max_centre = max(centre,max_centre);
        centre_vect = [centre_vect,centre];
        disp([char(Image_name),' : ',num2str(centre),'/',num2str(max_centre)]);
    end
    
    
end
disp(['Nettete moyenne au centre des ',num2str(index),' images : ',num2str(mean(centre_vect),3)]);
disp(['Min = ',num2str(min(centre_vect))]);
disp(['Max = ',num2str(max(centre_vect))]);

disp('---------------- END ------------------------ ');

