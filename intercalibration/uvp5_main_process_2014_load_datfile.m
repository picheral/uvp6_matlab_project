%% Chargement des données DATFILE dans base UVP5
% Picheral, 2017/03


function base = uvp5_main_process_2014_load_datfile(base,fichier,results_dir,depth_offset)

% ---------- Chargement _datfile.txt -------------
datfile=[results_dir,char(base(fichier).profilename), '_datfile.txt'];
test=exist(datfile);
chargement = 0;
if test < 2
    disp([char(base(fichier).profilename), '_datfile.txt NOT FOUND '])
else
    % ------------- Chargement si pas déjà dans la base -----------
    if isfield(base(fichier),'datfile')
        if ~isfield(base(fichier).datfile,'temp_interne')
            chargement = 1;
        end
    else
        chargement = 1;
    end
end
    
%% ------------- Chargement du fichier --------------------------------    

if chargement == 1
    disp(['Loading   ', char(base(fichier).profilename), '_datfile.txt'])
    fid=fopen(datfile);
    compteur = 1;
    Pressure = [];
    Image = [];
    Flag = [];
    Temp_interne = [];
    Peltier = [];
    Temp_cam = [];
    pressure_prev = 0;
    while 1                     % loop on the number of lines of the file
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        dotcom=findstr(tline,';');  % find the end of petit gros column
        image = str2num(tline(1:dotcom(1)-1));
        pressure = tline(dotcom(2)+1:dotcom(3)-1);
        temp_interne = str2num(tline(dotcom(5)+1:dotcom(6)-1));
        
        peltier = str2num(tline(dotcom(11)+1:dotcom(12)-1));
        temp_cam = str2num(tline(dotcom(12)+1:dotcom(13)-1));
        % -------- Correction hauteur UVP5 --------------------
        pressure = str2num(pressure) + depth_offset * 10;
        % ----------------- Codage descente --------------------
        if pressure_prev >= pressure
            flag = 0;
        else
            flag = 1;
        end
        Pressure = [Pressure;pressure];
        Image = [Image;image];
        Flag = [Flag;flag];
        Temp_interne = [Temp_interne temp_interne];
        Peltier = [Peltier;peltier/1000];
        Temp_cam = [Temp_cam;temp_cam/1000];     
        
        compteur=compteur+1;
        pressure_prev = pressure;
    end             % end of loop to open one file
    fclose(fid);
    liste = [Image Pressure/10 Flag];
    base(fichier).datfile.image = Image;
    base(fichier).datfile.pressure = Pressure/10;
    base(fichier).datfile.temp_interne = Temp_interne';
    base(fichier).datfile.peltier = Peltier;
    base(fichier).datfile.temp_cam = Temp_cam;
end

