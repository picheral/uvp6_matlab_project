%% Calcul des histogrammes UVP5 LPM
% Picheral 2014/08


function [base ] = uvp5_main_process_2014_histo(base,skip_histo,fichier,recpx,uvp5_cor_mat,pasvert,results_dir,sample_dir,save_histo,ligne,depth_offset,groupe,calibration,process_calib,manual_filter,mult_entry,movmean_window_entry,threshold_percent_entry,method)


%% ++++++++++++++++++ Vecteur de classes de taille en Biovolume (mm3/L) ++++++++++++++++++++++
%     mini=1*10^-3;       % in mm
%     maxi=30;            % in mm
%     pas=2^(1/3);
[classe0,taille0,medi0,minor,maxor,step]=pasvar_marc;%(mini,maxi,pas);            % Choix du pas variable (echelle octaves detaillee)
[classe0y classe0x]=size(classe0);

[classe0red,taillered,medired,minorred,maxorred,stepred]=pasvarred;            % Choix du pas variable (echelle octaves commune reduite)
[classe0yred classe0xred]=size(classe0red);

classepxa=1;
classepxb=900;
if strcmp(recpx,'o')
    disp(['Attention, histogrammes pixels max : ',num2str(classepxb)])
end
pasclassepx=1;
classepx=[classepxa:pasclassepx:classepxb];

base(fichier).minor = minor;
base(fichier).maxor = maxor;
base(fichier).step = step;
base(fichier).minorred = minorred;
base(fichier).maxorred = maxorred;
base(fichier). stepred = stepred;
disp(['fichier = ',num2str(fichier), '/',num2str(ligne)]);
process_histo= 0;

% ------------- Test sur la présence de l'histogramme dans la base ----------
if (strcmp(skip_histo,'y') && isfield(base(fichier),'hisnb') == 1 && ...
        isfield(base(fichier),'hisbv') == 1 && isfield(base(fichier),'hisnbred') == 1 &&...
        isfield(base(fichier),'hisbvred') == 1)
    if (isempty(base(fichier).hisnb) == 1 || isempty(base(fichier).hisbv) == 1 || isempty(base(fichier).hisnbred) == 1 || isempty(base(fichier).hisbvred) == 1);
        process_histo = 1;
    end
elseif strcmp(skip_histo,'n')
    process_histo = 1;
else
    process_histo = 1;
end
if process_histo == 0
    %         base(fichier).hisnb = [];
    %         base(fichier).hisnbred = [];
    %         base(fichier).hisbv = [];
    %         base(fichier).hisbvred = [];
    
