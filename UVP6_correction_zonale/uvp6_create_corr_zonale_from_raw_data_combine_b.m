%% Comnbinaison des données acquises à différents gains pour créer une matrice de correction zonale
% Fonctionne dans l'architecture projet
% objets, leur coordonnées x et y dans l'image, l'aire en pixel et le niveau
% de gris moyen des pixels
% SYMETRIE de la matrice à POSTERIORI (après création matrice complète)
% Mise à l'échelle pour matrice WISIP
% FIT 2 pour ECARTS
% FIT 3 pour AREA et GREY
% Sauvegarde des matrices en fichier TXT pour calcul matrice à importer
% dans UVP6
% Date : 30/04/2019

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

% ----------------- Symetrie ------------------------------
symetrie = input('Process symetry on final matrice ? (y/n) ','s');
if isempty(symetrie);symetrie = 'y';end

% ----------------- Filtre ---------------------------------
% gauss = input('Enter value for gaussian filter (CR : 10) ');
% if isempty(gauss); gauss = 10; end
gauss_table = [5 10];

% ----------------- Liste des matrices disponibles ---------
list_mat = dir([results_folder,'spectres_*.mat']);
for i = 1 :numel(list_mat)
    disp([num2str(i),'  : ',list_mat(i).name]);
end
disp('---------------------------------------------------------------')

% ----------------- Selection des matrices à utiliser ------
% ----------- REF -------------
saisie = input('N° of REFERENCE matrix ');
disp(['REF : ',list_mat(saisie).name]);
mat_adj = [saisie];
index = 1;
while ~isempty(saisie)
    % ----------- AUTRES ----------
    saisie = input('Input matrice to include in adjustment (CR to exit) ');
    if ~isempty(saisie)
        mat_adj = [mat_adj saisie];
        disp(['ADJ : ',list_mat(saisie).name]);
    end
end
disp('---------------------------------------------------------------')

% Fit_data = input('Polynomial level for fit (CR for 2) ');
% if isempty(Fit_data);Fit_data = 2;end
% fit_type = ['poly', num2str(Fit_data)];
% % ---- Set up fittype and options ----
% ft = fittype( fit_type );
% disp('---------------------------------------------------------------')

