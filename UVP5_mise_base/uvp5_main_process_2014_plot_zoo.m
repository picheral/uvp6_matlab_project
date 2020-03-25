%% Trace des histogrammes et cartes du Zoo + LPM
% Utilise les abondances normalisées
% Picheral 2014/08
% La base est préalablement chargée et nomméee "base"
%       Une page par "station", moyenne des abondances et écarts
%       Six cartes globale des abondances moyennes par groupe
%       3 cartes entre 0 et 100m
%       3 cartes entre 100m et max depth
%       Une synthèse par station


function uvp5_main_process_2014_plot_zoo(base,results_dir,~)

disp(' ')
disp(' ')
disp('------------------------------------ LPM & Zooplankton UVP5 -----------------------------------------')
disp(' ')
eval('warning off MATLAB:divideByZero');
scrsz = get(0,'ScreenSize');

% ----------------------- Limite couche pour cartes intégrées -----------------
z_limit = 75;

%% ----------------- Sélection des enregistrements avec du Zooplankton -------------
index = 1;
base_new_index = [];
for i=1:size(base,2)
    if isfield(base(i),'zoopuvp5')
        if ~isempty(base(i).zoopuvp5)
            if isfield(base(i).zoopuvp5,'abondances')
                base_new_index = [base_new_index;i];
            end
        end
    end
end
base_new = base(base_new_index);

% ----------- Recherche taille max matrice abondances, CTD et LPM -------------------
nb_ligne_zoo = [];
nb_col_zoo = [];
zz_zoo = 0;
nb_ligne_lpm = [];
nb_col_lpm = [];
nb_ligne_ctd = [];
nb_col_ctd = [];
zz_lpm = 0;
zz_ctd = 0;
deep_stn_ctd = 0;

for i=1:numel(base_new);
    [nb_ligne_zoo(i) nb_col_zoo(i)] = size(base_new(i).zoopuvp5.abondances.data);
    [nb_ligne_lpm(i) nb_col_lpm(i)] = size(base_new(i).hisnb);
    if ~isempty(base(i).ctdrosettedata_normalized);
        [nb_ligne_ctd(i) nb_col_ctd(i)] = size(base(i).ctdrosettedata_normalized.data);
        if nb_ligne_ctd(i) > zz_ctd;
            zz_ctd= nb_ligne_ctd(i);
            deep_stn_ctd = i;
        end
    end
    if nb_ligne_zoo(i) > zz_zoo;
        zz_zoo = nb_ligne_zoo(i);
        deep_stn_zoo = i;
    end
    if nb_ligne_lpm(i) > zz_lpm;
        zz_lpm = nb_ligne_lpm(i);
        deep_stn_lpm = i;
    end
end
col_zoo = max(nb_col_zoo);
ligne_zoo = max(nb_ligne_zoo);
col_lpm = max(nb_col_lpm);
ligne_lpm = max(nb_ligne_lpm);
col_ctd = max(nb_col_ctd);
ligne_ctd = max(nb_ligne_ctd);

%% ---------- Matrice globale abondances LPM -----------------
ab_lpm(:,:,:) = NaN * ones(ligne_lpm,col_lpm,numel(base_new));
for tt = 1 : numel(base_new);
    ab_lpm(:,:,tt) = NaN * ones(ligne_lpm,col_lpm);
    % ---------- Matrice des abondances ------------------------
    [nb_ligne_lpm nb_col_lpm] = size(base_new(tt).hisnb);
    ab_lpm(1:nb_ligne_lpm,1:nb_col_lpm,tt) = base_new(tt).hisnb;
end
%% ---------- Matrice globale CTD NORMALISEES -----------------
if deep_stn_ctd ~= 0
    ctd_data(:,:,:) = NaN * ones(ligne_ctd,col_ctd,numel(base_new));
    for tt = 1 : numel(base_new);
        % ---------- Matrice des abondances ------------------------
        if ~isempty(base(tt).ctdrosettedata_normalized);
            [nb_ligne_ctd nb_col_ctd] = size( base(tt).ctdrosettedata_normalized.data);
            ctd_data(1:nb_ligne_ctd,1:nb_col_ctd,tt) = base(tt).ctdrosettedata_normalized.data;
        end
    end
