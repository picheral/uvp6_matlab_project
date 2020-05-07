%% Mise en matrice des données des objets d'images UVP6 acquises en Livecamera
% Fonctionne dans l'architecture projet après selection du threshold (cf
% protocole)
% objets, leur coordonnées x et y dans l'image, l'aire en pixel et le niveau
% de gris moyen des pixels
% Toutes les séquences ont été acquises/traitées avec le même threshold
% Les images *.png sont à la racine de la séquence
% Date : 16/04/2020

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

% ------------------- Liste des répertoires ----------------
list_seq = dir(raw_folder);

% --------------------- Verification "propreté" des noms --------
index = 0;
for k = 3:numel(list_seq)
    if list_seq(k).isdir == 1 && ~isempty(find(list_seq(k).name == '_', 1))
        disp(['Folder ',char(list_seq(k).name),' should be renamed to remove _ '])
        index = index + 1;
    elseif list_seq(k).isdir == 1
        % ---- verification data.txt ----
        datafile =  [list_seq(k).folder,'\',list_seq(k).name,'\',list_seq(k).name,'_data.txt'];
        if exist(datafile) ~= 2
            disp([char(list_seq(k).name),'_data.txt does not exists. Check and rename file !'])
            index = index + 1;
        end
    end
end
if index == 0
    disp('All sequences & files correctly named ')
else
    disp('Please correct the folder/file names and restart !')
end

%% ------- Options ---------------------------------
option = input(['Do you want to Create and analyse the matrix from the png images or only Analyse existing matrix ([a]/c) ? '],'s');
if isempty(option); option = 'a';end

% ----------------- DIM image ------------------------------
img_ve = 2056;
img_ho = 2464;
pixel = 0.073;

% ----------------- vecteur X Area en pixels ----------------
% pas d'objets de plus de 300 pixels
pixsize= [1:300];

% ----------------- Paramétrages ------------------------
disp('The analysis will be done only in the square zones, excluding the top, bottom and right remaining pixels')
nb_zones_v = input('Input number of vertical analyzed zones in the image, must be even (CR = 10) ');
if isempty(nb_zones_v);nb_zones_v = 10; end

esd_min = input('Minimum ESD [mm] for analysis (CR for 0.13) ');
if isempty(esd_min); esd_min = 0.13;end

esd_max = input('Maximum ESD [mm] for analysis (CR for 0.6) ');
if isempty(esd_max); esd_max = 0.6;end

Fit_data = input('Polynomial level for fit (CR for 3) ');
if isempty(Fit_data);Fit_data = 3;end
fit_type = ['poly', num2str(Fit_data)];

% scale_option = input('Process matrix test data / gain range data (t/r) ','s');
% if isempty(scale_option); scale_option = 't'; end
scale_option = 't';

if strcmp(scale_option,'t')
    %max_a = 10; max_b = 30; max_area = 3; max_grey = 2;
    max_a = 10; max_b = 0.5; max_area = 3; max_grey = 2;
else
    max_a = 200; max_b = 200; max_area = 3; max_grey = 3;
end


%% -------------- Creation matrice à partir images -------------------
if option == 'c'
    %------------- Boucle sur sequences ---------------
    data_final = [];
    for k = 3:numel(list_seq)
        if list_seq(k).isdir == 1
            cd([list_seq(k).folder,'\',list_seq(k).name,'\']);
            disp('---------------------------------------------------------------')
            disp(['Sequence ',list_seq(k).name])
            
            % ------------- Lecture du threshold dans le fichier data ---------
            path = [list_seq(k).folder,'\',list_seq(k).name,'\',list_seq(k).name,'_data.txt'];
            [sn,day,cruise,base_name,pvmtype,soft,light,shutter,threshold,volume,gain,pixel,Aa,Exp] = uvp6_read_metadata_from_datafile(folder,path);
            
            % ------------- correction threshold Matlab/uvp6
            threshold = threshold + 1;
            
            % ------------- Liste des images -------------------
            %             im_list = dir('save*.png');
            im_list = dir('20*.png');
            
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
        
    end
    disp('------------- SAVING data -----------------------------------')
    eval(['save ',results_folder,'data_corr_zonale_',filename(6:15),'_s',num2str(threshold-1),'.mat data_final list_seq pvmtype cruise threshold'])
end
option = 'a';

%% ----------------- Analyse matrice ---------------------------------
if option == 'a'
    
    % ---- Set up fittype and options ----
    ft = fittype( fit_type );
    
    % ----------------- Selection size range -------------------
    camsm_ref = 2*(((pixel^2)*(pixsize)./pi).^0.5);
    aa = find(camsm_ref >= esd_min & camsm_ref <= esd_max);
    deb_x = aa(1);
    end_x = aa(end);
    
    % ----------------- Vecteur vertical zone -----------------------
    dim_v = floor(img_ve/nb_zones_v);
    rest_v = (img_ve - dim_v*nb_zones_v)/2;
    vect_y = [1 + rest_v];
    for i = 1 : nb_zones_v
        value = dim_v + vect_y(end);
        vect_y = [vect_y value];
    end
    
    % ----------------- Vecteur horizontal zone -----------------------
    nb_zones_h = floor(img_ho / dim_v);
    rest_h = (img_ho - dim_v*nb_zones_h);
    vect_x = [1];
    for i = 1 : nb_zones_h
        value = dim_v + vect_x(end);
        vect_x = [vect_x value];
    end
    
    % ------------ Calcul du % de pixels non pris en compte dans les zones ----
    img_ve_sel = vect_y(end) - vect_y(1);
    img_ho_sel = vect_x(end) - vect_x(1);
    ratio = 100 * (img_ve_sel *img_ho_sel)/(img_ve * img_ho);
    
    disp('---------------------------------------------------------------')
    nb_zones = nb_zones_v * nb_zones_h;
    disp(['Nb zones : ',num2str(nb_zones_v),' x ',num2str(nb_zones_h),' of ',num2str(dim_v),' x ',num2str(dim_v),' pixels']);
    disp([num2str(ratio), ' % of raw image is utilized '])
    disp('---------------------------------------------------------------')
    
    % ----------------- Liste des matrices disponibles ---------
    list_mat = dir([results_folder,'data_corr_zonale_*.mat']);
    
    %% ---------------- Boucle sur les matrices à analyser ------
    
    if ~isempty(list_mat)
        for i = numel(list_mat) :-1: 1
            % ---------- Chargement données ----------------
            disp(['Analysing ',list_mat(i).name])
            data = load([results_folder,list_mat(i).name]);
            data_final = data.data_final;
            %       data_final = [image x_centroids y_centroids area mean_px];
            
            % -------------- Données totales des N zones ------------
            aa = data_final(:,2) >= vect_x(1) & data_final(:,2) < vect_x(end) & data_final(:,3) >= vect_y(1) & data_final(:,3) < vect_y(end);
            data_final = data_final(aa,:);
            
            % --- Nb d'images dans la matrice pour normalisation --
            nb_img = data_final(end,1);
            
            % -------------- Matrices "vide" -----------------------
            %         spectre_total =         NaN * zeros(nb_zones,numel(pixsize));
            spectre_select =            NaN * zeros(nb_zones+1,numel(pixsize(deb_x:end_x)));
            spectre_select_fit =        NaN * zeros(nb_zones+1,numel(pixsize(deb_x:end_x)));
            area_total =                NaN * zeros(nb_zones+1,1);
            mean_grey_total =           NaN * zeros(nb_zones+1,1);
            ecarts =                    NaN * zeros(nb_zones+1,8);  % spectre area grey x x y y
            image_ecarts_spectres_a =     double(zeros(img_ve,img_ho));
            image_ecarts_spectres_b =     double(zeros(img_ve,img_ho));
            image_ecarts_area =         double(zeros(img_ve,img_ho));
            image_ecarts_grey =         double(zeros(img_ve,img_ho));
            
            spectre_select(1,:) =       pixsize(deb_x:end_x);
            spectre_select_fit(1,:) =   pixsize(deb_x:end_x);
            area_total(1) =             nansum(data_final(:,4)/nb_img,1);
            mean_grey_total(1) =        nansum(data_final(:,4) .* data_final(:,5))/nb_img;
            ecarts(1,5:8) =             [rest_v,img_ve_sel,1,img_ho_sel];
            
            
            % --- Calcul du spectre de taille global / Area -------
            spectre_tot = zeros( numel(pixsize),1)';
            for j = 1: numel(pixsize)
                spectre_tot(j) = numel(find(data_final(:,4) == j));
            end
            
            % --- Normalisation par image ------------------------
            spectre_tot = spectre_tot/nb_img;
            
            % --- Ajustement polynomial sur spectre complet -----------------------
            [xData, yData] = prepareCurveData( log(pixsize), log(spectre_tot) );
            [fitresult_all, gof] = fit( xData, yData, ft );
            [y_all] = poly_from_fit(log(pixsize),fitresult_all,fit_type);
            
            % --- Ajustement polynomial sur spectre de taille réduit --------------------------
            [xData, yData] = prepareCurveData( log(pixsize(deb_x:end_x)), log(spectre_tot(deb_x:end_x)) );
            [fitresult_sel, gof] = fit( xData, yData, ft );
            [y_sel] = poly_from_fit(log(pixsize(deb_x:end_x)),fitresult_sel,fit_type);
            
            %% ---------- Figure ---------------------------------
            fig1 = figure('numbertitle','off','name','UVP6_cor_zonale','Position',[10 50 900 1200]);
            titre =  list_mat(i).name;
            sgtitle({'Zonal Correction Analysis';titre}, 'Interpreter', 'none');
            % -------- Spectre entier et réduit ----------------------------
            subplot(4,3,1)
            loglog(pixsize,spectre_tot,'r.');
            hold on
            loglog(pixsize(deb_x:end_x),spectre_tot(deb_x:end_x),'g.');
            %         hold on
            %         loglog( (pixsize), exp(y_all), 'r-' );
            xlabel('Area [pixel]','fontsize',7);
            ylabel('Ab. [# img-1]','fontsize',7);
            xlim([1 5*end_x]);
            ylim([0.001 1000000]);
            legend([num2str(ratio,3),'% of data'], ['size [',num2str(esd_min),' - ',num2str(esd_max),' mm]'], 'Location', 'NorthEast','fontsize',6 );
            title(['RAW data'],'fontsize',7);
            
            % ------- Plot ajustements --------------------------
            subplot(4,3,2)
            loglog( (pixsize), exp(y_all), 'r-' );
            hold on
            loglog( pixsize(deb_x:end_x), exp(y_sel), 'g-','LineWidth',2 );
            xlabel('Area [pixel]','fontsize',7);
            ylabel('Fitted ab. [# img-1]','fontsize',7);
            xlim([1 5*end_x]);
            ylim([0.001 1000000]);
            legend([num2str(ratio,3),'% of data'], ['size [',num2str(esd_min),' - ',num2str(esd_max),' mm]'], 'Location', 'NorthEast' ,'fontsize',6 );
            title(['FIT'],'fontsize',7);
            
            % ------------------ Affichage positions de certains objets --
            subplot(4,3,3)
            area_min = 5;
            aa = find(data.data_final(:,4) > area_min);
            nb_obj = min([1000 numel(aa)]);
            %         plot(data.data_final(aa,2),flip(data.data_final(aa,3)),'k.')
            plot(data.data_final(aa(1:nb_obj),2),data.data_final(aa(1:nb_obj),3),'k.')
            axis([0 img_ho 0 img_ve]);
            title([num2str(nb_obj),' objects  [area > ',num2str(area_min),' pixels]'],'fontsize',7);
            
            %% --------------- ANALYSE par zone avec selection taille ----------
            index = 1;
            for v = 1 : nb_zones_v
                v_a = vect_y(v);
                v_b = vect_y(v+1);
                for h = 1 : nb_zones_h
                    h_a = vect_x(h);
                    h_b = vect_x(h+1);
                    % ------------ Selection objets dans la zone -------
                    aa = find(data_final(:,2) >= h_a & data_final(:,2) < h_b & data_final(:,3) >= v_a & data_final(:,3) < v_b);
                    %                 disp(['Zone : ',num2str(index),' nb : ',num2str(numel(aa)),' ho : ',num2str(h_a),'-',num2str(h_b),'  ve : ',num2str(v_a),'-',num2str(v_b)])
                    index = index + 1;
                    if ~isempty(aa)
                        % -------------- pas vide ----------------------
                        data_zone = data_final(aa,:);
                        
                        % --- Calcul du spectre de taille global / Area / Zone -------
                        spectre_zone = zeros( numel(pixsize),1)';
                        for j = 1: numel(pixsize)
                            spectre_zone(j) = numel(find(data_final(aa,4) == j));
                        end
                        
                        % --- Normalisation par image et par nb pixels de la zone ------------------------
                        spectre_zone = spectre_zone/nb_img;
                        
                        % --- Correction par le nb de pixels de la zone / image
                        spectre_zone = spectre_zone * nb_zones;
                        
                        % --- Ajustement polynomial sur spectre de taille réduit --------------------------
                        [xData, yData] = prepareCurveData( log(pixsize(deb_x:end_x)), log(spectre_zone(deb_x:end_x)) );
                        [fitresult_sel, gof] = fit( xData, yData, ft );
                        [y_sel_zone] = poly_from_fit(log(pixsize(deb_x:end_x)),fitresult_sel,fit_type);
                        
                        
                        % -------- Spectre réduit ----------------------------
                        subplot(4,3,4)
                        loglog(pixsize(deb_x:end_x),spectre_zone(deb_x:end_x),'k.');
                        hold on
                        xlabel('Area [pixel]','fontsize',7);
                        ylabel('Abundance per zone [# image-1]','fontsize',7);
                        %                         xlim([1 100]);
                        %                         ylim([0.01 100000]);
                        xlim([1 5*end_x]);
                        ylim([0.001 1000000]);
                        title(['RAW ',num2str(nb_zones),' zones of ',num2str(dim_v),' x ',num2str(dim_v),' pixels'],'fontsize',7);
                        
                        % ------- Plot ajustements --------------------------
                        subplot(4,3,5)
                        %                     loglog( pixsize(deb_x:end_x), (y_sel_zone), '-' );
                        loglog( pixsize(deb_x:end_x), exp(y_sel_zone), '-' );
                        hold on
                        xlabel('Area [pixel]','fontsize',7);
                        ylabel('Fitted abundance per zone [# image-1]','fontsize',7);
                        xlim([1 5*end_x]);
                        ylim([0.001 1000000]);
                        title(['FIT '],'fontsize',7);
                        
                        % ------- Calcul écart au spectre de la zone entière ----
                        %                     ecart_spectre = nansum(abs((exp(y_sel_zone) - exp(y_sel))./exp(y_sel)));
                        %                     ecart_spectre_a = nansum(((exp(y_sel_zone) - exp(y_sel))./exp(y_sel)));
                        ecart_spectre_a = (nansum((abs(exp(y_sel_zone) - exp(y_sel)))./exp(y_sel)))/(numel(y_sel_zone));
                        %ecart_spectre_b =  ((nansum((exp(y_sel_zone) - exp(y_sel)).^2)) / (end_x - deb_x + 1))^0.5;
                        ecart_spectre_b = data_similarity_score(exp(y_sel_zone), exp(y_sel));
                        
                        % ------- Calcul ecarts Area et Grey -------------------------
                        area = nansum(data_zone(:,4),1)/nb_img;
                        grey = nansum(data_zone(:,4) .* data_zone(:,5))/nb_img;
                        
                        %                     ecart_area = abs((area - area_total(1)/nb_zones)/(area_total(1)/nb_zones));
                        %                     ecart_grey = abs((grey - mean_grey_total(1)/nb_zones)/(mean_grey_total(1)/nb_zones));
                        
                        ecart_area = ((area - area_total(1)/nb_zones)/(area_total(1)/nb_zones));
                        ecart_grey = ((grey - mean_grey_total(1)/nb_zones)/(mean_grey_total(1)/nb_zones));
                        
                        % -------- Matrices ----------------------------------
                        spectre_select(index,:) =       spectre_zone(deb_x:end_x);
                        spectre_select_fit(index,:) =   y_sel_zone;
                        area_total(index) =             area;
                        mean_grey_total(index) =        grey;
                        ecarts(index,:) =               [ecart_spectre_a,ecart_spectre_b,ecart_area,ecart_grey,v_a,v_b,h_a,h_b];
                        image_ecarts_spectres_a(v_a:v_b,h_a:h_b) =        ecart_spectre_a;
                        image_ecarts_spectres_b(v_a:v_b,h_a:h_b) =        ecart_spectre_b;
                        image_ecarts_area(v_a:v_b,h_a:h_b) =            ecart_area;
                        image_ecarts_grey(v_a:v_b,h_a:h_b) =            ecart_grey;
                    end
                    
                end
            end
            
            % ------------------ Resultats ---------------------------------
            somme_ecarts_spectres_fit_a =     nansum(abs(ecarts(2:end,1)),1);
            somme_ecarts_spectres_fit_b =     nansum(abs(ecarts(2:end,2)),1);
            mean_ecarts_spectres_fit_b =     nanmean(abs(ecarts(2:end,2)),1);
            min_ecarts_spectres_fit_b =     nanmin(abs(ecarts(2:end,2)));
            max_ecarts_spectres_fit_b =     nanmax(abs(ecarts(2:end,2)));
            std_ecarts_spectres_fit_b =     nanstd(abs(ecarts(2:end,2)),1);
            mediane_ecarts_spectres_fit_b =     nanmedian(abs(ecarts(2:end,2)),1);
            somme_ecarts_area =             nansum(abs(ecarts(2:end,3)),1);
            somme_ecarts_grey =             nansum(abs(ecarts(3:end,4)),1);
            
            %         disp(['Sum of spectra differences : ',num2str(somme_ecarts_spectres_fit_a)])
            disp(['Mean of spectra differences : ',num2str(mean_ecarts_spectres_fit_b)])
            disp(['Sum of spectra differences : ',num2str(somme_ecarts_spectres_fit_b)])
            disp(['Mediane of spectra differences : ',num2str(mediane_ecarts_spectres_fit_b)])
            disp(['Sum of area differences    : ',num2str(somme_ecarts_area)])
            disp(['Sum of grey differences    : ',num2str(somme_ecarts_grey)])
            
            % ------------------ Ajout courbe image entière --------------
            subplot(4,3,5)
            loglog( pixsize(deb_x:end_x), exp(y_sel),'g-','LineWidth',2 );
            
            % ------------------ Histo des ecarts spectres a-------
            %         subplot(4,3,6)
            %         hist(ecarts(:,1));
            %         xlim([0 max_a]);
            %         ylim([0 nb_zones/2]);
            %         title('Histogramme of differences of spectra (a)','fontsize',10);
            
            % ------------------ Histo des ecarts spectres b -------
            subplot(4,3,12)
            data = ecarts(:,2);
            aa = ~isnan(data);
            aa = find(aa==1);
            data = data(aa);
            histogram(data,30,'BinLimits',[0 max_b]);
            xlim([0 max_b]);
            ylim([0 nb_zones]);
            title('Differences of spectra ','fontsize',7);
            
            % ------------------ Histo des ecarts area -------
            subplot(4,3,10)
            histogram(ecarts(:,3),20,'BinLimits',[-1 1]);
            xlim([-max_area max_area]);
            ylim([0 nb_zones/2]);
            title('Differences of area ','fontsize',7);
            
            % ------------------ Histo des ecarts grey -------
            subplot(4,3,11)
            histogram(ecarts(:,4),20,'BinLimits',[-1 1]);
            xlim([-max_grey max_grey]);
            ylim([0 nb_zones/2]);
            title('Differences of grey x area ','fontsize',7);
            
            % ---- Normalisation image SPECTRES a ----------------
            %         ecart_spectre_min = min(ecarts(:,1));
            %         ecart_spectre_max = max(ecarts(:,1));
            %         image = - ecart_spectre_min + image_ecarts_spectres_a *(255-ecart_spectre_min)/ecart_spectre_max;
            %         image =  50 + image_ecarts_spectres_a *2;
            %         image = image_ecarts_spectres + 1;
            % ------------------ Affichage des carrés couleur proportionnels --
            %         subplot(4,3,7)
            %         imagesc(image_ecarts_spectres_a,[0 max_a]);
            %         title(['Map spectral differences (a) S : ',num2str(somme_ecarts_spectres_fit_a,5)],'fontsize',10);
            %         colorbar
            
            % ---- Normalisation image SPECTRES b ----------------
            ecart_spectre_max = max(ecarts(:,2));
            %         image = image_ecarts_spectres_b * 255/ecart_spectre_max;
            %         disp(['ecart_spectre_max : ',num2str(ecart_spectre_max)]);
            %         image = image_ecarts_spectres_b * 255/350;
            %         image = image_ecarts_spectres + 1;
            % ------------------ Affichage des carrés couleur proportionnels --
            subplot(4,3,9)
            imagesc(image_ecarts_spectres_b,[0 max_b]);
            colormap(fig1,gray);
            
            title(['Spectral differences M: ',num2str(mean_ecarts_spectres_fit_b,5)],'fontsize',7);
            colorbar
            
            
            % ---- Normalisation image AREA----------------
            %         ecart_area_max = max(ecarts(:,2));
            %         image = image_ecarts_area * 255/ecart_area_max;
            %         image = 150*(image_ecarts_area + 1);
            % ------------------ Affichage des carrés couleur proportionnels --
            subplot(4,3,7)
            imagesc(image_ecarts_area,[-max_area max_area]);
            title(['Area differences S : ',num2str(somme_ecarts_area,5)],'fontsize',7);
            colorbar
            
            % ---- Normalisation image GREY ----------------
            %         ecart_grey_max = max(ecarts(:,3));
            %         image = image_ecarts_grey * 255/ecart_grey_max;
            %         image = 125*(image_ecarts_grey +1);
            % ------------------ Affichage des carrés couleur proportionnels --
            subplot(4,3,8)
            imagesc(image_ecarts_grey,[-max_grey max_grey]);
            title(['Grey x Area differences S : ',num2str(somme_ecarts_grey,5)],'fontsize',7);
            colorbar
            
            % ------------------ Affichage meta data ----------------------
            ha = subplot(4,3,6);
            pos = get(ha,'Position');
            un = get(ha,'Units');
            pos(1) = pos(1) - 0.05;
            delete(ha)
            try
                uvp = pvmtype;
                thres = num2str(threshold);
            catch
                warning('No metadata in the zonal corr data');
                uvp = 'unkown';
                thres = 'unkown';
            end
            d = {['uvp : ', uvp], ['project : ', folder(4:end)], ['threshold : ', thres],...
                ['zones nb : ', num2str(nb_zones)], ['esd min (mm) : ', num2str(esd_min)], ['esd max (mm) : ', num2str(esd_max)],...
                ['mean score : ', num2str(mean_ecarts_spectres_fit_b)],['min score : ', num2str(min_ecarts_spectres_fit_b)],...
                ['max score : ', num2str(max_ecarts_spectres_fit_b)], ['std score : ', num2str(std_ecarts_spectres_fit_b)]};
            t = annotation('textbox', pos, 'Units', un, 'String', d, 'Interpreter', 'none', 'EdgeColor', 'none');
            t.FontSize = 9;
            
            % ------------------ Sauvegarde image --------------------------
            orient tall
            set(gcf,'PaperPositionMode','auto')
            print(gcf,'-dpng',[results_folder,'\spectres_',num2str(nb_zones),'_zones_',num2str(1000*esd_min),'_',num2str(1000*esd_max),'_',list_mat(i).name(1:end-4)]);
            print(gcf,'-dpdf','-bestfit',[results_folder,'\spectres_',num2str(nb_zones),'_zones_',num2str(1000*esd_min),'_',num2str(1000*esd_max),'_',list_mat(i).name(1:end-4)]);
            disp('-------------- Figure saved ----------------------------------- ');
            
            % ----- Sauvegarde matrice de résultats pour matrice entrée ----
            disp('------------- SAVING matrix -----------------------------------')
            eval(['save ',results_folder,'spectres_',num2str(nb_zones),'_zones_',num2str(1000*esd_min),'_',num2str(1000*esd_max),'_',list_mat(i).name ,' spectre_select spectre_select_fit area_total mean_grey_total ecarts'])
        end
    end
    
    cd(folder);
    
    
end

disp('------------- END of PROCESS -----------------------------------')