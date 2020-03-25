%% Chargement des données Zooplankton dans base UVP5
% Picheral, 2014/09


function base = uvp5_main_process_2014_load_zoopk(base,fichier,zooerase,zoopuvp5,validated_dir,results_dir,depth_offset,load_more_recent,pixel_size)


%% ----------------- Effacement -----------------------------
if strcmp(zooerase,'y');base(fichier).zoopuvp5 = [];end
% ------------------ Chargement DAT1.TXT du PVM5 -------------------------------------------------------
if strcmp( zoopuvp5,'y');
    dat1fileshort = char(base(fichier).profilename);
    if strcmp(base(fichier).cruise,'sn000_operex2008');
        dat1fileshort = str2num(dat1fileshort);
        dat1fileshort = num2str(dat1fileshort);
        dat1fileshort = char(dat1fileshort);
    end
    dat1file=[validated_dir,dat1fileshort, '_dat1.txt'];
    test=exist(dat1file);
    %   disp(dat1file);
    %   isempty(base(i).zoopuvp5);
    process_dat1txt = 0;
    if test == 2;
        % Le fichier existe, on teste le reste
        e = dir(dat1file);
        if ~isfield(base(fichier),'zoopuvp5')
            base(fichier).zoopuvp5 = [];
        end
        if isempty(base(fichier).zoopuvp5)
            % Si le champ existe mais vide, on charge les données
            process_dat1txt = 1;
        else
            % Si le champ existe et contient des données, on charge si plus récent
            if strcmp(load_more_recent,'y') == 1;
                if isfield(base(fichier).zoopuvp5,'filedate');
                    % Si information existe ET plus récent de 1h30, on charge
                    disp([datestr(base(fichier).zoopuvp5.filedate),'     ',datestr(e.datenum)]);
                    if base(fichier).zoopuvp5.filedate < e.datenum - 0.0625;
                        
                        process_dat1txt = 1;
                    end
                else
                    % On charge si la date du précédent chargement n'es pas enregistrée
                    %                         disp('No date');
                    process_dat1txt = 1;
                end
            else
                process_dat1txt = 1;
            end
        end
    end
    
    if process_dat1txt == 0;
        disp([dat1fileshort, '_dat1.txt NOT LOADED '])
        if isfield(base(fichier),'zoopuvp5')== 0;
            base(fichier).zoopuvp5 = [];
        end
    else
        disp(['Loading   ', dat1fileshort, '_dat1.txt'])
        % ------------ Chargement des fichiers dat1.txt -------------
        DATA = [];
        ident = [];
        DATA = Chargement_uvp5_dat1txt(dat1file,pixel_size,base(fichier).a0,base(fichier).exp0);
        % ----------------- Correction hauteur UVP5 -----------------
        DATA.Depth = DATA.Depth + depth_offset;
        base(fichier).zoopuvp5 = DATA;
        base(fichier).zoopuvp5.datfile = {[char(base(fichier).profilename), '_dat1.txt']};
        base(fichier).zoopuvp5.dateload = datenum(now);
        disp(['loaded file date : ', datestr(base(fichier).zoopuvp5.filedate)]);
%         % ---------- Chargement _datfile.txt -------------
%         datfile=[results_dir,char(base(fichier).profilename), '_datfile.txt'];
%         test=exist(datfile);
%         if test < 2;
%             disp([char(base(fichier).profilename), '_datfile.txt NOT FOUND '])
%         else
%             disp(['Loading   ', char(base(fichier).profilename), '_datfile.txt'])
%             fid=fopen(datfile);
%             compteur = 1;
%             Pressure = [];
%             Image = [];
%             Flag = [];
%             pressure_prev = 0;
%             while 1                     % loop on the number of lines of the file
%                 tline = fgetl(fid);
%                 if ~ischar(tline), break, end
%                 dotcom=findstr(tline,';');  % find the end of petit gros column
%                 image = str2num(tline(1:dotcom(1)-1));
%                 pressure = tline(dotcom(2)+1:dotcom(3)-1);
%                 % -------- Correction hauteur UVP5 --------------------
%                 pressure = str2num(pressure) + depth_offset * 10;
%                 % ----------------- Codage descente --------------------
%                 if pressure_prev > pressure;
%                     flag = 0;
%                 else
%                     flag = 1;
%                 end
%                 Pressure = [Pressure;pressure];
%                 Image = [Image;image];
%                 Flag = [Flag;flag];
%                 compteur=compteur+1;
%                 pressure_prev = pressure;
%             end             % end of loop to open one file
%             fclose(fid);
%             liste = [Image Pressure/10 Flag];
%             base(fichier).datfile.image = Image;
%             base(fichier).datfile.pressure = Pressure/10;
%         end
    end
else
    disp([char(base(fichier).profilename),'_dat1.txt file not loaded.']);
end