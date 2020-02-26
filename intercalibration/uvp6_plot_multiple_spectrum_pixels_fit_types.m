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
index_plot = 1;
data_table = [];
data_name = {};


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
esd_max = input('Max ESD [mm] (default = 1.0) ? ');
if isempty(esd_max); esd_max = 1.0; end

% depth range
zmin = input('Min depth for all profiles (default = 40) ? ');
if isempty(zmin);zmin = 40; end
zmax = input('Max depth for all profiles (default = max) ? ');
if isempty(zmax);zmax = 100000; end

% polynomial degree
Fit_data = input(['Enter poly fit level for data [3-6] (default = 3) ']);
if isempty(Fit_data);      Fit_data=3;  end
fit_type = ['poly', num2str(Fit_data)];

% sample selection option
disp('SELECT OPTION')
disp(' 1 : all flexible')
disp(' 2 : a unique reference and all samples from same project ')
type_selection = input('Option (default = 2) ');
if isempty(type_selection);type_selection = 2;end

disp('------------------------------------------------------');

%% ------------- Selection du projet de REFERENCE -------------
selectprojet = 0;
while (selectprojet == 0)
    disp('>> Select UVP REFERENCE project directory');
    project_folder_ref = uigetdir('', 'Select UVP REFERENCE project directory');
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
base_ref = eval(base_list(base_selected).name(1:end-4));
ligne_ref = size(base_ref,2);
for i = 1 : ligne_ref
    disp(['Number : ',num2str(i),'   >  Profile : ',char(base_ref(i).profilename)]);
end
rec_ref = input('Enter Number of the profile for the reference UVP (default = 1) ');
if isempty(rec_ref); rec_ref = 1; end


%% Reading uvp5_configuration_data.txt REF
if (strcmp(project_folder_ref(4:7),'uvp5'))
    filename=[project_folder_ref,'\config\uvp5_settings\uvp5_configuration_data.txt'];
    [ aa_data_ref, expo_data_ref, img_vol_data_ref, pix_ref, light1_ref, light2_ref] = read_uvp5_configuration_data( filename ,'data' );
else
    aa_data_ref = base_ref(rec_ref).a0/1000000;
    expo_data_ref = base_ref(rec_ref).exp0;
    img_vol_data_ref = base_ref(rec_ref).volimg0;
    pix_ref = base_ref(rec_ref).pixel_size;
end

%% Reading *.hdr REF
if (strcmp(project_folder_ref(4:7),'uvp5'))
    filename=[project_folder_ref,'\raw\HDR',char(base_ref(rec_ref).histfile),'\HDR',...
        char(base_ref(rec_ref).histfile),'.hdr'];
    [ a, b, c, d, l1, l2, gain_ref, Thres_ref, Exposure_ref, ShutterSpeed_ref, SMBase_ref] = ...
        read_uvp5_configuration_data( filename , 'hdr');
else
    gain_ref = base_ref(rec_ref).gain;
    Thres_ref = base_ref(rec_ref).threshold;
    Exposure_ref = base_ref(rec_ref).shutter;
    ShutterSpeed_ref = base_ref(rec_ref).shutter;
    SMBase_ref    = 1;
end

uvp_ref = char(base_ref(rec_ref).pvmtype);
ee = find(uvp_ref == '_');
uvp_ref(ee) = '-';

txt_ref = [char(uvp_ref),' : ',char(base_ref(rec_ref).profilename),' (ref)'];
aa = txt_ref == '_';
txt_ref(aa) = ' ';

% --------------------- REFERENCE ----------------------
if isfield(base_ref,'histopx')
    aa = find(base_ref(rec_ref).histopx(:,2) >= zmin & base_ref(rec_ref).histopx(:,2) <= zmax);
    refpix=base_ref(rec_ref).histopx(aa,5:end);
    nombreimages=base_ref(rec_ref).histopx(aa,3);
