%% PLOT spectres PIXELS de multiples UVP6-5
% Lombard -Picheral, 2016/02, 2019/08
% Compatible UVP5 et UVP6

% Ce code permet de visualiser les spectres de différents UVP5-6 sur un
% même graphe. Ce graphe est enregistré dans le répertoire RESULTS du
% projet de référence (le premier choisi).
% Ajout figure FIT et comparaison chiffree
% Automatisation intercalibrage


clear all
close all
warning('OFF')
scrsz = get(0,'ScreenSize');


disp('------------------------------------------------------')
disp('--------------- START PROCESS ------------------------')
disp('------------------------------------------------------')
disp('------------------- OPTIONS --------------------------')
% plot type
type_plot = input('Select plot type (raw/calibrated) (default = r) ','s');
if isempty(type_plot)
    type_plot = 'r';
end

% ESD range for fit and score
esd_min = input('Min ESD [mm] (default = 0.40) ? ');
if isempty(esd_min); esd_min = 0.40; end
esd_max = input('Max ESD [mm] (default = 0.8) ? ');
if isempty(esd_max); esd_max = 0.8; end

% depth range
zmin = input('Min depth for all profiles (default = 40) ? ');
if isempty(zmin);zmin = 40; end
zmax = input('Max depth for all profiles (default = max) ? ');
if isempty(zmax);zmax = 100000; end

% polynomial degree
Fit_data = input(['Enter poly fit level for data [3-6] (default = 3) ']);
if isempty(Fit_data);      Fit_data=3;  end
fit_type = ['poly', num2str(Fit_data)];

% profile selection option
disp('SELECT OPTION')
disp(' 1 : all flexible')
disp(' 2 : a unique reference and all profiles from same project ')
type_selection = input('Option (default = 2) ');
if isempty(type_selection);type_selection = 2;end

disp('------------------------------------------------------');
% ----------------------- Creation de la figure ---------------------------
color = 'rgbykygbckygbckyrgbykygbckygbckyrgbykygbckygbckyrgbykygbckygbcky';
legende = {};
fig5 = figure('numbertitle','off','name','UVP_spectres_pixels','Position',[10 50 1000 700]);

