%% ANALYSE des matrice des donn�es des objets d'images UVP6 acquises en Livecamera
% Fonctionne dans l'architecture projet
% objets, leur coordonn�es x et y dans l'image, l'aire en pixel et le niveau
% de gris moyen des pixels
% Date : 19/04/2019

close all
clear all
warning('off','all')

%% --------- PROJECT FOLDER -------------------
disp('------------------- START ZONAL ANALYSIS of DATA --------------')
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

%% ---------------- ZONES A ANALYSER --------------------------------------
% ----------------- DIM image ------------------------------
img_ve = 2056;
img_ho = 2464;
pixel = 0.073;

% ----------------- vecteur X Area en pixels ----------------
% pas d'objets de plus de 300 pixels
pixsize= [1:300];

% ----------------- Param�trages ------------------------
disp('The analysis will be done only in the square zones, excluding the top, bottom and right remaining pixels')
nb_zones_v = input('Input number of vertical analyzed zones in the image, must be even (CR = 10) ');
if isempty(nb_zones_v);nb_zones_v = 10; end

esd_min = input('Minimum ESD [mm] for analysis (CR for 0.2) ');
if isempty(esd_min); esd_min = 0.2;end

esd_max = input('Maximum ESD [mm] for analysis (CR for 0.5) ');
if isempty(esd_max); esd_max = 0.5;end

Fit_data = input('Polynomial level for fit (CR for 3) ');
if isempty(Fit_data);Fit_data = 3;end
fit_type = ['poly', num2str(Fit_data)];

scale_option = input('Process matrix test data / gain range data (t/r) ','s');
if isempty(scale_option); scale_option = 't'; end

if strcmp(scale_option,'t')
    max_a = 10; max_b = 30; max_area = 3; max_grey = 2; 
else
    max_a = 200; max_b = 125; max_area = 3; max_grey = 3; 
end

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
list_mat = dir([results_folder,'data_sn*.mat']);

%% ---------------- Boucle sur les matrices � analyser ------

if ~isempty(list_mat)
    for i = numel(list_mat) :-1: 1
        % ---------- Chargement donn�es ----------------
        disp(['Analysing ',list_mat(i).name])
        data = load([results_folder,list_mat(i).name]);
        data_final = data.data_final;
        %       data_final = [image x_centroids y_centroids area mean_px];
        
        % -------------- Donn�es totales des N zones ------------
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
        area_total(1) =             sum(data_final(:,4)/nb_img,1, "omitnan");
        mean_grey_total(1) =        sum(data_final(:,4) .* data_final(:,5), "omitnan")/nb_img;
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
        
        % --- Ajustement polynomial sur spectre de taille r�duit --------------------------
        [xData, yData] = prepareCurveData( log(pixsize(deb_x:end_x)), log(spectre_tot(deb_x:end_x)) );
        [fitresult_sel, gof] = fit( xData, yData, ft );
        [y_sel] = poly_from_fit(log(pixsize(deb_x:end_x)),fitresult_sel,fit_type);
        
        %% ---------- Figure ---------------------------------
        fig1 = figure('numbertitle','off','name','UVP6_cor_zonale','Position',[10 50 1300 1000]);
        % -------- Spectre entier et r�duit ----------------------------
        subplot(4,3,1)
        loglog(pixsize,spectre_tot,'r.');
        hold on
        loglog(pixsize(deb_x:end_x),spectre_tot(deb_x:end_x),'g.');
        %         hold on
        %         loglog( (pixsize), exp(y_all), 'r-' );
        xlabel('Area [pixel]','fontsize',9);
        ylabel('Abundance [# image-1]','fontsize',9);
        legend([num2str(ratio,3),'% of data'], ['size [',num2str(esd_min),' - ',num2str(esd_max),' mm]'], 'Location', 'NorthEast' );
        titre =  list_mat(i).name;
        aa = titre == '_';
        titre(aa) = ' ';
        title(['RAW ',titre],'fontsize',10);
        
        % ------- Plot ajustements --------------------------
        subplot(4,3,2)
        loglog( (pixsize), exp(y_all), 'r-' );
        hold on
        loglog( pixsize(deb_x:end_x), exp(y_sel), 'g-','LineWidth',2 );
        xlabel('Area [pixel]','fontsize',9);
        ylabel('Fitted abundance [# image-1]','fontsize',9);
        legend([num2str(ratio,3),'% of data'], ['size [',num2str(esd_min),' - ',num2str(esd_max),' mm]'], 'Location', 'NorthEast' );
        title(['FIT ',titre],'fontsize',10);
        
        % ------------------ Affichage positions de certains objets --
        subplot(4,3,3)
        area_min = 5;
        aa = find(data.data_final(:,4) > area_min);
        nb_obj = min([1000 numel(aa)]);