end


%% ---------- Matrice globale des nombres et abondances ZOO -----------------
ab_zoo(:,:,:) = NaN * ones(ligne_zoo,col_zoo, numel(base_new));
nb_zoo(:,:,:) = NaN * ones(ligne_zoo,col_zoo, numel(base_new));
for tt = 1 : numel(base_new);
    % ---------- Matrice des abondances ------------------------
    [nb_ligne_zoo nb_col_zoo] = size(base_new(tt).zoopuvp5.abondances.data);
    ab_zoo(1:nb_ligne_zoo,1:nb_col_zoo,tt) = base_new(tt).zoopuvp5.abondances.data;
    % ----------- Matrice des nombres reconstruite -------------
    data_nb = base_new(tt).zoopuvp5.abondances.data(:,1:4);
    for cc = 5:col_zoo
        aaa = base_new(tt).zoopuvp5.abondances.data(:,4).*base_new(tt).zoopuvp5.abondances.data(:,cc);
        data_nb = [data_nb aaa];
    end
    nb_zoo(1:nb_ligne_zoo,1:nb_col_zoo,tt) = data_nb;
end

% ----------- Matrice abondances 0 - z_limitm --------------------------
ee = find(base_new(deep_stn_zoo).zoopuvp5.abondances.data(:,3)<=z_limit);
nb_0_z_limit = nansum(nb_zoo(1:ee(end),:,:),1);
vol_sum = nb_0_z_limit(:,4,:);
data_ab_0_z_limit =  nb_0_z_limit(:,1:4,:);
for cc = 5:col_zoo
    aaa = nb_0_z_limit(:,cc,:)./vol_sum;
    data_ab_0_z_limit = [data_ab_0_z_limit aaa];
end

% ----------- Matrice abondances > z_limitm --------------------------
nb_z_limit = nansum(nb_zoo(ee(end)+1:end,:,:),1);
vol_sum = nb_z_limit(:,4,:);
data_ab_z_limit =  nb_z_limit(:,1:4,:);
for cc = 5:col_zoo
    aaa = nb_z_limit(:,cc,:)./vol_sum;
    data_ab_z_limit = [data_ab_z_limit aaa];
end

%% ----------------- CARTES GENERALE CAMPAGNE ---------------------------
% Calcul des coordonnees des stations
for k=1:1:numel(base_new)
    latt(k,1)=[base_new(k).latitude];
    latt(k,2)=[base_new(k).latitude];
    long(k,1)=[base_new(k).longitude];
    long(k,2)=[base_new(k).longitude];
end

% Dimensions de la carte
x=[floor(min(long(:,1))) ceil(max(long(:,1)))];
y=[floor(min(latt(:,1))) ceil(max(latt(:,1)))];
xcor = x;
ycor = y;

m_proj('Mercator','longitudes',xcor,'latitudes',ycor);
sondes=[-6000 -5000 -4000 -3000 -2000 -1000 -500 -250 -150 -100 -50];

% Conversion des positions pour tracé sur la carte
[lon,lat]=m_ll2xy(long,latt);
[x,y]=m_ll2xy(x,y);

% ------------------ Boucle sur les ID à conserver ----------
% On retire certains groupes
name_list = base_new(1).zoopuvp5.abondances.names(1:end);
aa = ~strcmp(name_list,'to_skip(#/m3)');
name_list_cor = name_list(aa);
aa = ~strcmp(name_list_cor,'other_heart_like(#/m3)');
name_list_cor = name_list_cor(aa);
cruise = base_new(1).cruise;

%% ----------------- Liste des stations ----------------------------------
station_list = unique([base_new.stationname]);

if strcmp(base_new(1).cruise,'sn003_ccelter_2014');
    ea = ~strcmp(station_list,'test');
    eb = ~strcmp(station_list,'random_00');
    ec = ~strcmp(station_list,'random_01');
    ed = ~strcmp(station_list,'random_02');
    ee = ~strcmp(station_list,'random_03');
    station_list = station_list(ea & eb &  ec & ed & ee);
