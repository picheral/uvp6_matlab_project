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

% -------- Option creation base en plus vecteurs bruts --------------------
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
auto = input('Select manually the data range for each sample ? (n/y) ','s');
if isempty(auto);auto = 'n';end

% ----- RAW folder -----------------------------
raw_folder = [folder,'\raw\'];
cd(raw_folder);

% ----- SETTINGS -------------------------------
zmin = 100;
disp("zmin is by default " + zmin)

% ----- Results folder -------------------------
results_folder = [folder,'\results\'];
if exist(results_folder) ~= 7
    mkdir(folder,'\results\');
end

% ------ Liste des répertoires séquence --------
seq = dir([cd '\2*']);
N_seq = size(seq,1);

% ------ Boucle sur les répertoires ------------
j= 1;
index = 0;
sample = 0;
while j < N_seq+1
    sample = sample +1;
%     profilename = [seq(j).name(1:15),'_sample_',num2str(sample)];
    profilename = [seq(j).name(1:end),'_sample_',num2str(sample)];
    disp('---------------------------------------------------------------')
    disp(['SAMPLE : ',char(profilename)]);
    txt = dir([seq(j).name '\*data.txt']);
    % path is the path for the text file stored in each sequence folder
    path = [raw_folder, seq(j).name, '\', txt.name];
    fid = fopen(path);
    % ----------------- Ligne HW -----------------
    tline = fgetl(fid);
    
    %tline is the first line of the text folder in which the parameters of the sequence are stored : shutter, threshold, gain, .....
    A = strsplit(tline,{','});
    
    %----- Vérification longueur ligne ----------
    if size(A,2) == 45 || size(A,2) == 44
        X = 0;
    else
        X = -1;
    end
    
    % ---- get all the metadata from the hardware line of the text file --
    % ---- premiere sequence ---------
    if j == 1
        %         eval([base_name '=[];']);
        sn = A{2};
        day = A{25+X};%(1:end-4)
        cruise = folder(4:end);
        base_name = ['base',folder(4:end)];
        pvmtype = ['uvp6_sn' sn];
        soft = 'uvp6';
        light =  A{6};
    end
    shutter = str2num(A{17+X});
    threshold = str2num(A{19+X});
    volume = str2num(A{23+X});
    gain = str2num(A{18+X});
    pixel = str2num(A{22+X})/1000;
    Aa = str2num(A{20});
    Exp = str2num(A{21});
    
    % ------------ LIgne ACQ ----------------------------------
    tline = fgetl(fid);
    tline = fgetl(fid);
    A = strsplit(tline,{','});
    black_ratio = str2num(A{15+X});
    %black_ratio = str2num(A{11+X});
    
    % ------------- Fermeture fichier -------------------------
    fclose(fid);
    
    eval([base_name '(sample).cruise = {cruise};']);
    eval([base_name '(sample).raw_folder = {seq(j).name};']);
    eval([base_name '(sample).pvmtype = {pvmtype};']);
    eval([base_name '(sample).soft = {soft};']);
    eval([base_name '(sample).profilename = {profilename};']);%         eval([base_name '=[];']);
    eval([base_name '(sample).shutter = shutter;']);
    eval([base_name '(sample).threshold = threshold;']);
    eval([base_name '(sample).gain = gain;']);
    eval([base_name '(sample).pixel_size= pixel;']);
    eval([base_name '(sample).volimg0 = volume;']);
    eval([base_name '(sample).black_ratio = black_ratio;']);
    eval([base_name '(sample).a0 = Aa;']);
    eval([base_name '(sample).exp0 = Exp;']);
    eval([base_name '(sample).light = light;']);
    
    %T is the table with all the lines of the text file, seperated in two tables : first part is the begnning with the date and time, pressure and black image flag
    T = readtable(path,'Filetype','text','ReadVariableNames',0,'Delimiter',':');
%     20190724-123151,22.31,34.50,1:  1,1048,41.7,14.5; 2,26,38.2,5.6;    3,1,66.0,28.5;
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
    %     prof_black = NaN*zeros(1,m);
    % prof_black = [];
    
    % -------- Boucle sur les lignes (images) --------------
    % for each image / each text file line
    % overexposed = 1
    % black = 2
    % data = 3
    disp('----------------- Reading loop ----------------------')
    for h=1:n
        if h/500==floor(h/500)
            disp(num2str(h))
        end
        % ------------ Ligne de zeros -----------------------
        line = zeros(1,900);
        
        % -------- VECTEURS METADATA -------
        C = strsplit(meta{h},{','});
        time_data(h) = datenum(datetime(char(C(1)),'InputFormat','yyyyMMdd-HHmmss'));
        prof_data(h) =  str2num(C{2});
        Flag = str2num(C{4});
        
        % --------- VECTEURS DATA -------------
        if isempty(findstr('OVER',data{h})) && isempty(findstr('EMPTY',data{h}))
            % -------- DATA ------------
            eval(['temp_matrix=[' data{h} '];']);
            [o,p]=size(temp_matrix);
            
            for k=1:o
                if temp_matrix(k,1)<=900
                    line(temp_matrix(k,1)) = temp_matrix(k,2);
                end
            end
            
            if Flag == 1
                raw_nb(h,:) = line;
                image_status(h) = 3;
            else
                black_nb(h,:) = line;
                image_status(h) = 2;
            end
            
            
        elseif ~isempty(findstr('OVER',data{h}))
            image_status(h) = 1;
        elseif ~isempty(findstr('EMPTY',data{h}))
            if Flag == 1
                raw_nb(h,:) = line;
                image_status(h) = 3;
            else
                black_nb(h,:) = line;
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
        %% -------- Enrgistrement table metadata -------------------
        %     vect = {'Z' 'timenum' 'pixel_1' 'pixel_2' 'pixel_3' 'pixel_4' 'pixel_5'};
        %     T = array2table(black_nb(:,1:7),'VariableNames',vect);
        %     T.time = %
        
        % --------- Retrait des trames vides indiquées par NaN -----------------------
        I = isnan(raw_nb(:,3));
        data_nb(I,:) = [];
        I = isnan(black_nb(:,3));
        black_nb(I,:) = [];
        
        % --------- Vecteur des images noires (Methode à vérifier) ------------
        vect_img_black = (black_ratio-1)*[1:numel(black_nb(:,1))];
        
        % --------- Calcul du bruit pour UVPdb --------------------------
        disp('---------------------------------------------------------------')
        median_1px = nanmedian(black_nb(:,3));
        median_2px = nanmedian(black_nb(:,4));
        disp(['Black_nb median abundance of 1 pixel objects (UVPdb) : ',num2str(median_1px)])
        disp(['Black_nb median abundance of 2 pixel objects (UVPdb) : ',num2str(median_2px)])
        
        disp('---------------------------------------------------------------')
        
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
            %         eval(['semilogx((', base_name, '(sample).raw_black(:,k)./',base_name,'(sample).raw_black(:,3)),-', base_name,'(sample).raw_black(:,1)),']);
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
        
        % -------- Selection des données ----------------------------------
        if strcmp(auto,'y')
            disp('---------------------------------------------------------------')
            depth_option = input('Choose selection option Image/Depth (i/d) ? ','s');
            if isempty(depth_option);depth_option = 'i';end
            aa = find(data_nb(:,1) == max(data_nb(:,1)));
            if strcmp(depth_option,'i')
                firstimg = input('Input first image for selection (DATA) (CR for 1) ');
                if isempty(firstimg);firstimg = 1;end
                disp(['Detected Image number at ',num2str(max(data_nb(:,1))),' dB : ' ,num2str(aa(1))])
                lastimg = input(['Input last image for selection (DATA) (CR for ',num2str(aa(1)),') ']);
                if isempty(lastimg);lastimg = aa(1);end
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
            % -------------- Valeurs par défaut ( > 100m )-----------------
            
            firstimg = find(data_nb(:,1) >= zmin);
            firstimg = firstimg(1);
            lastimg = max(data_nb(:,1));
            lastimg = find(data_nb(:,1) == lastimg);
            
        end
        
        % --------------------- Latitude / longitude / Time -----------------
        
        time = data_nb(firstimg,2);
        disp(['First image time : ',char(datetime(datevec(time)))])
        disp('---------------------------------------------------------------')
        if strcmp(auto,'y')
            latitude = input('Enter decimal latitude (- for S) ');
            longitude = input('Enter decimal longitude (- for W) ');
            
            if isempty(latitude); latitude = 12.5;end
            if isempty(longitude); longitude = 12.5;end
            
            
        else
            latitude = 12.5;
            longitude = 12.5;
        end
        
        eval([base_name '(sample).latitude = latitude;']);
        eval([base_name '(sample).longitude = longitude;']);
        
        eval([base_name '(sample).datenum = time;']);
        eval([base_name '(sample).datevect = datetime(datevec(time));']);
        
        % --------------------- Data selection -----------------------
        firstimg_black = floor(firstimg/(black_ratio-1)) +1;
        lastimg_black = floor(lastimg/(black_ratio-1))+1;
        [aa bb] = size(black_nb);
        lastimg_black = min(aa,lastimg_black);
        [aa bb] = size(data_nb);
        lastimg = min(aa,lastimg);
        data_nb = data_nb(firstimg :lastimg,:);
        
        black_nb = black_nb(firstimg_black  :lastimg_black , : );
        x2 = size(black_nb,1);
        
        %     [prof_black,x2] = max(prof_black);
        black_histo = [black_nb(:,1) black_nb(:,2) ones(x2,1) ones(x2,1) black_nb(:,3:7)];
        
        % -------- Profondeur virtuelle pour bassin --------------------
        if strcmp(process_calib,'y')
            data_nb(:,1) = [firstimg :lastimg]';
        end
        
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
        eval([base_name '(sample).histopx = nb_d;']);
        %     eval([base_name '(sample).raw_histopx = raw_nb(1:x1,1:900);']);
        eval([base_name '(sample).raw_histopx = data_nb;']);
        eval([base_name '(sample).raw_black = black_histo;']);
        
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
            eval(['semilogx((', base_name, '(sample).histopx(:,k)./',base_name,'(sample).histopx(:,3)),-', base_name,'(sample).histopx(:,1))']);
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
        eval(['histo_px=',base_name,'(sample).histopx(:,5:end);']);
        histo_mm2 = histo_px./(pixel^2);
        vol_img = volume;
        eval(['adj_nb_img=',base_name,'(sample).histopx(:,3);']);
        vol_ech=vol_img*adj_nb_img;
        
        vol_ech=vol_ech*ones(1,size(histo_mm2,2));
        histo_mm2_vol_mean=nanmean(histo_mm2./vol_ech);
        
        % ------ Calcul BLACK spectre de taille -----------------------
        eval(['histo_px_black=',base_name,'(sample).raw_black(:,5:9);']);
        histo_mm2_black = histo_px_black./(pixel^2);
        eval(['adj_nb_img_black=',base_name,'(sample).raw_black(:,3);']);
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
        if strcmp(auto,'y')
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
    eval(['save ' base_name ,'.mat ', base_name])
    disp('---------------------------------------------------------------')
    disp('------------- DATABASE saved : END of Process -----------------')
end
disp('---------------------------------------------------------------')