%% ------------- Selection du projet de REFERENCE -------------
base_ref_list = [];
project_folder_ref_list = [];
uvp_ref_title = [];
y_ref_list = [];
data_table = [];
data_name = {};
index_plot = 1;
nb_of_ref = 0;
another_ref = 'y';
while another_ref == 'y'
    nb_of_ref = nb_of_ref +1;
    selectprojet = 0;
    while (selectprojet == 0)
        disp('>> Select UVP REFERENCE project directory');
        project_folder_ref = uigetdir('', 'Select UVP REFERENCE project directory');
        project_folder_ref_list = [project_folder_ref_list; project_folder_ref];
        if strcmp(project_folder_ref(4:6),'uvp')
            selectprojet = 1;
        else
            disp(['Selected project ' project_folder_ref ' is not correct. It must be on the root of a drive.']);
        end
    end
    cd(project_folder_ref);

    % ------------- Liste des bases --------------------
    results_dir_ref = [project_folder_ref,'\results\'];
    if isfolder(results_dir_ref)
        base_list = dir([results_dir_ref, 'base*.mat']);
        if ~isempty(base_list)
            disp('----------- Base list --------------------------------');
            disp([num2str(size(base_list,1)),' database in ', results_dir_ref]);
            for i = 1:size(base_list)
                disp(['N°= ',num2str(i),' : ',base_list(i).name]);
            end
        else
            disp(['No database in ',results_dir_ref]);
            return
        end
    else
        disp(['Process cannot continue : no reference base in ',results_dir_ref]);
        return
    end

    % ------------------ Chargement de la base de référence -----------------
    disp('------------------------------------------------------');
    base_selected = 1;
    if i > 1
        base_selected = input('Enter number corresponding to selected uvp database. (default = 1) ');
        if isempty(base_selected); base_selected = 1;   end
    end

    % ---------------- Chargement de la base choisie ------------------
    load([results_dir_ref,base_list(base_selected).name]);
    % try statement in order to deal with old and new base name syntaxe
    try
        base_ref = eval(base_list(base_selected).name(1:end-4));
    catch
        base_ref = base;
    end
    ligne_ref = size(base_ref,2);
    for i = 1 : ligne_ref
        disp(['Number : ',num2str(i),'   >  Profile : ',char(base_ref(i).profilename)]);
    end
    rec_ref = input('Enter Number of the profile for the reference UVP (default = 1) ');
    if isempty(rec_ref); rec_ref = 1; end
    
    base_ref_list = [base_ref_list, base_ref(rec_ref)];
    % ask for another reference
    disp('It is possible to add another reference cast')
    disp('The adjusted cast will be compared to the mean of the reference casts')
    disp('ATTENTION ! : seulement pour uvp6')
    another_ref = input('Add another REFERENCE PROFILE ? ([n]/y) ','s');
    if isempty(another_ref);another_ref = 'n';end
end

% patch for taking into account multiple calib ref (TO BE REFACTORED)
if nb_of_ref >1 && type_plot == 'c'
    camsm_ref_list = [];
    camsm_ref_sum = [];
    refsum_log_list = [];
    refsum_log_sum = [];
    aa_ref_list = [];
    expo_ref_list = [];
    for ref_nb = 1:length(base_ref_list)
    %% ref base histopx and configuration
        base_ref = base_ref_list(ref_nb);
        project_folder_ref = project_folder_ref_list(ref_nb,:);
        % Reading uvp5_configuration_data.txt REF
        if (strcmp(project_folder_ref(4:7),'uvp5'))
            filename=[project_folder_ref,'\config\uvp5_settings\uvp5_configuration_data.txt'];
            [ aa_ref_from_base, expo_ref_from_base, img_vol_data_ref, pix_ref, light1_ref, light2_ref] = read_uvp5_configuration_data( filename ,'data' );
        else
            aa_ref_from_base = base_ref.a0/1000000;
            expo_ref_from_base = base_ref.exp0;
            img_vol_data_ref = base_ref.volimg0;
            pix_ref = base_ref.pixel_size;
        end
        % Reading *.hdr REF
        if (strcmp(project_folder_ref(4:7),'uvp5'))
            filename=[project_folder_ref,'\raw\HDR',char(base_ref.histfile),'\HDR',...
                char(base_ref.histfile),'.hdr'];
            [ a, b, c, d, l1, l2, gain_ref, Thres_ref, Exposure_ref, ShutterSpeed_ref, SMBase_ref] = ...
                read_uvp5_configuration_data( filename , 'hdr');
        else
            gain_ref = base_ref.gain;
            Thres_ref = base_ref.threshold;
            Exposure_ref = base_ref.shutter;
            ShutterSpeed_ref = base_ref.shutter;
            SMBase_ref    = 1;
        end


        %% ref data preparation
        uvp_ref = char(base_ref.pvmtype);
        ee = find(uvp_ref == '_');
        uvp_ref(ee) = '-';
        uvp_ref_title = [uvp_ref_title, uvp_ref];

        txt_ref = [char(uvp_ref),' : ',char(base_ref.profilename),' (ref)'];
        aa = txt_ref == '_';
        txt_ref(aa) = ' ';

        % --------------------- REFERENCE ----------------------
        if isfield(base_ref,'histopx')
            aa = find(base_ref.histopx(:,2) >= zmin & base_ref.histopx(:,2) <= zmax);
            refpix=base_ref.histopx(aa,5:end);
            nombreimages=base_ref.histopx(aa,4);
        elseif isfield(base_ref,'data_nb')
            aa = find(base_ref.data_nb(:,2) >= zmin & base_ref.data_nb(:,2) <= zmax);
            refpix=base_ref.data_nb(aa,5:end);
            nombreimages=base_ref.data_nb(aa,3);
        end
        refpix_raw = refpix;
        refpix = refpix./(pix_ref^2);
        volumeimage=base_ref.volimg0;
        % depth=baseref(profilref).hisnb(:,1);
        volumeechref=volumeimage*nombreimages;
        volumeechref=volumeechref*ones(1,size(refpix,2));
        refs=refpix./volumeechref;

        % custom ref calibration parameters
        disp(['Calibration parameters for ', project_folder_ref])
        aa_ref = input(['REF aa (default = from base = ', num2str(aa_ref_from_base*1000000), ') ']) / 1000000;
        if isempty(aa_ref); aa_ref = aa_ref_from_base; end
        expo_ref = input(['REF expo (default = from base = ', num2str(expo_ref_from_base), ') ']);
        if isempty(expo_ref); expo_ref = expo_ref_from_base; end

        % -------- max size where <30 object counts ---------------------------
        aa = find( sum(refpix_raw,1) <= 30);
        i_size_limit = aa(1);

        pixsize= [1:size(refpix,2)];
        tailleref=2*((aa_ref*(pixsize.^expo_ref)./pi).^0.5);
        newsize=tailleref;
        camsm_ref = 2*((aa_ref*(pixsize.^expo_ref)./pi).^0.5);

        % --------- Selection gamme de taille REF -----------------------
        aa = find(camsm_ref <= esd_min);
        bb = find(camsm_ref <= esd_max);
        if isempty(aa)
            deb_x = 1;
        else
            deb_x = aa(end);
        end
        if isempty(bb)
            end_x = size(camsm_ref,2);
        else
            end_x = bb(end);
        end

        refsum=nanmean(refs);
        refsum_log = log(refsum);
        
        camsm_ref_list = [camsm_ref_list; camsm_ref];
        camsm_ref_sum = [camsm_ref_sum, camsm_ref(deb_x:end_x)];
        refsum_log_list = [refsum_log_list; refsum_log];
        refsum_log_sum = [refsum_log_sum, refsum_log(deb_x:end_x)]; 
        aa_ref_list = [aa_ref_list, aa_ref];
        expo_ref_list = [expo_ref_list, expo_ref];
    end
    
    % -------- FIT sur données REF ------------------------------
    [fitresult] = create_two_fits(camsm_ref_sum, refsum_log_sum, fit_type, 0, camsm_ref_sum, refsum_log_sum, fit_type);
    x_ref = [esd_min:0.01:esd_max];
    [y_ref] = poly_from_fit(x_ref,fitresult,fit_type);

    % -------------------------- Table données synthétiques ---------
    data_table(index_plot,:) = [0 0 0 img_vol_data_ref pix_ref gain_ref Thres_ref Exposure_ref ShutterSpeed_ref SMBase_ref 1 camsm_ref(i_size_limit)];
    data_name(index_plot) = {'mean_ref'};
    data_list = {'profilename' 'score' 'aa' 'exp' 'img_vol' 'pixel' 'gain' 'threshold' 'exposure' 'shutter' 'smbase' 'ratio' 'stat size limit'};

else
    %% ref base histopx and configuration
    if nb_of_ref > 1
        base_ref = Uvp6MeanInstruRawBases(base_ref_list);
        aa_ref_from_base = base_ref.a0/1000000;
        expo_ref_from_base = base_ref.exp0;
        img_vol_data_ref = base_ref.volimg0;
        pix_ref = base_ref.pixel_size;
        gain_ref = base_ref.gain;
        Thres_ref = base_ref.threshold;
        Exposure_ref = base_ref.shutter;
        ShutterSpeed_ref = base_ref.shutter;
        SMBase_ref    = 1;
    else
        base_ref = base_ref(rec_ref);
        % Reading uvp5_configuration_data.txt REF
        if (strcmp(project_folder_ref(4:7),'uvp5'))
            filename=[project_folder_ref,'\config\uvp5_settings\uvp5_configuration_data.txt'];
            [ aa_ref_from_base, expo_ref_from_base, img_vol_data_ref, pix_ref, light1_ref, light2_ref] = read_uvp5_configuration_data( filename ,'data' );
        else
            aa_ref_from_base = base_ref.a0/1000000;
            expo_ref_from_base = base_ref.exp0;
            img_vol_data_ref = base_ref.volimg0;
            pix_ref = base_ref.pixel_size;
        end
        % Reading *.hdr REF
        if (strcmp(project_folder_ref(4:7),'uvp5'))
            filename=[project_folder_ref,'\raw\HDR',char(base_ref.histfile),'\HDR',...
                char(base_ref.histfile),'.hdr'];
            [ a, b, c, d, l1, l2, gain_ref, Thres_ref, Exposure_ref, ShutterSpeed_ref, SMBase_ref] = ...
                read_uvp5_configuration_data( filename , 'hdr');
        else
            gain_ref = base_ref.gain;
            Thres_ref = base_ref.threshold;
            Exposure_ref = base_ref.shutter;
            ShutterSpeed_ref = base_ref.shutter;
            SMBase_ref    = 1;
        end
    end




    %% ref data preparation
    uvp_ref = char(base_ref.pvmtype);
    ee = find(uvp_ref == '_');
    uvp_ref(ee) = '-';
    uvp_ref_title = [uvp_ref_title, uvp_ref];

    txt_ref = [char(uvp_ref),' : ',char(base_ref.profilename),' (ref)'];
    aa = txt_ref == '_';
    txt_ref(aa) = ' ';

    % --------------------- REFERENCE ----------------------
    if isfield(base_ref,'histopx')
        aa = find(base_ref.histopx(:,2) >= zmin & base_ref.histopx(:,2) <= zmax);
        refpix=base_ref.histopx(aa,5:end);
        nombreimages=base_ref.histopx(aa,4);
    elseif isfield(base_ref,'data_nb')
        aa = find(base_ref.data_nb(:,2) >= zmin & base_ref.data_nb(:,2) <= zmax);
        refpix=base_ref.data_nb(aa,5:end);
        nombreimages=base_ref.data_nb(aa,3);
    end
    refpix_raw = refpix;
    refpix = refpix./(pix_ref^2);
    volumeimage=base_ref.volimg0;
    % depth=baseref(profilref).hisnb(:,1);
    volumeechref=volumeimage*nombreimages;
    volumeechref=volumeechref*ones(1,size(refpix,2));
    refs=refpix./volumeechref;

    % custom ref calibration parameters
    if type_plot == 'c'
        aa_ref = input(['REF aa (default = from base = ', num2str(aa_ref_from_base*1000000), ') ']) / 1000000;
        if isempty(aa_ref); aa_ref = aa_ref_from_base; end
        expo_ref = input(['REF expo (default = from base = ', num2str(expo_ref_from_base), ') ']);
        if isempty(expo_ref); expo_ref = expo_ref_from_base; end
    else
        aa_ref = aa_ref_from_base;
        expo_ref = expo_ref_from_base;
    end

    % -------- max size where <30 object counts ---------------------------
    aa = find( sum(refpix_raw,1) <= 30);
    i_size_limit = aa(1);

    pixsize= [1:size(refpix,2)];
    tailleref=2*((aa_ref*(pixsize.^expo_ref)./pi).^0.5);
    newsize=tailleref;
    if type_plot == 'c'
        camsm_ref = 2*((aa_ref*(pixsize.^expo_ref)./pi).^0.5);
    else
        camsm_ref = 2*(((pix_ref^2)*(pixsize)./pi).^0.5);
    end

    % --------- Selection gamme de taille REF -----------------------
    aa = find(camsm_ref <= esd_min);
    bb = find(camsm_ref <= esd_max);
    if isempty(aa)
        deb_x = 1;
    else
        deb_x = aa(end);
    end
    if isempty(bb)
        end_x = size(camsm_ref,2);
    else
        end_x = bb(end);
    end

    refsum=nanmean(refs);
    refsum_log = log(refsum);

    % -------- FIT sur données REF ------------------------------
    [fitresult] = create_two_fits(camsm_ref(deb_x:end_x),(refsum_log(deb_x:end_x)),fit_type,0,camsm_ref(deb_x:end_x),(refsum_log(deb_x:end_x)),fit_type);
    x_ref = [esd_min:0.01:esd_max];
    [y_ref] = poly_from_fit(x_ref,fitresult,fit_type);

    % -------------------------- Table données synthétiques ---------
    data_table(index_plot,:) = [0 aa_ref*1000000 expo_ref img_vol_data_ref pix_ref gain_ref Thres_ref Exposure_ref ShutterSpeed_ref SMBase_ref 1 camsm_ref(i_size_limit)];
    data_name(index_plot) = {txt_ref};
    data_list = {'profilename' 'score' 'aa' 'exp' 'img_vol' 'pixel' 'gain' 'threshold' 'exposure' 'shutter' 'smbase' 'ratio' 'stat_size_limit'};
end


%% -------------------------- Boucle sur les projets à ajouter ------------

select_adj = 1;
adj_record = 0;
adj_first = 0;
other_cast = 1;
while other_cast == 1
    
    if select_adj == 1
        %% ------------------ Choix du projet UVP à ajuster ----------------------
        disp('------------------------------------------------------');
        disp('UVP to adjust');
        disp('>> Select the ''uvp'' root folder containing profiles(s) of UVP to add');
        selectprojet = 0;
        while (selectprojet == 0)
            project_folder_adj = uigetdir('', 'Select UVP project directory');
            if strcmp(project_folder_adj(4:6),'uvp')
                selectprojet = 1;
            else
                disp(['Selected project ' project_folder_adj ' is not correct. It must be on the root of a drive.']);
                continue
            end
        end
        cd(project_folder_adj);
        % ------------- Liste des bases --------------------
        results_dir_adj = [project_folder_adj,'\results\'];
        if isfolder(results_dir_adj)
            base_list = dir([results_dir_adj, 'base*.mat']);
            base_nofile = isempty(base_list);
            if base_nofile == 0
                disp('----------- Base list --------------------------------');
                disp([num2str(size(base_list,1)),' database in ', results_dir_adj]);
                for gg = 1:size(base_list)
                    disp(['N°= ',num2str(gg),' : ',base_list(gg).name]);
                end
            else
                disp(['No database in ',results_dir_adj]);
                continue
            end
        else
            disp(['Process cannot continue : no base in ',results_dir_adj]);
            continue
        end
        % ------------------ Chargement de la base à ajuster -----------------
        disp('------------------------------------------------------');
        base_selected = 1;
        if gg > 1
            base_selected = input('Enter number corresponding to selected uvp database. (default = 1) ');
            if isempty(base_selected); base_selected = 1;   end
        end
        
        % ---------------- Chargement de la base choisie ------------------
        load([results_dir_adj,base_list(base_selected).name]);
        % try statement in order to deal with old and new base name syntaxe
        try
            base_adj = eval(base_list(base_selected).name(1:end-4));
        catch
            base_adj = base;
        end
        ligne_adj = size(base_adj,2);
        % ------------- List of profiles ---------------
        for k = 1 : ligne_adj
            disp(['Number : ',num2str(k),'   >  Profile : ',char(base_adj(k).profilename)]);
        end
        
        if type_selection == 1
            % --------- Selection de chaque profile --------------
            adj_record = input('Enter Number of the profile to be adjusted (default = 1) ');
            if isempty(adj_record); adj_record = 1; end
        else
            % --------- On lit tous les profile de la base un par un -----------
            adj_first = input('Enter the number of the FIRST profile to process (default = 1) ');
            adj_last =  input('Enter the number of the LAST profile to process (default = last) ');
            if isempty(adj_first); adj_first = 1;end
            if isempty(adj_last); adj_last = numel(base_adj); end
            adj_record = adj_first-1;
        end
    else
        % ---------- même projet que pour les autres profils
    end
    if type_selection == 2
        % ---------- incrément automatique ------------
        adj_record = adj_record + 1;
    end
    
    uvp_adj = char(base_adj(1).pvmtype);
    ee = find(uvp_adj == '_');
    uvp_adj(ee) = '-';
    
    %% Reading configuration
    if (strcmp(project_folder_adj(4:7),'uvp5'))
        % Reading uvp5_configuration_data.txt ADJ
        filename=[project_folder_adj,'\config\uvp5_settings\uvp5_configuration_data.txt'];
        [ aa_adj_from_base, expo_adj_from_base, img_vol_data_adj, pix_adj, light1_adj, light2_adj] = read_uvp5_configuration_data( filename , 'data');
    else
        aa_adj_from_base = base_adj(adj_record).a0/1000000;
        expo_adj_from_base = base_adj(adj_record).exp0;
        img_vol_data_adj = base_adj(adj_record).volimg0;
        pix_adj = base_adj(adj_record).pixel_size;
    end
    
    %% Reading instru conf
    if (strcmp(project_folder_adj(4:7),'uvp5'))
        % Reading *.hdr ADJ
        filename=[project_folder_adj,'\raw\HDR',char(base_adj(adj_record).histfile),'\HDR',...
            char(base_adj(adj_record).histfile),'.hdr'];
        [ a, b, c, d, l1, l2, gain_adj, Thres_adj, Exposure_adj, ShutterSpeed_adj, SMBase_adj] = ...
            read_uvp5_configuration_data( filename , 'hdr');
    else
        gain_adj = base_adj(adj_record).gain;
        Thres_adj = base_adj(adj_record).threshold;
        Exposure_adj = base_adj(adj_record).shutter;
        ShutterSpeed_adj = base_adj(adj_record).shutter;
        SMBase_adj    = 1;
    end
    if type_selection == 2
        % ----------- On ne demande plus le projet à ajuster -------
        select_adj = 0;
    end
    
    
    % ----- Nombre de profils --------- (ancienne boucle)
    rec_adj = adj_record; % + i -1;

    % ---------------------- AJUST --------------------------
    if isfield(base_adj,'histopx')
        aa = find(base_adj(rec_adj).histopx(:,2) >= zmin & base_adj(rec_adj).histopx(:,2) <= zmax);
        data=base_adj(rec_adj).histopx(aa,5:end);
        nombreimages=base_adj(rec_adj).histopx(aa,4);
    elseif isfield(base_adj,'data_nb')
        aa = find(base_adj(rec_adj).data_nb(:,2) >= zmin & base_adj(rec_adj).data_nb(:,2) <= zmax);
        data=base_adj(rec_adj).data_nb(aa,5:end);
        nombreimages=base_adj(rec_adj).data_nb(aa,3);
    end
    data_raw = data;
    data = data./(pix_adj^2);
    volumeimage=base_adj(rec_adj).volimg0;
    %     hisnb=baseadj(profildata).hisnb;
    volumeech=volumeimage*nombreimages;
    volumeech2=volumeech*ones(1,27);
    volumeech=volumeech*ones(1,size(refpix,2));
    nbre=data./volumeech;
    [n,m]=size(nbre);
    %refsum=sum(refs);
    nbsum=nanmean(nbre);
    nbsum_adj_log = log(nbsum);
    x = [esd_min:0.01:esd_max];

    % -------- max size where <30 object counts ---------------------------
    aa = find( sum(data_raw,1) <= 1);
    i_size_limit = aa(1);
    
    % custom ref calibration parameters
    if type_plot == 'c'
        aa_adj = input(['ADJ aa (default = from base = ', num2str(aa_adj_from_base*1000000), ') ']) / 1000000;
        if isempty(aa_adj); aa_adj = aa_adj_from_base; end
        expo_adj = input(['ADJ expo (default = from base = ', num2str(expo_adj_from_base), ') ']);
        if isempty(expo_adj); expo_adj = expo_adj_from_base; end
    else
        aa_adj = aa_adj_from_base;
        expo_adj = expo_adj_from_base;
    end
    
    % -------- Figure RAW data ----------------------------------
    %subplot(2,2,1)
    subplot(1,2,1)
    hold on
    if type_plot == 'c'
        camsm_adj = 2*((aa_adj*(pixsize.^expo_adj)./pi).^0.5);
    else
        camsm_adj = 2*(((pix_adj^2)*(pixsize)./pi).^0.5);
    end
    camsm_adj_log = log(camsm_adj);
    loglog(exp(camsm_adj_log),exp(nbsum_adj_log),[color(index_plot+1),'+']);

    % --------- Selection gamme de taille ADJ -----------------------
    aa = find(camsm_adj <= esd_min);
    bb = find(camsm_adj <= esd_max);
    if isempty(aa)
        deb_x = 1;
    else
        deb_x = aa(end);
    end
    if isempty(bb)
        end_x = size(camsm_adj,2);
    else
        end_x = bb(end);
    end

    % -------- FIT sur données RAW ------------------------------
    [fitresult] = create_two_fits(camsm_adj(deb_x:end_x),(nbsum_adj_log(deb_x:end_x)),fit_type,0,camsm_adj(deb_x:end_x),(nbsum_adj_log(deb_x:end_x)),fit_type);
    [y] = poly_from_fit(x,fitresult,fit_type);

    % -------------- Pour calcul Score final -----------------------------
    [y_adj] = poly_from_fit(x_ref,fitresult,fit_type);
    Score = data_similarity_score(exp(y_adj), exp(y_ref));
    
    % -------- Figure FIT ADJ -------------------------------------
    %subplot(2,2,2)
    subplot(1,2,2)
    hold on
    loglog(x,exp(y),[color(index_plot+1),'-']);

    % -------- Figure RATIO --------------------------------------
    %subplot(2,2,3)
%     subplot(1,3,3)
%     %         semilogx(x,(y_ref-y)./y_ref,[color(index_plot),'-']);
%     hold on
%     semilogx(x,y./y_ref,[color(index_plot+1),'-']);
    
    txt = [char(uvp_adj),' : ',char(base_adj(adj_record).profilename)];
    aa = txt == '_';
    txt(aa) = ' ';
    legende(index_plot) = {txt};    %{char(uvp_adj)};
    
    % -------------------------- Table données synthétiques ---------
    data_table(index_plot+1,:) = [Score aa_adj*1000000 expo_adj img_vol_data_adj pix_adj gain_adj Thres_adj Exposure_adj ShutterSpeed_adj SMBase_adj nanmean(y./y_ref), camsm_adj(i_size_limit)];
    data_name(index_plot+1) = {txt};
    
    if type_selection == 1
        % -------------------------- CONTINUE ???? ----------
        other_cast = input('Add another ADJUSTED PROFILE (1/0) ? ');
        if isempty(other_cast); other_cast = 1;end
    else
        % ----------- Fin automatique -----------------------
        if adj_record == adj_last
            other_cast = 0;
        end
    end
    index_plot = index_plot + 1;
end

%% ------------- Mise en forme finale RAW -----------------
%subplot(2,2,1)
subplot(1,2,1)
% plot ref
%for i=1:length(camsm_ref_list_log)
%    loglog(exp(camsm_ref_list_log(i)),exp(refsum_list_log(i)),[color(1),'o']);
%end
if nb_of_ref >1 && type_plot == 'c'
    ref_plot = loglog(camsm_ref_list, exp(refsum_log_list), [color(1), 'o']);
    uistack(ref_plot, 'bottom');
else
    loglog(camsm_ref, refsum, [color(1), 'o']);
end
if nb_of_ref == 1
    legende(index_plot) = {txt_ref};
else
    legende(index_plot) = {'refs mean'};
end
if type_plot == 'c'
    xlabel('ADJUSTED ESD [mm]','fontsize',12);
else
    xlabel('RAW ESD [mm]','fontsize',12);
end
ylabel('ABUNDANCE [#/L/mm²]','fontsize',12);
% legend(legende);
% axis([0.01 5 0.0001 1000]);
axis([0.05 4 0.001 1000000]);
% axis([0.05 3 0.0000001 100]);
set(gca,'xscale','log');
set(gca,'yscale','log');
orient tall
texte = project_folder_ref(4:end);
aa = find(texte == '_');
texte(aa) = ' ';

% textbox with the refs projects and aa and exp
if nb_of_ref == 1
    if type_plot == 'c'
        str =  {['aa ref : ' num2str(aa_ref*1000000)],['expo ref : ' num2str(expo_ref)],['aa adj : ' num2str(aa_adj*1000000)],['expo adj : ' num2str(expo_adj)]};
        annotation('textbox',[.6 .6 .3 .3],'String',str,'FitBoxToText','on');
    end
    title(['Normalized SPECTRA (ref : ',texte,')'],'fontsize',10);
else
    if type_plot == 'c'
        %str = {};
        %for ref_nb = 1:length(base_ref_list)
        %    str =  {str, ['aa ref : ' num2str(aa_ref_list(ref_nb)*1000000)],['expo ref : ' num2str(expo_ref_list(ref_nb))]};
        %end
        %str = {str, ['aa adj : ' num2str(aa_adj*1000000)],['expo adj : ' num2str(expo_adj)]};
        str =  {['aa ref : ' num2str(aa_ref_list*1000000)],['expo ref : ' num2str(expo_ref_list)],['aa adj : ' num2str(aa_adj*1000000)],['expo adj : ' num2str(expo_adj)]};
        annotation('textbox',[.6 .6 .3 .3],'String',str,'FitBoxToText','on');
    end
    title('Normalized SPECTRA','fontsize',10);
    str = string(project_folder_ref_list);
    annotation('textbox',[.1 .6 .3 .3],'String',str,'FitBoxToText','on');
end

%% ------------- Mise en forme finale FIT -----------------
%subplot(2,2,2)
subplot(1,2,2)
% plot ref
loglog(x_ref,exp(y_ref),[color(1),'-'], 'LineWidth', 1);
if type_plot == 'c'
    xlabel('ADJUSTED ESD [mm]','fontsize',12);
else
    xlabel('RAW ESD [mm]','fontsize',12);
end
ylabel('ABUNDANCE [#/L/mm²]','fontsize',12);
legend(legende,'Location','southwest')
% axis([0.01 5 0.0001 1000]);
% axis([0.05 2 0.01 10000000]);
axis([0.05 4 0.001 1000000]);
% axis([0.05 3 0.0000001 100]);
set(gca,'xscale','log');
set(gca,'yscale','log');
title(['FIT (',char(fit_type),') on selected data [',num2str(esd_min),' - ',num2str(esd_max),'mm]'],'fontsize',10);

%% ------------- Mise en forme finale RATIO -----------------
%subplot(2,2,3)
% subplot(1,3,3)
% % plot ref
% plot(x_ref,ones(numel(x_ref),1),[color(1),'-']);
% if type_plot == 'c'
%     xlabel('ADJUSTED ESD [mm]','fontsize',12);
% else
%     xlabel('RAW ESD [mm]','fontsize',12);
% end
% ylabel('RATIO','fontsize',12);
% legend(legende,'Location','best');
% % axis([0.05 2 0.5 2]);
% axis([0.1 1 0.5 2]);
% set(gca,'xscale','log');
% % set(gca,'yscale','log');
% title('Ratio of fit / reference','fontsize',10);

%% --------------- PLOT Ratio/shutter ----------------
% data_list = {'profilename' 'aa' 'exp' 'img_vol' 'pixel' 'gain' 'threshold' 'exposure' 'shutter' 'smbase' 'ratio'};
% subplot(2,2,4)
% for i = 2:size(data_table,1)
%     hold on
%     plot(data_table(i,8),data_table(i,11),[color(i),'o']);
% end
% ylabel('RATIO (mean)','fontsize',12);
% xlabel('SHUTTER','fontsize',12);
% % axis([0.05 2 -2 2]);
% % set(gca,'xscale','log');
% title('Mean ratio / shutter','fontsize',10);

% -------------- Enregistrement figure ---------------
disp('------------------------------------------------------')
orient tall
titre = [char(uvp_ref_title),'_',char(uvp_adj),'_',char(base_ref.profilename)];
titre_file = input(['Input filename (default = ',titre,') '],'s');
if isempty(titre_file);titre_file = titre;end
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[results_dir_ref,'\',char(titre_file)]);
savefig([results_dir_ref,'\',char(titre_file)]);
disp('-------------- Figure saved -------------------------- ');

%% -------------- TABLE --------------------------------
T = array2table(data_table,'VariableNames',data_list(2:end));
T.profilename = data_name';
writetable(T,[results_dir_ref,'\',char(titre_file),'.txt']);
T

disp('--------------- Table saved -------------------------- ');
disp('------------------ END ------------------------------- ');