elseif isfield(base_ref,'data_nb')
    aa = find(base_ref(rec_ref).data_nb(:,2) >= zmin & base_ref(rec_ref).data_nb(:,2) <= zmax);
    refpix=base_ref(rec_ref).data_nb(:,5:end);
    nombreimages=base_ref(rec_ref).data_nb(:,3);
end
refpix = refpix./(pix_ref^2);
volumeimage=base_ref(rec_ref).volimg0;
aa_ref=base_ref(rec_ref).a0;
expo_ref=base_ref(rec_ref).exp0;
% depth=baseref(profilref).hisnb(:,1);
volumeechref=volumeimage*nombreimages;
volumeechref=volumeechref*ones(1,size(refpix,2));
refs=refpix./volumeechref;
pixsize= [1:size(refpix,2)];
tailleref=2*((aa_ref*(pixsize.^expo_ref)./pi).^0.5);
newsize=tailleref;
if type_plot == 'c'
    camsm_ref = 2*((aa_ref*(pixsize.^expo_ref)./pi).^0.5);
else
    camsm_ref = 2*(((pix_ref^2)*(pixsize)./pi).^0.5);
end

camsm_ref_log = log(camsm_ref);
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
[fitresult] = create_two_fits((camsm_ref(deb_x:end_x)),(refsum_log(deb_x:end_x)),fit_type,0,camsm_ref(deb_x:end_x),(refsum_log(deb_x:end_x)),fit_type);
x_ref = [esd_min:0.01:esd_max];
[y_ref] = poly_from_fit(x_ref,fitresult,fit_type);

%% -------------------------- Boucle sur les projets à ajouter ------------

% -------------------------- Table données synthétiques ---------
data_table(index_plot,:) = [0 aa_data_ref expo_data_ref img_vol_data_ref pix_ref gain_ref Thres_ref Exposure_ref ShutterSpeed_ref SMBase_ref 1];
data_name(index_plot) = {txt_ref};
data_list = {'profilename' 'score' 'aa' 'exp' 'img_vol' 'pixel' 'gain' 'threshold' 'exposure' 'shutter' 'smbase' 'ratio'};

% ----------------------- Creation de la figure ---------------------------
color = 'rgbykygbckygbckyrgbykygbckygbckyrgbykygbckygbckyrgbykygbckygbcky';
legende = {};
fig5 = figure('numbertitle','off','name','UVP_spectres_pixels','Position',[10 50 1000 1000]);
% % -------- Figure RAW -----------------------------
% subplot(2,2,1)
% loglog(exp(camsm_ref_log),exp(refsum_log),[color(index_plot),'o']);
% legende(1) = {txt_ref};
% 
% % -------- Figure FIT ---------------------------------------
% subplot(2,2,2)
% hold on
% loglog(x_ref,exp(y_ref),[color(index_plot),'-']);

% ---------Figure ratio -----------------
% subplot(2,2,3)
% plot(x_ref,ones(numel(x_ref),1),[color(index_plot),'-']);

% -------- Figure Ratio/shutter ----------------
subplot(2,2,4)
plot(data_table(index_plot,8),data_table(index_plot,11),[color(index_plot),'o']);

