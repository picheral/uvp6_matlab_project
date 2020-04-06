
%% PLOT spectres PIXELS de multiples UVP5 pour un même cast
% Lombard -Picheral, 2016/02, 2020/03


uvpt_ref_ype = 'std';
scrsz = get(0,'ScreenSize');

disp('--------------- START PLOT ------------------------')

%% ----------------- Settings ------------------------------
type_plot = input('Select plot type (raw/calibrated) (r/c) ','s');
if isempty(type_plot); type_plot = 'r'; end
input_aa_ex = 'n';
if strcmp(type_plot,'c')
    input_aa_ex = input('Manually input Aa, and Exp (y/n) ','s');
    if isempty(input_aa_ex) ; input_aa_ex = 'y';end
end

depth_min = input('Set the minimum depth for the profiles (default = 0)');
depth_max = input('Set the maximum depth for the profiles (default = max)');
if isempty(depth_min); depth_min =0; end
if isempty(depth_max); depth_max = 99999;end

disp('---------------------------------------------------')

%% ------------- Selection du projet de REFERENCE -------------
selectprojet = 0;
while (selectprojet == 0)
    disp('>> Select UVP5 REFERENCE project directory');
    project_folder_ref = uigetdir('Select UVP5 REFERENCE project directory');
    if strcmp(project_folder_ref(4:7),'uvp5');  selectprojet = 1;
    else disp(['Selected project ' project_folder_ref ' is not correct. It must be on the root of a drive.']); end