%         plot(data.data_final(aa,2),flip(data.data_final(aa,3)),'k.')
        plot(data.data_final(aa(1:nb_obj),2),data.data_final(aa(1:nb_obj),3),'k.')
        axis([0 img_ho 0 img_ve]);
        title(['Position of objects  [area > ',num2str(area_min),' pixels]'],'fontsize',10);
        
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
                    
                    % --- Ajustement polynomial sur spectre de taille r�duit --------------------------
                    [xData, yData] = prepareCurveData( log(pixsize(deb_x:end_x)), log(spectre_zone(deb_x:end_x)) );
                    [fitresult_sel, gof] = fit( xData, yData, ft );
                    [y_sel_zone] = poly_from_fit(log(pixsize(deb_x:end_x)),fitresult_sel,fit_type);
                    
                    
                    % -------- Spectre r�duit ----------------------------
                    subplot(4,3,4)
                    loglog(pixsize(deb_x:end_x),spectre_zone(deb_x:end_x),'k.');
                    hold on
                    xlabel('Area [pixel]','fontsize',9);
                    ylabel('Abundance per zone [# image-1]','fontsize',9);
                    xlim([1 100]);
                    ylim([0.01 100000]);
                    title(['RAW ',num2str(nb_zones),' zones of ',num2str(dim_v),' x ',num2str(dim_v),' pixels'],'fontsize',10);
                    
                    % ------- Plot ajustements --------------------------
                    subplot(4,3,5)
                    %                     loglog( pixsize(deb_x:end_x), (y_sel_zone), '-' );
                    loglog( pixsize(deb_x:end_x), exp(y_sel_zone), '-' );
                    hold on
                    xlabel('Area [pixel]','fontsize',9);
                    ylabel('Fitted abundance per zone [# image-1]','fontsize',9);
                    xlim([1 100]);
                    ylim([0.01 100000]);
                    title(['FIT ',num2str(nb_zones),' zones of ',num2str(dim_v),' x ',num2str(dim_v),' pixels'],'fontsize',10);
                    
                    % ------- Calcul �cart au spectre de la zone enti�re ----
                    %                     ecart_spectre = nansum(abs((exp(y_sel_zone) - exp(y_sel))./exp(y_sel)));
%                     ecart_spectre_a = nansum(((exp(y_sel_zone) - exp(y_sel))./exp(y_sel)));
                    ecart_spectre_a = (sum((abs(exp(y_sel_zone) - exp(y_sel)))./exp(y_sel), "omitnan"))/(numel(y_sel_zone));
                    ecart_spectre_b =  ((sum((exp(y_sel_zone) - exp(y_sel)).^2, "omitnan")) / (end_x - deb_x + 1))^0.5;

                    % ------- Calcul ecarts Area et Grey -------------------------
                    area = sum(data_zone(:,4),1, "omitnan")/nb_img;
                    grey = sum(data_zone(:,4) .* data_zone(:,5), "omitnan")/nb_img;
                    
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
        somme_ecarts_spectres_fit_a =     sum(abs(ecarts(2:end,1)),1, "omitnan");
        somme_ecarts_spectres_fit_b =     sum(abs(ecarts(2:end,2)),1, "omitnan");
        mediane_ecarts_spectres_fit_b =     median(abs(ecarts(2:end,2)),1, "omitmissing");
        somme_ecarts_area =             sum(abs(ecarts(2:end,3)),1, "omitnan");
        somme_ecarts_grey =             sum(abs(ecarts(3:end,4)),1, "omitnan");
        
