%% Script de comparaison des spectres de taille entre 2 instruments déployés ensemble 
% basé sur la correspondance temporelle entre les profils à moins de 30 min.
% Picheral, 2023/09/30

% input :
%   - Deux bases préalablement construites dans leurs projets
%   - Le black est préalablement retiré des données UVP6 1 et 2 pixels

% output :
%   - Figures dans le répertoire résults du projet source

clear all
close all

disp('------------------------------ START ------------------------------')
% chargement base de référence
disp('Loading reference project')
[ref_base_source,project_folder_ref,results_dir_ref] = UvpOpenBase('reference');

% chargement base de référence
disp('Loading adjusted project')
[adj_base_source,project_folder_adj,results_dir_adj] = UvpOpenBase('adjusted');

% limites profondeurs
disp('-------------------------------------------------------------------')
disp('DEPTH range selection. The range must be > 100 dbars.')
depth_limit_min = input("Input min depth (default = 0 dbars)");
if isempty(depth_limit_min); depth_limit_min = 0; end
depth_limit_max = input("Input max depth (default = 6000 dbars)");
if isempty(depth_limit_max); depth_limit_max = 60000; end
disp('-------------------------------------------------------------------')

% settings
process_params.esd_min = 0.13;
process_params.esd_max = 1.5;
process_params.esd_vect_ecotaxa = [0.0403 0.0508 0.064 0.0806 0.102 0.128 0.161 0.203 0.256 0.323 0.406 0.512 0.645 0.813 1.020 1.290 1.630 2.050 2.580];

%% PLOTS

v_plots = ceil(sqrt(size(ref_base_source,2)));
h_plots = ceil(size(ref_base_source,2)/v_plots);

v_plots = 3;
h_plots = 4;
nb_plots = v_plots * h_plots;

%% Boucle sur la base de référence
date_num_adj = [adj_base_source(:).datem];
no_fig = 0;

