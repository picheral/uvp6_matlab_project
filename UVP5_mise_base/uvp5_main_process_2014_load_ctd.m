%% Chargement données CTD pour bases UVP5
% Picheral, 2015/11



function [base num_cce txt_cce] = uvp5_main_process_2014_load_ctd(base,fichier,ctdcnv_dir,num_cce, txt_cce,base_all)

% --------------- Cas gatekeeper2010 ---------------
if strcmp(base(fichier).cruise,'sn002zd_gatekeeper2010');
    % Fichier DATA
    cnv_file=char(base(fichier).ctdrosette);
    toto=[ctdcnv_dir,cnv_file,'asc.txt'];
    test=exist(toto);
    if test==2          % Le fichier existe et est charge
        disp(['Loading ',toto]);
        base(fichier).ctdrosettedata.data = textread(toto);
    else
        disp([toto,' not found !']);
    end
    % Fichier HDR
    cnv_file=char(base(fichier).ctdrosette);
    toto=[ctdcnv_dir,cnv_file,'hdr.txt'];
    test=exist(toto);
    if test==2          % Le fichier existe et est charge
        disp(['Loading ',toto]);
        fid=fopen(toto,'rt');
        str='*START*';
        while (~strncmp(str,'*END*',5));
            str=fgetl(fid);
            if (strncmp(str,'# name',6))
                var=sscanf(str(7:10),'%d',1);
                var=var+1;  % .CNV file counts from 0, Matlab counts from 1
                %      stuff variable names into cell array
                names{var}=str;
            end
        end
        fclose(fid);
        base(fichier).ctdrosettedata.names = cellstr(names);
        base(fichier).ctdrosettedata.sensors = cellstr(names);
    else
        disp([toto,' not found !']);
    end
elseif strcmp(base(fichier).cruise,'sn008_subice_2014')
    % ------------ SUBICE ----------------
    if ~isempty(txt_cce)
        names = txt_cce(1,8:33);
        % ----------- Boucle sur les profils -----------------
        %         for kk = 1:numel(cast_list);
        ctd_name = char(base(fichier).ctdrosette);
        ff = findstr(char(base(fichier).ctdrosette),'_');
        ctd_name = str2num(ctd_name(ff(end)+1:end));
        ee = find(num_cce(:,1) == ctd_name);
        if ~isempty(ee)
            base(fichier).ctdrosettedata.data = num_cce(ee,7:32);
            base(fichier).ctdrosettedata.names = names';
            base(fichier).ctdrosettedata.sensors = names';
            base(fichier).latitude =      num_cce(ee(1),5);
            base(fichier).longitude =     num_cce(ee(1),4);
            disp([num2str(fichier) ,'  ',char(base(fichier).ctdrosette),' CTD data LOADED & GPS position updated from NMEA']);
        end
    end
    