%% ----------------- Boucle de creation des matrices 3D -----
mat_spectre_fit = [];
mat_area = [];
mat_grey= [];
for i = 1 : numel(mat_adj)
    % ---------- Chargement des données -----------------------
    index = mat_adj(i);
    eval(['load(''',results_folder,list_mat(index).name,''')'])
    %     disp(list_mat(index).name)
    mat_spectre_fit(i,:,:) = spectre_select_fit(:,:);
    mat_area(i,:) = area_total;
    mat_grey(i,:) = mean_grey_total;
end

% ----------- X vecteur ------------------------------
x_sel = ones(size(mat_spectre_fit,3),1);
x_sel(:) = mat_spectre_fit(1,1,:); % pixel range

% ------------ Matrice des gains ----------------------
mat_gain = NaN * zeros(numel(mat_adj)-1,1);
for i = 1 : numel(mat_adj) - 1
    index = mat_adj(i+1);
    aa = findstr(list_mat(index).name,'_');
    mat_gain(i) = str2num(list_mat(index).name(aa(end) + 2 :end - 4));
end
% ------------ GAIN REF -------------------------------
aa = findstr(list_mat(mat_adj(1)).name,'_');
gain_ref = list_mat(mat_adj(1)).name(aa(end) + 2 :end - 4);

% --------- Gamme et PAS de gain ----------------
x = [min(mat_gain):0.1:max(mat_gain)];
x = [8:0.1:30];

% ------------ Calcul des matrices d'écarts --------------------------
% x_sel = mat_spectre_fit(1,1,:); % pixel range
% ysel = mat_spectre_fit(1,2,:);  % spectre de reference ajuste
% area_sel = mat_area(1,2:end);   % matrice des area de reference pour N zones
% grey_sel = mat_grey(1,2:end);   % matrice des grey de reference pour N zones

%% ----------- Recherche du gain pour les différentes zones et methodes ---
nb_zones = size(area_total,1) - 1;
if nb_zones == 120
    x_zones = 12;
    y_zones = nb_zones/x_zones;
    mat_zones = NaN*ones(y_zones,x_zones);
    index = 1;
    for yi = 1 : y_zones
        mat_zones(yi,:) = [index :x_zones - 1 + index];
        index = index + x_zones;
    end
elseif nb_zones == 42
    x_zones = 7;
    y_zones = nb_zones/x_zones;
    mat_zones = NaN*ones(y_zones,x_zones);
    index = 1;
    for yi = 1 : y_zones
        mat_zones(yi,:) = [index :x_zones - 1 + index];
        index = index + x_zones;
    end
end

%% ---------- Figure de contrôle ---------------------------------
fig1 = figure('numbertitle','off','name','UVP6_cor_zonale','Position',[10 50 700 900]);
aa = filename == '_';
titre = filename;
titre(aa) = ' ';
% -------------- Plot des spectres moyens par zone -------------
subplot(2,2,1)
spectre_moyen_zones = ones(size(mat_spectre_fit,3),1);
legende(1) = {'REF'};
for i = 1 : numel(mat_adj)
    spectre_moyen_zones(:) = nanmean(mat_spectre_fit(i,2:end,:),2);
    loglog( x_sel, exp(spectre_moyen_zones), '-' );
    hold on
    if i > 1;    legende(i) = { num2str(mat_gain(i-1))}; end
end
legend(legende);
xlabel('Area [pixel]','fontsize',9);
ylabel('Fitted abundance [# image-1]','fontsize',9);
title(titre,'fontsize',9);

% ------------- Plot des area ----------------------------------------
subplot(2,2,2)
legende(1) = {'REF'};
area = nanmean(mat_area(1,:));
plot(mat_gain(mat_adj(1)),area,'o')
hold on
for i = 2 : numel(mat_adj)
    area = nanmean(mat_area(i,:));
    plot(mat_gain(i-1),area,'+')
    hold on
    if i > 1;    legende(i) = { num2str(mat_gain(i-1))}; end
end
% legend(legende);
xlabel('GAIN','fontsize',9);
ylabel('MEAN AREA (sum)','fontsize',9);
title(titre,'fontsize',9);

% ------------- Plot des mean grey ----------------------------------------
subplot(2,2,3)
legende(1) = {'REF'};
area = nanmean(mat_grey(1,:));
plot(mat_gain(mat_adj(1)),area,'o')
hold on
for i = 2 : numel(mat_adj)
    grey = nanmean(mat_grey(i,:));
    plot(mat_gain(i-1),grey,'+')
    hold on
    if i > 1;    legende(i) = { num2str(mat_gain(i-1))}; end
end
% legend(legende);
xlabel('GAIN','fontsize',9);
ylabel('MEAN GREY (sum)','fontsize',9);
title(titre,'fontsize',9);

% ------------- Plot des mean grey ----------------------------------------
subplot(2,2,4)
imagesc(mat_zones,[1 nb_zones]);
colorbar
title(titre,'fontsize',9);
xlabel('Zone positions','fontsize',9);

% ------------------ Sauvegarde image --------------------------
orient tall
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[results_folder,'matrice_',num2str(nb_zones),'_zones_mean_results_',num2str(mat_adj(1)),'_',filename]);

%% ------------ Boucle sur les zones ----------------------------------
% mat_ecarts_spectre_fit_a = NaN * zeros(nb_zones,numel(mat_adj)-1);
% mat_ecarts_spectre_fit_b = NaN * zeros(nb_zones,numel(mat_adj)-1);
% mat_ecarts_area = NaN * zeros(nb_zones,numel(mat_adj)-1);
% mat_ecarts_grey = NaN * zeros(nb_zones,numel(mat_adj)-1);

mat_ecarts_spectre_fit_a = NaN * zeros(numel(mat_adj)-1,nb_zones);
mat_ecarts_spectre_fit_b = NaN * zeros(numel(mat_adj)-1,nb_zones);
mat_ecarts_area = NaN * zeros(numel(mat_adj)-1,nb_zones);
mat_ecarts_grey = NaN * zeros(numel(mat_adj)-1,nb_zones);

% ------------- Valeurs de reference l'image ---------
spectre_ref = nanmean(mat_spectre_fit(1,2:nb_zones + 1,:));
area_ref = nanmean(mat_area(1,2:nb_zones + 1));
grey_ref = nanmean(mat_grey(1,2:nb_zones + 1));


disp('---------------------------------------------------------------')
disp(['Area_ref = ',num2str(area_ref)])
disp(['Grey_ref = ',num2str(grey_ref)])
disp('---------------------------------------------------------------')
for j = 2 : nb_zones + 1
    %     disp(['Zone : ',num2str(j-1)])
    % ------------- Valeurs de reference pour la zone ---------
    %     spectre_ref_zone = mat_spectre_fit(1,j,:);
    %     area_ref_zone = mat_area(1,j);
    %     grey_ref_zone = mat_grey(1,j);
    
    for i = 2 : numel(mat_adj)
        % ----------- Spectre FIT -----------------------------
        spectre_zone = mat_spectre_fit(i,j,:);
        % ----------- Area ------------------------------------
        area_zone = mat_area(i,j);
        % ----------- Grey ------------------------------------
        grey_zone = mat_grey(i,j);
        
        % ----------- Ecart spectre a -------------------------
        %         mat_ecarts_spectre_fit_a(i-1,j-1) = nansum(((exp(spectre_zone) - exp(spectre_ref))./exp(spectre_ref)));
        
        mat_ecarts_spectre_fit_a(i-1,j-1) = (      nansum((abs(exp(spectre_zone) - exp(spectre_ref))) ./exp(spectre_ref))   ) / (numel(x_sel));
        
        % ----------- Ecart spectre b -------------------------
        mat_ecarts_spectre_fit_b(i-1,j-1) = ((nansum((exp(spectre_zone) - exp(spectre_ref)).^2)) / (numel(x_sel)))^0.5;
        
        % ----------- Ecart area -------------------------
        mat_ecarts_area(i-1,j-1) = abs(area_zone - area_ref)/area_ref;
        
        % ----------- Ecart grey -------------------------
        mat_ecarts_grey(i-1,j-1) = abs(grey_zone - grey_ref)/grey_ref;
    end
end

%% ------------- Boucle sur differents FIT --------------------------
% for f = 2 : 3%min(5,numel(mat_adj)-2)
%     disp('---------------------------------------------------------------')
%     disp(fit_type)

mat_cor_fit_a = NaN * zeros(nb_zones,1);
mat_cor_fit_b = NaN * zeros(nb_zones,1);
mat_cor_area = NaN * zeros(nb_zones,1);
mat_cor_grey = NaN * zeros(nb_zones,1);
mat_cor_ecart_area = NaN * zeros(nb_zones,1);
mat_cor_ecart_grey = NaN * zeros(nb_zones,1);

for j = 2 : nb_zones + 1
    % ------- POLY 3 pour AREA et GREY -------------------
    fit_type = ['poly3'];
    ft = fittype( fit_type );
    opts = fitoptions( 'Method', 'LinearInterpolant' );
%     opts.Robust = 'Bisquare';
    % ---- mat area ----------
    [xData, yData] = prepareCurveData( mat_gain, mat_area(2:end,j ));
    [fitresult_all, gof] = fit( xData, yData, ft ,opts);
    [y_area] = poly_from_fit(x,fitresult_all,fit_type);
    
    % ---- mat grey ----------
    [xData, yData] = prepareCurveData( mat_gain, mat_grey(2:end,j ));
    [fitresult_all, gof] = fit( xData, yData, ft ,opts);
    [y_grey] = poly_from_fit(x,fitresult_all,fit_type);
    
    % ------- POLY 2 pour ECARTS -------------------
    fit_type = ['poly2'];
    ft = fittype( fit_type );
    opts = fitoptions( 'Method', 'LinearInterpolant' );
%     opts.Robust = 'Bisquare';
    % ---- mat ecarts_area ----------
    [xData, yData] = prepareCurveData( mat_gain, mat_ecarts_area(:,j-1));
    [fitresult_all, gof] = fit( xData, yData, ft ,opts);
    [y_ecart_area] = poly_from_fit(x,fitresult_all,fit_type);
    
    % ---- mat ecarts_grey ----------
    [xData, yData] = prepareCurveData( mat_gain, mat_ecarts_grey(:,j-1));
    [fitresult_all, gof] = fit( xData, yData, ft ,opts);
    [y_ecart_grey] = poly_from_fit(x,fitresult_all,fit_type);
    
    % ---- mat ecarts fit a ----------
    [xData, yData] = prepareCurveData( mat_gain, mat_ecarts_spectre_fit_a(:,j-1));
    [fitresult_all, gof] = fit( xData, yData, ft ,opts);
    [y_ecart_fit_a] = poly_from_fit(x,fitresult_all,fit_type);
    
    % ---- mat ecarts fit b ----------
    [xData, yData] = prepareCurveData( mat_gain, mat_ecarts_spectre_fit_b(:,j-1));
    [fitresult_all, gof] = fit( xData, yData, ft ,opts);
    [y_ecart_fit_b] = poly_from_fit(x,fitresult_all,fit_type);
    
    % --------------- Matrices de correction ----------
    %     aa = find(mat_area(2:end,j ) <= area_ref);
    %     if ~isempty(aa)
    %         if aa(1) >= 1 && aa(end) < numel(x)
    %             mat_cor_area(j-1) = mat_gain(aa(end));
    %         end
    %     end
    %
    %     aa = find(mat_grey(2:end,j ) < grey_ref);
    %     if ~isempty(aa)
    %         if aa(1) >= 1 && aa(end) < numel(x)
    %             mat_cor_grey(j-1) = mat_gain(aa(end));
    %         end
    %     end
    
    aa = find(y_area < area_ref);
    if ~isempty(aa)
        if aa(1) >= 1 && aa(end) < numel(x)
            mat_cor_area(j-1) = x(aa(end));
        end
    end
    
    aa = find(y_grey < grey_ref);
    if ~isempty(aa)
        if aa(1) >= 1 && aa(end) < numel(x)
            mat_cor_grey(j-1) = x(aa(end));
        end
    end
    
    aa = find( mat_ecarts_area(:,j-1) == min(mat_ecarts_area(:,j-1)));
    if ~isempty(aa)
        if aa(1) > 1 && aa(end) < numel(x)
            mat_cor_ecart_area(j-1) = mat_gain(aa(end));
        end
    end
    
    aa = find(mat_ecarts_grey(:,j-1) == min(mat_ecarts_grey(:,j-1)));
    if ~isempty(aa)
        if aa(1) > 1 && aa(end) < numel(x)
            mat_cor_ecart_grey(j-1) = mat_gain(aa(end));
        end
    end
    
    aa = find(mat_ecarts_spectre_fit_a(:,j-1) == min(mat_ecarts_spectre_fit_a(:,j-1)));
    %         aa = find(y_ecart_fit_a <= 0);
    if ~isempty(aa)
        if aa(1) > 1 && aa(end) < numel(x)
            mat_cor_fit_a(j-1) = mat_gain(aa(end));
        end
    end
    
    aa = find(mat_ecarts_spectre_fit_b(:,j-1) == min(mat_ecarts_spectre_fit_b(:,j-1)));
    if ~isempty(aa)
        if aa(1) > 1 && aa(end) < numel(x)
            mat_cor_fit_b(j-1) = mat_gain(aa(end));
        end
    end
    
    % ---------- Figure de contrôle ---------------------------------
    if round(j/5)-1 == j/5 - 1
        fig2 = figure('numbertitle','off','name',['UVP6_cor_zonale_',num2str(j-1)],'Position',[10 50 900 300]);
        subplot(1,6,1)
        plot(mat_gain,mat_area(2:end,j),'+')
        hold on
        plot(x,y_area,'-');
        hold on
        plot(mat_cor_area(j-1), area_ref,'go')
        xlabel('AREA','fontsize',9);
        title(['Zone : ',num2str(j)       ],'fontsize',9);
        
        subplot(1,6,2)
        plot(mat_gain,mat_grey(2:end,j),'+')
        hold on
        plot(x,y_grey,'-');
        hold on
        plot(mat_cor_grey(j-1), grey_ref,'go')
        xlabel('GREY','fontsize',9);
        title(['Zone : ',num2str(j)       ],'fontsize',9);
        
        subplot(1,6,3)
        plot(mat_gain,mat_ecarts_area(:,j-1),'+')
        hold on
        plot(x,y_ecart_area,'-');
        xlabel('Ecarts AREA','fontsize',9);
        hold on
        plot(mat_cor_ecart_area(j-1), min(y_ecart_area),'go')
        title(['Zone : ',num2str(j)       ],'fontsize',9);
        
        subplot(1,6,4)
        plot(mat_gain,mat_ecarts_grey(:,j-1),'+')
        hold on
        plot(x,y_ecart_grey,'-');
        hold on
        plot(mat_cor_ecart_grey(j-1), min(y_ecart_grey),'go')
        xlabel('Ecarts GREY','fontsize',9);
        title(['Zone : ',num2str(j)       ],'fontsize',9);
        
        subplot(1,6,5)
        plot(mat_gain,mat_ecarts_spectre_fit_a(:,j-1),'+')
        hold on
        plot(x,y_ecart_fit_a,'-');
        hold on
        plot(mat_cor_fit_a(j-1), min(y_ecart_fit_a),'go')
        xlabel('Ecarts fit a','fontsize',9);
        title(['Zone : ',num2str(j)       ],'fontsize',9);
        
        subplot(1,6,6)
        plot(mat_gain,mat_ecarts_spectre_fit_b(:,j-1),'+')
        hold on
        plot(x,y_ecart_fit_b,'-');
        hold on
        plot(mat_cor_fit_b(j-1), min(y_ecart_fit_b),'go')
        xlabel('Ecarts fit b','fontsize',9);
        title(['Zone : ',num2str(j)       ],'fontsize',9);
        
        % ------------------ Sauvegarde image --------------------------
        orient tall
        set(gcf,'PaperPositionMode','auto')
        print(gcf,'-dpng',[results_folder,'matrice_',num2str(nb_zones),'_zones_',num2str(mat_adj(1)),'_zone_',num2str(j),'_',filename]);
        
    end
    
end

%% ----------------- Images des matrices de correction --------------
% ------- Reconstruction images -------------
index = 1;
for i = 1 : y_zones
    for j = 1 : x_zones
        image_cor_area(i,j) = mat_cor_area(index);
        image_cor_grey(i,j) = mat_cor_grey(index);
        image_cor_ecarts_area(i,j) = mat_cor_ecart_area(index);
        image_cor_ecarts_grey(i,j) = mat_cor_ecart_grey(index);
        image_cor_fit_a(i,j) = mat_cor_fit_a(index);
        image_cor_fit_b(i,j) = mat_cor_fit_b(index);
        index = index + 1;
    end
end

%% ------------- Boucle  --------------------------
% On remplace les valeurs NaN n'ayant pu être calculées par le minimum ou
% le maximum selon la zone

% LP - VE
color_scale = [8 30];
color_scale_gauss = [1 6];
% LP - HO
color_scale = [6 18];
color_scale_gauss = [1 4];


for mm = 1 : 2
    
    [X,Y] = meshgrid([1:x_zones],[1:y_zones]);
    
    % -------------- Figure à l'échelle originale -----------------------
    fig3 = figure('numbertitle','off','name','UVP6_cor_zonale','Position',[10 50 900 900]);
    subplot(3,2,1)
    if strcmp(symetrie,'y')
        ff = (image_cor_area + flip(image_cor_area))/2;
    else
        ff = image_cor_area;
    end
    if mm ==2
        for nn = 3:8
            hh = isnan(ff(nn,1:7));
            hh = find(hh == 1);
            ff(nn,hh) = nanmin(nanmin(ff));
        end
        for nn = 1:2;
            hh = isnan(ff(nn,1:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
        for nn = 9:10;
            hh = isnan(ff(nn,1:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
        for nn = 3:8
            hh = isnan(ff(nn,8:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
    end
    imagesc(ff,color_scale);
    xlabel(['cor area [',num2str(min(min(image_cor_area))),'  -  ',num2str(max(max(image_cor_area))),']']);
    title(titre);
    colorbar
    
    subplot(3,2,2)
    if strcmp(symetrie,'y')
        ff = (image_cor_grey + flip(image_cor_grey))/2;
    else
        ff = image_cor_grey;
    end
    if mm ==2
        for nn = 3:8
            hh = isnan(ff(nn,1:7));
            hh = find(hh == 1);
            ff(nn,hh) = nanmin(nanmin(ff));
        end
        for nn = 1:2;
            hh = isnan(ff(nn,1:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
        for nn = 9:10;
            hh = isnan(ff(nn,1:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
        for nn = 3:8
            hh = isnan(ff(nn,8:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
    end
    imagesc(ff,color_scale);
    xlabel(['cor grey [',num2str(min(min(image_cor_grey))),'  -  ',num2str(max(max(image_cor_grey))),']']);
    title(['No fit sym AFTER ref : ',char(gain_ref)]);
    colorbar
    
    subplot(3,2,3)
    if strcmp(symetrie,'y')
        ff = (image_cor_ecarts_area + flip(image_cor_ecarts_area))/2;
    else
        ff = image_cor_ecarts_area;
    end
    if mm ==2
        for nn = 3:8
            hh = isnan(ff(nn,1:7));
            hh = find(hh == 1);
            ff(nn,hh) = nanmin(nanmin(ff));
        end
        for nn = 1:2;
            hh = isnan(ff(nn,1:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
        for nn = 9:10;
            hh = isnan(ff(nn,1:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
        for nn = 3:8
            hh = isnan(ff(nn,8:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
    end
    imagesc(ff,color_scale);
    xlabel(['cor ecarts area [',num2str(min(min(image_cor_ecarts_area))),'  -  ',num2str(max(max(image_cor_ecarts_area))),']']);
    colorbar
    
    subplot(3,2,4)
    if strcmp(symetrie,'y')
        ff = (image_cor_ecarts_grey + flip(image_cor_ecarts_grey))/2;
    else
        ff = image_cor_ecarts_grey;
    end
    if mm ==2
        for nn = 3:8
            hh = isnan(ff(nn,1:7));
            hh = find(hh == 1);
            ff(nn,hh) = nanmin(nanmin(ff));
        end
        for nn = 1:2;
            hh = isnan(ff(nn,1:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
        for nn = 9:10;
            hh = isnan(ff(nn,1:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
        for nn = 3:8
            hh = isnan(ff(nn,8:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
    end
    imagesc(ff,color_scale);
    xlabel(['cor ecarts grey [',num2str(min(min(image_cor_ecarts_grey))),'  -  ',num2str(max(max(image_cor_ecarts_grey))),']']);
    colorbar
    
    subplot(3,2,5)
    if strcmp(symetrie,'y')
        ff = (image_cor_fit_a + flip(image_cor_fit_a))/2;
    else
        ff = image_cor_fit_a;
    end
    if mm ==2
        for nn = 3:8
            hh = isnan(ff(nn,1:7));
            hh = find(hh == 1);
            ff(nn,hh) = nanmin(nanmin(ff));
        end
        for nn = 1:2;
            hh = isnan(ff(nn,1:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
        for nn = 9:10;
            hh = isnan(ff(nn,1:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
        for nn = 3:8
            hh = isnan(ff(nn,8:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
    end
    imagesc(ff,color_scale);
    xlabel(['cor fit a [',num2str(min(min(image_cor_fit_a))),'  -  ',num2str(max(max(image_cor_fit_a))),']']);
    colorbar
    
    subplot(3,2,6)
    if strcmp(symetrie,'y')
        ff = (image_cor_fit_b + flip(image_cor_fit_b))/2;
    else
        ff = image_cor_fit_b;
    end
    if mm ==2
        for nn = 3:8
            hh = isnan(ff(nn,1:7));
            hh = find(hh == 1);
            ff(nn,hh) = nanmin(nanmin(ff));
        end
        for nn = 1:2;
            hh = isnan(ff(nn,1:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
        for nn = 9:10;
            hh = isnan(ff(nn,1:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
        for nn = 3:8
            hh = isnan(ff(nn,8:end));
            hh = find(hh == 1);
            ff(nn,hh) = nanmax(nanmax(ff));
        end
    end
    imagesc(ff,color_scale);
    xlabel(['cor fit b [',num2str(min(min(image_cor_fit_b))),'  -  ',num2str(max(max(image_cor_fit_b))),']']);
    colorbar
    
    % ------------------ Sauvegarde image --------------------------
    orient tall
    set(gcf,'PaperPositionMode','auto')
    if mm == 1
        print(gcf,'-dpng',[results_folder,'matrice_',num2str(nb_zones),'_zones_',num2str(mat_adj(1)),'_post_raw_',filename]);
    else
        print(gcf,'-dpng',[results_folder,'matrice_',num2str(nb_zones),'_zones_',num2str(mat_adj(1)),'_post_raw_interp',filename]);
    end
    
end

%% ---------------- Boucle sur les valeurs de filtres gaussien ----------
for gg = 1: numel(gauss_table)
    % -------------- Figure à l'échelle matrice WISIP -----------------------
    gauss = gauss_table(gg);
    cd(results_folder);
    fig4 = figure('numbertitle','off','name','UVP6_cor_zonale','Position',[10 50 900 900]);
    subplot(3,2,1)
    if strcmp(symetrie,'y')
        ff = (image_cor_area + flip(image_cor_area))/2;
    else
        ff = image_cor_area;
    end
    for nn = 3:8;        hh = isnan(ff(nn,1:7));         hh = find(hh == 1);     ff(nn,hh) = nanmin(nanmin(ff));    end
    for nn = 1:2;             hh = isnan(ff(nn,1:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    for nn = 9:10;             hh = isnan(ff(nn,1:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    for nn = 3:8;             hh = isnan(ff(nn,8:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    ff = imresize(ff,[129 154],'bicubic');
    ff = exp(ff*0.1155);
    ff = imgaussfilt(ff,gauss);
    mini = min(min(ff));
    ff = ff/mini;
    maxi = max(max(ff));
    imagesc(ff,color_scale_gauss);
    xlabel(['cor area gauss ',num2str(gauss),' [x',num2str(maxi,2),']']);
    title(titre);
    colorbar
    if isempty(find(isnan(ff), 1))
        file = [filename,'_area_gauss_',num2str(gauss),'.mat'];
        eval(['save ',file,' ff']);
    end
    
    subplot(3,2,2)
    if strcmp(symetrie,'y')
        ff = (image_cor_grey + flip(image_cor_grey))/2;
    else
        ff = image_cor_grey;
    end
    for nn = 3:8;             hh = isnan(ff(nn,1:7));             hh = find(hh == 1);             ff(nn,hh) = nanmin(nanmin(ff));         end
    for nn = 1:2;             hh = isnan(ff(nn,1:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    for nn = 9:10;             hh = isnan(ff(nn,1:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    for nn = 3:8;             hh = isnan(ff(nn,8:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    ff = imresize(ff,[129 154],'bicubic');
    ff = exp(ff*0.1155);
    ff = imgaussfilt(ff,gauss);
    mini = min(min(ff));
    ff = ff/mini;
    maxi = max(max(ff));
    imagesc(ff,color_scale_gauss);
    xlabel(['cor grey gauss ',num2str(gauss),' [x',num2str(maxi,2),']']);
    title([fit_type,'  sym AFTER ref : ',char(gain_ref)]);
    colorbar
    if isempty(find(isnan(ff), 1))
        file = [filename,'_grey_gauss_',num2str(gauss),'.mat'];
        eval(['save ',file,' ff']);
    end
    
    subplot(3,2,3)
    if strcmp(symetrie,'y')
        ff = (image_cor_ecarts_area + flip(image_cor_ecarts_area))/2;
    else
        ff = image_cor_ecarts_area;
    end
    for nn = 3:8;             hh = isnan(ff(nn,1:7));             hh = find(hh == 1);             ff(nn,hh) = nanmin(nanmin(ff));         end
    for nn = 1:2;             hh = isnan(ff(nn,1:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    for nn = 9:10;             hh = isnan(ff(nn,1:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    for nn = 3:8;             hh = isnan(ff(nn,8:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    ff = imresize(ff,[129 154],'bicubic');
    ff = exp(ff*0.1155);
    ff = imgaussfilt(ff,gauss);
    mini = min(min(ff));
    ff = ff/mini;
    maxi = max(max(ff));
    imagesc(ff,color_scale_gauss);
    xlabel(['cor ecarts area  gauss ',num2str(gauss),' [x',num2str(maxi,2),']']);
    colorbar
    if isempty(find(isnan(ff), 1))
        file = [filename,'_ecarts_area_gauss_',num2str(gauss),'.mat'];
        eval(['save ',file,' ff']);
    end
    
    subplot(3,2,4)
    if strcmp(symetrie,'y')
        ff = (image_cor_ecarts_grey + flip(image_cor_ecarts_grey))/2;
    else
        ff = image_cor_ecarts_grey;
    end
    for nn = 3:8;             hh = isnan(ff(nn,1:7));             hh = find(hh == 1);             ff(nn,hh) = nanmin(nanmin(ff));         end;
    for nn = 1:2;             hh = isnan(ff(nn,1:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    for nn = 9:10;             hh = isnan(ff(nn,1:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    for nn = 3:8;             hh = isnan(ff(nn,8:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    ff = imresize(ff,[129 154],'bicubic');
    ff = exp(ff*0.1155);
    ff = imgaussfilt(ff,gauss);
    mini = min(min(ff));
    ff = ff/mini;
    maxi = max(max(ff));
    imagesc(ff,color_scale_gauss);
    xlabel(['cor ecarts grey  gauss ',num2str(gauss),' [x',num2str(maxi,2),']']);
    colorbar
    if isempty(find(isnan(ff), 1))
        file = [filename,'_ecarts_grey_gauss_',num2str(gauss),'.mat'];
        eval(['save ',file,' ff']);
    end
    
    subplot(3,2,5)
    if strcmp(symetrie,'y')
        ff = (image_cor_fit_a + flip(image_cor_fit_a))/2;
    else
        ff = image_cor_fit_a;
    end
    for nn = 3:8;             hh = isnan(ff(nn,1:7));             hh = find(hh == 1);             ff(nn,hh) = nanmin(nanmin(ff));         end
    for nn = 1:2;             hh = isnan(ff(nn,1:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    for nn = 9:10;             hh = isnan(ff(nn,1:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    for nn = 3:8;             hh = isnan(ff(nn,8:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    ff = imresize(ff,[129 154],'bicubic');
    ff = exp(ff*0.1155);
    ff = imgaussfilt(ff,gauss);
    mini = min(min(ff));
    ff = ff/mini;
    maxi = max(max(ff));
    imagesc(ff,color_scale_gauss);
    xlabel(['cor fit a  gauss ',num2str(gauss),' [x',num2str(maxi,2),']']);
    colorbar
    if isempty(find(isnan(ff), 1))
        file = [filename,'_ecarts_fit_a_gauss_',num2str(gauss),'.mat'];
        eval(['save ',file,' ff']);
    end
    
    subplot(3,2,6)
    if strcmp(symetrie,'y')
        ff = (image_cor_fit_b + flip(image_cor_fit_b))/2;
    else
        ff = image_cor_fit_b;
    end
    for nn = 3:8;             hh = isnan(ff(nn,1:7));             hh = find(hh == 1);             ff(nn,hh) = nanmin(nanmin(ff));         end
    for nn = 1:2;             hh = isnan(ff(nn,1:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    for nn = 9:10;             hh = isnan(ff(nn,1:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    for nn = 3:8;             hh = isnan(ff(nn,8:end));             hh = find(hh == 1);             ff(nn,hh) = nanmax(nanmax(ff));         end
    ff = imresize(ff,[129 154],'bicubic');
    ff = exp(ff*0.1155);
    ff = imgaussfilt(ff,gauss);
    mini = min(min(ff));
    ff = ff/mini;
    maxi = max(max(ff));
    imagesc(ff,color_scale_gauss);
    xlabel(['cor fit b  gauss ',num2str(gauss),' [x',num2str(maxi,2),']']);
    colorbar
    if isempty(find(isnan(ff), 1))
        file = [filename,'_ecarts_fit_b_gauss_',num2str(gauss),'.mat'];
        eval(['save ',file,' ff']);
    end
    
    % ------------------ Sauvegarde image --------------------------
    orient tall
    set(gcf,'PaperPositionMode','auto')
    print(gcf,'-dpng',[results_folder,'matrice_',num2str(nb_zones),'_zones_',num2str(mat_adj(1)),'_post_res_interp_gauss_',num2str(gauss),'_',filename]);
end
% end
cd(folder);
disp('------------- Figures saved ------------------------------------ ');
disp('------------- END of PROCESS -----------------------------------')