select_adj = 1;
adj_record = 0;
adj_first = 0;
other_cast = 1;
while other_cast == 1
    
    if select_adj == 1
        %% ------------------ Choix du projet UVP à ajuster ----------------------
        disp('------------------------------------------------------');
        disp('>> Select the ''uvp'' root folder containing samples(s) of UVP to add');
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
                for i = 1:size(base_list)
                    disp(['N°= ',num2str(i),' : ',base_list(i).name]);
                end
            else
                disp(['No database in ',results_dir_adj]);
                continue
            end
        else
            disp(['Process cannot continue : no reference base in ',results_dir_adj]);
            continue
        end
        % ------------------ Chargement de la base à ajuster -----------------
        disp('------------------------------------------------------');
        base_selected = 1;
        if i > 1
            base_selected = input('Enter number corresponding to selected uvp database. (default = 1) ');
            if isempty(base_selected); base_selected = 1;   end
        end
        
        % ---------------- Chargement de la base choisie ------------------
        load([results_dir_adj,base_list(base_selected).name]);
        base_adj = eval(base_list(base_selected).name(1:end-4));
        ligne_adj = size(base_adj,2);
        % ------------- List of samples ---------------
        for k = 1 : ligne_adj
            disp(['Number : ',num2str(k),'   >  Profile : ',char(base_adj(k).profilename)]);
        end
        
        if type_selection == 1
            % --------- Selection de chaque sample --------------
            adj_record = input('Enter Number of the profile to be adjusted (default = 1) ');
            if isempty(adj_record); adj_record = 1; end
        else
            % --------- On lit tous les sample de la base un par un -----------
            adj_first = input('Enter the number of the FIRST sample to process (default = 1) ');
            adj_last =  input('Enter the number of the LAST sample to process (default = last) ');
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
        [ aa_data_adj, expo_data_adj, img_vol_data_adj, pix_adj, light1_adj, light2_adj] = read_uvp5_configuration_data( filename , 'data');
    else
        aa_data_adj = base_adj(adj_record).a0/1000000;
        expo_data_adj = base_adj(adj_record).exp0;
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
    rec_adj = adj_record + i -1;

    % ---------------------- AJUST --------------------------
    if isfield(base_adj,'histopx')
        aa = find(base_adj(rec_adj).histopx(:,2) >= zmin & base_adj(rec_adj).histopx(:,2) <= zmax);
        data=base_adj(rec_adj).histopx(:,5:end);
        nombreimages=base_adj(rec_adj).histopx(:,3);
    elseif isfield(base_adj,'data_nb')
        aa = find(base_adj(rec_adj).data_nb(:,2) >= zmin & base_adj(rec_adj).data_nb(:,2) <= zmax);
        data=base_adj(rec_adj).data_nb(:,5:end);
        nombreimages=base_adj(rec_adj).data_nb(:,3);
    end
    data = data./(pix_adj^2);
    volumeimage=base_adj(rec_adj).volimg0;
    %     hisnb=baseadj(profildata).hisnb;
    volumeech=volumeimage*nombreimages;
    volumeech2=volumeech*ones(1,27);
    volumeech=volumeech*ones(1,size(refpix,2));
    aa_adj=base_adj(rec_adj).a0;
    expo_adj=base_adj(rec_adj).exp0;
    nbre=data./volumeech;
    [n,m]=size(nbre);
    %refsum=sum(refs);
    nbsum=nanmean(nbre);
    nbsum_adj_log = log(nbsum);
    x = [esd_min:0.01:esd_max];

    % -------- Figure RAW data ----------------------------------
    subplot(2,2,1)
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
        end_x = size(camsm_adj);
    else
        end_x = bb(end);
    end

    % -------- FIT sur données RAW ------------------------------
    [fitresult] = create_two_fits((camsm_adj(deb_x:end_x)),(nbsum_adj_log(deb_x:end_x)),fit_type,0,camsm_adj(deb_x:end_x),(nbsum_adj_log(deb_x:end_x)),fit_type);
    [y] = poly_from_fit(x,fitresult,fit_type);

    % -------------- Pour calcul Score final -----------------------------
    [y_adj] = poly_from_fit(x_ref,fitresult,fit_type);
    Score = data_similarity_score(exp(y_adj), exp(y_ref));
    
    % -------- Figure FIT ADJ -------------------------------------
    subplot(2,2,2)
    hold on
    loglog(x,exp(y),[color(index_plot+1),'-']);

    % -------- Figure RATIO --------------------------------------
    subplot(2,2,3)
    %         semilogx(x,(y_ref-y)./y_ref,[color(index_plot),'-']);
    hold on
    semilogx(x,y./y_ref,[color(index_plot+1),'-']);
    
    txt = [char(uvp_adj),' : ',char(base_adj(adj_record).profilename)];
    aa = txt == '_';
    txt(aa) = ' ';
    legende(index_plot) = {txt};    %{char(uvp_adj)};
    
    % -------------------------- Table données synthétiques ---------
    data_table(index_plot+1,:) = [Score aa_data_adj expo_data_adj img_vol_data_adj pix_adj gain_adj Thres_adj Exposure_adj ShutterSpeed_adj SMBase_adj nanmean(y./y_ref)];
    data_name(index_plot+1) = {txt};
    
    if type_selection == 1
        % -------------------------- CONTINUE ???? ----------
        other_cast = input('Add other scan (1/0) ? ');
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
subplot(2,2,1)
% plot ref
loglog(exp(camsm_ref_log),exp(refsum_log),[color(1),'o']);
legende(index_plot) = {txt_ref};
if type_plot == 'c'
    xlabel('ADJUSTED ESD [mm]','fontsize',12);
