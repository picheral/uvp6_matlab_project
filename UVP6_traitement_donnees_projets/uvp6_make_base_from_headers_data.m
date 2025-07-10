%% Procédure de mise en base des fichiers data de UVP6


% Mise en base des données UVP6
% L'outil nécessite l'architecture "projet" classique de Zooprocess:
% => repertoires de la séquence en sous répertoire de "raw"
% => utilisation du fichier "data.txt"
% => utilisation du fichier "header"

%output
%base de tous les profils
%figures de contrôle dans results
%matrices brutes par profil dans results

%Creator : Marc Picheral
%Date : 2023/06/29


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

folder_details = split(folder,'\');
header_file = char(folder_details(end));
header_file = ['uvp6_header',header_file(5:end),'.txt'];

[char(folder_details(end)),'.txt'];
%% ================ OPTIONS =========================

% ----- meta folder -------------------------
meta_folder = [folder,'\meta\'];

% ----- RAW folder -----------------------------
raw_folder = [folder,'\raw\'];

% ----- Results folder -------------------------
results_folder = [folder,'\results\'];

% ------ Liste des répertoires séquence --------
seq = dir([cd '\2*']);
N_seq = size(seq,1);

% ------ Read header file (-------------------
[header] = uvp6_read_header_file(meta_folder,header_file);

base = [];
disp('---------------------------------------------------------------')

%% ------ Boucle sur les sampleId ------------
for i = 1: size(header,2)
    % ------- Présence répertoire sequence
    if exist([raw_folder,header(i).filename]) == 7
        data_txt_path = [raw_folder,header(i).filename,'\',header(i).filename,'_data.txt'];
        % ----------- get HW conf metadata ------------------------
        if i==1
            [sn,day,cruise,base_name,pvmtype,soft,light,shutter,threshold,volume,gain,pixel,Aa,Exp,black_ratio] = Uvp6ReadMetadataFromDatafile(char(folder_details(end)),data_txt_path);
        else
            [~,~,~,~,~,~,~,shutter,threshold,volume,gain,pixel,Aa,Exp,black_ratio] = Uvp6ReadMetadataFromDatafile(char(folder_details(end)),data_txt_path);
        end
        base(i).cruise = {header(i).cruise};
        base(i).raw_folder = {raw_folder};
        base(i).pvmtype = {pvmtype};
        base(i).soft = {soft};
        profilename = char(header(i).sampleid);
        base(i).profilename = {profilename};
        base(i).histfile = {char(header(i).filename)};
        base(i).shutter = shutter;
        base(i).threshold = threshold;
        base(i).gain = gain;
        base(i).pixel_size= pixel;
        base(i).volimg0 = volume;
        base(i).black_ratio = black_ratio;
        base(i).a0 = Aa;
        base(i).exp0 = Exp;
        base(i).light = light;

        %% read data of the sequence
        %T is the table with all the lines of the text file, seperated in two tables : first part is the begnning with the date and time, pressure and black image flag
        %20190724-123151,22.31,34.50,1:  1,1048,41.7,14.5; 2,26,38.2,5.6;    3,1,66.0,28.5;
        [data_all, meta_all] = Uvp6DatafileToArray(data_txt_path);

       % from first to last image
       firstimg = str2num(header(i).firstimage);
       lastimg = str2num(header(i).lastimage);
       data = data_all(firstimg:lastimg,:);
       meta = meta_all(firstimg:lastimg,:);

        %Initialisation of the variables updated for each line of the text
        %file / each image
        [n,m]=size(data);
        nb_d = [];

        disp('----------------- Reading loop ----------------------')
        [time_data, prof_data, raw_nb, black_nb, ~, image_status] = Uvp6ReadDataFromDattable(meta, data);
        disp('----------------- end of loop ----------------------')

        %% -------- Construction matrices de travail -----------------
        % raw_nb et black_nb sont les histo d'abondances par taille de pixel
        data_nb = [prof_data time_data raw_nb];
        black_nb = [prof_data time_data black_nb];
        image_status = [prof_data time_data image_status];

        %% -------- Saving data ------------------------------------
        seq_name = [header(i).sampleid,'_sequence_',num2str(i)];
        disp(['saving ',seq_name,'_data.mat'])
        eval(['save ',results_folder,'\',seq_name,'_data.mat data_nb black_nb image_status;'])
        disp('----------------- Data saved ----------------------')

        % --------- Retrait des trames vides indiquées par NaN -----------------------
        I = isnan(data_nb(:,3));
        data_nb(I,:) = [];
        I = isnan(black_nb(:,3));
        black_nb(I,:) = [];

        % --------- Calcul du bruit pour UVPdb --------------------------
        disp('---------------------------------------------------------------')
        median_1px = median(black_nb(:,3), "omitmissing");
        median_2px = median(black_nb(:,4), "omitmissing");
        disp(['Black_nb median abundance of 1 pixel objects (UVPdb) : ',num2str(median_1px)])
        disp(['Black_nb median abundance of 2 pixel objects (UVPdb) : ',num2str(median_2px)])
                
        mean_1px = nanmean(black_nb(:,3));
        mean_2px = nanmean(black_nb(:,4));
        disp(['Black_nb mean abundance of 1 pixel objects (UVPdb) : ',num2str(mean_1px)])
        disp(['Black_nb mean abundance of 2 pixel objects (UVPdb) : ',num2str(mean_2px)])
        disp('---------------------------------------------------------------')
        base(i).median_1px = median_1px;
        base(i).median_2px = median_2px;

        % --------- Correction du bruit ----------------------------------
        black_nb(:,3) = black_nb(:,3) - median_1px;
        black_nb(:,4) = black_nb(:,4) - median_2px;

        %% plots
        % --------- DATA --------------------------------------
        fig1 = figure('numbertitle','off','name','UVP6_control','Position',[10 50 1100 1200]);
        subplot(2,2,1);
        %     plot([1:numel(prof_data)],-prof_data,'k');
        plot(-data_nb(:,1),'k-');
        xlabel('Image','fontsize',12);
        ylabel('Pressure (dB)','fontsize',12);
        titre = ['DATA : ',char(profilename)];
        aa = find(titre == '_');
        titre(aa) = ' ';
        title(titre);

        % -------- BLACK ----------------------------------
        subplot(2,2,2);
        %     plot([1:numel(prof_black)],-prof_black,'k+');
        plot(-black_nb(:,1),'k.');
        xlabel('Image','fontsize',12);
        ylabel('Pressure (dB)','fontsize',12);
        titre = ['BLACK : ',char(profilename)];
        aa = find(titre == '_');
        titre(aa) = ' ';
        title(titre);

        % ------------- time of first image -----------------
        time = data_nb(1,2);
        disp(['First image time : ',char(datetime(datevec(time)))])
        base(i).datenum = time;
        base(i).datem = time;
        base(i).datevect = datetime(datevec(time));
        disp('---------------------------------------------------------------')

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
                % passe de 5:902 à 5:904 et 3:900 à 3:902 le 30/04/2020
                nb_d(h,5:904) = sum(data_nb(aa(dd),3:902),1, "omitnan");
                nb_d(h,4) = size(dd,1);
                nb_d(h,3) = size(aa,1);
                nb_d(h,2) = nanmean(data_nb(aa(dd),1));
                nb_d(h,1) = (depth(h+1)+ depth(h))/2;
            else
                nb_d(h,1:904) = NaN(1,904);
            end
        end

        %All variables measured lately are stored in the base
        base(i).histopx = nb_d;
 %       base(i).raw_histopx = data_nb;

        % ------------ PROFIL Abondance DATA -----------------
        subplot(2,2,3)
        for k=6:5:40
            semilogx((base(i).histopx(:,k) ./ base(i).histopx(:,3)), -base(i).histopx(:,1));
            hold on
        end
        xlabel('Abundances','fontsize',12);
        ylabel('Pressure (dB)','fontsize',12);
        titre = 'UNCORRECTED DATA PROFILES';
        aa = titre == '_';
        titre(aa) = ' ';
        title(titre);
        %legend('1 pixel','2 pixels','3 pixels','Location','best');
        axis([0.001 10000 -100*ceil(max(prof_data)/100) 0]);

        % --------------- FIGURE spectre de tailles ---------------------
        % ------ Calcul DATA spectre de taille -----------------------
        histo_px = base(i).histopx(:,5:end);
        histo_mm2 = histo_px./(pixel^2);
        vol_img = volume;
        adj_nb_img = base(i).histopx(:,3);
        vol_ech=vol_img*adj_nb_img;

        vol_ech=vol_ech*ones(1,size(histo_mm2,2));
        histo_mm2_vol_mean=nanmean(histo_mm2./vol_ech);


        pix_vect_x = [1:1:size(histo_mm2,2)];
        esd_x = 2*(((pixel^2)*(pix_vect_x)./pi).^0.5);

        % ----- SPECTRES ---------------
        subplot(2,2,4);
        legende = {};
        % ------- DATA -------------------
        loglog(esd_x,histo_mm2_vol_mean,'r+');
        legende(1) = {'data'};

        % ---------------------- Save figure ---------------------------
        orient tall
        titre = ['Control_figure_',char(profilename)];
        set(gcf,'PaperPositionMode','auto')
        print(gcf,'-dpng',[results_folder,char(titre)]);
        close(fig1);

    end

end

% ------------ Sauvegarde base ---------------------------

save([results_folder,'base_',base_name(7:end) ,'.mat'] , 'base')
disp('---------------------------------------------------------------')
disp('------------- DATABASE saved : END of Process -----------------')

disp('---------------------------------------------------------------')