elseif strcmp(base(fichier).cruise,'sn003_ccelter_2014')...
        || strcmp(base(fichier).cruise,'sn000_lter2008')...
        || strcmp(base(fichier).cruise,'sn002zd_ccelter_2011')...
        || strcmp(base(fichier).cruise,'sn000_ccelter_2012')
    % ---------------- CAS CCELTER 2008 2011 2012 2014 ----------------------
    % On pourrait en plus ouvrir les CNV pour récupérer latitude et longitude GPS !!!!
    
    if isempty(txt_cce)
        toto = [ctdcnv_dir,'CTD_Downcast.xlsx'];
        if strcmp(base(fichier).cruise,'sn003_ccelter_2014');toto = [ctdcnv_dir,'CTD_Downcast_2014.xlsx'];end
        test=exist(toto);
        if test==2          % Le fichier existe et est charge
            disp(['Loading ',toto]);
            %   [data,names,sensors] = xls_cce_p1106([ctdcnv_dir,CTD_Downcast,'.xls'],str2num(cnv_file(end-1:end)));
            [num_cce, txt_cce]= xlsread(toto);
        else
            disp([ctdcnv_dir,toto,' does not exist !']);
        end
    end
    names = {'Pressure','Depth','TimeSec','T090C','T190C','Cond1','Cond2','OxymicroM','OxyPerSat','SurPAR','PAR','Cpar','Fluor','TransPer','FluorVolt','TransVolt','UVPVolt','ISUS_V1','ISUS_V2','ISUS_NO3','UVPNum','Sal00','Sal11','SecS-PriS','Sigma_00','Sigma_11','Potemp090C','Potemp190C','T2-T1_90C','C2-C1','Flag'};
    
    % ------------ Recherche des lignes de ce fichier -------
    cnv_file = {char(base(fichier).ctdrosette)};
    ee = find(strcmp(txt_cce(:,2),cnv_file)==1);
    if isempty(ee)
        ee = find(strcmp(txt_cce(:,2),[' ' char(cnv_file)])==1);
    end
    if ~isempty(ee)
        %                 ctddata = NaN * ones(numel(ee),size(num_cce,2)-4);
        if strcmp(base(fichier).cruise,'sn003_ccelter_2014');
            ctddata = num_cce(ee,2:end);
        else
            ctddata = num_cce(ee,4:end);
        end
        
        data=sortrows(ctddata,1);
        base(fichier).ctdrosettedata.data = ctddata;
        base(fichier).ctdrosettedata.names = names';
        base(fichier).ctdrosettedata.sensors = names';
        disp([num2str(fichier) ,'  ',char(base(fichier).ctdrosette),' data LOADED ']);
    else
        disp([num2str(fichier) ,'  ',char(base(fichier).ctdrosette),' data NOT FOUND in ','CTD_Downcast.xlsx']);
    end
elseif strcmp(base(fichier).cruise,'sn201_ccelter_2017')
    % ---------------- CAS CCELTER 2017 ----------------------
    % On pourrait en plus ouvrir les CNV pour récupérer latitude et longitude GPS !!!!
    
    if isempty(txt_cce)
        toto = [ctdcnv_dir,'DataZoo - P1706 CTD Downcast Data.xlsx'];
        test=exist(toto);
        if test==2          % Le fichier existe et est charge
            disp(['Loading ',toto]);
            %   [data,names,sensors] = xls_cce_p1106([ctdcnv_dir,CTD_Downcast,'.xls'],str2num(cnv_file(end-1:end)));
            [num_cce, txt_cce]= xlsread(toto);
        else
            disp([ctdcnv_dir,toto,' does not exist !']);
        end
    end
    names = {'Pressure','Depth','T090C','T190C','Cond1','Cond2','Sal00','Sal11','OxymicroM','OxyPerSat','SurPAR','PAR','Cpar','Cpar_Flag','Fluor','TransTra','TransAtt','ISUS_V1','ISUS_V2','Rinko_O2','Rinko_Temp','SecS-PriS','Sigma_00','Sigma_11','Potemp090C','Potemp190C','T2-T1_90C','C2-C1'};
    
    % ------------ Recherche des lignes de ce fichier -------
    cnv_file = char(base(fichier).ctdrosette);
    cnv_file = str2num(cnv_file(end-2:end));
    
    ee = find(num_cce(:,2) == cnv_file);
    
    if ~isempty(ee)
        
        ctddata = num_cce(ee,5:end);
        
        data=sortrows(ctddata,1);
        base(fichier).ctdrosettedata.data = ctddata;
        base(fichier).ctdrosettedata.names = names';
        base(fichier).ctdrosettedata.sensors = names';
        disp([num2str(fichier) ,'  ',char(base(fichier).ctdrosette),' data LOADED ']);
    else
        disp([num2str(fichier) ,'  ',char(base(fichier).ctdrosette),' data NOT FOUND in ','CTD_Downcast.xlsx']);
    end
