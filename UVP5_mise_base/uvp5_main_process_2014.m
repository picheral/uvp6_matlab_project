% Traitement données UVP5 avec gestion de projet type Zooprocess
% Picheral 2012/11, 2017/12

clear all
close all


warning off MATLAB:divideByZero
% warning OFF 'NaN found in Y, interpolation at undefined values will
% result in undefined values.')

groupe = 1;
nbzoo = 0;
pasvert=1;
%% ------------ Volumes selon calibrage 2012 --------------------
% uvp5_cor_mat = ones(1,27);
% uvp5_sn001 = ones(1,27);
% uvp5_sn002 = ones(1,27);
% uvp5_sn005 = ones(1,27);
% uvp5_sn102 = ones(1,27);
% uvp5_sn103 = ones(1,27);
% uvp5_sn201 = ones(1,27);
% uvp5_sn202 = ones(1,27);
% uvp5_sn203 = ones(1,27);
% uvp5_sn204 = ones(1,27);
% uvp5_sn008 = ones(1,27);
% uvp5_sn010 = ones(1,27);

% % uvp5_sn002 =
% % [0.87,NaN,0.89,NaN,0.79,0.73,0.76,0.81,0.93,0.85,0.83,0.90,0.92,1.08,1,1,1,1,1,1,1,1,1,1,1,1,1]; (2012)
% % uvp5_sn002 = [0.5622,NaN,0.5956,NaN,0.7052,0.8379,0.9243,0.9926,1.1549,1.1445,1.1937,1.2054,1.1474,1.1699,1.1740,1,1,1,1,1,1,1,1,1,1,1,1];
% uvp5_sn000 = [2.46,NaN,2.28,NaN,1.52,1.06,0.88,0.79,0.75,0.69,0.78,0.70,0.66,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
% uvp5_sn003 = [1.34,NaN,1.35,NaN,1.06,0.87,0.82,0.83,0.87,0.82,0.83,0.87,0.90,0.95,1.04,1,1,1,1,1,1,1,1,1,1,1,1];
% uvp5_sn002zh = [0.76,NaN,0.88,NaN,0.71,1.34,0.58,0.80,0.75,0.49,0.66,0.59,0.73,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
% uvp5_sn002zp = [0.60,NaN,0.79,NaN,0.90,2.73,1.55,2.96,3.73,2.99,4.12,4.93,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5];
% uvp5_sn003zp = [0.60,NaN,0.79,NaN,0.90,2.73,1.55,2.96,3.73,2.99,4.12,4.93,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5];
% uvp5_sn002zd = [0.85,NaN,0.90,NaN,0.30,0.66,0.19,0.27,0.28,0.19,0.24,0.56,.5,.5,.5,.5,.5,.5,.5,.5,.5,.5,.5,.5,.5,.5,.5];
% uvp5_sn008 = [1.34,NaN,1.32,NaN,1.27,1.15,1.04,.97,.88,.79,.84,1.21,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
% % uvp5_sn008 =    [1.59,NaN,1.52,NaN,1.08,0.82,0.78,0.81,0.89,0.85,0.85,0.91,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
% uvp5_sn009 =    [0.7593,NaN,0.7767,NaN,0.9315,1.1036,1.1880,1.3371,1.2863,1.4393,1.2341,1.3224,1.1523,2.3946,0.9957,0.8124,1.1529,1,1,1,1,1,1,1,1,1,1];
% % uvp5_sn010 =   [0.8663,NaN,0.8380,NaN,0.8330,0.8644,0.8603,0.8569,0.9103,0.7847,0.8490,1.0391,0.9474,0.8745,0.6866,0.9072,0.2997,1,1,1,1,1,1,1,1,1,1];
% % uvp5_sn010 =  [1.04,NaN,1.03,NaN,1.01,.93,.85,.79,.77,.70,.74,.93,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
% uvp5_sn011 =   [1.5240,NaN,1.4999,NaN,1.0907,0.8126,0.7328,0.7377,0.7983,0.7314,0.7334,0.8193,0.9307,1.2108,1.2414,1,1,1,1,1,1,1,1,1,1,1,1];
% uvp5_sn101 =   [1.1593,NaN,1.1723,NaN,0.9777,0.8176,0.7954,0.8101,0.8900,0.7807,0.8102,0.9039,1.1019,1.5209,1.6738,1.0856,1,1,1,1,1,1,1,1,1,1,1];

% uvp_list = {'uvp5_sn000' 'uvp5_sn001' 'uvp5_sn002' 'uvp5_sn003' 'uvp5_sn005' 'uvp5_sn002zh' 'uvp5_sn002zd' 'uvp5_sn002zp' 'uvp5_sn008'...
%     'uvp5_sn009' 'uvp5_sn010' 'uvp5_sn011' 'uvp5_sn101' 'uvp5_sn102' 'uvp5_sn103' 'uvp5_sn201' 'uvp5_sn201a' 'uvp5_sn201b' 'uvp5_sn201c'...
%     'uvp5_sn202'  'uvp5_sn202a' 'uvp5_sn203' 'uvp5_sn204' 'uvp5_sn204a' 'uvp5_sn204a' 'uvp5_sn205' 'uvp5_sn205a' 'uvp5_sn205b' 'uvp5_sn206'...
%     'uvp5_sn207' 'uvp5_sn207a' 'uvp5_sn207b'};

disp('------------------- UVP5 data process tools ------------------------');
% ------------ Existence du répertoire CONFIG

if exist('W:\UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\') == 7
    zoo_list_dir = 'W:\UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\';
elseif exist('Z:\UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\') == 7
    zoo_list_dir = 'Z:\UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\';
elseif exist('Y:\UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\') == 7
    zoo_list_dir = 'Y:\UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\';
elseif exist('X:\UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\') == 7
    zoo_list_dir = 'X:\UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\';
elseif exist('C:\Users\zooprocess partage\Documents\MATLAB\toolbox_partagees\toolbox_uvp5\uvp5_bases\')==7
    zoo_list_dir = 'C:\Users\zooprocess partage\Documents\MATLAB\toolbox_partagees\toolbox_uvp5\uvp5_bases\';
elseif exist('C:\Users\Marc Piheral\Documents\Matlab_toolbox\toolbox_partagees\toolbox_uvp5\uvp5_bases\') == 7
    zoo_list_dir = 'C:\Users\Marc Piheral\Documents\Matlab_toolbox\toolbox_partagees\toolbox_uvp5\uvp5_bases\';
elseif exist('C:\Documents\Documents\Matlab_toolbox\toolbox_partagees\toolbox_uvp5\uvp5_bases\') == 7
    zoo_list_dir = 'C:\Documents\Documents\Matlab_toolbox\toolbox_partagees\toolbox_uvp5\uvp5_bases\';
elseif exist('C:\Users\UVP5SN009\Documents\MATLAB\toolbox_uvp5\uvp5_bases\')==7
    zoo_list_dir = 'C:\Users\UVP5SN009\Documents\MATLAB\toolbox_uvp5\uvp5_bases\';
elseif exist('C:\Documents\Documents\Matlab_toolbox\Marc\PVM2005_Matlab\UVP5_matlab\') == 7
    zoo_list_dir = 'C:\Documents\Documents\Matlab_toolbox\Marc\PVM2005_Matlab\UVP5_matlab\';
elseif exist('C:\Users\UVP5SN009\Documents\MATLAB\')== 7
    zoo_list_dir = 'C:\Users\UVP5SN009\Documents\MATLAB\';
elseif exist('C:\Users\picheral\Documents\MATLAB\toolbox_partagees\toolbox_uvp5\uvp5_bases\') == 7
    zoo_list_dir = 'C:\Users\picheral\Documents\MATLAB\toolbox_partagees\toolbox_uvp5\uvp5_bases\';
elseif exist('C:\Users\picheral\Documents\Matlab_toolbox\toolbox_partagees\toolbox_uvp5\uvp5_bases\') == 7
    zoo_list_dir = 'C:\Users\picheral\Documents\Matlab_toolbox\toolbox_partagees\toolbox_uvp5\uvp5_bases\';
elseif exist('C:\Users\emna\Documents\Matlab_toolbox\toolbox_partagees\toolbox_uvp5\uvp5_bases\') == 7
    zoo_list_dir = 'C:\Users\emna\Documents\Matlab_toolbox\toolbox_partagees\toolbox_uvp5\uvp5_bases\';
elseif exist('C:\Users\user\Documents\MATLAB\toolbox_partagees\toolbox_uvp5\uvp5_bases\') == 7
    zoo_list_dir = 'C:\Users\user\Documents\MATLAB\toolbox_partagees\toolbox_uvp5\uvp5_bases\';
elseif exist('C:\Users\Marc Picheral\Documents\Matlab_toolbox\toolbox_partagees\toolbox_uvp5\uvp5_bases\') == 7
    zoo_list_dir = 'C:\Users\Marc Picheral\Documents\Matlab_toolbox\toolbox_partagees\toolbox_uvp5\uvp5_bases\';
end

TXT_base = {};
% ------------- LECTURE DU FICHIER base_to_process.xlsx -------------
[NUMERIC,TXT_base,RAW]=xlsread([zoo_list_dir,'base_to_process.xlsx']);
disp('------------------- Project in ''base_to_process.xlsx'' ---------------------------');
for bbb = 1 : numel(TXT_base);        disp(char(TXT_base(bbb)));    end
disp('------------------------------------------------------------------');

%% ------------------ BOUCLE / Unique --------------------------------
general_process = input('Batch process using Base_to_process.xlsx or Unique project or All (u/b/a) ? ','s');
if isempty(general_process) ; general_process = 'u'; end

if strcmp(general_process,'u')
    disp('Select the ''uvp5_cruise'' root folder you want to process');
    TXT_base = {};
    %% ------------ Choix du projet ---------------------------------
    selectprojet = 0;
    while (selectprojet == 0)
        project_folder = uigetdir('Select UVP5 project directory');
        if strcmp(project_folder(4:7),'uvp5');  selectprojet = 1;
        else disp(['Selected project ' project_folder ' is not correct. It must be on the root of a drive.']); end
    end
    TXT_base = {TXT_base;project_folder};
    disp('---------------------------------------------------------------------');
elseif strcmp(general_process,'a')
    %% ------------- TOUS les projets du disque ----------------------
    drive = uigetdir('Select DRIVE containing all PROJECTS ');
    TXT_base = {};
    %% Boucle sur les projets dans le "drive"
    bb = dir(drive);
    index = 0;
    for m = 1: numel(bb)
        project_folder = bb(m).name;
        if strncmp(project_folder,'uvp5_sn',7)
            TXT_base = {TXT_base;[drive,project_folder]};
            disp(project_folder);
        end
    end
end

disp('--------------------------- OPTIONS --------------------------------');
create_base = input('Update existing bases or Create a new base (u/c) ?  ','s');
save_histo = 'n';


%% ---------------- OPTIONS -----------------------
option_sel = input('Keep all default options (y/n) ? ','s');
if isempty(option_sel); option_sel = 'y'; end

load_meta = [];
skip_histo = [];
save_histo = [];
recpx = [];
pasvert = [];
depth_offset = [];
save_figures = [];
sbecnv = [];
zooerase = [];
zoopuvp5 = [];
load_more_recent = [];
zoo_norm = [];
processnor = [];
matvert = [];
min_zoo_esd = [];
process_depth = [];
process_plot = [];
process_odv = [];
include_ctd = [];
include_zoo_det = [];
exclude_detritus = [];
reduce_ident_norm = [];
matverti = [2.5:5:6000];
calibration = [];
process_calib = 'n';
manual_filter = 'n';
process_map = 'n';

if strcmp(option_sel,'n')
    manual_filter = input('Filter each sequence for light failure detection (No, Auto, Manual : n/a/m ) ? ','s');
    process_calib = input('Process data from aquarium inter-calibration ? (n/y) ','s');
    recpx=input('Process pixel histogramms ? (n/y) ','s');
    if strcmp(process_calib,'y')
        recpx = 'y';
    else
        pasvert =      input('Input depth bin size (m) (default = 5) ');
        depth_offset =      input('Input depth_offset (m) (default = 1.2) ');
        matvert = input(['Input depth intervals (default is [2.5:5:6000]) ']);
        process_map = input('Process station map (n/y) ','s');
        %         calibration = input('Adjust particule abundances and biovolume using calibration results (y/n) ? ','s');
        load_meta = input('Load metadata into base (y/n) ?  ','s');
        skip_histo = input('SKIP process again already processed histogramms (y/n) ?  ','s');
        save_histo = input('Save histogramms as separate txt files (n/y) ?  ','s');
        save_figures = input('Save figures as image files (y/n) ?  ','s');
        sbecnv =     input('Load CTD data files (y/n) ','s');
        zooerase =      input('Remove all previous Zooplankton data (y/n) ','s');
        zoopuvp5 =      input('Load validated identifications (y/n) ','s');
        processnor = input('Process zooplankton abundances for all profiles (y/n) ','s');
        min_zoo_esd =     input('Enter min ESD (mm) for zooplankton abundances if needed ');
        process_depth =     input('Process theoretical depth (n/y) ','s');
        process_plot =     input('Process PLOT (n/y) ','s');
        process_odv =     input('Process ODV text file (n/y) ','s');
    end
end
% -------------- Valeurs par défaut ---------------
if isempty(process_map); process_map = 'n';end
if isempty(manual_filter); manual_filter = 'n'; end
if isempty(load_meta); load_meta = 'y'; end
if isempty(skip_histo); skip_histo = 'y'; end
if isempty(save_histo); save_histo = 'n'; end
if isempty(recpx);   recpx = 'n';end
if isempty(pasvert); pasvert = 5;end
if isempty(depth_offset); depth_offset = 1.2;end
if isempty(save_figures); save_figures = 'n'; end
if isempty(sbecnv); sbecnv = 'y';end
if isempty(zooerase); zooerase = 'Y';end
if isempty(zoopuvp5); zoopuvp5 = 'y';end
if isempty(process_calib); process_calib = 'n';end
if strcmp(zoopuvp5,'y')
    load_more_recent = input('Load only more recent identifications (y/n) ','s');
    if isempty(load_more_recent); load_more_recent = 'y';end
    zoo_norm = input(['Normalize identifications in the base ("Noms_zoo_UVP5_matlab_*.xls" must be in config folder) (y/n) '],'s');
    if isempty(zoo_norm); zoo_norm = 'y';end
else
    load_more_recent = 'y';
    zoo_norm = 'y';
end
if isempty(processnor); processnor = 'y';end
if isempty(matvert); matvert = matverti;end
if isempty(min_zoo_esd); min_zoo_esd = 0;end
if isempty(process_depth); process_depth = 'n';end
if strcmp(process_depth,'y')
    %cd('E:\Matlab65\toolbox\Marc\m_map\private');
    mmaplist = {'C:\Users\picheral\Documents\Matlab_toolbox\toolbox_partagees\toolbox_uvp5\m_map\private\' 'C:\Users\zooprocess partage\Documents\MATLAB\toolbox_partagees\toolbox_uvp5\m_map\private' 'C:\Program Files\MATLAB\R2012a\toolbox\m_map\private\','E:\Documents\Matlab_toolbox\Marc\m_map\private\','D:\Documents\Matlab_toolbox\Marc\m_map\private\','C:\Program Files\MATLAB\R2009b\toolbox\Marc\m_map\private\' 'C:\Documents\Documents\Matlab_toolbox\Marc\m_map'};
    move_mmap = [];
    for o = 1:numel(mmaplist)
        if exist(char(mmaplist(o))) == 7
            move_mmap = ['cd(''',char(mmaplist(o)),''')'];
        end
    end
    if isempty( move_mmap);disp('The m_map library folder cannot be found.');end
    disp(['m_map\private folder : ',move_mmap(5:end-2)]);
end
if isempty(process_plot); process_plot = 'n';end
if isempty(process_odv); process_odv = 'n';end
if strcmp(process_odv,'y')
    include_ctd =     input('Include CTD in ODV file (y/n) ','s');
    if isempty(include_ctd); include_ctd = 'y';end
    include_zoo_det =     input('Process ODV Zooplankton individual file (n/y) ','s');
    if isempty(include_zoo_det); include_zoo_det = 'n';end
    exclude_detritus =     input('Exclude detritus from individual file (y/n) ','s');
    if isempty(exclude_detritus); exclude_detritus = 'y';end
end
reduce_ident_norm = 'y';
if strcmp(recpx,'y');   skip_histo = 'y';end

% if strcmp(process_odv,'y')
%     reduce_ident_norm = input('Simplify Id list for synthetized ODV file ("Noms_zoo_UVP5_matlab_cruise.xls" must be in config folder) (y/n) ','s');
%     if isempty(reduce_ident_norm); reduce_ident_norm = 'y';end
% end

%% ------------------ Inventaire de la taxo dans tous les projets --------
root=cd;
disp('-------------------------------------------------------------');
disp('--------------- TAXO inventaire -----------------------------');
disp('-------------------------------------------------------------');
% drive = uigetdir('Select DRIVE containing all PROJECTS ');
project_folder = char(TXT_base(2));
drive = project_folder(1:3);
cd(drive);
bb = dir(drive);
index = 0;
biglist={};
for m = 1:numel(bb)
    project_folder = bb(m).name;
    if strncmp(project_folder,'uvp5_sn',7)
        filename = [bb(m).name,'\PID_process\Pid_results\Dat1_validated\category_list.txt'];
        if exist(filename) == 2
            disp([num2str(m),' :  ',bb(m).name]);
            fid = fopen(filename);
            while 1                     % loop on the number of lines of the file
                tline = fgetl(fid);
                %                 disp(tline)
                if ~ischar(tline), break, end
                
                biglist=[biglist;{tline}];
            end
            fclose(fid);
            % table to array
            % write table
            %             T=readtable(filename,'ReadVariableNames',false,'Delimiter',',');
            %             biglist=[biglist;T];
        end
    end
end
biglist=unique(biglist);
% -------------------- Sauvegarde du fichier des taxo uniques --------------------
fid=fopen([zoo_list_dir,'\category_list_all_projects.txt'],'w');
for i = 1 : numel(biglist)
    tline =char(biglist(i));
    aa = findstr(tline,'>');
    if numel(aa) > 1
        tline_converted = [tline(aa(end)+1:end),' (',tline(aa(end-1)+1:aa(end)-1),')'];
    elseif numel(aa)==1
        tline_converted = [tline(aa(end)+1:end),' (',tline(1:aa(end)-1),')'];
    else
        tline_converted = tline;
    end
    %     disp(biglist(i,1))
    fprintf(fid,'%s\t%s\n',tline,tline_converted);
    %     fprintf(fid,'%s\n',char(biglist(i,1)));
end
fclose(fid);
disp([zoo_list_dir,'\category_list_all_projects.txt SAVED now !']);
cd(root);
disp('-------------------------------------------------------------');

%% =======================================================================
%% ----------------- BOUCLE SUR LES PROJETS ------------------------------
%% =======================================================================
for bbb = 2 : numel(TXT_base);
    project_folder = char(TXT_base(bbb));
    project_name = project_folder(9:end);
    disp(['Project ',project_name,' accepted.']);
    cd(project_folder);
    config_dir = [project_folder,'\config\'];
    selectprojet = 1;
    %++++++++++++++++++ Tests sur le projet ++++++++++++++++++++++++++++++++
    % ------------- Existence du répertoire META
    meta_dir = [project_folder,'\meta\'];
    if isdir(meta_dir);
        disp([meta_dir,' folder exists.']);
        % Existence d'un fichier entete
        meta_file = ['uvp5_header_',project_name,'.txt'];
        meta = exist([meta_dir,meta_file]);                 % 2 si OK
        if meta == 2; disp([meta_file,' exists.']);
        else
            disp([meta_file,' DOES NOT exist !!!!!!!.']);
        end
    else
        disp(['No ',meta_dir,' folder. You MUST fill metadata and process profiles in Zooprocess ! ']);
        meta = 1;
    end
    
    % ---------------- Existence de fichiers dans RESULTS
    results_dir = [project_folder,'\results\'];
    if isdir(results_dir)
        disp([results_dir,' folder exists.']);
        % --------- Existence de fichiers BRU
        bru_list = dir([results_dir, '*.bru']);
        bru_nofile = isempty(bru_list);
        if bru_nofile == 0
            disp([num2str(size(bru_list,1)), ' bru files.']);
        else
            disp(['No bru files in ',results_dir]);
        end
        
        % --------- Existence de fichiers datfile.txt
        datfile_list = dir([results_dir, '*datfile.txt']);
        datfile_nofile = isempty(datfile_list);
        if datfile_nofile == 0
            disp([num2str(size(datfile_list,1)), ' datfile.txt files.']);
        else
            disp(['No datfile.txt files in ',results_dir]);
        end
        % --------- Existence d'une base dans results
        base_list = dir([results_dir, 'base*.mat']);
        base_nofile = isempty(base_list);
        if base_nofile == 0
            disp('----------- Base list --------------------------------');
            disp([num2str(size(base_list,1)),' database in ', results_dir]);
            for i = 1:size(base_list)
                disp(['N°= ',num2str(i),' : ',base_list(i).name]);
            end
        else
            disp(['No database in ',results_dir]);
        end
    else
        bru_nofile = 1;
        datfile_nofile = 1;
        base_nofile = 1;
    end
    
    % ---------- Existence de fichiers dans DAT1_validated
    validated_dir = [project_folder,'\PID_process\Pid_results\Dat1_validated\'];
    if isdir(validated_dir)
        % Existence de fichiers dat1.txt
        dat1txtval_list = dir([validated_dir, '*dat1.txt']);
        dat1txt_nofile = isempty(dat1txtval_list);
    else
        dat1txt_nofile = 1;
    end
    
    % ---------- Existence de fichiers CTD
    ctdcnv_dir = [project_folder,'\ctd_data_cnv\'];
    if isdir(ctdcnv_dir)
        % Existence de fichiers cnv
        cnv_list = dir([validated_dir, '*.cnv']);
        cnv_nofile = isempty(cnv_list);
    else
        cnv_nofile = 1;
    end
    
    % ---------- Existence de fichiers RAW
    disp('---------------------------------------------------------------------');
    raw_dir = [project_folder,'\raw\'];
    if isdir(raw_dir)
        % Existence de fichiers raw
        raw_list = dir([raw_dir]);
        raw_nofile = isempty(raw_list);
    else
        raw_nofile = 1;
    end
    
    if raw_nofile == 0
        rawzip_dir = [project_folder,'\raw\HDR*.zip'];
        rawzip_list = dir(rawzip_dir);
        hdrfolder = size(raw_list,1)-size(rawzip_list,1)-2;
        disp([num2str(hdrfolder), ' raw HDR folders.']);
    else
        disp(['No raw folder in ',results_dir]);
        hdrfolder = 0;
    end
    
    % ----------- Nouvelle base ----------------------
    base_new = ['baseuvp5_',project_name];
    
    %% +++++++++++++++++++++++++++++++ OPTIONS +++++++++++++++++++++++++++++++
    if isempty(calibration) ; calibration = 'y'; end
    if strcmp(calibration,'y'); base_new = ['baseuvp5_',project_name,'_cal'];end
    
    % ----------- MAJ possible si une base existe ----------
    if ((isempty(create_base)|| strcmp(create_base,'u'))&& base_nofile == 0)
        % -------Update database------
        create_base = 'u';
        if ~strcmp(general_process,'b')
            if numel(base_list) == 1
                base_selected = 1;
            else
                disp('------------------------------------------------------');
                base_selected = input('Enter number corresponding to selected uvp database. (default = 1) ');
                if isempty(base_selected); base_selected = 1;   end
            end
        else
            base_selected = 1;
        end
        
        % ---------------- Chargement de la base choisie ------------------
        toto=['load ',results_dir,base_list(base_selected).name,';'];
        eval(toto);
        toto=['base = ',base_list(base_selected).name(1:end-4),';'];
        eval(toto);
        ligne = size(base,2);
        
    else
        % -------------Sinon creation nouvelle----------------
        load_meta = 'y';
        skip_histo = 'n';
        base = [];
        disp([base_new,' will be created or will replace existing.']);
    end
    
    %% ++++++++++++++++++ Création ou mise à jour de la base +++++++++++++++++
    
    %% --------------- Mise à jour des metadata à partir du fichier header ----------
    if strcmp(load_meta,'y')
        % Fonction de lecture des entetes
        [base compteur ligne] = uvp5_main_process_2014_metadata(base,raw_dir,meta_dir,meta_file,create_base,results_dir);
    else
        % Lecture des metad[base compteur ligne]ata à partir de la base
        toto = ['basepvm5 = ',char(base_new)];
        eval(toto);
    end
    
    if (i ~= hdrfolder);
        disp('--------------------------------------------------------------------------------------');
        disp(['The number of raw folders does not match the number of profiles in the metadata file.']);
        disp('--------------------------------------------------------------------------------------');
    end
    
    %% +++++++++++++++ TAILLE PIXEL +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    filename=[project_folder,'\config\uvp5_settings\uvp5_configuration_data.txt'];
    [ aa_data_adj expo_data_adj img_vol_data_adj pixel_size light1_adj light2_adj] = read_uvp5_configuration_data( filename , 'data');
    disp('The pixel size is read from the uvp5_configuration_data.txt file.')
    for kk = 1:numel(base)
        base(kk).pixel_size = pixel_size;
    end
    
    
    %% ++++++++++++++++ Ajustement des volummes selon calibrages de 2012 ++++++++++++++++++++++
    
    %     if strcmp(calibration,'y') ;
    %         for i = 1 : numel(uvp_list);
    %             if strcmp(base(1).pvmtype,char(uvp_list(i)));
    %                 toto = ['uvp5_cor_mat = ' char(uvp_list(i)) ';'];
    %                 eval (toto);
    %             end
    %         end
    %     end
    
    uvp5_cor_mat = ones(1,27);
    % ------------- VOL pour abondances ZOO --------------------------
    % ---- 30 px 0.6 mm --------------------
    volume_zoo = base(1).volimg0 * nanmean(uvp5_cor_mat(15:end));
    
    %% ++++++++++++++++++++++++ BOUCLE PRINCIPALE sur Liste des fichiers ++++++++++++++++++++++++++++++++
    disp('-------------------------------------------------------');
    disp('--------------- PROCESSING HISTOGRAMS -----------------');
    h=waitbar(0,'Processing UVP5 LPM data ...');%create and display a bar that show progess of the analysis
    for fichier=1:ligne
        waitbar(fichier / ligne);
        %--------------- Calcul des histogrammes ----------------------
        disp('-------------------------------------------------------');
        
        [base ] = uvp5_main_process_2014_histo(base,skip_histo,fichier,recpx,uvp5_cor_mat,pasvert,results_dir,save_histo,ligne,depth_offset,groupe,calibration,process_calib,manual_filter );
        disp('-------------------------------------------------------');
        
        %   ------------------- Theo Depth ----------------
        if strcmp( process_depth,'y')
            lat=base(fichier).latitude;
            long=-base(fichier).longitude;
            if abs(lat) > 71
                base(fichier).theo_depth= NaN;
            else
                minlat= floor(max(-90,lat-1));
                maxlat= ceil(min(90,lat+1));
                minlong= floor(max(-180,long-1));
                maxlong= ceil(min(180,long+1));
                eval(move_mmap);
                [lati,longi,elevations]=satbath(1,[minlat,maxlat],[minlong,maxlong]);
                [longnew,latnew,xpos,ypos]=localisation(long,lat,longi(1,:)-360,lati(:,1));
                depth=elevations(ypos(1),xpos(1));
                base(fichier).theo_depth=-depth;
            end
        end
    end
    close(h);
    disp('-------------------------------------------------------');
    disp('Saving database, WAIT !');
    cd(results_dir);
    toto=[base_new,'=base;'];
    eval(toto);
    toto=['save ',base_new,'.mat ',base_new,];
    eval(toto);
    
    disp('-------------------------------------------------------');
    disp('--------------- PROCESSING CTD ------------------------');
    num_cce = [];
    txt_cce = [];
    h=waitbar(0,'Loading CTD data ...');%create and display a bar that show progess of the analysis
    
    % --------- TARA - SUBICE cases -------------------------
    if (strcmp(base(fichier).cruise,'sn000_tara2009'))||(strcmp(base(fichier).cruise,'sn000_tara2010'))||(strcmp(base(fichier).cruise,'sn000_tara2011'))||(strcmp(base(fichier).cruise,'sn003zp_tara2012'))||(strcmp(base(fichier).cruise,'sn000_tara2012') ||(strcmp(base(fichier).cruise,'sn003_tara2013')));
        base_ctd_path = [ctdcnv_dir,'\base_CTD_full_isus_carb.mat'];
        if (exist(base_ctd_path) == 2 && exist('base_all') == 0)
            base_all = load([ctdcnv_dir,'\base_CTD_full_isus_carb.mat']);
        elseif isempty(base_all)
            base_all = load([ctdcnv_dir,'\base_CTD_full_isus_carb.mat']);
        end
        disp(['Loading ',ctdcnv_dir,'\base_CTD_full_isus_carb.mat']);
        
    elseif (strcmp(base(1).cruise,'sn008_subice_2014'));
        toto = [ctdcnv_dir,'subice_ctd.xlsx'];
        test = exist(toto);
        if test==2          % Le fichier existe et est charge
            disp(['Loading ',toto]);
            [num_cce, txt_cce]= xlsread(toto);
        else
            disp('CTD data (subice_ctd.xlsx) not found !');
        end
        base_all = [];
    else
        base_all = [];
    end
    
    if strcmp( sbecnv,'y')
        ctd_norm_file = [zoo_list_dir,'ctd_uvp_normalisation_for_ecotaxa.xlsx'];
        disp(['Normailsation for Ecotaxa using : ',ctd_norm_file])
        for fichier=1:ligne
            waitbar(fichier / ligne);
            %%------------------ CHARGEMENT Donnees CTD ----------------
            
            [base num_cce txt_cce] = uvp5_main_process_2014_load_ctd(base,fichier,ctdcnv_dir,num_cce,txt_cce,base_all);
            % ----------------- NORMALISATION CTD -------------------------------
            if isfield(base(fichier),'ctdrosettedata')
                base = uvp5_main_process_2014_ctd_norm(base,fichier,zoo_list_dir);
                
                % ---------------- NORMALISATION POUR ECOTAXA ----------
                base = uvp5_main_process_2014_ctd_norm_ecotaxa(base,fichier,zoo_list_dir);
                
            end
            
        end
    else
        disp('CTD files not loaded/normalised ');
    end
    close(h);
    
    % --------------- CREATION FICHIERS .ctd pour ECOTAXA ---------
    [base] = uvp5_process_ctd_for_ecotaxa(base,ctdcnv_dir);
    
    disp('-------------------------------------------------------');
    disp('Saving database, WAIT !');
    cd(results_dir);
    toto=[base_new,'=base;'];
    eval(toto);
    toto=['save ',base_new,'.mat ',base_new,];
    eval(toto);
    
    %% ------------- Chargement des DAT FILE ---------------------------
    disp('-------------------------------------------------------');
    disp('--------------- PROCESSING DATFILES -------------------');
    for fichier=1:ligne
        [Image Pressure Temp_interne Peltier Temp_cam Flag Part listecor liste] = uvp5_main_process_2014_load_datfile(base,fichier,results_dir,depth_offset,process_calib);
        base(fichier).datfile.image = Image;
        base(fichier).datfile.pressure = Pressure/10;
        base(fichier).datfile.temp_interne = Temp_interne;
        base(fichier).datfile.peltier = Peltier;
        base(fichier).datfile.temp_cam = Temp_cam;
        % ---------------- Filtrage ----------------------
        
        [im_filtered, part_util_filtered_rejected, movmean_window, threshold_percent] = DataFiltering(listecor,results_dir,base(fichier).profilename,manual_filter);
        disp(['Movmean_window = ', num2str(movmean_window)])
        disp(['Threshold_percent = ', num2str(threshold_percent*100)])
        disp(['Total of images from 1st and zmax = ',num2str(size(listecor,1))])
        dd = find(listecor(:,3) == 1);
        disp(['Total of descent images = ',num2str(numel(dd))])
        disp(['Total number of un-rejected images (from descent only) = ',num2str(numel(im_filtered))])
        disp(['Number of rejected images (from descent only) = ',num2str(numel(part_util_filtered_rejected))])
        disp(['Percentage of un-rejected images (from descent only) = ',num2str((100*(numel(dd)-numel(part_util_filtered_rejected))/numel(listecor(:,1))),3)])
        base(fichier).tot_rejected_img = numel(part_util_filtered_rejected);
        base(fichier).tot_utilized_img = numel(im_filtered);
        base(fichier).filter_movmean = movmean_window;
        base(fichier).filter_threshold_percent = threshold_percent*100;
    end
    
    %% ------------ Bruit UVP5hd --------------------------------------
    if strcmp(project_name(1:3),'sn2')
        for fichier=1:ligne
            if strcmp(process_calib,'y')
                UVP5_check_noise_aquarium(base,fichier,results_dir);
                %             else
                %                 UVP5_check_noise(base,fichier,results_dir);
            end
        end
    end
    
    
    %% ------------- Chargement et trt du Zooplankton ---------------------------
    disp('-------------------------------------------------------');
    disp('--------------- PROCESSING ZOOPLANKTON ----------------');
    h=waitbar(0,'Processing UVP5 ZOO data ...');%create and display a bar that show progess of the analysis
    
    %% ---------------------- Conversion TSV Ecotaxa en DAT1.txt ---------------------------------
    tsv_to_dat1_uvp(validated_dir);
    
    % ---------------- Vérification que toutes les catégories de la liste sont bien dans la table de mapping ZOO -------------------
    %     uvp5_main_process_2014_check_taxa(validated_dir,zoo_list_dir,'Noms_zoo_UVP5_matlab_generic_ecotaxa.xls');
    
    for fichier=1:ligne
        waitbar(fichier / ligne);
        
        disp('-------------------------------------------------------');
        disp([num2str(fichier),' / ',num2str(ligne)]);
        
        %% ----------------- CHARGEMENT ET PROCESS ZOOPLANKTON ---------------
        base = uvp5_main_process_2014_load_zoopk(base,fichier, zooerase,zoopuvp5,validated_dir,results_dir,depth_offset,load_more_recent,pixel_size);
        
        %% ---------------- Normalisation et abondance des identifications---------
        base = uvp5_main_process_2014_norm_ab_zoopk(base,fichier,zoo_norm,processnor,volume_zoo,matvert,min_zoo_esd,config_dir,zoo_list_dir);
        
        %% ---------- Existence de données Zoo dans la base -------
        if isfield(base(fichier),'zoopuvp5')
            if isempty(base(fichier).zoopuvp5)==0;nbzoo = nbzoo+1;end
        else
            base(fichier).zoopuvp5 = [];
            base(fichier).datfile = [];
        end
        
    end
    close(h);
    %% ++++++++++++++++++++++++++++ CREATION du META MAJ lat/Lon ++++++++++++++++++++++++++++
    meta_file = strcat('ctd_cor_',meta_file);
    uvp5_main_process_2014_maj_metafile(base,meta_dir,meta_file);
    
    %% ++++++++++++++++++++++++++++ PLOT CARTE STN Mission ++++++++++++++++++++++++++++++++++
    if strcmp(process_map,'y')
        uvp5_main_process_2014_plot_cruise_map(base,results_dir);
    end
    
    % -------------- Graphe des temperatures / pressure ------------------------
    uvp5_main_process_2014_print_temp_depth(base,results_dir);
    
    %% ++++++++++++++++++++++++++++ Enregistrement de la base ++++++++++++++++++++++++++++++++
    
    disp('------------------------------------------------------------------------');
    disp('Saving database, WAIT !');
    cd(results_dir);
    toto=[base_new,'= base;'];
    eval(toto);
    toto=['save ',base_new,'.mat ',base_new,];
    eval(toto);
    
    % ------------------- Purge de la base pour récupération mémoire-----------------------
    if strcmp(general_process,'a') || strcmp(general_process,'b');
        toto=['clear ',base_new];
        eval(toto);
        disp(['Data base ',base_new,' deleted now to save memory.']);
    end
    %% ----------------- VERIFICATION HISNB vides ------------------------
    
    disp('----------------------------------------------------------------------')
    for fichier=1:ligne
        if isempty(base(fichier).hisnb)
            disp(['HISNB empty for ',char(base(fichier).profilename),'  record : ',num2str(fichier)]);
        end
    end
    disp('-------------- Base checked for empty HISTOGRAMS ---------------------');
    
    disp('----------------------------------------------------------------------')
    disp('-------------- Data processed and loaded into base -------------------');
    disp('----------------------------------------------------------------------')
    
    %% ++++++++++++++++++++++++++++++++ PLOT ++++++++++++++++++++++++++++++++++++++++++++++
    if strcmp(process_plot,'y')
        uvp5_main_process_2014_plot_zoo(base,results_dir);
    end
    
    %% ++++++++++++++++++++++++++++++++ Création archives ODV +++++++++++
    ctddebut = 1;
    if (strcmp(process_odv,'y'))
        % ---------- Fichiers ODV LPM et CTD ---------------
        [base,ctddebut] = uvp5_process_odv_lpm_ctd(base,results_dir,base_new,include_ctd);
        
        % --------------- ZOOPLANKTON ---------------------
        if nbzoo >=1
            [base] = uvp5_process_odv_zoo_ctd(base,results_dir,base_new,ctddebut,include_zoo_det,exclude_detritus);
        end %nbzoo
    end
    
    
    %% ++++++++++++++++++++++++++++++++++ Retour répertoire +++++++++++++++++++++++++++
    cd(project_folder);
end