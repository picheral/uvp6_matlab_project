%% Lecture des metadata et HDR
% Picheral, 2014/08


function [base compteur ligne] = uvp5_main_process_2014_metadata(base_source,raw_dir,meta_dir,meta_file,create_base,results_dir)


disp([meta_dir,meta_file]);


if exist([meta_dir,meta_file])==2;
    fid=fopen([meta_dir,meta_file]);
    basepvm5 = [];
    compteur = 0;
    disp('-------------------------- METADATA ----------------------------------');
    %  Open one file
    while 1                     % loop on the number of lines of the file
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        % Suppression ligne d'entete
        if compteur > 0;
            disp(tline);
            dotcom=findstr(tline,';');  % find the dotcoma index
            basepvm5(compteur).cruise = tline(1:dotcom(1)-1);
            basepvm5(compteur).ship = tline(dotcom(1)+1:dotcom(2)-1);
            basepvm5(compteur).filename = tline(dotcom(2)+1:dotcom(3)-1);
            basepvm5(compteur).profilename = tline(dotcom(3)+1:dotcom(4)-1);
            basepvm5(compteur).bottomdepth = tline(dotcom(4)+1:dotcom(5)-1);
            basepvm5(compteur).ctdrosettefilename = tline(dotcom(5)+1:dotcom(6)-1);
            basepvm5(compteur).latitude = tline(dotcom(6)+1:dotcom(7)-1);
            basepvm5(compteur).longitude = tline(dotcom(7)+1:dotcom(8)-1);
            basepvm5(compteur).firstimage = tline(dotcom(8)+1:dotcom(9)-1);
            basepvm5(compteur).volimage = tline(dotcom(9)+1:dotcom(10)-1);
            basepvm5(compteur).aa = tline(dotcom(10)+1:dotcom(11)-1);
            basepvm5(compteur).exp = tline(dotcom(11)+1:dotcom(12)-1);
            basepvm5(compteur).dn = tline(dotcom(12)+1:dotcom(13)-1);
            basepvm5(compteur).winddir = tline(dotcom(13)+1:dotcom(14)-1);
            basepvm5(compteur).windspeed = tline(dotcom(14)+1:dotcom(15)-1);
            basepvm5(compteur).seastate = tline(dotcom(15)+1:dotcom(16)-1);
            basepvm5(compteur).nebuloussness = tline(dotcom(16)+1:dotcom(17)-1);
            if numel(dotcom) > 17;
                basepvm5(compteur).comment = tline(dotcom(17)+1:dotcom(18)-1);
                basepvm5(compteur).lastimage = tline(dotcom(18)+1:dotcom(19)-1);
                basepvm5(compteur).yoyo = tline(dotcom(19)+1:dotcom(20)-1);
                
                
                % --------- Retrait ';' ajoutés par erreur ----------
                stationname = char(tline(dotcom(20)+1:end));
                oo = find(stationname == ';');
                if ~isempty(oo)
                    basepvm5(compteur).stationname = stationname(1:oo(1)-1);
                else
                    basepvm5(compteur).stationname = stationname;
                end
                
                 
            else
                basepvm5(compteur).comment = tline(dotcom(17)+1:end);
                basepvm5(compteur).lastimage = '999999999999999';
                basepvm5(compteur).yoyo = [];
                basepvm5(compteur).stationname = basepvm5(compteur).profilename;
            end
        end
        compteur  = compteur+1;
    end
    fclose(fid);
    % Boucle sur les profils dans le fichier entetepvm5
    [a ligne] =size(basepvm5);
    for i = 1:ligne;
        % ---------- Récupération des anciennes données ---------------
        if ~isempty(base_source) && i <= size(base_source,2);
            base(i) = base_source(i);
        end
        % ---------- Ajout des metadata "nouvelles" -------------------
        base(i).histfile =              {basepvm5(i).filename};
        base(i).cruise =                {basepvm5(i).cruise};
        base(i).profile =               i;
        
        % --------------- Detection du type d'UVP5 ----------------
        if strncmp(base(i).cruise,'sn',2) && isempty(findstr(char(base(i).cruise),'_')) == 0;
            aa = char(base(i).cruise);
            bb = findstr(char(base(i).cruise),'_');
            base(i).pvmtype =               {['uvp5_',aa(1:bb(1)-1)]};
        else
            base(i).pvmtype =               {'uvp5'};
        end
        base(i).soft =                  {'uvp5'};
        base(i).profilename =           {basepvm5(i).profilename};
        base(i).stationname =           {basepvm5(i).stationname};
        base(i).depth =                 str2num(basepvm5(i).bottomdepth);
        base(i).ctdrosette =            {basepvm5(i).ctdrosettefilename};
        base(i).a0 =                    str2num(basepvm5(i).aa);
        base(i).exp0 =                  str2num(basepvm5(i).exp);
        base(i).volimg0 =               str2num(basepvm5(i).volimage);
        base(i).bru0 =                      {basepvm5(i).filename};
        base(i).quality =                   1;
        base(i).groupe =                    i;
        latitude  = str2num(basepvm5(i).latitude);
        ent = fix(latitude);
        latitude = ent+ (latitude-ent)/0.6;
        longitude  = str2num(basepvm5(i).longitude);
        ent = fix(longitude);
        longitude = ent+ (longitude-ent)/0.6;
        base(i).latitude =          latitude;
        base(i).longitude =         longitude;
        base(i).date =              str2num(basepvm5(i).filename(1:8));
        base(i).time =              str2num(basepvm5(i).filename(9:end));

        date = str2num(basepvm5(i).filename(1:8));
        time = str2num(basepvm5(i).filename(9:end));
        an=floor(date/10000);
        mois=floor((floor(date)-10000*floor(date/10000))/100);
        jour=floor(date)-an*10000-mois*100;
        heure=floor(time/10000);
        minute=floor((floor(time)-10000*floor(time/10000))/100);
        seconde=floor(time)-heure*10000-minute*100;
        datechiffre=datenum(an,mois,jour,heure,minute,seconde);
        
        base(i).datem=              datechiffre;
        base(i).ship = 		basepvm5(i).ship;
        base(i).firstimage =    round(str2num(basepvm5(i).firstimage));
        base(i).dn =    basepvm5(i).dn;
        base(i).winddir =   str2num(basepvm5(i).winddir);
        base(i).windspeed = str2num(basepvm5(i).windspeed);
        base(i).seastate =  str2num(basepvm5(i).seastate);
        base(i).nebuloussness =     str2num(basepvm5(i).nebuloussness);
        base(i).comment =   basepvm5(i).comment;
        base(i).lastimage = str2num(basepvm5(i).lastimage);
        base(i).yoyo = {basepvm5(i).yoyo};
        if strcmp(create_base,'c')
            % --------- Creation donc champs vides ----------
            base(i).hdr = [];
            base(i).minor = [];
            base(i).maxor = [];
            base(i).step = [];
            base(i).minorred = [];
            base(i).maxorred = [];
            base(i). stepred = [];
            base(i).maxesd0 = [];
            base(i).zimgprem0 = [];
            base(i).nbimgok0 = [];
            base(i).minpixelsurf0 = [];
            base(i).theo_depth = [];
            base(i).ctdrosettedata = [];
            %             base(i).datfile = [];
            base(i).calibration = [];
            %             base(i).zoopuvp5 = [];
            base(i).ctdrosettedata_normalized =[];
        end
    end
    
    %------- Chargement HDR --------------------
    for i = 1:ligne;
        tta=[raw_dir, 'HDR', char(base(i).histfile),'\HDR',char(base(i).histfile), '.hdr'];
        esta=exist(tta);
        process_dat1 = 0;
        if esta ~=2;
            tta=[results_dir,'HDR',char(base(i).histfile), '.hdr'];
            if exist(tta) == 2;
                disp(['Loading HDR',char(base(i).histfile), '.hdr'])
                process_dat1 = 1;
            end
        elseif esta == 2;
            process_dat1 = 1;
        end
        if process_dat1 == 1;
            fid=fopen(tta);
            basehdr = [];
            compteur = 0;
            %  Open one file
            while 1                     % loop on the number of lines of the file
                tline = fgetl(fid);
                if ~ischar(tline), break, end
                % Suppression ligne d'entete
                if strncmp(tline,'TaskType',8);                     TaskType = tline;                   end
                if strncmp(tline,'DiskType',8)                      DiskType= tline;                    end
                if strncmp(tline,'Filesavetype',9)                  Filesavetype= tline;                end
                if strncmp(tline,'ShutterSpeed=',9)                 ShutterSpeed= tline;                end
                if strncmp(tline,'ShutterMode',9)                   ShutterMode= tline;                 end
                if strncmp(tline,'ShutterPolarity',9)               ShutterPolarity= tline;             end
                if strncmp(tline,'Gain',4)                          Gain= tline;                        end
                if strncmp(tline,'Gamma',5)                         Gamma= tline;                       end
                if strncmp(tline,'Threshold',9)                     Threshold= tline;                   end
                if strncmp(tline,'TriggerMode=',9)                  TriggerMode= tline;                 end
                if strncmp(tline,'Thresh=',7)                       Thresh= tline;                      end
                if strncmp(tline,'SMbase',6)                        SMbase = tline;                     end
                if strncmp(tline,'SMzoo',5)                         SMzoo= tline;                       end
                if strncmp(tline,'TimeOut',7)                       TimeOut= tline;                     end
                if strncmp(tline,'BRUoption',9)                     BRUoption = tline;                  end
                if strncmp(tline,'Choice',6)                        Choice= tline;                      end
                if strncmp(tline,'Ratio',5)                         Ratio = tline;                      end
                if strncmp(tline,'N',1)                             n= tline;                           end
                if strncmp(tline,'DataMoy',7)                       DataMoy= tline;                     end
                if strncmp(tline,'FontPath',8)                      FontPath = tline;                   end
                if strncmp(tline,'FontSubstract',12)                FontSubstract= tline;               end
                if strncmp(tline,'SaveAfterSub',10)                 SaveAfterSub= tline;                end
            end
            fclose(fid);
        else
            disp(['HDR',char(base(i).histfile), '.hdr  NOT found !'])
            base(i).hdr = [];
        end
        
    end
else
    disp('NO METADATA file or name incorrect.');
end