elseif(strcmp(base(fichier).cruise,'sn000_tara2009'))||(strcmp(base(fichier).cruise,'sn000_tara2010'))||(strcmp(base(fichier).cruise,'sn000_tara2011'))||(strcmp(base(fichier).cruise,'sn003zp_tara2012'))||(strcmp(base(fichier).cruise,'sn000_tara2012') ||(strcmp(base(fichier).cruise,'sn003_tara2013')));
    % ---------------- CAS TARA base validée -------------------
    
    for g=1:size(base_all.base,2)
        toto = 0;
        if strcmpi(char(base(fichier).ctdrosette),char(base_all.base(g).cnv_file));
            if isfield(base_all.base(g).ctdrosettedata,'data_descente')
                if ~isempty(base_all.base(g).ctdrosettedata.data_descente)
                    base(fichier).ctdrosettedata.data = base_all.base(g).ctdrosettedata.data_descente;
                    toto = 1;
                end
            elseif isfield(base_all.base(g).ctdrosettedata,'data_upward')
                if ~isempty(base_all.base(g).ctdrosettedata.data_upward)
                    base(fichier).ctdrosettedata.data = base_all.base(g).ctdrosettedata.data_upward;
                    toto = 1;
                end
            end
            
            
            if toto == 1;
                base(fichier).ctdrosettedata.names = cellstr(base_all.base(g).ctdrosettedata.short_names);
                base(fichier).ctdrosettedata.sensors = cellstr(base_all.base(g).ctdrosettedata.short_names);
                base(fichier).latitude =      base_all.base(g).ctdrosettedata.latitude;
                base(fichier).longitude =     base_all.base(g).ctdrosettedata.longitude;
                disp(['UVP Position corrected using base_CTD_full.mat']);
            end
        end
    end
    
elseif(strcmp(base(fichier).cruise,'sn002zd_vlfr_20110504'))
    cnv_file=char(base(fichier).ctdrosette);
    toto=[ctdcnv_dir,cnv_file,'.cnv'];
    test=exist(toto);
    % Special TARA
    if (test==0 && isempty(strfind(cnv_file,'tara'))==0 && size(cnv_file,2)> 11)
        if strcmp(cnv_file(11),'c');        cnv_file(11) = 'C';
        elseif strcmp(cnv_file(11),'s');    cnv_file(11) = 'S';
            
        end
    end
    if test==2          % Le fichier existe et est charge
        disp(['Loading ',char(base(fichier).ctdrosette),'.cnv']);
        [data,names,sensors] = cnv2mat_tara([ctdcnv_dir,cnv_file,'.cnv']);
        base(fichier).ctdrosettedata.data = data;
        base(fichier).ctdrosettedata.names = cellstr(names);
        base(fichier).ctdrosettedata.sensors = sensors;
    end
elseif(strcmp(base(fichier).cruise,'sn002zh_tvarmine2012'))
    % --------- CAS Mesocosms Finland 2012 ------------------------
    int_file=char(base(fichier).ctdrosette);
    toto=[ctdcnv_dir,int_file,'.xls'];
    test=exist(toto);
    if test==2          % Le fichier existe et est charge
        disp(['Loading ',char(base(fichier).ctdrosette),'.xls']);
        filectd = [ctdcnv_dir,int_file,'.xls'];
        [NUMERIC,TXT,RAW]=xlsread(filectd);
        base(fichier).ctdrosettedata.names = char(TXT(31,5:19));
        base(fichier).ctdrosettedata.sensors = char(TXT(31,5:19));
        data = NUMERIC(34:end,5:19);
        ee = isnan(data(1:end,1));
        aa = find(ee == 1);
        %                 ff = find(data(:,1) > 0);
        data = data(aa(1)+1:aa(2)-1,:);
        base(fichier).ctdrosettedata.data = data;
    end