elseif strcmp(base_new(1).cruise,'sn003_outpace_2015');
    ea = ~strncmp(station_list,'test',4);
    station_list = station_list(ea);
end

station_list_cor = {};
for k = 1: numel(station_list);
    station = char(station_list(k));
    g=findstr('_',station);
    station(g) = ' ';
    station_list_cor(k) = {station};
end


% ----------- Immersions ------------------------------
% z_bar = 5*floor(ab_zoo(:,1,deep_stn_zoo)/5);
z_bar = floor(ab_zoo(:,1,deep_stn_zoo));
profmin = max(ab_zoo(:,3,deep_stn_zoo));
profmin = min(500,profmin);

nb_ids = numel(name_list_cor) - 4;


%% ------------------- Synthèse LPM -------------------------
figname = [char(cruise),'_LPM_CTD'];
fig=figure('numbertitle','off','name',figname,'Position',[10 50 4*scrsz(3)/5  4*scrsz(4)/5]);
set(gcf,'color','white');
ax=axes('NextPlot','add');

ab_lpm_all = ab_lpm(:,4:9,:);
ab_lpm_all_smal_sum = nansum(ab_lpm_all,2);
ab_lpm_all = ab_lpm(:,10:13,:);
ab_lpm_all_int_sum = nansum(ab_lpm_all,2);
ab_lpm_all = ab_lpm(:,14:end,:);
ab_lpm_all_large_sum = nansum(ab_lpm_all,2);

stn_colors = 'rgbckmkrgbckmkrgbcymkrgbcymkrgbcymkrgbcymkrgbcymkrgbcymkrgbcymkrgbcymkrgbcymkrgbcymkrgbcymkrgbcymkrgbcymkrgbcymkrgbcym';
% ------------------------- LPM DATA -------------------------------
for i = 1 : 3
    subplot(3,3,i);
    maxx = 0;
    if i == 1;
        data_all = ab_lpm_all_smal_sum;
        x_axe = 'LPM < 200µm (#/L)';
    elseif i== 2
        data_all = ab_lpm_all_int_sum;
        x_axe = 'LPM 200µm - 500µm(#/L)';
    else
        data_all = ab_lpm_all_large_sum;
        x_axe = 'LPM > 500µm (#/L)';
    end
    % --------------- Plot de tous les profils 0.06 - 0.2 mm ---------
    %     for j = 1: numel(base_new)
    %         plot(data_all(:,1,j),ab_lpm(:,1,j),'k');
    %         hold on
    %     end
    % --------------- PLOT de profils moyens par station -------------
    for k = 1: numel(station_list);
        % ----------- Profils de la station -------------
        station = station_list(k);
        Station = char(station);
        g=findstr('_',Station);
        Station(g) = ' ';
        % --------- Particules ---------------
        bbb = find(strcmp([base_new.stationname],station));
        ab_lpm_plot = nanmean(data_all(:,:,bbb),3);
        plot(ab_lpm_plot,ab_lpm(:,1,deep_stn_ctd),stn_colors(k),'linewidth',1);
        hold on
        
        ccc = max(max(ab_lpm_plot));
        maxx = max(ccc,maxx);
        
        if maxx == 0; maxx = 1;
        elseif maxx > 100000; maxx = ceil(maxx*0.00001)/0.00001;
        elseif maxx > 10000; maxx = ceil(maxx*0.0001)/0.0001;
        elseif maxx > 1000; maxx = ceil(maxx*0.001)/0.001;
        elseif maxx > 1000; maxx = ceil(maxx*0.001)/0.001;
        elseif maxx > 100; maxx = ceil(maxx*0.01)/0.01;
        elseif maxx > 10; maxx = ceil(maxx*0.1)/0.1;
        elseif maxx > 1; maxx = ceil(maxx);
        elseif maxx > 0.1; maxx = ceil(maxx*10)/10;
        elseif maxx > 0.01; maxx = ceil(maxx*100)/100;
        elseif maxx > 0.001; maxx = ceil(maxx*1000)/1000;
        elseif maxx > 0.0001; maxx = ceil(maxx*10000)/10000;
        elseif maxx > 0.00001; maxx = ceil(maxx*100000)/100000;
        elseif maxx > 0.000001; maxx = ceil(maxx*1000000)/1000000;
        end
    end
    
    hold off
    set(gca,'xlim',[0 maxx],'ydir','reverse','ylim',[0 profmin],'fontsize',6);
    xlabel(x_axe,'fontsize',8);
    ylabel('DEPTH (m)','fontsize',8);
    if i == 1;
        titre = ['UVP5 : ', char(cruise),' LPM & CTD data (AVERAGED  PER STATION)'];
        g=findstr('_',titre);
        titre(g) = ' ';
        text(0,- 0.2*profmin,titre,'color','b','fontsize',15);
    end
    % ------------- Legende ----------------
    if i == 1;
