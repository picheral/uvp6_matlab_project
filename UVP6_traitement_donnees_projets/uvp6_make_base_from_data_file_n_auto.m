<<<<<<< HEAD
%% Procédure de mise en base des fichiers data de UVP6

% Si mesures en aquarium, une profondeur fictive est calculee afin de se
% retrouver dans le cas d'un profil "classique".
% L'outil permet de sélectionner la section du profil à mettre en base en
% utilisant le profil de descente/montée et le profil de bruit pour détecter visuellement la fin de l'eblouissement.
% L'outil n'effetue aucune correction de bruit. Il enregistre les données
% de bruit dans un champ séparé.
% Il est possible de sectionner un même "sample" en plusieurs profils afin
% de traiter des YOYO ou des comparaisons descente/remontée
% L'outil nécessite l'architecture "projet" classique de Zooprocess:
% => repertoires de la séquence en sous répertoire de "raw"
% => utilisation du fichier "data.txt"

%Creator : Louis Petiteau
%Modified : Marc Picheral
%Date : 2019/01/25

% -----------------------------------------------------------------
% TO DO :
% modifier graphes (N) images, S/N%
% -----------------------------------------------------------------


% ------ raw_black
raw_black_col = {' '};
raw_histopx_col = {' '};
histopx_col ={' '};

% ------ Creation de base UVP6 generique avec contrôle des données --------

clear all
close all

disp('------------------- START CREATING BASE for UVP6 --------------')
disp('Select PROJECT folder ')
folder = uigetdir('', 'Select PROJECT Folder ');
disp('---------------------------------------------------------------')
disp(['Folder : ',char(folder)])
disp('---------------------------------------------------------------')

% -------- Option creation base en plus des vecteurs bruts --------------------
% les data.mat sont toujours créés :
% Image status : Z, datenum, statut image (1: overexposed, 2 : black, 3 : lpm)
create_profils = input('Process also profile database ? (y/n) ','s');
if isempty(create_profils); create_profils = 'y';end

% --------  AQUARIUM OPTION --------------------
% Va créer un vecteur de profondeur fictif en utilisant le N° d'image
process_calib = input('Process data from aquarium inter-calibration ? (n/y) ','s');
if isempty(process_calib); process_calib = 'n'; end

% -------- AUTO --------------------------------
% Par défaut, création d'une base avec les même profondeurs et metadata
% pour tous les sample/sequence, sinon, toutes options possibles.
manually = input('Select manually the data range for each sample ? (n/y) ','s');
if isempty(manually);manually = 'n';end

if strcmp(manually,'n')
    zmin = input('Select Zmin for all profiles (100) ');
    if isempty(zmin); zmin = 100; end 
    disp("zmin is by default " + zmin)
end
   

