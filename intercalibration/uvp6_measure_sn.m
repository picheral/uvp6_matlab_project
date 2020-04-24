%% Extraction du bruit moyen pour bases UVP6

clear all
close all
warning('OFF')
scrsz = get(0,'ScreenSize');


disp('------------------------------------------------------')
disp('--------------- START PROCESS ------------------------')
disp('------------------------------------------------------')
disp('------------------- OPTIONS --------------------------')

%% ------------- ouverture base -------------------------
selectprojet = 0;
while (selectprojet == 0)
    disp('>> Select UVP project directory');
    project_folder_ref = uigetdir('', 'Select UVP project directory');
    if strcmp(project_folder_ref(4:6),'uvp')
        selectprojet = 1;
    else
        disp(['Selected project ' project_folder_ref ' is not correct. It must be on the root of a drive.']);
    end
end
cd(project_folder_ref);

% ------------- Liste des bases --------------------
results_dir = [project_folder_ref,'\results\'];
if isfolder(results_dir)
    base_list = dir([results_dir, 'base*.mat']);
    if ~isempty(base_list)
        disp('----------- Base list --------------------------------');
        disp([num2str(size(base_list,1)),' database in ', results_dir]);
        for i = 1:size(base_list)
            disp(['N°= ',num2str(i),' : ',base_list(i).name]);
        end
    else
        disp(['No database in ',results_dir]);
        return
    end
else
    disp(['Process cannot continue : no base in ',results_dir]);
    return
end
disp('------------------------------------------------------');
base_selected = 1;
if i > 1
    base_selected = input('Enter number corresponding to selected uvp database. (default = 1) ');
    if isempty(base_selected); base_selected = 1;   end
end

threshold = input('Enter threshold for noise measurement ');

% ---------------- Chargement de la base choisie ------------------
load([results_dir,base_list(base_selected).name]);
% try statement in order to deal with old and new base name syntaxe
try
    base_ref = eval(base_list(base_selected).name(1:end-4));
catch
    base_ref = base;
end


%% -------------- calcul bruit et signal par pixels size --------------
ligne_ref = size(base_ref,2);
entete = ['Profilename;sn_1;sn_2;sn_3;nb_img_black;black_mean_1;black_mean_2;black_mean_3;black_stddev_1;black_stddev_2;black_stddev_3;nb_img_signal;signal_mean_1;signal_mean_2;signal_mean_3;signal_stddev_1;signal_stddev_2;signal_stddev_3'];

% ---------------- Creation fichier ----------------
path = [results_dir,char(base_list(base_selected).name),'_noise_data.txt'];
fid = fopen(path,'w');
fprintf(fid,'%s\r',char(entete));

% ------------ Boucle sur la base ------------------
for i = 1 : ligne_ref
    % ------------- Profilename --------------------
    if ~isempty(base_ref(i).raw_black)
        tt = char(base_ref(i).profilename);
        aa = find(tt == '_');
        if threshold == str2double(tt(aa(1)+1:aa(1)+3))
            
            disp([char(base_ref(i).profilename)])
            raw_black =  base_ref(i).raw_black;
            raw_histopx = base_ref(i).raw_histopx;
            nb_img_black = size(raw_black,1);
            black_mean_1 = nanmean(raw_black(:,5));
            black_mean_2 = nanmean(raw_black(:,6));
            black_mean_3 = nanmean(raw_black(:,7));
            black_stddev_1 = std(raw_black(:,5),'omitnan');
            black_stddev_2 = std(raw_black(:,6),'omitnan');
            black_stddev_3 = std(raw_black(:,7),'omitnan');
            
            nb_img_signal = size(raw_histopx,1);
            signal_mean_1 = nanmean(raw_histopx(:,3));
            signal_mean_2 = nanmean(raw_histopx(:,4));
            signal_mean_3 = nanmean(raw_histopx(:,5));
            signal_stddev_1 = std(raw_histopx(:,3),'omitnan');
            signal_stddev_2 = std(raw_histopx(:,4),'omitnan');
            signal_stddev_3 = std(raw_histopx(:,5),'omitnan');
            
            sn_1 = round(100 * black_mean_1/(signal_mean_1-black_mean_1));
            sn_2 = round(100 * black_mean_2/(signal_mean_2-black_mean_2));
            sn_3 = round(100 * black_mean_3/(signal_mean_3-black_mean_3));
            
            dataline = [sn_1,sn_2,sn_3,nb_img_black,black_mean_1,black_mean_2,black_mean_3,black_stddev_1,black_stddev_2,black_stddev_3,nb_img_signal,signal_mean_1,signal_mean_2,signal_mean_3,signal_stddev_1,signal_stddev_2,signal_stddev_3'];
            % ------- impression fichier ----------------
            fprintf(fid,'%s',[char(base_ref(i).profilename),';']);
            for k = 1 : size(dataline,2)
                fprintf(fid,'%s',[num2str(round(dataline(k))),';']);
            end
            fprintf(fid,'%s\n','');
        end
    end
    
end
fclose(fid);
disp('--------------------------------------------------------------------');
disp([char(base_list(base_selected).name),'_noise_data.txt saved.'])
disp('--------------------------------------------------------------------');