%         legend(station_list,'location','SouthEast')
    end
end

% ------------------------- CTD DATA -------------------------------
if deep_stn_ctd ~= 0
    for i = 4 : 9
        subplot(3,3,i);
        ctd_col = [26 28 12 8 11 16];
        % --------------- PLOT de profils moyens par station -------------
        for k = 1: numel(station_list);
            % ----------- Profils de la station -------------
            station = station_list(k);
            Station = char(station);
            g=findstr('_',Station);
            Station(g) = ' ';
            % --------- Particules ---------------
            bbb = strcmp([base_new.stationname],station);
            ctd_plot = mean(ctd_data(:,ctd_col(i-3),bbb),3);
            plot(ctd_plot,ctd_data(:,1,deep_stn_ctd),stn_colors(k),'linewidth',1);
            hold on
        end
        hold off
        %     set(gca,'xlim',[minx maxx],'ydir','reverse','ylim',[0 profmin],'fontsize',6);
        set(gca,'ydir','reverse','ylim',[0 profmin],'fontsize',6);
        x_axe = base_new(deep_stn_ctd).ctdrosettedata_normalized.names(ctd_col(i-3));
        %     legend(station_list,'location','SouthEast')
        xlabel(x_axe,'fontsize',8);
        ylabel(base_new(deep_stn_ctd).ctdrosettedata_normalized.names(1),'fontsize',8);
    end
end

% ------------ Sauvegarde --------------------
orient landscape
saveas(fig,[results_dir,figname,'.png']);
close(fig);


%% ------------------- Boucle sur les figures ----------------
h = waitbar(0,'Processing Maps ...');
mapmax = 2;
sheetmax = 4;
nbx = 3;
nby = 3;
tot_plot = nbx *  nby * sheetmax * mapmax;
plot_idx = 0;