elseif process_histo == 1
    % On retraite ou on traite
    colimg = 1;
    colsurf = 3;
    colgrey = 4;
    tta = [results_dir, char(base(fichier).profilename) '_datfile.txt'];
    ttb = [results_dir, char(base(fichier).profilename) '.bru'];
    ttc = [results_dir, 'HDR',char(base(fichier).histfile) '.bru'];
    
    if (exist(tta) == 2 && (exist(ttb) == 2 ||exist(ttc) == 2)==1 )
        %% --------------- Chargement du BRU modifie par ImageJ ---------------------------
        if (exist(ttb) == 2)
            name= [ char(base(fichier).profilename) '.bru'];
            disp(['Loading ',char(base(fichier).profilename),'.bru'])
            file = load(ttb);
        elseif (exist(ttc) == 2)
            name= [ char(base(fichier).histfile) '.bru'];
            disp(['Loading HDR',char(base(fichier).histfile),'.bru'])
            file = load(ttc);
        end
        % ------------------ Calibration (obsolete 2020/03/23) ----------------------
        base(fichier).calibration = uvp5_cor_mat;
        
        %% ------------------ Histogrammes --------------------------------------
        aa=(base(fichier).a0);
        exp=(base(fichier).exp0);
        volume=(base(fichier).volimg0);               % Volume d'une image
        imgOK=(base(fichier).firstimage);
        pixelsurfordre=sort(file(:,colsurf));
        pixelsurfliste=find(pixelsurfordre>0);
        pixelsurf=pixelsurfordre(pixelsurfliste(1));
        imgprem = (base(fichier).firstimage);
        imglast = (base(fichier).lastimage);
        minpixelarea = min(file(:,colsurf));
        
        %% ------------- Chargement du fichier immersions issu du DAT ------------        
        %         name= [char(base(fichier).profilename) '_datfile.txt'];
        %         disp(['Loading ', name])
        %         fid=fopen(tta);
        %         compteur = 1;
        %         Pressure = [];
        %         Image = [];
        %         Flag = [];
        %         Part = [];
        %
        %         pressure_prev = 0;
        %
        %         while 1                     % loop on the number of lines of the file
        %             tline = fgetl(fid);
        %             if ~ischar(tline), break, end
        %             dotcom=findstr(tline,';');  % find the end of petit gros column
        %             image = tline(1:dotcom(1)-1);
        %             pressure = tline(dotcom(2)+1:dotcom(3)-1);
        %             part = tline(dotcom(14)+1:dotcom(15)-1);
        %
        %             % -------- Correction hauteur UVP5 ----------------
        %             pressure = str2num(pressure) + depth_offset * 10;
        %             %                 disp(['Image=',image,'---pressure=',pressure]);
        %
        %             % ----------------- Codage descente --------------------
        %             %             if pressure_prev > pressure   % descente ou meme profondeur ! (>= ajouté 20120525)
        % %             if pressure_prev >= pressure   % descente ou meme profondeur ! (>= ajouté 20120525)
        %             if pressure_prev > pressure % Corrigé 2019/10/06
        %                 flag = 0;
        %             else
        %                 flag = 1;
        %             end
        %             Pressure = [Pressure;pressure];
        %             Image = [Image;str2num(image)];
        %             Flag = [Flag;flag];
        %             Part = [Part;str2double(part)];
        %             compteur=compteur+1;
        %             if compteur == 1000*floor(compteur/1000)
        %                 disp(['line = ',num2str(compteur)]);
        %             end
        %             pressure_prev = pressure;
        %         end             % end of loop to open one file
        %         fclose(fid);
        
        %         % ------------- Profils pseudo horizontaux pour calibrage --------
        %         if strcmp(process_calib,'y')
        %                 Pressure = [1:numel(Pressure)]';
        %                 Flag = ones(numel(Pressure),1);
        %         end
        %
        %         % ------------- DERNIERE image ----------------------------
        %         if strcmp(base(fichier).profilename,'tara_123_00_a'); imglast = 4620;end
        %         gg = find(Image == imglast);
        %         if isempty(gg);               gg = numel(Image);    end
        %
        %         % Profondeur premiere image OK
        %         % ----------- Corriger pour le N° d'image OK ! -------------------
        %         kk = find(Image >= imgprem);
        %
        %         % ---------- Création de liste qui contient tout ce qui est utile -
        %         liste = [ Image(kk(1):gg(end)) Pressure(kk(1):gg(end))/10 Flag(kk(1):gg(end)) Part(kk(1):gg(end)) ];
        %

        %         %              imgprem = 1;
        %
        %         % ----------- Corriger pour Zmax ---------------------------------
        %         zmax = max(liste(:,2));
        %         gg = find(liste(:,2) == zmax);
        %
        %         %% ----------- On travaille maintenant avec listcor -----------------------
        %         listecor = liste(1:gg(1),:);
        %        
        % -------------- Fonction de chargement et filtrage du DAT entre firstimage et zmax ainsi que descente --------    
        [Image Pressure Temp_interne Peltier Temp_cam Flag Part listecor liste] = uvp5_main_process_2014_load_datfile(base,fichier,sample_dir,depth_offset,process_calib);
        zimgprem = listecor(1,2);
        disp(['Profondeur DEB = ',num2str(zimgprem),'   First Img = ',num2str(imgprem),'   Last Img = ',num2str(imglast)]);
        [listesize c]=size(listecor);
        zmax = max(listecor(:,2));
        disp(['Profondeur MAX = ',num2str(zmax)]);
        
        %% ------------ Data quality check ----------------------------
        % data validation
        validation = 'ok';
        base(fichier).reject_img_percent = 0;
        if manual_filter == 'm'
            disp('------------------------------------------------')
            disp('Validation of the data...')
            % --------- Affichage pour déterminer si le profil mérite d'être filtré
            validation = DataValidation(listecor, results_dir, base(fichier).profilename);
        end
        
        % filtering of bad data points
        if strcmp(validation, 'n') || strcmp(manual_filter , 'a')
            % filtering
            disp('------------------------------------------------')
           % ---------------- Filtrage ----------------------
            % utilise les données chargées ci-dessus
            [im_filtered, part_util_filtered_rejected, movmean_window, threshold_percent, mult] = DataFiltering(listecor,results_dir,base(fichier).profilename,manual_filter,mult_entry,movmean_window_entry,threshold_percent_entry,method);