% ----- RAW folder -----------------------------
raw_folder = [folder,'\raw\'];
cd(raw_folder);

% ----- Results folder -------------------------
results_folder = [folder,'\results\'];
if exist(results_folder) ~= 7
    mkdir(folder,'\results\');
end

% ------ Liste des répertoires séquence --------
seq = dir([cd '\2*']);
N_seq = size(seq,1);

%% ------ Boucle sur les répertoires ------------
j= 1;
index = 0;
sample = 0;
% initialise base structure
base(N_seq) = struct();
while j < N_seq+1
    %% read HW and ACQ lines of the sequence
    sample = sample + 1;
    profilename = [seq(j).name,'_sample_',num2str(sample)];
    disp('---------------------------------------------------------------')
    disp(['SAMPLE : ',char(profilename)]);
    txt = dir([seq(j).name '\*data.txt']);
    
    % open data.txt file
    % path is the path for the text file stored in each sequence folder
    path = [raw_folder, seq(j).name, '\', txt.name];
    
    %% ----------- A REMPLACER PAR FONCTION ------------------------
    % [sn,day,cruise,base_name,pvmtype,soft,light,shutter,threshold,volume,gain,pixel,Aa,xp] = uvp6_read_metadata_from_datafile(folder,path);
    
    fid = fopen(path);
    
    % ----------------- Ligne HW -----------------
    tline = fgetl(fid);
    %tline is the first line of the text folder in which the parameters of the sequence are stored : shutter, threshold, gain, .....
    hw_line = strsplit(tline,{','});
    
    %----- Vérification longueur ligne ----------
    if size(hw_line,2) == 45 || size(hw_line,2) == 44
        X = 0;
    else
        X = -1;
    end
    
    % ---- get all the metadata from the hardware line of the text file --
    % ---- premiere sequence ---------
    if j == 1
        sn = hw_line{2};
        day = hw_line{25+X};
        cruise = folder(4:end);
        base_name = ['base',folder(4:end)];
        pvmtype = ['uvp6_sn' sn];
        soft = 'uvp6';
        light =  hw_line{6};
    end
    shutter = str2double(hw_line{17+X});
    threshold = str2double(hw_line{19+X});
    volume = str2double(hw_line{23+X});
    gain = str2double(hw_line{18+X});
    pixel = str2double(hw_line{22+X})/1000;
    Aa = str2double(hw_line{20});
    Exp = str2double(hw_line{21});
    
    % ------------ LIgne ACQ ----------------------------------
    tline = fgetl(fid);
    tline = fgetl(fid);
    acq_line = strsplit(tline,{','});
    black_ratio = str2double(acq_line{15+X});
    
    % ------------- Fermeture fichier -------------------------
    fclose(fid);
    
    base(sample).cruise = {cruise};
    base(sample).raw_folder = {seq(j).name};
    base(sample).pvmtype = {pvmtype};
    base(sample).soft = {soft};
    base(sample).profilename = {profilename};
    base(sample).shutter = shutter;
    base(sample).threshold = threshold;
    base(sample).gain = gain;
    base(sample).pixel_size= pixel;
    base(sample).volimg0 = volume;
    base(sample).black_ratio = black_ratio;
    base(sample).a0 = Aa;
    base(sample).exp0 = Exp;
    base(sample).light = light;
    
    %% read data of the sequence
    %T is the table with all the lines of the text file, seperated in two tables : first part is the begnning with the date and time, pressure and black image flag
    %20190724-123151,22.31,34.50,1:  1,1048,41.7,14.5; 2,26,38.2,5.6;    3,1,66.0,28.5;
    T = readtable(path,'Filetype','text','ReadVariableNames',0,'Delimiter',':');
    data = table2array(T(:,2));
    meta = table2array(T(:,1));
    
    %Initialisation of the variables updated for each line of the text
    %file / each image
    [n,m]=size(data);
    nb_d = [];
    prof_data =     NaN*zeros(n,1);
    time_data =     NaN*zeros(n,1);
    black_nb =      NaN*zeros(n,900);
    raw_nb =        NaN*zeros(n,900);
    image_status =  NaN*zeros(n,1);
    
    % -------- Boucle sur les lignes (images) --------------
    % h is the number of the line
    % n is the max number of lines
    % for each image / each text file line
    % overexposed = 1
    % black = 2
    % data = 3
    
    disp('----------------- Reading loop ----------------------')
    for h=1:n
        if h/500==floor(h/500)
            disp(num2str(h))
        end
        
        % -------- VECTEURS METADATA -------
        C = strsplit(meta{h},{','});
        time_data(h) = datenum(datetime(char(C(1)),'InputFormat','yyyyMMdd-HHmmss'));
        prof_data(h) =  str2double(C{2});
        Flag = str2double(C{4});
        
        % --------- VECTEURS DATA -------------
        if isempty(strfind(data{h},'OVER')) && isempty(strfind(data{h},'EMPTY'))
            % -------- DATA ------------
            % cast the data line in nb_classx4 numerical matrix
            temp_matrix = str2num(data{h}); %#ok<ST2NM>
            % limit to class of 900 pixels wide objects
            % ------------ Ligne de zeros -----------------------
            line = zeros(1,900);
            [o,p]=size(temp_matrix);
            for k=1:o
                if temp_matrix(k,1)<=900
                    line(temp_matrix(k,1)) = temp_matrix(k,2);
                end
            end
            seen_classes_nb = length(line);
            
            if Flag == 1
                raw_nb(h,:) = 0;
                raw_nb(h,1:seen_classes_nb) = line;
                image_status(h) = 3;
            else
                black_nb(h,:) = 0;
                black_nb(h,1:seen_classes_nb) = line;
                image_status(h) = 2;
            end
        elseif ~isempty(strfind(data{h},'OVER'))
            % if the line is overexposed
            image_status(h) = 1;
        elseif ~isempty(strfind(data{h},'EMPTY'))
            if Flag == 1
                raw_nb(h,:) = 0;
                image_status(h) = 3;
            else
                black_nb(h,:) = 0;
                image_status(h) = 2;
            end
        end
    end
    disp('----------------- end of loop ----------------------')
    
    
    
    
    %% -------- Construction matrices de travail -----------------
    % raw_nb et black_nb sont les histo d'abondances par taille de pixel
    data_nb = [prof_data time_data raw_nb];
    black_nb = [prof_data time_data black_nb];
    image_status = [prof_data time_data image_status];
    
    %% -------- Saving data ------------------------------------
    seq_name = [seq(j).name(1:15),'_sequence_',num2str(j)];
    disp(['saving ',seq_name,'_data.mat'])
    eval(['save ',results_folder,'\',seq_name,'_data.mat data_nb black_nb image_status;'])
    disp('----------------- Data saved ----------------------')
   
    %% -------------- Creation de la base des profils "baseuvp6...." -----------------
    if strcmp(create_profils,'y')
        %% data preparation
        % -------- Enrgistrement table metadata -------------------
        %     vect = {'Z' 'timenum' 'pixel_1' 'pixel_2' 'pixel_3' 'pixel_4' 'pixel_5'};
        %     T = array2table(black_nb(:,1:7),'VariableNames',vect);
        %     T.time = %
        
        % --------- Retrait des trames vides indiquées par NaN -----------------------
        I = isnan(data_nb(:,3));
        data_nb(I,:) = [];
        I = isnan(black_nb(:,3));
        black_nb(I,:) = [];
        
        % --------- Vecteur des images noires (Methode à vérifier) ------------
        vect_img_black = (black_ratio-1)*[1:numel(black_nb(:,1))];
        
        % -------- Profondeur virtuelle pour bassin --------------------
        if strcmp(process_calib,'y')
            data_nb_lines_nb = size(data_nb);
            prof_data = [1 :data_nb_lines_nb(1)]';
            data_nb(:,1) = prof_data;
        end
        
        % --------------------- Latitude / longitude -----------------
        disp('---------------------------------------------------------------')
        if strcmp(manually,'y')
            latitude = input('Enter decimal latitude (- for S) ');
            if isempty(latitude); latitude = 12.5;end
            
            longitude = input('Enter decimal longitude (- for W) ');
            if isempty(longitude); longitude = 12.5;end
            
        else
            latitude = 12.5;
            longitude = 12.5;
        end
        base(sample).latitude = latitude;
        base(sample).longitude = longitude;
        disp('---------------------------------------------------------------')
        
        % --------- Calcul du bruit pour UVPdb --------------------------
        disp('---------------------------------------------------------------')
        median_1px = nanmedian(black_nb(:,3));
        median_2px = nanmedian(black_nb(:,4));
        disp(['Black_nb median abundance of 1 pixel objects (UVPdb) : ',num2str(median_1px)])
        disp(['Black_nb median abundance of 2 pixel objects (UVPdb) : ',num2str(median_2px)])
        disp('---------------------------------------------------------------')
        
        %% plots
        % --------- DATA --------------------------------------
        fig1 = figure('numbertitle','off','name','UVP6_control','Position',[10 50 1100 1200]);
        subplot(3,2,1);
        %     plot([1:numel(prof_data)],-prof_data,'k');
        plot(-data_nb(:,1),'k-');
        xlabel('Image','fontsize',12);
        ylabel('Pressure (dB)','fontsize',12);
        titre = ['DATA : ',char(profilename)];
        aa = find(titre == '_');
        titre(aa) = ' ';
        title(titre);
        
        % -------- BLACK ----------------------------------
        subplot(3,2,2);
        %     plot([1:numel(prof_black)],-prof_black,'k+');
        plot(-black_nb(:,1),'k.');
        xlabel('Image','fontsize',12);
        ylabel('Pressure (dB)','fontsize',12);
        titre = ['BLACK : ',char(profilename)];
        aa = find(titre == '_');
        titre(aa) = ' ';
        title(titre);
        
        % ------------ PROFIL NOISE -----------------
        subplot(3,2,3)
        for k=1:2
            semilogy(vect_img_black,black_nb(:,k+2),'.');
            hold on
        end
        xlabel('Image','fontsize',12);
        ylabel('Noise','fontsize',12);
        titre = ['NOISE'];
        aa = titre == '_';
        titre(aa) = ' ';
        title(titre);
        legend('1 pixel','2 pixels','Location','best');
        
        
        %% -------- Selection des données ----------------------------------
        % -------------- images selection -----------------
        % first and last images selected by image nb or Depth
        if strcmp(manually,'y')
            disp('---------------------------------------------------------------')
            depth_option = input('Choose selection option Image/Depth (i/d) ? ','s');
            if isempty(depth_option);depth_option = 'i';end
            max_depth_index = find(data_nb(:,1) == max(data_nb(:,1)));
            if strcmp(depth_option,'i')
                firstimg = input('Input first image for selection (DATA) (CR for 1) ');
                if isempty(firstimg);firstimg = 1;end
                disp(['Detected max depth Image number at ',num2str(max(data_nb(:,1))),' dB : ' ,num2str(max_depth_index(1))])
                lastimg = input(['Input last image for selection (DATA) (CR for ',num2str(max_depth_index(1)),') ']);
                if isempty(lastimg);lastimg = max_depth_index(1);end
                firstimg = max(firstimg,1);
                lastimg = min(lastimg,numel(data_nb(:,1)));
            else
                firstimg = input('Input starting depth (DATA) (CR for min) ');
                if isempty(firstimg)
                    firstimg = min(data_nb(:,1));
                    firstimg = find(data_nb(:,1) == firstimg);
                else
                    firstimg = find(data_nb(:,1) >= firstimg);
                    firstimg = firstimg(1);
                end
                lastimg = input('Input ending depth (DATA) (CR for max) ');
                if isempty(lastimg)
                    lastimg = max(data_nb(:,1));
                    lastimg = find(data_nb(:,1) == lastimg);
                else
                    lastimg = find(data_nb(:,1) <= lastimg);
                    lastimg = lastimg(end);
                end
            end
        else
            % Valeurs par défaut ( > 100m )
            firstimg = find(data_nb(:,1) >= zmin);
            firstimg = firstimg(1);
            lastimg = max(data_nb(:,1));
            lastimg = find(data_nb(:,1) == lastimg);
        end
        
        % ------------- time of first image -----------------
        time = data_nb(firstimg,2);
        disp(['First image time : ',char(datetime(datevec(time)))])
        base(sample).datenum = time;
        base(sample).datevect = datetime(datevec(time));
        disp('---------------------------------------------------------------')
        
        % --------------------- Data and black selection -----------------------
        firstimg_black = floor(firstimg/(black_ratio-1))+1;
        lastimg_black = floor(lastimg/(black_ratio-1))+1;
        [aa bb] = size(black_nb);
        lastimg_black = min(aa,lastimg_black);
        [aa bb] = size(data_nb);
        lastimg = min(aa,lastimg);
        data_nb = data_nb(firstimg :lastimg,:);
        
        black_nb = black_nb(firstimg_black  :lastimg_black , : );
        x2 = size(black_nb,1);
        black_histo = [black_nb(:,1) black_nb(:,2) ones(x2,1) ones(x2,1) black_nb(:,3:7)];
        
%         % -------- Profondeur virtuelle pour bassin --------------------
%         if strcmp(process_calib,'y')
%             data_nb(:,1) = [firstimg :lastimg]';
%         end
        
        % --------- Vecteur profondeurs --------------------------------
        [prof1,x1] = max(data_nb(:,1));
        depth = [2.5:5:prof1+4.999];
        
        % ----------- Creation des histogrammes DATA -----------------
        %Now all the text lines are stored in a raw_nb array, creates a
        %new array with the same format than the .histopx of the uvp5 which
        %is a list with integrated data from 5m thick water column.
        for h=1:size(depth,2)-1
            aa = find(data_nb(:,1)<depth(h+1) & data_nb(:,1)>=depth(h));
            if ~isempty(aa)
                if data_nb(1,1) < data_nb(end,1)-10 
                    % ------ Profil descente -------
                    dd = find(aa <= x1);
                else
                    dd = find(aa >= x1);
                end
                % passe de 5:902 à 3:900 le 12/02/2020
                nb_d(h,5:902) = nansum(data_nb(aa(dd),3:900),1);
                nb_d(h,4) = size(dd,1);
                nb_d(h,3) = size(aa,1);
                nb_d(h,2) = nanmean(data_nb(aa(dd),1));
                nb_d(h,1) = (depth(h+1)+ depth(h))/2;                
            else
                nb_d(h,1:904) = NaN(1,904);
            end
        end
        
        %All variables measured lately are stored in the base
        base(sample).histopx = nb_d;
        base(sample).raw_histopx = data_nb;
        base(sample).raw_black = black_histo;
        
        % ------------- SELECTION ------------------
        subplot(3,2,1);
        if strcmp(process_calib,'n');    hold on; end
        plot([1:numel(data_nb(:,1))]+firstimg,-data_nb(:,1),'r');
        xlabel('Image','fontsize',12);
        ylabel('Pressure (dB)','fontsize',12);
        titre = ['DATA : UVP6_sn',sn, ' ', char(profilename)];
        aa = titre == '_';
        titre(aa) = ' ';
        title(titre);
        legend('ALL',['Selection (',num2str(firstimg),'-',num2str(lastimg),') '],'Location','best');
        
        subplot(3,2,2);
        hold on
        plot([firstimg_black:lastimg_black],-black_nb(:,1),'r+');
        xlabel('Image','fontsize',12);
        ylabel('Pressure (dB)','fontsize',12);
        titre = ['BLACK '];
        aa = titre == '_';
        titre(aa) = ' ';
        title(titre);
        legend('ALL','Selection','Location','best');
        
        % ------------ PROFIL Abondance DATA -----------------
        subplot(3,2,4)
        for k=6:8
            semilogx((base(sample).histopx(:,k) ./ base(sample).histopx(:,3)), -base(sample).histopx(:,1));
            hold on
        end
        xlabel('Abundances','fontsize',12);
        ylabel('Pressure (dB)','fontsize',12);
        titre = ['UNCORRECTED DATA PROFILES'];
        aa = titre == '_';
        titre(aa) = ' ';
        title(titre);
        legend('1 pixel','2 pixels','3 pixels','Location','best');
        axis([1 10000 -100*ceil(max(prof_data)/100) 0]);
        
        % --------------- FIGURE spectre de tailles ---------------------
        % ------ Calcul DATA spectre de taille -----------------------
        histo_px = base(sample).histopx(:,5:end);
        histo_mm2 = histo_px./(pixel^2);
        vol_img = volume;
        adj_nb_img = base(sample).histopx(:,3);
        vol_ech=vol_img*adj_nb_img;
        
        vol_ech=vol_ech*ones(1,size(histo_mm2,2));
        histo_mm2_vol_mean=nanmean(histo_mm2./vol_ech);
        
        % ------ Calcul BLACK spectre de taille -----------------------
        histo_px_black = base(sample).raw_black(:,5:9);
        histo_mm2_black = histo_px_black./(pixel^2);
        adj_nb_img_black = base(sample).raw_black(:,3);
        vol_ech=vol_img*adj_nb_img_black;
        vol_ech=vol_ech*ones(1,5);
        histo_mm2_vol_mean_black=nanmean(histo_mm2_black./vol_ech);
        
        pix_vect_x = [1:1:size(histo_mm2,2)];
        esd_x = 2*(((pixel^2)*(pix_vect_x)./pi).^0.5);
        
        % ----- SPECTRES ---------------
        subplot(3,2,5);
        legende = {};
        % ------- DATA -------------------
        loglog(esd_x,histo_mm2_vol_mean,'r+');
        legende(1) = {'data'};
        % ------- BLACK ------------------
        hold on
        loglog(esd_x(1:5),histo_mm2_vol_mean_black,'b+');
        legende(2) = {'noise'};
        xlabel('RAW ESD [mm]','fontsize',12);
        ylabel('ABUNDANCE [#/L/mm²]','fontsize',12);
        legend(legende,'Location','best');
        title('MEAN SPECTRA (DATA & NOISE)')
        %     axis([0.05 2 0.1 10000000]);
        
        % ------- S/N ratio ---------------
        sn_ratio = histo_mm2_vol_mean_black./histo_mm2_vol_mean(1:5);
        subplot(3,2,6);
        plot([1:5],sn_ratio,'ro');
        xlabel('PIXEL','fontsize',12);
        ylabel('N/S','fontsize',12);
        title('N/S Ratio')
        axis([0 6 0 1]);
        
        disp('---------------------------------------------------------------')
        if strcmp(manually,'y')
            process_option = input('Modify selection of data for the same sample ? (n/y) ','s');
            if isempty(process_option);process_option = 'n';end
            
            if strcmp(process_option,'n')
                option = input('Add a profile for same sequence ? (n/a) ','s');
                if strcmp(option,'a')
                    index = index +1;
                else
                    j=j+1;
                    index = 0;
                end
            else
                index = 0;
                sample = sample - 1;
            end
        else
            j=j+1;
            index = 0;            
        end
        % ---------------------- Save figure ---------------------------
        orient tall
        titre = ['Control_figure_',char(profilename)];
        set(gcf,'PaperPositionMode','auto')
        print(gcf,'-dpng',[results_folder,char(titre)]);
        close(fig1);
    else
        j = j + 1;
    end
end

% ------------ Sauvegarde base ---------------------------
if strcmp(create_profils,'y')
    cd(results_folder);
    save([base_name ,'.mat'] , 'base')
    disp('---------------------------------------------------------------')
    disp('------------- DATABASE saved : END of Process -----------------')
end
disp('---------------------------------------------------------------')
=======
%% Procédure de mise en base des fichiers data de UVP6

% Si mesures en aquarium, une profondeur fictive est calculee afin de se
% retrouver dans le cas d'un profil "classique".
% L'outil permet de sélectionner la section du profil à mettre en base en
% utilisant le profil de descente/montée et le profil de bruit pour détecter visuellement la fin de l'eblouissement.
% L'outil n'effetue aucune correction de bruit. Il enregistre les données
% de bruit dans un champ séparé.
% Il est possible de sectionner un même "sample" en plusieurs profils afin
% de traiter des YOYO ou des comparaisons descente/remontée
% L'outil nécessite l'architecture "projet" classique de Zooprocess:
% => repertoires de la séquence en sous répertoire de "raw"
% => utilisation du fichier "data.txt"

%Creator : Louis Petiteau
%Modified : Marc Picheral
%Date : 2019/01/25

% -----------------------------------------------------------------
% TO DO :
% modifier graphes (N) images, S/N%
% -----------------------------------------------------------------


% ------ raw_black
raw_black_col = {' '};
raw_histopx_col = {' '};
histopx_col ={' '};

% ------ Creation de base UVP6 generique avec contrôle des données --------

clear all
close all

disp('------------------- START CREATING BASE for UVP6 --------------')
disp('Select PROJECT folder ')
folder = uigetdir('', 'Select PROJECT Folder ');
disp('---------------------------------------------------------------')
disp(['Folder : ',char(folder)])
disp('---------------------------------------------------------------')

% -------- Option creation base en plus des vecteurs bruts --------------------
% les data.mat sont toujours créés :
% Image status : Z, datenum, statut image (1: overexposed, 2 : black, 3 : lpm)
create_profils = input('Process also profile database ? (y/n) ','s');
if isempty(create_profils); create_profils = 'y';end

% --------  AQUARIUM OPTION --------------------
% Va créer un vecteur de profondeur fictif en utilisant le N° d'image
process_calib = input('Process data from aquarium inter-calibration ? (n/y) ','s');
if isempty(process_calib); process_calib = 'n'; end

% -------- AUTO --------------------------------
% Par défaut, création d'une base avec les même profondeurs et metadata
% pour tous les sample/sequence, sinon, toutes options possibles.
manually = input('Select manually the data range for each sample ? (n/y) ','s');
if isempty(manually);manually = 'n';end

if strcmp(manually,'n')
    zmin = input('Select Zmin for all profiles (100) ');
    if isempty(zmin); zmin = 100; end 
    disp("zmin is by default " + zmin)
end
   

% ----- RAW folder -----------------------------
raw_folder = [folder,'\raw\'];
cd(raw_folder);

% ----- Results folder -------------------------
results_folder = [folder,'\results\'];
if exist(results_folder) ~= 7
    mkdir(folder,'\results\');
end

% ------ Liste des répertoires séquence --------
seq = dir([cd '\2*']);
N_seq = size(seq,1);

%% ------ Boucle sur les répertoires ------------
j= 1;
index = 0;
sample = 0;
% initialise base structure
base(N_seq) = struct();
while j < N_seq+1
    %% read HW and ACQ lines of the sequence
    sample = sample + 1;
    profilename = [seq(j).name,'_sample_',num2str(sample)];
    disp('---------------------------------------------------------------')
    disp(['SAMPLE : ',char(profilename)]);
    txt = dir([seq(j).name '\*data.txt']);
    
    % open data.txt file
    % path is the path for the text file stored in each sequence folder
    path = [raw_folder, seq(j).name, '\', txt.name];
    
    %% ----------- A REMPLACER PAR FONCTION ------------------------
    % [sn,day,cruise,base_name,pvmtype,soft,light,shutter,threshold,volume,gain,pixel,Aa,xp] = uvp6_read_metadata_from_datafile(folder,path);
    
    fid = fopen(path);
    
    % ----------------- Ligne HW -----------------
    tline = fgetl(fid);
    %tline is the first line of the text folder in which the parameters of the sequence are stored : shutter, threshold, gain, .....
    hw_line = strsplit(tline,{','});
    
    %----- Vérification longueur ligne ----------
    if size(hw_line,2) == 45 || size(hw_line,2) == 44
        X = 0;
    else
        X = -1;
    end
    
    % ---- get all the metadata from the hardware line of the text file --
    % ---- premiere sequence ---------
    if j == 1
        sn = hw_line{2};
        day = hw_line{25+X};
        cruise = folder(4:end);
        base_name = ['base',folder(4:end)];
        pvmtype = ['uvp6_sn' sn];
        soft = 'uvp6';
        light =  hw_line{6};
    end
    shutter = str2double(hw_line{17+X});
    threshold = str2double(hw_line{19+X});
    volume = str2double(hw_line{23+X});
    gain = str2double(hw_line{18+X});
    pixel = str2double(hw_line{22+X})/1000;
    Aa = str2double(hw_line{20});
    Exp = str2double(hw_line{21});
    
    % ------------ LIgne ACQ ----------------------------------
    tline = fgetl(fid);
    tline = fgetl(fid);
    acq_line = strsplit(tline,{','});
    black_ratio = str2double(acq_line{15+X});
    
    % ------------- Fermeture fichier -------------------------
    fclose(fid);
    
    base(sample).cruise = {cruise};
    base(sample).raw_folder = {seq(j).name};
    base(sample).pvmtype = {pvmtype};
    base(sample).soft = {soft};
    base(sample).profilename = {profilename};
    base(sample).shutter = shutter;
    base(sample).threshold = threshold;
    base(sample).gain = gain;
    base(sample).pixel_size= pixel;
    base(sample).volimg0 = volume;
    base(sample).black_ratio = black_ratio;
    base(sample).a0 = Aa;
    base(sample).exp0 = Exp;
    base(sample).light = light;
    
    %% read data of the sequence
    %T is the table with all the lines of the text file, seperated in two tables : first part is the begnning with the date and time, pressure and black image flag
    %20190724-123151,22.31,34.50,1:  1,1048,41.7,14.5; 2,26,38.2,5.6;    3,1,66.0,28.5;
    T = readtable(path,'Filetype','text','ReadVariableNames',0,'Delimiter',':');
    data = table2array(T(:,2));
    meta = table2array(T(:,1));
    
    %Initialisation of the variables updated for each line of the text
    %file / each image
    [n,m]=size(data);
    nb_d = [];
    prof_data =     NaN*zeros(n,1);
    time_data =     NaN*zeros(n,1);
    black_nb =      NaN*zeros(n,900);
    raw_nb =        NaN*zeros(n,900);
    image_status =  NaN*zeros(n,1);
    
    % -------- Boucle sur les lignes (images) --------------
    % h is the number of the line
    % n is the max number of lines
    % for each image / each text file line
    % overexposed = 1
    % black = 2
    % data = 3
    
    disp('----------------- Reading loop ----------------------')
    for h=1:n
        if h/500==floor(h/500)
            disp(num2str(h))
        end
        
        % -------- VECTEURS METADATA -------
        C = strsplit(meta{h},{','});
        time_data(h) = datenum(datetime(char(C(1)),'InputFormat','yyyyMMdd-HHmmss'));
        prof_data(h) =  str2double(C{2});
        Flag = str2double(C{4});
        
        % --------- VECTEURS DATA -------------
        if isempty(strfind(data{h},'OVER')) && isempty(strfind(data{h},'EMPTY'))
            % -------- DATA ------------
            % cast the data line in nb_classx4 numerical matrix
            temp_matrix = str2num(data{h}); %#ok<ST2NM>
            % limit to class of 900 pixels wide objects
            % ------------ Ligne de zeros -----------------------
            line = zeros(1,900);
            [o,p]=size(temp_matrix);
            for k=1:o
                if temp_matrix(k,1)<=900
                    line(temp_matrix(k,1)) = temp_matrix(k,2);
                end
            end
            seen_classes_nb = length(line);
            
            if Flag == 1
                raw_nb(h,:) = 0;
                raw_nb(h,1:seen_classes_nb) = line;
                image_status(h) = 3;
            else
                black_nb(h,:) = 0;
                black_nb(h,1:seen_classes_nb) = line;
                image_status(h) = 2;
            end
        elseif ~isempty(strfind(data{h},'OVER'))
            % if the line is overexposed
            image_status(h) = 1;
        elseif ~isempty(strfind(data{h},'EMPTY'))
            if Flag == 1
                raw_nb(h,:) = 0;
                image_status(h) = 3;
            else
                black_nb(h,:) = 0;
                image_status(h) = 2;
            end
        end
    end
    disp('----------------- end of loop ----------------------')
    
    
    
    
    %% -------- Construction matrices de travail -----------------
    % raw_nb et black_nb sont les histo d'abondances par taille de pixel
    data_nb = [prof_data time_data raw_nb];
    black_nb = [prof_data time_data black_nb];
    image_status = [prof_data time_data image_status];
    
    %% -------- Saving data ------------------------------------
    seq_name = [seq(j).name(1:15),'_sequence_',num2str(j)];
    disp(['saving ',seq_name,'_data.mat'])
    eval(['save ',results_folder,'\',seq_name,'_data.mat data_nb black_nb image_status;'])
    disp('----------------- Data saved ----------------------')
   
    %% -------------- Creation de la base des profils "baseuvp6...." -----------------
    if strcmp(create_profils,'y')
        %% data preparation
        % -------- Enrgistrement table metadata -------------------
        %     vect = {'Z' 'timenum' 'pixel_1' 'pixel_2' 'pixel_3' 'pixel_4' 'pixel_5'};
        %     T = array2table(black_nb(:,1:7),'VariableNames',vect);
        %     T.time = %
        
        % --------- Retrait des trames vides indiquées par NaN -----------------------
        I = isnan(data_nb(:,3));
        data_nb(I,:) = [];
        I = isnan(black_nb(:,3));
        black_nb(I,:) = [];
        
        % --------- Vecteur des images noires (Methode à vérifier) ------------
        vect_img_black = (black_ratio-1)*[1:numel(black_nb(:,1))];
        
        % -------- Profondeur virtuelle pour bassin --------------------
        if strcmp(process_calib,'y')
            data_nb_lines_nb = size(data_nb);
            prof_data = [1 :data_nb_lines_nb(1)]';
            data_nb(:,1) = prof_data;
        end
        
        % --------------------- Latitude / longitude -----------------
        disp('---------------------------------------------------------------')
        if strcmp(manually,'y')
            latitude = input('Enter decimal latitude (- for S) ');
            if isempty(latitude); latitude = 12.5;end
            
            longitude = input('Enter decimal longitude (- for W) ');
            if isempty(longitude); longitude = 12.5;end
            
        else
            latitude = 12.5;
            longitude = 12.5;
        end
        base(sample).latitude = latitude;
        base(sample).longitude = longitude;
        disp('---------------------------------------------------------------')
        
        % --------- Calcul du bruit pour UVPdb --------------------------
        disp('---------------------------------------------------------------')
        median_1px = nanmedian(black_nb(:,3));
        median_2px = nanmedian(black_nb(:,4));
        disp(['Black_nb median abundance of 1 pixel objects (UVPdb) : ',num2str(median_1px)])
        disp(['Black_nb median abundance of 2 pixel objects (UVPdb) : ',num2str(median_2px)])
        disp('---------------------------------------------------------------')
        
        %% plots
        % --------- DATA --------------------------------------
        fig1 = figure('numbertitle','off','name','UVP6_control','Position',[10 50 1100 1200]);
        subplot(3,2,1);
        %     plot([1:numel(prof_data)],-prof_data,'k');
        plot(-data_nb(:,1),'k-');
        xlabel('Image','fontsize',12);
        ylabel('Pressure (dB)','fontsize',12);
        titre = ['DATA : ',char(profilename)];
        aa = find(titre == '_');
        titre(aa) = ' ';
        title(titre);
        
        % -------- BLACK ----------------------------------
        subplot(3,2,2);
        %     plot([1:numel(prof_black)],-prof_black,'k+');
        plot(-black_nb(:,1),'k.');
        xlabel('Image','fontsize',12);
        ylabel('Pressure (dB)','fontsize',12);
        titre = ['BLACK : ',char(profilename)];
        aa = find(titre == '_');
        titre(aa) = ' ';
        title(titre);
        
        % ------------ PROFIL NOISE -----------------
        subplot(3,2,3)
        for k=1:2
            semilogy(vect_img_black,black_nb(:,k+2),'.');
            hold on
        end
        xlabel('Image','fontsize',12);
        ylabel('Noise','fontsize',12);
        titre = ['NOISE'];
        aa = titre == '_';
        titre(aa) = ' ';
        title(titre);
        legend('1 pixel','2 pixels','Location','best');
        
        
        %% -------- Selection des données ----------------------------------
        % -------------- images selection -----------------
        % first and last images selected by image nb or Depth
        if strcmp(manually,'y')
            disp('---------------------------------------------------------------')
            depth_option = input('Choose selection option Image/Depth (i/d) ? ','s');
            if isempty(depth_option);depth_option = 'i';end
            max_depth_index = find(data_nb(:,1) == max(data_nb(:,1)));
            if strcmp(depth_option,'i')
                firstimg = input('Input first image for selection (DATA) (CR for 1) ');
                if isempty(firstimg);firstimg = 1;end
                disp(['Detected max depth Image number at ',num2str(max(data_nb(:,1))),' dB : ' ,num2str(max_depth_index(1))])
                lastimg = input(['Input last image for selection (DATA) (CR for ',num2str(max_depth_index(1)),') ']);
                if isempty(lastimg);lastimg = max_depth_index(1);end
                firstimg = max(firstimg,1);
                lastimg = min(lastimg,numel(data_nb(:,1)));
            else
                firstimg = input('Input starting depth (DATA) (CR for min) ');
                if isempty(firstimg)
                    firstimg = min(data_nb(:,1));
                    firstimg = find(data_nb(:,1) == firstimg);
                else
                    firstimg = find(data_nb(:,1) >= firstimg);
                    firstimg = firstimg(1);
                end
                lastimg = input('Input ending depth (DATA) (CR for max) ');
                if isempty(lastimg)
                    lastimg = max(data_nb(:,1));
                    lastimg = find(data_nb(:,1) == lastimg);
                else
                    lastimg = find(data_nb(:,1) <= lastimg);
                    lastimg = lastimg(end);
                end
            end
        else
            % Valeurs par défaut ( > 100m )
            firstimg = find(data_nb(:,1) >= zmin);
            firstimg = firstimg(1);
            lastimg = max(data_nb(:,1));
            lastimg = find(data_nb(:,1) == lastimg);
        end
        
        % ------------- time of first image -----------------
        time = data_nb(firstimg,2);
        disp(['First image time : ',char(datetime(datevec(time)))])
        base(sample).datenum = time;
        base(sample).datevect = datetime(datevec(time));
        disp('---------------------------------------------------------------')
        
        % --------------------- Data and black selection -----------------------
        firstimg_black = floor(firstimg/(black_ratio-1))+1;
        lastimg_black = floor(lastimg/(black_ratio-1))+1;
        [aa bb] = size(black_nb);
        lastimg_black = min(aa,lastimg_black);
        [aa bb] = size(data_nb);
        lastimg = min(aa,lastimg);
        data_nb = data_nb(firstimg :lastimg,:);
        
        black_nb = black_nb(firstimg_black  :lastimg_black , : );
        x2 = size(black_nb,1);
        black_histo = [black_nb(:,1) black_nb(:,2) ones(x2,1) ones(x2,1) black_nb(:,3:7)];
        
%         % -------- Profondeur virtuelle pour bassin --------------------
%         if strcmp(process_calib,'y')
%             data_nb(:,1) = [firstimg :lastimg]';
%         end
        
        % --------- Vecteur profondeurs --------------------------------
        [prof1,x1] = max(data_nb(:,1));
        depth = [2.5:5:prof1+4.999];
        
        % ----------- Creation des histogrammes DATA -----------------
        %Now all the text lines are stored in a raw_nb array, creates a
        %new array with the same format than the .histopx of the uvp5 which
        %is a list with integrated data from 5m thick water column.
        for h=1:size(depth,2)-1
            aa = find(data_nb(:,1)<depth(h+1) & data_nb(:,1)>=depth(h));
            if ~isempty(aa)
                if data_nb(firstimg) < data_nb(lastimg)-10 
                    % ------ Profil descente -------
                    dd = find(aa <= x1);
                else
                    dd = find(aa >= x1);
                end
                % passe de 5:902 à 3:900 le 12/02/2020
                nb_d(h,5:902) = nansum(data_nb(aa(dd),3:900),1);
                nb_d(h,4) = size(dd,1);
                nb_d(h,3) = size(aa,1);
                nb_d(h,2) = nanmean(data_nb(aa(dd),1));
                nb_d(h,1) = (depth(h+1)+ depth(h))/2;                
            else
                nb_d(h,1:904) = NaN(1,904);
            end
        end
        
        %All variables measured lately are stored in the base
        base(sample).histopx = nb_d;
        base(sample).raw_histopx = data_nb;
        base(sample).raw_black = black_histo;
        
        % ------------- SELECTION ------------------
        subplot(3,2,1);
        if strcmp(process_calib,'n');    hold on; end
        plot([1:numel(data_nb(:,1))]+firstimg,-data_nb(:,1),'r');
        xlabel('Image','fontsize',12);
        ylabel('Pressure (dB)','fontsize',12);
        titre = ['DATA : UVP6_sn',sn, ' ', char(profilename)];
        aa = titre == '_';
        titre(aa) = ' ';
        title(titre);
        legend('ALL',['Selection (',num2str(firstimg),'-',num2str(lastimg),') '],'Location','best');
        
        subplot(3,2,2);
        hold on
        plot([firstimg_black:lastimg_black],-black_nb(:,1),'r+');
        xlabel('Image','fontsize',12);
        ylabel('Pressure (dB)','fontsize',12);
        titre = ['BLACK '];
        aa = titre == '_';
        titre(aa) = ' ';
        title(titre);
        legend('ALL','Selection','Location','best');
        
        % ------------ PROFIL Abondance DATA -----------------
        subplot(3,2,4)
        for k=6:8
            semilogx((base(sample).histopx(:,k) ./ base(sample).histopx(:,3)), -base(sample).histopx(:,1));
            hold on
        end
        xlabel('Abundances','fontsize',12);
        ylabel('Pressure (dB)','fontsize',12);
        titre = ['UNCORRECTED DATA PROFILES'];
        aa = titre == '_';
        titre(aa) = ' ';
        title(titre);
        legend('1 pixel','2 pixels','3 pixels','Location','best');
        axis([1 10000 -100*ceil(max(prof_data)/100) 0]);
        
        % --------------- FIGURE spectre de tailles ---------------------
        % ------ Calcul DATA spectre de taille -----------------------
        histo_px = base(sample).histopx(:,5:end);
        histo_mm2 = histo_px./(pixel^2);
        vol_img = volume;
        adj_nb_img = base(sample).histopx(:,3);
        vol_ech=vol_img*adj_nb_img;
        
        vol_ech=vol_ech*ones(1,size(histo_mm2,2));
        histo_mm2_vol_mean=nanmean(histo_mm2./vol_ech);
        
        % ------ Calcul BLACK spectre de taille -----------------------
        histo_px_black = base(sample).raw_black(:,5:9);
        histo_mm2_black = histo_px_black./(pixel^2);
        adj_nb_img_black = base(sample).raw_black(:,3);
        vol_ech=vol_img*adj_nb_img_black;
        vol_ech=vol_ech*ones(1,5);
        histo_mm2_vol_mean_black=nanmean(histo_mm2_black./vol_ech);
        
        pix_vect_x = [1:1:size(histo_mm2,2)];
        esd_x = 2*(((pixel^2)*(pix_vect_x)./pi).^0.5);
        
        % ----- SPECTRES ---------------
        subplot(3,2,5);
        legende = {};
        % ------- DATA -------------------
        loglog(esd_x,histo_mm2_vol_mean,'r+');
        legende(1) = {'data'};
        % ------- BLACK ------------------
        hold on
        loglog(esd_x(1:5),histo_mm2_vol_mean_black,'b+');
        legende(2) = {'noise'};
        xlabel('RAW ESD [mm]','fontsize',12);
        ylabel('ABUNDANCE [#/L/mm²]','fontsize',12);
        legend(legende,'Location','best');
        title('MEAN SPECTRA (DATA & NOISE)')
        %     axis([0.05 2 0.1 10000000]);
        
        % ------- S/N ratio ---------------
        sn_ratio = histo_mm2_vol_mean_black./histo_mm2_vol_mean(1:5);
        subplot(3,2,6);
        plot([1:5],sn_ratio,'ro');
        xlabel('PIXEL','fontsize',12);
        ylabel('N/S','fontsize',12);
        title('N/S Ratio')
        axis([0 6 0 1]);
        
        disp('---------------------------------------------------------------')
        if strcmp(manually,'y')
            process_option = input('Modify selection of data for the same sample ? (n/y) ','s');
            if isempty(process_option);process_option = 'n';end
            
            if strcmp(process_option,'n')
                option = input('Add a profile for same sequence ? (n/a) ','s');
                if strcmp(option,'a')
                    index = index +1;
                else
                    j=j+1;
                    index = 0;
                end
            else
                index = 0;
                sample = sample - 1;
            end
        else
            j=j+1;
            index = 0;            
        end
        % ---------------------- Save figure ---------------------------
        orient tall
        titre = ['Control_figure_',char(profilename)];
        set(gcf,'PaperPositionMode','auto')
        print(gcf,'-dpng',[results_folder,char(titre)]);
        close(fig1);
    else
        j = j + 1;
    end
end

% ------------ Sauvegarde base ---------------------------
if strcmp(create_profils,'y')
    cd(results_folder);
    save([base_name ,'.mat'] , 'base')
    disp('---------------------------------------------------------------')
    disp('------------- DATABASE saved : END of Process -----------------')
end
disp('---------------------------------------------------------------')
>>>>>>> 4477271aa0a8ba4596dcbc998da82958baf94e33