for map = 1:mapmax
    if map == 1;
        zrange = ['0-',num2str(z_limit),'m'];
        nb_mat = nb_0_z_limit;
        ab_mat = data_ab_0_z_limit;
        color = 'r';
    else
        zrange = ['under-',num2str(z_limit),'m'];
        nb_mat = nb_z_limit;
        ab_mat = data_ab_z_limit;
        color = 'g';
    end
    % ------------ Pourcentages -----------------------------
    vect_prop = nansum(nb_mat(1,5:end,:),3);
    vect_prop = vect_prop/sum(vect_prop);
    
    % ------------ Boucle sur les pages ---------------------
    index = 4;
    for p = 1: sheetmax
        figname = [char(cruise),'_____',zrange,'_____zoo_map_____',num2str(p)];
        fig=figure('numbertitle','off','name',figname,'Position',[10 50 4*scrsz(3)/5  4*scrsz(4)/5]);
        set(gcf,'color','white');
        ax=axes('NextPlot','add');
        % ------------- plotmax plot par page sauf dernier ---------------
        if p == 4;
            plot_nb = nb_ids - nbx * nby * (p - 1);
        else
            plot_nb = nbx * nby;
        end
        for mm = 1: plot_nb
            index = index+1;
            disp(['PLOT : ',num2str(index-4),'  /  ',num2str(tot_plot)]);
            plot_idx = plot_idx + 1 ;
            waitbar( plot_idx / tot_plot );
            % ----- N° de colonne du zoo à tracer ------------
            col_zoo_nb = strcmp(name_list_cor(index),name_list);
            % ----------- SUBPLOT ----------------------------
            subplot(nby,nbx,mm);
            % ------------------ Trace de la carte ----------------------
            m_gshhs_f('patch',[.7 .7 .7],'edgecolor','k');
            set(gca,'color','none')
            m_grid('box','fancy','parent',ax)
            set(gca,'color','white')
            m_tbase_cor('contour',sondes);
            Xname = char(name_list_cor(index));
            g=findstr('_',Xname);
            Xname(g) = ' ';
            xlabel([char(Xname(1:end-6)),' ',num2str(100*round(vect_prop(index-4)*1000)/1000),'%'],'fontsize',9);
            abundances = ab_mat(:,col_zoo_nb,:);
            ab_norm = 200*nanmean(abundances(:)/max(abundances),2);
            aa = find(~isnan(ab_norm));
            % ---------- Retrait valeurs negatives ----------------------
            bb = find(ab_norm(aa)>0);
            t = scatter(lon(:,1),lat(:,1),3,'k','filled');
%             hold on
%             for i = 1:numel(bb)
%                 text(lon(bb(i),1),lat(bb(i),1),char(base_new(bb(i)).stationname),'Fontsize',10)
%             end
            hold on
            if ~isempty(bb)
                t = scatter(lon(bb,1),lat(bb,1),ab_norm(bb),color,'filled');
            end
            set(t,'MarkerEdgeColor','k');
            % -------------- TITRE ------------------
            if mm == 1;
                Xname = figname;
                g=findstr('_',Xname);
                Xname(g) = ' ';
                text(x(1),y(2) - 0.11*(y(1)-y(2)),[Xname,'/4 relative abundances'],'color','k','fontsize',15);
            end
        end
        % ------------ Sauvegarde --------------------
        orient landscape
        saveas(fig,[results_dir,figname,'.png']);
        close(fig);
    end
end
close(h);
%% ----------------- Boucle BARGRAPH principale sur les stations ------------------

