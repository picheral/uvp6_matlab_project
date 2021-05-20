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

if exist('W:\_UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\') == 7
    zoo_list_dir = 'W:\_UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\';
elseif exist('Z:\_UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\') == 7
    zoo_list_dir = 'Z:\_UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\';
elseif exist('Y:\_UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\') == 7
    zoo_list_dir = 'Y:\_UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\';
elseif exist('X:\_UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\') == 7
    zoo_list_dir = 'X:\_UVP5\Protocoles_codes\Codes_Matlab\mise_en_base\';
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
mult_entry = 0.5;
movmean_window_entry = 16;
threshold_percent_entry = .5;
method = 'jo';

if strcmp(option_sel,'n')
    % -------------- Options de filtrage ----------------------
    manual_filter = input('Filter all samples using default settings ([n]/y) ? ','s');
    if isempty(manual_filter); manual_filter = 'n';end
    
    if manual_filter == 'y'
        manual_filter = input('Batch process of all samples using default settings or Manual checking of all ([b]/m) ? ','s');
        if isempty(manual_filter); manual_filter = 'b';end
        
        if manual_filter == 'm';   manual_filter = 'a';end
    
        % -------------------- Selection methode et parametres par defaut ----------------
        method = input('Select filtration method ([jo]/f) ? ','s');
        if isempty(method);method = 'jo';end
        
        if strcmp(method,'c')
            mult =1;
            movmean_window = 25;
            threshold_percent = 0.8;
        elseif strcmp(method,'jo')
            mult = 0.5; % multiplier of the quantile under which points are considered outliers
            movmean_window = 16;
            threshold_percent = 0.50;
        end
        
        mult_entry = input(['Enter multiplier of the quantile under which points are considered outliers [', num2str(mult), '] ']);
        if isempty(mult_entry);    mult_entry = mult;end
        
        movmean_window_entry = input(['Enter moving mean window [', num2str(movmean_window), '] ']);
        if isempty(movmean_window_entry); movmean_window_entry = movmean_window;end
        
        threshold_percent_entry = input(['Enter percent of moving mean for threshold [', num2str(threshold_percent*100), '] ']);
        if isempty(threshold_percent_entry); threshold_percent_entry = threshold_percent;end
        threshold_percent_entry = threshold_percent_entry/100;
        
    end
    
    process_calib = input('Process data from aquarium inter-calibration ? (n/y) ','s');
    recpx=input('Process pixel histogramms ? (y/n) ','s');
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
if isempty(recpx);   recpx = 'y';end
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

%% end