end
cd(project_folder_ref);
% ------------- Liste des bases --------------------
results_dir_ref = [project_folder_ref,'\results\'];
if isfolder(results_dir_ref)
    base_list = dir([results_dir_ref, 'base*.mat']);
    base_nofile = isempty(base_list);
    if base_nofile == 0
        disp('----------- Base list --------------------------------');
        disp([num2str(size(base_list,1)),' database in ', results_dir_ref]);
        for i = 1:size(base_list)
            disp(['N°= ',num2str(i),' : ',base_list(i).name]);
        end
    else
        disp(['No database in ',results_dir_ref]);
    end
else
    disp(['Process cannot continue : no reference base in ',results_dir_ref]);
end
% ------------------ Chargement de la base de référence -----------------
disp('------------------------------------------------------');
base_selected = 1;
if i > 1
    base_selected = input('Enter number corresponding to selected uvp database. (default = 1) ');
    if isempty(base_selected); base_selected = 1;   end
end

% ---------------- Chargement de la base choisie ------------------
toto=['load ',results_dir_ref,base_list(base_selected).name,';'];
eval(toto);
toto=['base_ref = ',base_list(base_selected).name(1:end-4),';'];
eval(toto);
ligne_ref = size(base_ref,2);
for i = 1 : ligne_ref
    disp(['Number : ',num2str(i),'   >  Profile : ',char(base_ref(i).profilename)]);
end
ref_record = input('Enter Number of the profile for the reference UVP (default = 1) ');
if isempty(ref_record); ref_record = 1; end


%% Reading uvp5_configuration_data.txt REF
%%
filename=[project_folder_ref,'\config\uvp5_settings\uvp5_configuration_data.txt'];
[ aa_data_ref expo_data_ref img_vol_data_ref, pix_ref light1_ref light2_ref] = read_uvp5_configuration_data( filename ,'data' );

uvp_ref = char(base_ref(1).pvmtype);
ee = find(uvp_ref == '_');
uvp_ref(ee) = '-';

%% -------------------------- Boucle sur les projets à ajouter ------------
fig5 = figure('numbertitle','off','name','UVP5_spectres_pixels','Position',[10 50 900 900]);
pixsize= [1:900];
other_cast = 1;
color = 'gbckygbckygbcky';
index_plot = 1;
legende = {};

while other_cast == 1
    
    %% ------------------ Choix du projet UVP à ajuster ----------------------
    
    disp('------------------------------------------------------');
    disp('>> Select the ''uvp5'' root folder containing profile of UVP to add ');
    selectprojet = 0;
    while (selectprojet == 0)
        project_folder_adj = uigetdir('Select UVP5 project directory');
        if strcmp(project_folder_adj(4:7),'uvp5');  selectprojet = 1;
        else disp(['Selected project ' project_folder_adj ' is not correct. It must be on the root of a drive.']); end
    end
    cd(project_folder_adj);
    % ------------- Liste des bases --------------------
    results_dir_adj = [project_folder_adj,'\results\'];
    if isdir(results_dir_adj)
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
        end
    else
        disp(['Process cannot continue : no reference base in ',results_dir_adj]);
    end
    % ------------------ Chargement de la base à ajuster -----------------
    disp('------------------------------------------------------');
    base_selected = 1;
    if i > 1
        base_selected = input('Enter number corresponding to selected uvp database. (default = 1) ');
        if isempty(base_selected); base_selected = 1;   end
    end
    
    % ---------------- Chargement de la base choisie ------------------
    toto=['load ',results_dir_adj,base_list(base_selected).name,';'];
    eval(toto);
    toto=['base_adj = ',base_list(base_selected).name(1:end-4),';'];
    eval(toto);
    ligne_adj = size(base_adj,2);
    for i = 1 : ligne_adj
        disp(['Number : ',num2str(i),'   >  Profile : ',char(base_adj(i).profilename)]);
    end
    adj_record = input('Enter Number of the profile to be adjusted (default = 1) ');
    if isempty(adj_record); adj_record = 1; end
    
    
    uvp_adj = char(base_adj(1).pvmtype);
    ee = find(uvp_adj == '_');
    uvp_adj(ee) = '-';
    
    %% Reading uvp5_configuration_data.txt ADJ
    %%
    filename=[project_folder_adj,'\config\uvp5_settings\uvp5_configuration_data.txt'];
    [ aa_data_adj expo_data_adj img_vol_data_adj, pix_adj light1_adj light2_adj] = read_uvp5_configuration_data( filename , 'data');
    
    % ----- Nombre de profils ---------
    nb_profils = 1;
    for i = 1 :nb_profils
        rec_adj = adj_record + i -1;
        rec_ref = ref_record + i -1;
        % --------------------- REFERENCE ----------------------
        dd = find(base_ref(rec_ref).histopx(:,2) < depth_max);   
        ee = find(base_ref(rec_ref).histopx(:,2) >= depth_min);      
        
        refpix=base_ref(rec_ref).histopx(ee(1):dd(end),5:end);
        refpix = refpix./(pix_ref^2);
        volumeimage=base_ref(rec_ref).volimg0;
        aa_ref=base_ref(rec_ref).a0;
        expo_ref=base_ref(rec_ref).exp0;
        nombreimages=base_ref(rec_ref).histopx(ee(1):dd(end),4);
        % depth=baseref(profilref).hisnb(:,1);
        volumeechref=volumeimage*nombreimages;
        volumeechref=volumeechref*ones(1,900);
        refs=refpix./volumeechref;
        tailleref=2*((aa_ref*(pixsize.^expo_ref)./pi).^0.5);
        newsize=tailleref;
        % ---------------------- AJUSTE -------------------------        
        dd = find(base_adj(rec_adj).histopx(:,2) < depth_max);
        ee = find(base_adj(rec_adj).histopx(:,2) >= depth_min); 
        data=base_adj(rec_adj).histopx(ee(1):dd(end),5:end);
        data = data./(pix_adj^2);
        volumeimage=base_adj(rec_adj).volimg0;
        nombreimages=base_adj(rec_adj).histopx(ee(1):dd(end),3);
        %     hisnb=baseadj(profildata).hisnb;
        volumeech=volumeimage*nombreimages;
        volumeech2=volumeech*ones(1,27);
        volumeech=volumeech*ones(1,900);
        aa_adj=base_adj(rec_adj).a0;
        expo_adj=base_adj(rec_adj).exp0;
        
        % ------------------- ANALYSE ---------------------------
        [i,j]=size(refs);
        [k,l]=size(data);
        minsize=min(i,k);
        data=data(1:minsize,:);
        refs=refs(1:minsize,:);
        %     depth=depth(1:minsize,:);
        volumeech=volumeech(1:minsize,:);
        volumeech2=volumeech2(1:minsize,:);
        refsum=nanmean(refs);
        refsum_log = log(refsum);
        
        nbre=data./volumeech;
        [n,m]=size(nbre);
        %refsum=sum(refs);
        nbsum=nanmean(nbre);
        nbsum_adj_log = log(nbsum);
        
        % -------- Figure "Fabien" ----------------------------------
        hold on
        if type_plot == 'c' 
            if strcmp(input_aa_ex','y')
                aa_adj_new = 	input(['ADJUSTED ',char(uvp_adj),' : Change Aa if necessary (',num2str(aa_adj,5),') ']);
                expo_adj_new =  input(['ADJUSTED ',char(uvp_adj),' : Change Exp if necessary (',num2str(expo_adj,5),') ']);
                if isfinite(aa_adj_new);    aa_adj = aa_adj_new;        end
                if isfinite(expo_adj_new);  expo_adj = expo_adj_new;    end
            end
            camsm_adj = 2*((aa_adj*(pixsize.^expo_adj)./pi).^0.5);
        else
            camsm_adj = 2*(((pix_adj^2)*(pixsize)./pi).^0.5);
        end
        camsm_adj_log = log(camsm_adj);
        loglog(exp(camsm_adj_log),exp(nbsum_adj_log),[color(index_plot),'+']);
        
    end
    
    legende(index_plot) = {[char(uvp_adj),' : ',char(base_adj(adj_record).profilename),' (',num2str(aa_adj),'/',num2str(expo_adj),')']};    %{char(uvp_adj)};
    % -------------------------- CONTINUE ???? ----------
    other_cast = input('Add other scan (1/0) ? ');
    if isempty(other_cast); other_cast = 1;end
    
    index_plot = index_plot + 1;
end

% ------ PLOT reference -----------------------------
hold on
if type_plot == 'c'
    if strcmp(input_aa_ex','y')
        aa_ref_new = 	input(['REFERENCE ',char(uvp_ref),' : Change Aa if necessary (',num2str(aa_ref,5),') ']);
        expo_ref_new =  input(['REFERENCE ',char(uvp_ref),' : Change Exp if necessary (',num2str(expo_ref,5),') ']);
        if isfinite(aa_ref_new);    aa_ref = aa_ref_new;        end
        if isfinite(expo_ref_new);  expo_ref = expo_ref_new;    end
    end
    camsm_ref = 2*((aa_ref*(pixsize.^expo_ref)./pi).^0.5);
else
    camsm_ref = 2*(((pix_ref^2)*(pixsize)./pi).^0.5);
end

camsm_ref_log = log(camsm_ref);
loglog(exp(camsm_ref_log),exp(refsum_log),'ro');
legende(index_plot) = {[char(uvp_ref),' : ',char(base_ref(ref_record).profilename),' (ref)',' (',num2str(aa_ref),'/',num2str(expo_ref),')']};

%% ------------- Mise en forme finale -----------------
if type_plot == 'c'
    xlabel('ADJUSTED ESD [mm]','fontsize',12);
else
    xlabel('RAW ESD [mm]','fontsize',12);
end
ylabel('COUNTS','fontsize',12);
legend(legende);
% axis([0.01 5 0.0001 1000]);
axis([0.05 2 0.01 100000]);
set(gca,'xscale','log');
set(gca,'yscale','log');
orient tall
% ----- Filename / Titre ---------
% titre = ['counts'];
% for i = 1:index_plot - 1
%     titre = [char(titre), '_', char(legende(i))];
% end
% 
% titre = [titre '_cast_' char(base_ref(ref_record).profilename)];

titre = [char(uvp_ref),'_',char(base_ref(ref_record).profilename)];
texte = titre;
aa = find(texte == '_');
texte(aa) = ' ';
title(texte);

set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[results_dir_ref,'\',char(titre)]);

disp('------------------ END --------------------- ');