for ref_cast_nb = 1 : size(ref_base_source,2)

    % ref cast metadata
    ref_cast.project_folder = [project_folder_ref,'\'];
    ref_cast.results_dir = results_dir_ref;
    ref_cast.record = ref_cast_nb;
    uvp = char(ref_base_source(ref_cast_nb).pvmtype);
    ee = uvp == '_';
    uvp(ee) = '-';
    ref_cast.uvp = uvp;
    ref_cast.profilename = ref_base_source(ref_cast_nb).profilename;
    ref_cast.label = 'ref';

    % data of ref_cast
    [ref_base, ref_cast] = CalibrationUvpGetConfig(ref_base_source(ref_cast_nb), ref_cast, 'Reference');
    % recherche cast le plus proche dans base adj
    vect_ecarts = abs(date_num_adj - ref_base_source(ref_cast_nb).datem);

    % contrôle sur l'écart (inférieur à 30 min)
    if min(vect_ecarts) < datenum(0,0,0,0,30,0)
        adj_cast_nb = find(vect_ecarts == min(vect_ecarts));

        % adj cast metadata
        adj_cast.project_folder = [project_folder_adj,'\'];
        adj_cast.results_dir = results_dir_adj;
        adj_cast.record = adj_cast_nb;
        uvp = char(adj_base_source(adj_cast_nb).pvmtype);
        ee = uvp == '_';
        uvp(ee) = '-';
        adj_cast.uvp = uvp;
        adj_cast.profilename = adj_base_source(adj_cast_nb).profilename;
        adj_cast.label = 'adj';

        %   A effacer après correction base uvp6
        % adj_base_source(adj_cast_nb).histfile = {'20230623-123500'};

        % data of adj_cast
        [adj_base, adj_cast] = CalibrationUvpGetConfig(adj_base_source(adj_cast_nb), adj_cast, 'Adjusted');

        % select depth ranges
        aa = find(ref_base.histopx(:,1) >= depth_limit_min);
        ref_base.histopx = ref_base.histopx(aa,:);
        aa = find(ref_base.histopx(:,1) <= depth_limit_max);
        ref_base.histopx = ref_base.histopx(aa,:);        
        
        aa = find(adj_base.histopx(:,1) >= depth_limit_min);
        adj_base.histopx = adj_base.histopx(aa,:);
        aa = find(adj_base.histopx(:,1) <= depth_limit_max);
        adj_base.histopx = adj_base.histopx(aa,:); 
               
        % check and select the same depth range
        [ref_cast.histopx, adj_cast.histopx, process_params.depth] = CalibrationUvpComputeDepthRange(ref_base.histopx,adj_base.histopx);

        % process raw data variale for plot and fit
        [ref_cast] = CalibrationUvpProcessRawData(process_params.esd_vect_ecotaxa, ref_cast);
        [adj_cast] = CalibrationUvpProcessRawData(process_params.esd_vect_ecotaxa, adj_cast);

        % plot individudel
        CalibrationUvpPlotRawData(process_params, ref_cast, adj_cast,1);

        % nouvelle figure tous les N plots
        if ref_cast_nb == 1 + nb_plots * round(ref_cast_nb / nb_plots)
            cast_deb_fig = ref_cast_nb;
            if ref_cast_nb > 1
                % ---------------------- Save figure -------------------------------------
                orient tall
                set(gcf,'PaperPositionMode','auto')
                print(gcf,'-dpng',[results_dir_ref,'\composite_',num2str(cast_deb_fig),'_',num2str(depth_limit_min,0),'_',num2str(depth_limit_max,0)]);
            end
            
            no_fig = no_fig + 1;
            expression = ['figure',num2str(no_fig),' = figure(''name'',''RAW-data-all'',''Position'',[50 50 1200 1200])'];
            eval(expression);
        end

        %% ---------------- plot multiple -----------------------------------------
        plot_index = ref_cast_nb - (no_fig-1) * nb_plots;
        expression = ['figure(figure',num2str(no_fig),')'];
        eval(expression);
        subplot(v_plots,h_plots,plot_index);

        % ----------------- used variables  ---------------------------------------
        results_dir_ref = ref_cast.results_dir;
        uvp_ref = ref_cast.uvp;
        pix_ref = ref_cast.pix;
        ref_esd_x = ref_cast.esd_x;
        ref_histo_mm2_vol_mean = ref_cast.histo_mm2_vol_mean;
        ref_histo_ab_mean_red_norm = ref_cast.histo_ab_mean_red_norm;
        ref_ab_vect_ecotaxa = ref_cast.ab_vect_ecotaxa;
        histopx_ref = ref_cast.histopx;
        volumeimage_ref = ref_cast.img_vol_data;

        uvp_adj = adj_cast.uvp;
        pix_adj = adj_cast.pix;
        adj_esd_x = adj_cast.esd_x;
        adj_histo_mm2_vol_mean = adj_cast.histo_mm2_vol_mean;
        adj_histo_ab_mean_red_norm = adj_cast.histo_ab_mean_red_norm;
        adj_ab_vect_ecotaxa = adj_cast.ab_vect_ecotaxa;
        histopx_adj = adj_cast.histopx;
        volumeimage_adj = adj_cast.img_vol_data;

        esd_min = process_params.esd_min;
        esd_max = process_params.esd_max;
        esd_vect_ecotaxa = process_params.esd_vect_ecotaxa;

        % ------------- plot ---------------------
        loglog(ref_esd_x,ref_histo_ab_mean_red_norm,'ro');
        hold on
        loglog(adj_esd_x,adj_histo_ab_mean_red_norm,'g+');
        hold on
        xline(esd_min, '--b');
        xline(esd_max, '--b');
        legend(uvp_ref,uvp_adj,'fontsize',6);
        titre = [char(ref_cast.profilename),' / ',char(adj_cast.profilename),' ',num2str(depth_limit_min),'-',num2str(depth_limit_max)];
        ee = titre == '_';
        titre(ee) = '-';
        title(titre,'fontsize',7);
        xlabel('ESD [mm]','fontsize',7);
        ylabel('NORMALIZED ABUNDANCE [rel]','fontsize',7);
        axis([0.05 2 0.01 1000000]);
        set(gca,'xscale','log');
        set(gca,'yscale','log');


    end
end

% ---------------------- Save figure -------------------------------------
orient tall
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[results_dir_ref,'\composite_',num2str(cast_deb_fig),'_',num2str(depth_limit_min,0),'_',num2str(depth_limit_max,0)]);

