%% Chargement des données DATFILE dans base UVP5
% Picheral, 2017/03, 2020/03/25


function [Imagelist Pressure Temp_interne Peltier Temp_cam Flag Part listecor liste] = uvp5_main_process_2014_load_datfile(base,fichier,results_dir,depth_offset,process_calib)

% ---------- Chargement _datfile.txt -------------
datfile=[results_dir,char(base(fichier).profilename), '_datfile.txt'];
test=exist(datfile);
chargement = 0;
if test < 2
    disp([char(base(fichier).profilename), '_datfile.txt NOT FOUND '])
else
    % ------------- Chargement si pas déjà dans la base -----------
    if isfield(base(fichier),'datfile')
        %         if ~isfield(base(fichier).datfile,'temp_interne')
                    chargement = 1;
        %         end
    else
        % ---------- On force le chargement ---------- (2020/03/25)
        chargement = 1;
    end
end

%% ------------- Chargement du fichier --------------------------------

if chargement == 1
%     disp(['Loading   ', char(base(fichier).profilename), '_datfile.txt'])
    fid=fopen(datfile);
    compteur = 1;
    Pressure = [];
    Imagelist = [];
    Flag = [];
    Temp_interne = [];
    Peltier = [];
    Temp_cam = [];
    Part = [];
    pressure_prev = 0;
    while 1                     % loop on the number of lines of the file
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        dotcom=findstr(tline,';');  % find the end of petit gros column
        image = str2num(tline(1:dotcom(1)-1));
        pressure = tline(dotcom(2)+1:dotcom(3)-1);
        part = tline(dotcom(14)+1:dotcom(15)-1);
        temp_interne = str2num(tline(dotcom(5)+1:dotcom(6)-1));
        peltier = str2num(tline(dotcom(11)+1:dotcom(12)-1));
        temp_cam = str2num(tline(dotcom(12)+1:dotcom(13)-1));
        % -------- Correction hauteur UVP5 --------------------
        pressure = str2num(pressure) + depth_offset * 10;
        % ----------------- Codage descente --------------------
        if pressure_prev > pressure
            flag = 0;
        else
            flag = 1;
        end
        Pressure = [Pressure;pressure];
        Imagelist = [Imagelist;image];
        Flag = [Flag;flag];
        Part = [Part;str2double(part)];
        Temp_interne = [Temp_interne temp_interne];
        Peltier = [Peltier;peltier/1000];
        Temp_cam = [Temp_cam;temp_cam/1000];
        
        compteur=compteur+1;
        pressure_prev = pressure;
    end             % end of loop to open one file
    fclose(fid);
    Temp_interne = Temp_interne';
    %     liste = [Imagelist Pressure/10 Flag];
    %     base(fichier).datfile.image = Imagelist;
    %     base(fichier).datfile.pressure = Pressure/10;
    %     base(fichier).datfile.temp_interne = Temp_interne;
    %     base(fichier).datfile.peltier = Peltier;
    %     base(fichier).datfile.temp_cam = Temp_cam;
    
    imgprem = (base(fichier).firstimage);
    imglast = (base(fichier).lastimage);
    
    % ------------- Profils pseudo horizontaux pour calibrage --------
    if strcmp(process_calib,'y')
        Pressure = [1:numel(Pressure)]';
        Flag = ones(numel(Pressure),1);
    end
    
    % ------------- DERNIERE image ----------------------------
    if strcmp(base(fichier).profilename,'tara_123_00_a'); imglast = 4620;end
    gg = find(Imagelist == imglast);
    if isempty(gg);               gg = numel(Imagelist);    end
    
    % Profondeur premiere image OK
    % ----------- Corriger pour le N° d'image OK ! -------------------
    kk = find(Imagelist >= imgprem);
    
    % ---------- Création de liste qui contient tout ce qui est utile -
    liste = [ Imagelist(kk(1):gg(end)) Pressure(kk(1):gg(end))/10 Flag(kk(1):gg(end)) Part(kk(1):gg(end)) ];
    
    %         zimgprem = liste(1,2);
    %         disp(['Profondeur DEB = ',num2str(zimgprem),'   First Img = ',num2str(imgprem),'   Last Img = ',num2str(imglast)]);
    %              imgprem = 1;
    
    % ----------- Corriger pour Zmax ---------------------------------
    zmax = max(liste(:,2));
    gg = find(liste(:,2) == zmax);
    
    %% ----------- On travaille maintenant avec listcor -----------------------
    listecor = liste(1:gg(1),:);
    
    %         [listesize c]=size(listecor);
    %         disp(['Profondeur MAX = ',num2str(zmax)]);
end