%         disp(['Sum of spectra differences : ',num2str(somme_ecarts_spectres_fit_a)])
        disp(['Sum of spectra differences : ',num2str(somme_ecarts_spectres_fit_b)])
        disp(['Mediane of spectra differences : ',num2str(mediane_ecarts_spectres_fit_b)])
        disp(['Sum of area differences    : ',num2str(somme_ecarts_area)])
        disp(['Sum of grey differences    : ',num2str(somme_ecarts_grey)])
        
        % ------------------ Ajout courbe image enti�re --------------
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
        title('Histogramme of differences of spectra (b)','fontsize',10);
        
        % ------------------ Histo des ecarts area -------
        subplot(4,3,10)
        histogram(ecarts(:,3),20,'BinLimits',[-1 1]);
        xlim([-1 1]);
        ylim([0 nb_zones/2]);
        title('Histogramme of differences of area ','fontsize',10);
        
        % ------------------ Histo des ecarts grey -------
        subplot(4,3,11)
        histogram(ecarts(:,4),20,'BinLimits',[-1 1]);
        xlim([-1 1]);
        ylim([0 nb_zones/2]);
        title('Histogramme of differences of grey x area ','fontsize',10);
        
        % ---- Normalisation image SPECTRES a ----------------
        %         ecart_spectre_min = min(ecarts(:,1));
        %         ecart_spectre_max = max(ecarts(:,1));
        %         image = - ecart_spectre_min + image_ecarts_spectres_a *(255-ecart_spectre_min)/ecart_spectre_max;
        %         image =  50 + image_ecarts_spectres_a *2;
        %         image = image_ecarts_spectres + 1;
        % ------------------ Affichage des carr�s couleur proportionnels --
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
        % ------------------ Affichage des carr�s couleur proportionnels --
        subplot(4,3,9)
        imagesc(image_ecarts_spectres_b,[0 max_b]);
        colormap(fig1,jet);
        
        title(['Map spectral differences (b) S: ',num2str(somme_ecarts_spectres_fit_b,5)],'fontsize',10);
        colorbar
        
        
        % ---- Normalisation image AREA----------------
        %         ecart_area_max = max(ecarts(:,2));
        %         image = image_ecarts_area * 255/ecart_area_max;
        %         image = 150*(image_ecarts_area + 1);
        % ------------------ Affichage des carr�s couleur proportionnels --
        subplot(4,3,7)
        imagesc(image_ecarts_area,[0 max_area]);
        title(['Map area differences S : ',num2str(somme_ecarts_area,5)],'fontsize',10);
        colorbar
        
        % ---- Normalisation image GREY ----------------
        %         ecart_grey_max = max(ecarts(:,3));
        %         image = image_ecarts_grey * 255/ecart_grey_max;
        %         image = 125*(image_ecarts_grey +1);
        % ------------------ Affichage des carr�s couleur proportionnels --
        subplot(4,3,8)
        imagesc(image_ecarts_grey,[0 max_grey]);
        title(['Map grey x area differences S : ',num2str(somme_ecarts_grey,5)],'fontsize',10);
        colorbar
        

        
        % ------------------ Sauvegarde image --------------------------
        orient tall
        set(gcf,'PaperPositionMode','auto')
        print(gcf,'-dpng',[results_folder,'\spectres_',num2str(nb_zones),'_zones_',num2str(1000*esd_min),'_',num2str(1000*esd_max),'_',list_mat(i).name(1:end-4)]);
        disp('-------------- Figure saved ----------------------------------- ');
        
        % ----- Sauvegarde matrice de r�sultats pour matrice entr�e ----
        disp('------------- SAVING matrix -----------------------------------')
        eval(['save ',results_folder,'spectres_',num2str(nb_zones),'_zones_',num2str(1000*esd_min),'_',num2str(1000*esd_max),'_',list_mat(i).name ,' spectre_select spectre_select_fit area_total mean_grey_total ecarts'])
    end
end

cd(folder);
disp('------------- END of PROCESS -----------------------------------')