%             disp(['Movmean_window = ', num2str(movmean_window)])
%             disp(['Threshold_percent = ', num2str(threshold_percent*100)])
            disp(['Number of images from 1st and zmax              = ',num2str(size(listecor,1))])
            dd = find(listecor(:,3) == 1);
            disp(['Number of descent images                        = ',num2str(numel(dd))])
            disp(['Number of rejected images (from descent only)   = ',num2str(numel(part_util_filtered_rejected))])
            disp(['Number of good images (from descent only)       = ',num2str(numel(im_filtered))])
            disp(['Percentage of good images (from descent only)   = ',num2str((100*(numel(dd)-numel(part_util_filtered_rejected))/numel(listecor(:,1))),3)])
            base(fichier).tot_rejected_img = numel(part_util_filtered_rejected);
            base(fichier).tot_utilized_img = numel(im_filtered);
            base(fichier).filter_movmean = movmean_window;
            base(fichier).filter_threshold_percent = threshold_percent*100;
            base(fichier).mult = mult;
            base(fichier).rejected_img = part_util_filtered_rejected;
            base(fichier).filtered_img = im_filtered;
            
            % enregistrement dans results_dir du fichier datfile.txt corrigé
            disp('Saving filtered datfile !')
            file_s = [sample_dir,char(base(fichier).profilename), '_datfile.txt'];
            file_f = [results_dir,char(base(fichier).profilename), '_datfile.txt'];
            write_filtered_datfile(file_s,file_f,im_filtered,0);           

        else
            disp('------------------------------------------------')
            disp('NO data filter has been applied')
            
        end
        clf;
        close all
        
        
        %% ---------------- Selection sur le BRU -------------------
        % ----------- BRU : Corriger pour le N° d'image OK ! -------------------
        kk = find(file(:,1) == imgprem);
        gg = 0;
        while isempty(kk)
            kk = find(file(:,1) == imgprem+gg);
            gg = gg+1;
        end
        file = file(kk(1):end,:);
        
        % ----------- BRU : Corriger pour le N° d'image FIN ! -------------------
        kk = find(file(:,1) == imglast);
        gg = 0;
        while isempty(kk) && gg < 50
            kk = find(file(:,1) == imglast+gg);
            gg = gg+1;
        end
        % ---------- File débute maintenant à imgprem et finit soit à zmax, soit à imglast
        if isempty(kk)
            file = file(:,:);
        else
            file = file(1:kk(1),:);
        end
        
        [lbru cbru]=size(file);    % lbru est la taille du fichier résultant...
        
        % -------------- Classes de profondeurs --------------------
        % Le pas se change ici (epaisseur de la couche en metres)
        profondeur=[pasvert/2:pasvert:max(listecor(:,2))];    % Matrice des classes de profondeurs
        [x,y]=size(profondeur);
        
        % --------------- Matrices histogrammes, création de matrices de NaN qui seront remplies pas les valeurs existantes
        histonb=ones(y-1,classe0x+2)*NaN;
        histobv=ones(y-1,classe0x+2)*NaN;
        histonbred=ones(y-1,classe0xred+2)*NaN;
        histobvred=ones(y-1,classe0xred+2)*NaN;
        histopx=ones(y-1,(classepxb-classepxa+4)/pasclassepx)*NaN;                     % Matrice des pixels (Permet de determiner le seuil de détection d'une camera)
        
        % ---------- Boucle sur les blocs de profondeurs (echantillon) ----
        debbloc=1;
        listea=1;   %   imgprem;
        filea=1;
        nbmaximg=listesize;
        pasrech=4;
        lignehis=0;
        filemax = lbru;
        hh = find(listecor(:,2)== zmax);
        imgzmax = hh(1);            % imgzmax est un index de ligne
        nbimgprocessed = 0;
        
        %% --------------- Recherche adaptative dans la LISTE : economie de temps de recherche !
        % ------------- Boucle sur les pas de profondeurs -------------
        for z=pasvert:pasvert:profondeur(end)
            lignehis=lignehis+1;                                    % N° des lignes de l'histogramme
            
            % La première valeur des histogramme est l'immersion theorique du centre du bloc
            histopx(lignehis,1)=z;
            histonb(lignehis,1)=z;
            histobv(lignehis,1)=z;
            histonbred(lignehis,1)=z;
            histobvred(lignehis,1)=z;
            
            % imglist correspond exactement au N° d'image à prendre              % en compte
            % la taille de imglist donne le nombre d'images acquises par la camera dans l'intervalle de profondeurs
            listeb=min(imgzmax,listea+listesize-1);                 % Ne pas dépasser la taille de liste !
            
            % -------- Recherche entre listea et listeb / imglist est la liste des index des lignes du bloc, si FLAG descente == 1
            imglist=find(listecor(listea:listeb,2)>(z-pasvert/2) & listecor(listea:listeb,2)<=(z+pasvert/2) & listecor(listea:listeb,3)==1);
            
            % Nombre total d'images qui devraient etre comptees par le logiciel d'imagerie dans l'intervalle de profondeurs de l'echantillon
            [imglistsize c]=size(imglist);
            histopx(lignehis,3)=imglistsize;
            
            % Les index des lignes sont incrementes du talon listea pour la recherche dans LISTE des images contenant des particules
            imglist=imglist+listea-1;
            % On prend les images, dont le N° est supérieur à imgOK
            imgint=find(listecor(imglist,1)>=imgprem );       % Images d'interet avec particules
            imgzero=[];
            
            % S'il n'y a pas d'image valide dans l'intervalle de profondeurs:
            if (isempty(imglist) | (isempty(imgint)))
                %disp('Pas d image dans l intervalle')
                % Pas de modification de la ligne de NaN dans les histogrammes, indication que le nb d'images echantillonné est egal à 0
                histonb(lignehis,3)=0;
                histobv(lignehis,3)=0;
                histonbred(lignehis,3)=0;
                histobvred(lignehis,3)=0;
                histopx(lignehis,3)=0;
                nbmaximg=listesize;             % On continue a chercher jusqu'a la fin du fichier LISTE lorsque le bloc est vide
                listepas=1;
                
                % S'il y a au moins une image valide dans l'intervalle de profondeurs
            else
                % Calcul de l'histogramme en cherchant les informations de surface des particules dans le BRU (file)
                [nbimgy nbimgx]=size(imgint);
                [nbimgzero c]=size(imgzero);
                nbimgech=(nbimgy+nbimgzero);            % nbimgech est le nb d'images de l'échantillon (3e colonne de l'histo)
                campx=[];
                imgbru=[];
                campxhis=[];
                filemax=lbru;
                [listepas c]=size(imglist);
                % L'intervalle de recherche suivant aura une taille de pasrech x l'intervalle actuel et au moins de 200 images
                nbmaximg=max(pasrech*10*listepas,5000);
                % Recherche adaptative dans le BRU : economie de temps de recherche !
                for img=1:nbimgy;
                    % disp('-------------------------')
                    noimgbru=listecor(imglist(1)+imgint(img)-1,1);          % N° de l'image en cours de traitement
                    % On recherche dans le BRU entre filea et fileb. La première recherche se fait dans tout le BRU
                    fileb=min(lbru,filea+filemax);
                    imgbru=find(file(filea:fileb,1)==noimgbru);            % Indice des lignes du BRU correspondant au N° d'image en cours
                    % Test sur la vitesse
                    ee = find(listecor(:,1)== noimgbru);
                    if listecor(ee,3) == 1;
                        % On considere que l'image est traitée car descente
                        % ou pass le data quality check
                        if isempty(imgbru)
                            % L'image n'existe pas mais elle a ete codee 0
                            filepas =1;
                            imgbrusurf=[];                      % Matrice VIDE des surfaces (pixels) de cette image
                        else
                            % L'image existe puisque imgbru n'est pas vide
                            [filepas c]=size(imgbru);
                            % Les index des lignes trouvees dans le BRU sont incrementes du talon filea
                            imgbru=imgbru+filea-1;
                            imgbrusurf=file(imgbru,colsurf);    % Matrice des surfaces (pixels) de cette image
                            filea=max(imgbru(end)-1,1);
                        end
                    else    % L'image n'est pas traitée car pas descente ou pass pas le data quality check
                        if isempty(imgbru)
                            % L'image n'existe pas dans le BRU mais elle a ete codee 0 (comme si comptee vide de particule)
                            filepas =1;
                            imgbrusurf=[];
                        else
                            % L'image existe dans le fichier BRU puisque imgbru n'est pas vide
                            [filepas c]=size(imgbru);
                            % Les index des lignes trouvees dans le BRU sont incrementes du talon filea
                            imgbru=imgbru+filea-1;
                            imgbrusurf=[];                      % Matrice VIDE des surfaces (pixels) de cette image
                            
                            % ----- On deduit cette image du Nb d'images comptées pour l'echantillon (calcul du volume)
                            nbimgech=nbimgech-1;
                            filea=max(imgbru(end)-1,1);
                            % Cumul du nombr d'images traitees
                            nbimgprocessed = nbimgprocessed + nbimgech;
                        end
                    end
                    
                    % L'intervalle de recherche suivant aura une taille de pasrech x l'intervalle actuel et au moins de 1000 particules
                    filemax=max(pasrech*filepas,1000);
                    campx=[campx;imgbrusurf];                               % Ajout de la matrice des surfaces en pixels
                end
                
                % ---------- Volume de l'échantillon pour calcul des concentrations
                vol=nbimgech*volume*uvp5_cor_mat;
                volred=nbimgech*volume;
                
                %   disp([num2str(nbimgech),'   ',num2str(imglistsize)]);
                
                % Calcul de l'immersion moyenne de l'histogramme
                zmean=mean(listecor(imgint+imglist(1)-1,2));           % Immersion moyenne des images sélectionnées
                camsm=2*((aa*(campx.^exp)./pi).^0.5);                       % ESD en mm
                cambv=(4*pi/3)*((camsm/2).^3);                              % Biovol en mm3
                
                % Histogramme en pixels (pour controle)
                histopx(lignehis,5:5+floor((classepxb-classepxa)/pasclassepx))  =   hist(campx,classepx);
                histopx(lignehis,2)=zmean;
                histopx(lignehis,4)=nbimgech;
                
                % Histogramme detaille
                [nb,nbvol]=nbclassevol(cambv,classe0);                      % le tri se fait sur le BIOVOLUME.... (Lionel Guidi 2004)
                
                histonb(lignehis,2:end)=[zmean nbimgech nb./vol];
                histobv(lignehis,2:end)=[zmean nbimgech nbvol./vol];
                
                % Histogramme reduit
                [nbred,nbvolred]=nbclassevol(cambv,classe0red);                      % le tri se fait sur le BIOVOLUME.... (Lionel Guidi 2004)
                histonbred(lignehis,2:end)=[zmean nbimgech nbred/volred];
                histobvred(lignehis,2:end)=[zmean nbimgech nbvolred/volred];
                % ------------- MISE en BASE ----------------------------------------
                base(fichier).hisnb = histonb;
                base(fichier).hisnbred = histonbred;
                base(fichier).hisbv = histobv;
                base(fichier).hisbvred = histobvred;
                if strcmp(recpx,'y')
                    base(fichier).histopx = histopx;
                end
                
                
            end
            % Fin de lintervalle de profondeur, affichage de la ligne pour info
            %pause
            if groupe>=1
                listea=listea+listepas-1;                   % Intervalle de recherche suivant
            else
                histonb(lignehis,1:8)
                listea=listea+listepas-1;                   % Intervalle de recherche suivant
            end
            
        end
        if strcmp(save_histo,'y')
            % Enregistrement des matrices brutes detaillees
            [results_dir, char(base(fichier).profilename) '_datfile.txt'];
            toto=['save ',results_dir,char(base(fichier).profilename),'_hismoynb.txt histonb -ascii -tabs'];
            eval(toto);
            toto=['save ',results_dir,char(base(fichier).profilename),'_hismoybv.txt histobv -ascii -tabs'];
            eval(toto);
            
            % Enregistrement des matrices brutes reduites
            toto=['save ',results_dir,char(base(fichier).profilename),'_hismoynbred.txt histonbred -ascii -tabs'];
            eval(toto);
            toto=['save ',results_dir,char(base(fichier).profilename),'_hismoybvred.txt histobvred -ascii -tabs'];
            eval(toto);
        end
        
        %         if strcmp(recpx,'y')
        %             % Enregistrement des matrices brutes detaillees en PIXELS
        %             toto=['save ',results_dir,char(base(fichier).profilename),'_hismoynb_px.txt histopx -ascii -tabs'];
        %             eval(toto);
        %         end
        
        % Suppression des lignes de pour lesquelles aucune image n'a ete traitee (lignes ne contenant que des 0)
        selecpx=find(histopx(:,2)>0);
        histopx=histopx(selecpx,:);
        histonb=histonb(selecpx,:);
        histobv=histobv(selecpx,:);
        histonbred=histonbred(selecpx,:);
        histobvred=histobvred(selecpx,:);
        
        % Calcul de la fonction cumulative des nombres classes en PIXELS (utilise pour le graphe)
        matricepx=histopx(:,5:end);
        [ll cc]=size(matricepx);
        ccpx=cc;
        histocumpx=[];
        for i=1:ll                                  % De la première à la dernière ligne
            summ=sum(matricepx(i,:));                 % Somme de la ligne
            histocipx=matricepx(i,:)/summ;              % Valeur relative des cellules
            histocumpx(i,1)=histocipx(1);
            for j=2:cc
                histocumpx(i,j)=histocumpx(i,j-1)+histocipx(j);
            end
        end
        
        % Calcul de la fonction cumulative des nombres classes detaillees en biovol (utilise pour le graphe)
        matrice=histonb(:,4:end);
        [ll cc]=size(matrice);
        ccbv=cc;
        histocum=[];
        for i=1:ll                                  % De la première à la dernière ligne
            summ=sum(matrice(i,:));                 % Somme de la ligne
            histoci=matrice(i,:)/summ;              % Valeur relative des cellules
            histocum(i,1)=histoci(1);               % Première valeur
            for j=2:cc
                histocum(i,j)=histocum(i,j-1)+histoci(j);
            end
        end
        
        % Calcul de la fonction cumulative des nombres classes reduites en biovol (utilise pour le graphe)
        matricered=histonbred(:,4:end);
        [ll cc]=size(matricered);
        ccbvred=cc;
        histocumred=[];
        for i=1:ll                                  % De la première à la dernière ligne
            summ=sum(matricered(i,:));                 % Somme de la ligne
            histocired=matricered(i,:)/summ;              % Valeur relative des cellules
            histocumred(i,1)=histocired(1);               % Première valeur
            for j=2:cc
                histocumred(i,j)=histocumred(i,j-1)+histocired(j);
            end
        end
        %         if horizontal == 0
        %-----------------------------------------------------------------------------------------------------------------------------
        %% Affichage de la figure, tracé à partir des immersions moyennes réelles des blocs
        scrsz = get(0,'ScreenSize');
        fig = figure('numbertitle','off','name',strcat('UVP5 ',char(base(fichier).histfile)),'Position',[10 50 scrsz(3)/2.2 scrsz(4)-150]);
        couleur=['bk'];
        yaxemax=0;
        yaxemin=0;
        titre=(['RAW file : ',char(base(fichier).histfile),'   CAST : ',char(base(fichier).profilename)]);
        
        gg = find(titre == '_');
        titre(gg) = ' ';
        yaxemaxvit=max(yaxemax,max(listecor(:,2)));
        yaxemax=yaxemaxvit;
        profmin=-100*ceil(yaxemax/100);
        
        % Trace du profil de descente
        subplot (2,3,1)
        sampleratio=[];
        hh=plot(liste(:,1),-liste(:,2),'b');
        hold on
        hh=plot(listecor(:,1),-listecor(:,2),'r');
        xlabel(['Image nb'],'fontsize',8);
        ylabel(['Depth (m)'],'fontsize',8);
        xmax=1000*ceil(max(liste(:,1))/1000);
        axis([0 xmax profmin 0]);
        set(gca,'xlim',[0 xmax],'fontsize',8);
        text(0,-.1*profmin,titre,'color',couleur(1),'fontsize',15);
        
        % Trace du vol / bloc
        somme = sum(histonb(:,3))*volume/1000;
        subplot (2,3,2)
        sampleratio=[];
        hh=plot(volume*histonb(:,3)/pasvert,-histonb(:,2),'k');
        xlabel(['Vol ech / m (L)'],'fontsize',8);
        xmax=10*ceil(max(volume*histonb(:,3)/pasvert)/10);
        axis([0 xmax profmin 0]);
        text(0.3*xmax,0.5*profmin,['S= ',num2str(somme) ' m3'],'color','r','fontsize',8);
        set(gca,'xlim',[0 xmax],'fontsize',8);
        
        maxpx=max(find(median(histopx(:,5:end)',2)==max(median(histopx(:,5:25)',2))));
        
        % Trace des spectres bruts detailles (classes par classes de biovol)
        subplot (2,3,3)
        semilogy(histonb(:,4:end)','b')
        % Plot du spectre median
        hold on
        plot(median(histonb(:,4:end)',2),'m','linewidth',2)
        axis([0 ccbv .0001 1000]);
        set(gca,'fontsize',8);
        if strcmp(calibration,'y');
            xlabel(['Spectra (#/Classe) (calib)'],'fontsize',8);
        else
            xlabel(['Spectra (#/Classe)'],'fontsize',8);
        end
        ylabel(['Particules (#/BvClass)'],'fontsize',8);
        
        % Tracé des profils verticaux detailles des nombres/L
        
        x3 = nansum(base(fichier).hisnb(:,4:13),2);
        x4 = nansum(base(fichier).hisnb(:,14:16),2);
        x5 = nansum(base(fichier).hisnb(:,17:20),2);
        z_hist = -1 * base(fichier).hisnb(:,2);
        
        subplot (2,3,4)
        hh=plot(x3,z_hist,'b');
        xlabel(['Particules 0.06-0.53 mm esd (#/L)'],'fontsize',8);
        ylabel(['Depth (m)'],'fontsize',8);
        xmax = 500 * ceil(max(x3)/500);
        axis([0 xmax profmin 0]);
        set(gca,'fontsize',8);
        % Ecriture du nom de fichier source
        texte7=[' Data file : ' char(base(fichier).histfile) '.bru'];
        text(0.01,profmin*1.15,texte7 ,'color',couleur(1),'fontsize',12)
        
        subplot (2,3,5)
        hh=plot(x4,z_hist,'b');
        xlabel(['Particules 0.53-1.06 mm esd (#/L)'],'fontsize',8);
        ylabel(['Depth (m)'],'fontsize',8);
        if ~isnan(x4)
            %                 xmax = min([ceil(max(x4)), 1000]);
            xmax = 500 * ceil(max(x4)/500);
            xmax = max([xmax, 1]);
            axis([0 xmax profmin 0]);
        end
        set(gca,'fontsize',8);
        
        subplot (2,3,6)
        hh=plot(x5,z_hist,'b');
        xlabel(['Particules 1.06-2.66 mm esd (#/L)'],'fontsize',8);
        ylabel(['Depth (m)'],'fontsize',8);
        if ~isnan(x5)
            xmax = min([0.1 * ceil(max(x5)/0.1), 1000]);
            axis([0 1 profmin 0]);
        end
        set(gca,'fontsize',8);
        
        % ----------------- Sauvegarde IMAGE --------------------------------
        orient tall
        saveas(fig,[results_dir,'cast_',char(base(fichier).profilename),'.png']);
        close(fig);
        % Sauvegarde du diametre equivalent pour laquelle il y a le plus de particules
        maxsm=2*((aa*(maxpx.^exp)./pi).^0.5);                       % ESD
        maxsm=.001*ceil(maxsm*1000);                                % Arrondi
        % Ajout des informations sur les classes
        base(fichier).minor =                     minor;
        base(fichier).maxor =                     maxor;
        base(fichier).step =                      step;
        base(fichier).minorred =                  minorred;
        base(fichier).maxorred =                  maxorred;
        base(fichier).stepred =                   stepred;
        base(fichier).maxesd0 =                   maxsm;
        base(fichier).zimgprem0 =                 zimgprem;
        base(fichier).nbimgok0 =                  nbimgprocessed;
        base(fichier).minpixelsurf0 =             minpixelarea;
        %         end
    else
        disp(['File ',char(base(fichier).profilename),' (bru or _datfile) does not exist in ',char(results_dir)]);
    end                                                 % Fin du test sur l'existence du fichier BRU et LISTE
end
