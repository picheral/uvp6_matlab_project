% sum des cast utiles d'un étalon, par threshold
% Camille Catalano, LOV, 2020/04

%pour uvp005lp
% de 28-46, 61-79, 81-99, 114-132
%pour uvp008lp34
% de 28-46, 74-92, 94-112, 114-132, 134-152, 174-192
%pour uvp010lp
% de 28-46, 74-92, 94-112, 114-132, 134-152, 167-185

%% OPEN BASE
clear all
close all

disp('------------------------------------------------------');
disp('---------- ADD sum of casts into a database ---------')
disp('------------------------------------------------------');
selectprojet = 0;
while (selectprojet == 0)
    disp(['>> Select UVP project directory']);
    project_folder = uigetdir('',['Select UVP project directory']);
    if strcmp(project_folder(4:6),'uvp')
        selectprojet = 1;
    else
        disp(['Selected project ' project_folder ' is not correct. ']);
    end
end
% ------------- Liste des bases --------------------
results_dir = [project_folder,'\results\'];
if isfolder(results_dir)
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
    disp(['Process cannot continue : no reference base in ',results_dir]);
end
% ------------------ Chargement de la base de référence -----------------
disp('------------------------------------------------------');
base_selected = 1;
if size(base_list,1) > 1
    base_selected = input('Enter number corresponding to selected uvp database. (default = 2) ');
    if isempty(base_selected); base_selected = 2;   end
end

% ---------------- Chargement de la base choisie ------------------
load([results_dir,base_list(base_selected).name]);
% try statement in order to deal with old and new base name syntaxe
try
    base = eval(base_list(base_selected).name(1:end-4));
catch
    base = base;
end
ligne_ref = size(base,2);


disp('---------------------------------------------------------------')
if (strcmp(project_folder(4:7),'uvp5'))
    %% casts selection for uvp5
    disp('uvp5 base selected')
    % ---------------- Sélection des casts ------------------------------------
    % --------- print casts -------------------------------------
    for i = 1 : ligne_ref
        if ~isempty(base(i).histopx)
            disp(['Number : ',num2str(i),'   >  Profile : ',char(base(i).profilename)]);
        else
            disp(['Number : ',num2str(i),'   >  Profile : ',char(base(i).profilename),' is empty.']);
        end
    end
    samples_nb = [];
    cast_nb_max = 0;
    other_cast = 'y';
    while other_cast == 'y'
        cast_nb_max = cast_nb_max + 1 ;
        
        % --------- On lit tous les sample de la base un par un -----------
        sample = input('Enter the number of the cast (default = 1) ');
        if isempty(sample); sample = 1;end
        
        samples_nb = [samples_nb; sample];
        
        % ask for other casts
        other_cast = input('Add other casts ? ([y]/n) ','s');
        if isempty(other_cast);other_cast = 'y';end
        
    end
    disp(['number of selected casts : ', num2str(cast_nb_max)])
    disp('---------------------------------------------------------------')
    if cast_nb_max == 1
        disp('--------  ERROR : only one cast has been selected -------')
        disp('------- Process Aborted -------')
        return
    end
    uvp = char(base(samples_nb(1)).pvmtype);
    ee = uvp == '_';
    uvp(ee) = '-';
    
    %% HISTOPX sum for uvp5
    base_size = length(base);
    base(base_size+1) = base(samples_nb(1));
    bru0 = base(samples_nb(1)).bru0{1};
    profilename = ['sum_',char(base(samples_nb(1)).profilename{1})];
    histopx_sum = base(samples_nb(1)).histopx;
    histopx_sum(:,2) = histopx_sum(:,2).*histopx_sum(:,4);
    histopx_sum(:,5:end) = histopx_sum(:,5:end);
    for j = 2 : cast_nb_max
        profilename = [profilename ,'_', char(base(samples_nb(j)).profilename{1})];
        bru0 = [bru0 ,'_', base(samples_nb(j)).bru0{1}];
        histopx_to_add = base(samples_nb(j)).histopx;
        [histopx_sum, histopx_to_add, ~] = CalibrationUvpComputeDepthRange(histopx_sum, histopx_to_add);
        histopx_sum(:,5:end) = histopx_sum(:,5:end) + histopx_to_add(:,5:end);
        histopx_sum(:,2) = histopx_sum(:,2) + histopx_to_add(:,2).*histopx_to_add(:,4);
        histopx_sum(:,3:4) = histopx_sum(:,3:4) + histopx_to_add(:,3:4);
    end
    histopx_sum(:,2) = histopx_sum(:,2) ./ histopx_sum(:,4);
    histopx_sum(:,5:end) = histopx_sum(:,5:end);
    base(base_size+1).histopx = histopx_sum;
    base(base_size+1).bru0 = {bru0};
    base(base_size+1).profilename = {profilename};
    base(base_size+1).histnb = [];
    base(base_size+1).histnbred = [];
    base(base_size+1).histbv =[];
    base(base_size+1).histbvred = [];
    base(base_size+1).profile = base_size+1;
else
    %% casts selection for uvp6
    disp('uvp6 base selected')
    % ---------------- Sélection des casts ------------------------------------
    % --------- print casts -------------------------------------
    for i = 1 : ligne_ref
        disp(['Number : ',num2str(i),'   >  Profile : ',char(base(i).profilename)]);
    end
    samples_nb = [];
    cast_nb_max = 0;
    other_cast = 'y';
    
    disp('--------------------------------------------------------------------------------')
    disp('Select a minimum of 2 sets of same thresholds ranges from 2 different profiles')
    disp('--------------------------------------------------------------------------------')
    while other_cast == 'y'
        cast_nb_max = cast_nb_max + 1 ;
        
        % --------- On lit tous les sample de la base un par un -----------
        thres_first = input('Enter the number of the FIRST threshold of a profile (default = 1) ');
        thres_last =  input('Enter the number of the LAST threshold of the same profile (default = last) ');
        if isempty(thres_first); thres_first = 1;end
        if isempty(thres_last); thres_last = numel(base); end
        
        samples_nb = [samples_nb; [thres_first, thres_last]];
        
        % ask for other casts
        other_cast = input('Add other casts ? ([y]/n) ','s');
        if isempty(other_cast);other_cast = 'y';end
        
    end

    if numel(samples_nb) == 1
        disp('--------  ERROR : only one cast has been selected -------')
        disp('--------  Process Aborted -------------------------------')
        return
    end
    
    % check cast selection
    threshold_nb = samples_nb(1,2) - samples_nb(1,1) +1;
    different_thresholds = samples_nb(:,2) - samples_nb(:,1) + 1 - threshold_nb;
    if any(different_thresholds)
        disp('--------  ERROR : different casts have different number of samples -------')
        disp('--------  Process Aborted ------------------------------------------------')
        return
    end
    
    disp('---------------------------------------------------------------')
    disp(['Number of selected thresholds : ', num2str(threshold_nb)])
    disp(['Number of selected casts : ', num2str(cast_nb_max)])
    disp('---------------------------------------------------------------')
    
    uvp = char(base(samples_nb(1)).pvmtype);
    ee = uvp == '_';
    uvp(ee) = '-';
    
    %% HISTOPX sum for uvp6
    % for uvp6
    base_size = length(base);
    for i = 1 : threshold_nb
        base(base_size+i) = base(samples_nb(1)+i-1);
        threshold = base(samples_nb(1)+i-1).threshold;
        raw_folder = base(samples_nb(1)+i-1).raw_folder{1};
        profilename = ['sum_',char(base(samples_nb(1)+i-1).profilename{1}(17:end))];
        histopx_sum = base(samples_nb(1)+i-1).histopx;
        histopx_sum(:,2) = histopx_sum(:,2).*histopx_sum(:,4);
        histopx_sum(:,5:end) = histopx_sum(:,5:end);
        for j = 2 : cast_nb_max
            if base(samples_nb(j)+i-1).threshold ~= threshold
                disp('--------  ERROR : different samples have different treshold -------')
                disp('------- Process Aborted -------')
                return
            end
            raw_folder = [raw_folder ,'_', base(samples_nb(j)+i-1).raw_folder{1}];
            profilename = [profilename ,'_', char(base(samples_nb(j)+i-1).profilename{1}(17:end))];
            histopx_to_add = base(samples_nb(j)+i-1).histopx;
            [histopx_sum, histopx_to_add, ~] = CalibrationUvpComputeDepthRange(histopx_sum, histopx_to_add);
            histopx_sum(:,5:end) = histopx_sum(:,5:end) + histopx_to_add(:,5:end);
            histopx_sum(:,2) = histopx_sum(:,2) + histopx_to_add(:,2).*histopx_to_add(:,4);
            histopx_sum(:,3:4) = histopx_sum(:,3:4) + histopx_to_add(:,3:4);
        end
        histopx_sum(:,2) = histopx_sum(:,2) ./ histopx_sum(:,4);
        histopx_sum(:,5:end) = histopx_sum(:,5:end);
        base(base_size+i).histopx = histopx_sum;
        base(base_size+i).raw_folder = {raw_folder};
        base(base_size+i).profilename = {profilename};
        base(base_size+i).raw_histopx = [];
        base(base_size+i).raw_black = [];
        base(base_size+i).histnb = [];
        base(base_size+i).histnbred = [];
        base(base_size+i).histbv =[];
        base(base_size+i).histbvred = [];
    end
end

%% SAVE IN BASE
check = input('Are you OK to save the new database (y/n) ? ','s');
if isempty(check); check = 'y';end

if check == 'y'
    % ---------- Type d'UVP ----------------
    if strcmp(results_dir(7),'5')
        basename = base_list(base_selected).name(1:end-4);
        eval([basename '= base;']);
        eval(['save ',results_dir,base_list(base_selected).name,' ',basename]);
    else
        save([results_dir,base_list(base_selected).name] , 'base')
    end
    disp('---------------------------------------------------------------')
    disp('------------- DATABASE saved : END of Process -----------------')
    disp('---------------------------------------------------------------')
else
    disp('---------------------------------------------------------------')
    disp('------------- DATABASE NOT saved : END of Process -------------')
    disp('---------------------------------------------------------------')
end