elseif strcmp(base(fichier).cruise,'sn000_malina2009')...
        || strcmp(base(fichier).cruise,'sn203_greenedge_2016')...
        || strcmp(base(fichier).cruise,'sn203_greenedge_2016_1b')...
        || strcmp(base(fichier).cruise,'sn203_demo_altidev_hd')...
        % --------- CAS MALINA 2009 ------------------------
    int_file=char(base(fichier).ctdrosette);
    if strcmp(base(fichier).cruise,'sn203_greenedge_2016') || strcmp(base(fichier).cruise,'sn203_greenedge_2016_1b') || strcmp(base(fichier).cruise,'sn203_demo_altidev_hd')
        int_file = [int_file(1:4) '_' int_file(5:end)];
    end
    toto=[ctdcnv_dir,int_file,'.int'];
    test=exist(toto);
    if test==2          % Le fichier existe et est charge
        disp(['Loading ',int_file,'.int']);
        filectd = [ctdcnv_dir,int_file,'.int'];
        % ----------- Detection nb de lignes entete --------------
        ff = importdata(filectd,' ',40);
        for k=1:50
            %             disp(ff.textdata(k));
            
            if strncmp(ff.textdata(k),'      Pres      Temp     ',25)...
                    || strncmp(ff.textdata(k),'    Pres   Temp    Trans ',25)...
                    nbff = k;
            end
        end
        %         ff = importdata(filectd,' ',nbff);
        aa = ff.textdata(nbff);
        
        [gg,aa] = strtok(aa,' ');
        names = char(gg);
        while ~isempty(aa) && ~strcmp(aa,'')
            [gg,aa] = strtok(aa,' ');
            names = [names  {char(gg)}];
        end
        
        %% Lecture data
        ff = importdata(filectd,' ',nbff+1);
        %% Lecture names
        %         ff = importdata(filectd,' ',nbff);
        %         names = char(ff(nbff,:)');
        base(fichier).ctdrosettedata.data = ff.data;
        base(fichier).ctdrosettedata.names = cellstr(names);
        base(fichier).ctdrosettedata.sensors = cellstr(names);
        %% LATITUDE LONGITUDE
        fid = fopen(filectd,'r');
        for i = 1:30
            tline = fgetl(fid);
            if strncmp(tline,'% Initial_Latitude [deg]: ',26);
                [bb aa] = strtok(char(tline),':');
                [bb aa] = strtok(aa,':');
                Latitude = str2num(bb);
            elseif strncmp(tline,'% Initial_Longitude [deg]: ',27);
                [bb aa] = strtok(char(tline),':');
                [bb aa] = strtok(aa,':');
                Longitude = str2num(bb);
                disp(['Position loaded from CTD file NMEA']);
                base(fichier).latitude =          Latitude;
                base(fichier).longitude =         Longitude;
            end
        end
        fclose(fid);
    end
elseif(strcmp(base(fichier).cruise,'sn008_an1406') || strcmp(base(fichier).cruise,'sn008_an1407'))
    % --------- CAS MALINA 2009 ------------------------
    int_file=char(base(fichier).ctdrosette);
    toto=[ctdcnv_dir,int_file,'.int'];
    test=exist(toto);
    if test==2          % Le fichier existe et est charge
        disp(['Loading ',char(base(fichier).ctdrosette),'.int']);
        filectd = [ctdcnv_dir,int_file,'.int'];
        %% Detection première ligne
        deb = 1;
        m = 30;
        while (deb ==  1);
            m = m + 1;
            ff = importdata(filectd,' ',m);
            %             disp([num2str(m),' ** ',char(ff(m,:)')]);
            ligne = char(ff(m,:)');
            if strcmp(ligne,'%')
                deb = 0;
            end
        end
        %% Lecture data
        ff = importdata(filectd,' ',m+2);
        data = ff.data;
        %% Lecture names
        ff = importdata(filectd,' ',m+1);
        
        
        aa = ff(m+1);     
        [gg,aa] = strtok(aa,' ');
        names = char(gg);
        while ~isempty(aa) && ~strcmp(aa,'')
            [gg,aa] = strtok(aa,' ');
            names = [names  {char(gg)}];
        end
        
        base(fichier).ctdrosettedata.data = data;
        base(fichier).ctdrosettedata.names = cellstr(names);
        base(fichier).ctdrosettedata.sensors = cellstr(names);
        
        %% LATITUDE LONGITUDE
        fid = fopen(filectd,'r');
        for i = 1:30
            tline = fgetl(fid);
            if strncmp(tline,'% Initial_Latitude [deg]: ',26);
                [bb aa] = strtok(char(tline),':');
                [bb aa] = strtok(aa,':');
                Latitude = str2num(bb);
            elseif strncmp(tline,'% Initial_Longitude [deg]: ',27);
                [bb aa] = strtok(char(tline),':');
                [bb aa] = strtok(aa,':');
                Longitude = str2num(bb);
                disp(['Position loaded from CTD file NMEA']);
                base(fichier).latitude =          Latitude;
                base(fichier).longitude =         Longitude;
            end
        end
        fclose(fid);
        
        
        %                             disp(['Position loaded from CTD file NMEA']);
        %                     base(fichier).latitude =          Latitude;
        %                     base(fichier).longitude =         Longitude;
        %
        
    end
elseif(strcmp(base(fichier).cruise,'sn009_2015_p16n'))
    % --------- P16N Andrew -------------------------
    %     int_file=char(base(fichier).ctdrosette);
    yyy = char(base(fichier).ctdrosette);
    if ~strcmp(yyy,'no')
        for nbr = 1 : 4
            %         int_file = ['33RO20150525_00',base(fichier).ctdrosette(end-2:end),'_0000',num2str(nbr),'_ct1'];
            
            
            if numel(yyy) == 3
                int_file = ['33RO20150410_00',yyy(1:3),'_0000',num2str(nbr),'_ct1'];
            else
                
                int_file = ['33RO20150525_00',yyy(1:3),'_0000',yyy(5),'_ct1'];
            end
            
            toto=[ctdcnv_dir,int_file,'.csv'];
            test=exist(toto);
            if (test==2 )         % Le fichier existe et est charge
                disp(['Loading ',int_file,'.csv']);
                filectd = [ctdcnv_dir,int_file,'.csv'];
                % Lecture LAT LONG
                fid = fopen(filectd,'r');
                if ~strcmp(yyy,'006')
                    for i = 1:30
                        tline = fgetl(fid);
                        if strncmp(tline,'LATITUDE =',10);
                            [bb aa] = strtok(char(tline),' ');
                            [bb aa] = strtok(aa,' ');
                            Latitude = str2num(aa) ;
                        elseif strncmp(tline,'LONGITUDE =',11);
                            [bb aa] = strtok(char(tline),' ');
                            [bb aa] = strtok(aa,' ');
                            Longitude = str2num(aa);
                            disp(['Position loaded from CTD file NMEA']);
                            base(fichier).latitude =          Latitude;
                            base(fichier).longitude =         Longitude;
                        end
                    end
                    
                    fclose(fid);end
                %% Lecture data
                %         nbff = 24;
                %         ff = importdata(filectd,',',nbff);
                % %         data = ff.data;
                %         %% Lecture names
                %         aa = char(ff.textdata(nbff));
                aa = 'CTDPRS,CTDPRS_FLAG_W,CTDTMP,CTDTMP_FLAG_W,CTDSAL,CTDSAL_FLAG_W,CTDOXY,CTDOXY_FLAG_W,XMISS,XMISS_FLAG_W,FLUOR,FLUOR_FLAG_W,CTDNOBS,CTDETIME';
                [gg,aa] = strtok(aa,',');
                names = char(gg);
                while ~isempty(aa);
                    [gg,aa] = strtok(aa,',');
                    names = [names  {gg}];
                end
                
                %         aa = char(ff.textdata(nbff+1));
                aa = 'DBAR,,ITS-90,,PSS-78,,UMOL/KG,,0-5VDC,,0-5VDC,,,SECONDS';
                [gg,aa] = strtok(aa,',');
                units = char(gg);
                while ~isempty(aa);
                    [gg,aa] = strtok(aa,',');
                    units = [units  {gg}];
                end
                % ---------- DATA -----------------
                ff = importdata(filectd,',',25);
                data = ff.data;
                base(fichier).ctdrosettedata.data = data(:,1:end);
                base(fichier).ctdrosettedata.names = names;
                base(fichier).ctdrosettedata.sensors = units;
            end
        end
    end
    
elseif(strncmp(base(fichier).cruise,'sn010_2014_m108',15)...
        || strncmp(base(fichier).cruise,'sn010_2016_m',12)...
        || strncmp(base(fichier).cruise,'sn010_2015_m',12)...
        || strcmp(base(fichier).cruise,'sn010_2014_ps88b')...
        || strncmp(base(fichier).cruise,'sn010_2014_m107',15)...
        || strncmp(base(fichier).cruise,'sn010_2014_m106',15)...
        || strncmp(base(fichier).cruise,'sn010_2014_m105',15)...
        || strcmp(base(fichier).cruise,'sn010_2015_m116')...
        || strncmp(base(fichier).cruise,'sn001_2012_msm',14)...
        || strncmp(base(fichier).cruise,'sn001_2013_m',12)...
        || strncmp(base(fichier).cruise,'sn001_2014_msm',14)...
        || strncmp(base(fichier).cruise,'sn001_2012_msm',14)...
        || strncmp(base(fichier).cruise,'sn001_2012_msm',14)...
        || strncmp(base(fichier).cruise,'sn010_2017_m',12)...
        || strncmp(base(fichier).cruise,'sn202_msm',9))
    % --------- MSM et M ------------------------
    int_file=char(base(fichier).ctdrosette);
    toto=[ctdcnv_dir,int_file,'.ctds'];
    test=exist(toto);
    if test==2          % Le fichier existe et est charge
        disp(['Loading ',char(base(fichier).ctdrosette),'.ctds']);
        filectd = [ctdcnv_dir,int_file,'.ctds'];
        % Lecture LAT LONG
        fid = fopen(filectd,'r');
        for i = 1:10
            tline = fgetl(fid);
            % Taille pixel des metadata du fichier
            if strncmp(tline,'Latitude',8);
                [bb aa] = strtok(char(tline),' ');
                [Latitude aa] = strtok(aa,' ');
                Latitude = str2num(aa) ;
            elseif strncmp(tline,'Longitude',9);
                [Longitude aa] = strtok(char(tline),' ');
                [Longitude aa] = strtok(aa,' ');
                Longitude = str2num(Longitude)  ;
                disp(['Position loaded from CTD file NMEA']);
                base(fichier).latitude =          Latitude;
                base(fichier).longitude =         Longitude;
            end
        end
        fclose(fid);
        
        %% Lecture data
        if strcmp(base(fichier).cruise,'sn001_2012_msm23')...
                ||strcmp(base(fichier).cruise,'sn001_2012_msm22')...
                || strncmp(base(fichier).cruise,'sn010_2014_m106',15)...
                || strncmp(base(fichier).cruise,'sn010_2014_m107',15)...
                || strncmp(base(fichier).cruise,'sn001_2013_m96',14)...
                || strncmp(base(fichier).cruise,'sn001_2013_m97',14)...
                || strncmp(base(fichier).cruise,'sn001_2013_m98',14)...
                || strncmp(base(fichier).cruise,'sn001_2014_msm40',16)
            nbff = 66;
            ff = importdata(filectd,' ',nbff);
        elseif strcmp(base(fichier).cruise,'sn010_2014_m108')
            nbff = 6;
            ff = importdata(filectd,'\t',nbff);
        elseif strcmp(base(fichier).cruise,'sn010_2016_m130')
            nbff = 69;
            ff = importdata(filectd,' ',nbff);
        elseif strcmp(base(fichier).cruise,'sn010_2014_m105')
            nbff = 65;
            ff = importdata(filectd,' ',nbff);
        elseif strcmp(base(fichier).cruise,'sn202_msm060') || strcmp(base(fichier).cruise,'sn010_2017_m135')
            nbff = 70;
            ff = importdata(filectd,' ',nbff);
        else
            nbff = 67;
            ff = importdata(filectd,' ',nbff);
        end
        
        data = ff.data;
        %% Lecture names
        aa = char(ff.textdata(nbff));
        
        if strcmp(base(fichier).cruise,'sn010_2014_m108')
            [gg,aa] = strtok(aa,' ');
            [gg,aa] = strtok(aa,' ');
            [gg,aa] = strtok(aa,':');
            names = char(gg(end));
            while ~isempty(aa);
                [gg,aa] = strtok(aa,':');
                names = [names  {gg}];
            end
            data = data(1:end,[1 2 4 5 6]);
            base(fichier).ctdrosettedata.data = data;
        else
            [gg,aa] = strtok(aa,' ');
            [gg,aa] = strtok(aa,' ');
            [gg,aa] = strtok(aa,':');
            [gg,aa] = strtok(aa,':');
            names = char(gg);
            while ~isempty(aa);
                [gg,aa] = strtok(aa,':');
                names = [names  {gg}];
            end
            base(fichier).ctdrosettedata.data = data(:,2:end);
        end
        base(fichier).ctdrosettedata.names = names;
        base(fichier).ctdrosettedata.sensors = names;
        disp('CTD data read !');
        
    end
else
    % ----------- AUTRES CAS ---------------------------------------------
    %     disp('AUTRES CAS');
    cnv_file=char(base(fichier).ctdrosette);
    cnv_file_ext = [ctdcnv_dir,cnv_file,'.cnv'];
    %     if strncmp(base(fichier).cruise,'sn203_greenedge_2016',18) || strncmp(base(fichier).cruise,'sn200_greenedge_2016',18);
    %         % ------------ Fichiers temporaires GREENEDGE ---------------
    %         cnv_file_ext = [ctdcnv_dir,cnv_file,'avg.cnv'];
    %     end
    test1 = exist(cnv_file_ext);
    if test1==2        % Le fichier existe et est charge
        disp(['Loading ',char(cnv_file),'.cnv']);
        if strcmp(base(fichier).cruise,'sn000_lohafex2009');
            [data,names,sensors] = cnv2mat_lohafex2009([ctdcnv_dir,cnv_file,'.cnv']);
        elseif strcmp(base(fichier).cruise,'sn002_iado_2014') ||...
                strcmp(base(fichier).cruise,'sn000_operex2008') ||...
                strcmp(base(fichier).cruise,'sn000_ccelter_2012') ;
            [data,names]=cnv2mat_xml([ctdcnv_dir,cnv_file,'.cnv']);
        else
            % -------- On considère comme 'normal" les fichiers XML AVEC NMEA ----------
            [lat,lon,gtime,data,names]=cnv2mat_w_xml(cnv_file_ext);
            % ----------- Récupération LAT et LONG NMEA ---------------
            if isnan(lat) == 0 && isnan(lon) == 0;
                base(fichier).latitude =          lat;
                base(fichier).longitude =         lon;
                disp(['Position loaded from CTD file NMEA']);
            end
            % -------- On positionne PRESSURE en première colonne --------
            col_press = 1;
            for m=1:size(names,1);
                fff = findstr(names(m,:),'Pressure');
                if isempty(fff) == 0;
                    col_press = m;
                end
            end
            % disp(['Col press = ',num2str(col_press)]);
            ppp = find([1:size(names,1)] ~=col_press);
            names = [names(col_press,:);names(ppp,:)];
            data = [data(:,col_press) data(:,ppp)];
        end
        base(fichier).ctdrosettedata.data = data;
        base(fichier).ctdrosettedata.names = cellstr(names);
        base(fichier).ctdrosettedata.sensors = names;
    end
end