for k = 1: numel(station_list);
    % ----------- Profils de la station -------------
    station = station_list(k);
    Station = char(station);
    g=findstr('_',Station);
    Station(g) = ' ';
    index = 4;
    bbb = find(strcmp([base_new.stationname],station));
    % ----------------- DEUX feuilles ---------------
    for map = 1: 2
        if map==1;
            plot_max = 20;%     ceil(nb_ids/2);
        else
            plot_max = nb_ids - plot_max;
        end
        % --------- Particules ---------------
        z_data = base_new(bbb(1)).hisnb(:,2);
        
        ab_lpm_stn = ab_lpm(1:numel(z_data),4:9,bbb);
        ab_lpm_stn = nansum(ab_lpm_stn,2);
        ab_lpm_smal = nanmean(ab_lpm_stn,3);
        
        ab_lpm_stn = ab_lpm(1:numel(z_data),14:end,bbb);
        ab_lpm_stn = nansum(ab_lpm_stn,2);
        ab_lpm_large = nanmean(ab_lpm_stn,3);
        
        ab_lpm_stn = ab_lpm(1:numel(z_data),10:13,bbb);
        ab_lpm_stn = nansum(ab_lpm_stn,2);
        ab_lpm_int = nanmean(ab_lpm_stn,3);
        
        ccc = find(ab_lpm_smal>0);
        figname = [char(cruise),'_zoo_bargraph_',Station,'_',num2str(map)];
        fig=figure('numbertitle','off','name',figname,'Position',[10 50 4*scrsz(3)/5  7*scrsz(4)/8]);
        set(gcf,'color','white');
        % ----------- Boucle sur les categories ---------------
        for mm = 5:plot_max+4;
            index = index+1;
            % ----- N° de colonne du zoo à tracer ------------
            col_zoo_nb = strcmp(name_list_cor(index),name_list);
            % ----- Data pour cette Id -----------------------
            data_bar = 1000*nanmean(ab_zoo(:,col_zoo_nb,bbb),3);
            maxx = max(data_bar);
            % ----------- Axe X ------------------------------
            if maxx == 0; maxx = 1;
            elseif maxx > 100000; maxx = ceil(maxx*0.00001)/0.00001;
            elseif maxx > 10000; maxx = ceil(maxx*0.0001)/0.0001;
            elseif maxx > 1000; maxx = ceil(maxx*0.001)/0.001;
            elseif maxx > 1000; maxx = ceil(maxx*0.001)/0.001;
            elseif maxx > 100; maxx = ceil(maxx*0.01)/0.01;
            elseif maxx > 10; maxx = ceil(maxx*0.1)/0.1;
            elseif maxx > 1; maxx = ceil(maxx);
            elseif maxx > 0.1; maxx = ceil(maxx*10)/10;
            elseif maxx > 0.01; maxx = ceil(maxx*100)/100;
            elseif maxx > 0.001; maxx = ceil(maxx*1000)/1000;
            elseif maxx > 0.0001; maxx = ceil(maxx*10000)/10000;
            elseif maxx > 0.00001; maxx = ceil(maxx*100000)/100000;
            elseif maxx > 0.000001; maxx = ceil(maxx*1000000)/1000000;
            end
            
            % ----------- SUBPLOT ----------------------------
            subplot(4,5,mm-4);
            rr = find(data_bar>0, 1);
            if ~isempty(rr)
                barh(z_bar,data_bar,3,'b','EdgeColor','b');
                hold on;
            end
            
            %           zz=get(gca,'children');
            %           get(zz)
            % ---------- Particules 0-200µm ------
            plot(0.9*maxx*ab_lpm_smal(ccc)/max(ab_lpm_smal(ccc)),z_data(ccc),'r');
            hold on
            % ---------- Particules 200 - 500 µm ------
            plot(0.8*maxx*ab_lpm_int(ccc)/max(ab_lpm_int(ccc)),z_data(ccc),'c');
            hold on
            % ---------- Particules > 500µm ------
            plot(0.7*maxx*ab_lpm_large(ccc)/max(ab_lpm_large(ccc)),z_data(ccc),'g');
            hold off
            set(gca,'xlim',[0 maxx],'ydir','reverse','ylim',[0 profmin],'fontsize',6);
            
            % ----------- Label graphes de gauche ------------
            if mm == 1+(floor(mm/5))*5;
                ylabel('Depth (m)','fontsize',6);
            end
            
            % ---- Legende particules ----------
            text(0.45*maxx,0.5*profmin,'ZOO : #/m3','color','k','fontsize',5);
            text(0.45*maxx,0.6*profmin,'LPM : relative','color','k','fontsize',5);
            text(0.45*maxx,0.7*profmin,'LPM < 200µm','color','r','fontsize',4);
            text(0.45*maxx,0.8*profmin,'200µm < LPM < 500µm','color','c','fontsize',4);
            text(0.45*maxx,0.9*profmin,'LPM > 500µm','color','g','fontsize',4);
            
            Xname = char(name_list_cor(index));
            g=findstr('_',Xname);
            Xname(g) = ' ';
            xlabel(char(Xname(1:end-6)),'fontsize',6);
            
            % -------------- TITRE ------------------
            if mm == 5;
                titre = ['Zooplankton MEAN abundance ', char(cruise),' STN ',Station,' sheet ',num2str(map),'/2'];
                g=findstr('_',titre);
                titre(g) = ' ';
                text(0,- 0.2*profmin,titre,'color','b','fontsize',15);
            end
        end
        % ------------ Sauvegarde --------------------
        orient landscape
        saveas(fig,[results_dir,figname,'.png']);
        close(fig);
    end
end

disp('---------------------- END PLOT ZOO ----------------------------');