else
    xlabel('RAW ESD [mm]','fontsize',12);
end
ylabel('ABUNDANCE [#/L/mm²]','fontsize',12);
% legend(legende);
% axis([0.01 5 0.0001 1000]);
axis([0.05 2 0.01 10000000]);
% axis([0.05 3 0.0000001 100]);
set(gca,'xscale','log');
set(gca,'yscale','log');
orient tall
texte = project_folder_ref(4:end);
aa = find(texte == '_');
texte(aa) = ' ';
title(['Normalized SPECTRA (ref : ',texte,')'],'fontsize',10);

%% ------------- Mise en forme finale FIT -----------------
subplot(2,2,2)
% plot ref
loglog(x_ref,exp(y_ref),[color(1),'-'], 'LineWidth', 1);
if type_plot == 'c'
    xlabel('ADJUSTED ESD [mm]','fontsize',12);
else
    xlabel('RAW ESD [mm]','fontsize',12);
end
ylabel('ABUNDANCE [#/L/mm²]','fontsize',12);
% legend(legende);
% axis([0.01 5 0.0001 1000]);
% axis([0.05 2 0.01 10000000]);
axis([0.1 1 0.01 10000000]);
% axis([0.05 3 0.0000001 100]);
set(gca,'xscale','log');
set(gca,'yscale','log');
title(['FIT (',char(fit_type),') on selected data [',num2str(esd_min),' - ',num2str(esd_max),'mm]'],'fontsize',10);

%% ------------- Mise en forme finale RATIO -----------------
subplot(2,2,3)
% plot ref
plot(x_ref,ones(numel(x_ref),1),[color(1),'-']);
if type_plot == 'c'
    xlabel('ADJUSTED ESD [mm]','fontsize',12);
else
    xlabel('RAW ESD [mm]','fontsize',12);
end
ylabel('RATIO','fontsize',12);
legend(legende,'Location','best');
% axis([0.05 2 0.5 2]);
axis([0.1 1 0.5 2]);
set(gca,'xscale','log');
% set(gca,'yscale','log');
title('Ratio of fit / reference','fontsize',10);

%% --------------- PLOT Ratio/shutter ----------------
% data_list = {'profilename' 'aa' 'exp' 'img_vol' 'pixel' 'gain' 'threshold' 'exposure' 'shutter' 'smbase' 'ratio'};
subplot(2,2,4)
for i = 2:size(data_table,1)
    hold on
    plot(data_table(i,8),data_table(i,11),[color(i),'o']);
end
ylabel('RATIO (mean)','fontsize',12);
xlabel('SHUTTER','fontsize',12);
% axis([0.05 2 -2 2]);
% set(gca,'xscale','log');
title('Mean ratio / shutter','fontsize',10);

% -------------- Enregistrement figure ---------------
disp('------------------------------------------------------')
orient tall
titre = [char(uvp_ref),'_',char(uvp_adj),'_',char(base_ref(rec_ref).profilename)];
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
disp('------------------------------------------------------')