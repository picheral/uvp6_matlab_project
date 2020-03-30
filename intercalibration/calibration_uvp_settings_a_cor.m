%% UVP5 calibration settings & analyses
% Picheral Lombard 2017/11
% Updated 2019/06/11

function [process_params, ref_cast, adj_cast] = calibration_uvp_settings_a_cor(ref_cast, adj_cast, ref_base, adj_base)

% ----------------- used variables  ---------------------------------------
project_folder_ref = ref_cast.project_folder;
results_dir_ref = ref_cast.results_dir;
uvp_ref = ref_cast.uvp;
pix_ref = ref_cast.pix;
img_vol_data_ref = ref_cast.img_vol_data;
aa_data_ref = ref_cast.aa_data;
expo_data_ref = ref_cast.expo_data;

uvp_adj = adj_cast.uvp;
pix_adj = adj_cast.pix;
img_vol_data_adj = adj_cast.img_vol_data;

% --------------- process params user inputs  -----------------------------
% fit_type = 'poly6';
EC_factor = 0.01;
% pixel_min = input('Enter value of first pixel class (default = 1) ');
% if isempty(pixel_min); pixel_min = 1; end

esd_min = input('Enter ESD minimum for minimisation [mm] (default = 0.1) ');
if isempty(esd_min); esd_min = 0.1; end

tt = 1.5;
if contains(uvp_adj,'uvp6'); tt = 1;end 
esd_max = input(['Enter ESD maximum for minimisation [mm] (default = ',num2str(tt),') ']);
if isempty(esd_max); esd_max = tt; end

% vecteur "ECOTAXA"
esd_vect_ecotaxa = [0.00403 0.00508 0.064 0.0806 0.102 0.128 0.161 0.203 0.256 0.323 0.406 0.512 0.645 0.813 1.002 1.290 1.630 2.050 2.580];
% esd_vect_ecotaxa = [0.064  0.102  0.161  0.256  0.406  0.645  1.002  1.630  2.580  4.100];
% esd_vect_reg = [0:0.2:4];

X0 = input(['Enter starting values X [',num2str(0.55*pix_adj^2),' 1.1] as d�faut ']);
if isempty(X0);      X0=[0.55*pix_adj^2 1.1];  end

Fit_data = input(['Enter fit level for data [3-6] 6 default = 6 ']);
if isempty(Fit_data);      Fit_data=6;  end
Fit_range = input(['Enter fit level for adj [3-6] default = fit for data ']);
if isempty(Fit_range);      Fit_range=Fit_data;  end
fit_type = ['poly', num2str(Fit_data)];
Fit_range = ['poly',num2str(Fit_range)];
EC_factor = input(['Enter EC factor (default = 0.5) ']);
if isempty(EC_factor);      EC_factor=0.5;  end

% -------------- Ranges ---------------------------------------------------
Smax_mm = pi * (esd_max/2)^2;
Smax_px_ref = round(Smax_mm/(pix_ref^2));
Smax_px_adj = round(Smax_mm/(pix_adj^2));

Smin_mm = pi * (esd_min/2)^2;
Smin_px_ref = ceil(Smin_mm/(pix_ref^2));
Smin_px_adj = ceil(Smin_mm/(pix_adj^2));


%% REFERENCE (REF)
% -------------- Checks --------------------------------------------------
if (strcmp(project_folder_ref(4:7),'uvp5'))
    aa_ref = ref_base.a0;
else
    aa_ref = ref_base.a0/1000000;
    aa_data_ref = aa_data_ref/1000000;
end
expo_ref = ref_base.exp0;
volumeimageref=ref_base.volimg0;
if (aa_ref ~= aa_data_ref || expo_ref ~= expo_data_ref || volumeimageref ~= img_vol_data_ref)
    disp('The calibration parameters of the reference UVP are not the same in the data base and in the configuration file. Check them !!! ');
    disp('Configuration_data');
    disp(['Image volume [L]    : ',num2str(img_vol_data_ref)]);
    disp(['Aa                  : ',num2str(aa_data_ref)]);
    disp(['Exp                 : ',num2str(expo_data_ref)]);
    disp('BASE');
    disp(['Image volume [L]    : ',num2str(volumeimageref)]);
    disp(['Aa                  : ',num2str(aa_ref)]);
    disp(['Exp                 : ',num2str(expo_ref)]);
else
    disp('All metadata of the reference profile are OK.')
end


% find the deepest first depth between the two base, in order to compare
% profiles in the same range of depth
firstdepth_ref = nanmin(ref_base.histopx(:,1));
firstdepth_adj = nanmin(adj_base.histopx(:,1));
if max(firstdepth_ref, firstdepth_adj) == firstdepth_ref
    first_depth = firstdepth_ref;
else
    first_depth = firstdepth_adj;
end

% --------------- Normalisation par pixel area ----------------------------

% take only useful profile
histopx = ref_base.histopx;
aa = find(histopx(:,1) >= first_depth);
histopx_ref = histopx(aa,:);

ref_histo_px = histopx_ref(:,5:end);
%ref_histo_px=histopx_ref(:,4+Smin_px_ref:4+Smax_px_ref); % TO BE DELETED
%mis en commentaire pour afficher tout le range
ref_histo_mm2 = ref_histo_px./(pix_ref^2);
ref_nb_img=histopx_ref(:,4);
ref_vol_ech=volumeimageref*ref_nb_img;
ref_vol_ech=ref_vol_ech*ones(1,size(ref_histo_mm2,2));
ref_histo_mm2_vol=ref_histo_mm2./ref_vol_ech;
% pixsize_ref = [pixel_min:size(ref_histo_mm2,2)];
%pixsize_ref = [Smin_px_ref:Smax_px_ref]; % TO BE DELETED
pixsize_ref = [1:size(ref_histo_px,2)-4];
ref_esd_calib = 2*((aa_ref*(pixsize_ref.^expo_ref)./pi).^0.5);
ref_esd_calib_all = 2*((aa_ref*([1:500].^expo_ref)./pi).^0.5);
ref_esd_calib_log = log(ref_esd_calib);
ref_area_mm2_calib = aa_ref*(pixsize_ref.^expo_ref);

ref_histo_ab = (ref_histo_px./ref_vol_ech);
ref_esd_x = 2*(((pix_ref^2)*(pixsize_ref)./pi).^0.5);

% Vecteur pour normalisation
ref_norm_vect = [];
for i=1:numel(ref_esd_x)-1
    ref_norm_vect(i) = ref_esd_x(i+1) - ref_esd_x(i);  
end
ref_norm_vect_calib = [];
for i=1:numel(ref_esd_calib)-1
    ref_norm_vect_calib(i) = ref_esd_calib(i+1) - ref_esd_calib(i);  
end


%% AJUSTED (DATA)
% -------------- Checks --------------------------------------------------
volumeimage=adj_base.volimg0;
if volumeimage ~= img_vol_data_adj
    disp('The image volume of the adjusted UVP is not the same in the data base and in the configuration file. Check the file !!! ');
    disp('Configuration_data');
    disp(['Image volume [L]    : ',num2str(img_vol_data_adj)]);
    disp('BASE');
    disp(['Image volume [L]    : ',num2str(volumeimage)]);
else
    disp('All metadata of the adjusted profile are OK.')
end

% --------------- Normalisation using pixel area --------------------------

% take only useful profile
histopx = adj_base.histopx;
aa = find(histopx(:,1) >= first_depth);
histopx_adj = histopx(aa,:);

adj_histo_px=histopx_adj(:,5:end);
%adj_histo_px=histopx_adj(:,4+Smin_px_adj:4+Smax_px_adj); % TO BE DELETED
adj_histo_mm2 = adj_histo_px./(pix_adj^2);
adj_nb_img=histopx_adj(:,4);
adj_vol_ech=volumeimage*adj_nb_img;
adj_vol_ech=adj_vol_ech*ones(1,size(adj_histo_mm2,2));
% pixsize_adj = [pixel_min:size(adj_histo_mm2,2)];
%pixsize_adj = [Smin_px_adj:Smax_px_adj]; % TO BE DELETED
pixsize_adj = [1:size(adj_histo_mm2,2)-4];

adj_histo_ab = (adj_histo_px./adj_vol_ech);
adj_esd_x = 2*(((pix_adj^2)*(pixsize_adj)./pi).^0.5);

% Vecteur pour normalisation
adj_norm_vect = [];
for i=1:numel(adj_esd_x)-1
    adj_norm_vect(i) = adj_esd_x(i+1) - adj_esd_x(i);  
end


%% Calcul des vecteurs
% ------------------- Same Depth range for both profiles ------------------
depth=ref_base.histopx(:,1);
[i,j]=size(ref_histo_mm2_vol);
[k,l]=size(adj_histo_mm2);
minsize=min(i,k);
adj_histo_mm2=adj_histo_mm2(1:minsize,:);
ref_histo_mm2_vol=ref_histo_mm2_vol(1:minsize,:);
ref_histo_ab = ref_histo_ab(1:minsize,:);
depth=depth(1:minsize,:);
adj_vol_ech=adj_vol_ech(1:minsize,:);
adj_histo_ab = adj_histo_ab(1:minsize,:);
ref_histo_ab_mean = nanmean(ref_histo_ab);

% ------------------- Retrait valeurs manquantes surface (20180313)--------
aaa = ~isnan(adj_histo_mm2(:,1));
adj_histo_mm2 = adj_histo_mm2(aaa,:);
ref_histo_mm2_vol = ref_histo_mm2_vol(aaa,:);
ref_histo_ab = ref_histo_ab(aaa,:);
adj_histo_px = adj_histo_px(aaa,:);

depth = depth(aaa,:);
adj_vol_ech = adj_vol_ech(aaa,:);
adj_histo_ab = adj_histo_ab(aaa,:);
adj_histo_mm2_vol_mean=nanmean(adj_histo_mm2./adj_vol_ech);
adj_histo_ab_mean = nanmean(adj_histo_ab);

% --------- NEW FIT on REFERENCE ------------------------------------------
ref_histo_mm2_vol_mean = nanmean(ref_histo_mm2_vol);
ref_histo_mm2_vol_mean_red = ref_histo_mm2_vol_mean;
ref_histo_mm2_vol_mean_red = ref_histo_mm2_vol_mean_red(1:numel(ref_esd_calib));
ref_histo_mm2_vol_mean_red_log = log(ref_histo_mm2_vol_mean_red);

% -------- Vecteurs finaux d'abondances -----------------------------------
ref_histo_ab_mean_red = ref_histo_ab_mean(1:numel(ref_esd_x));
adj_histo_ab_mean_red = adj_histo_ab_mean(1:numel(adj_esd_x));

% -------- Vecteurs finaux par classe -------------------------------------
[ref_ab_vect_ecotaxa]= sum_ab_classe(ref_esd_x,esd_vect_ecotaxa,ref_histo_ab_mean_red);
[adj_ab_vect_ecotaxa]= sum_ab_classe(adj_esd_x,esd_vect_ecotaxa,adj_histo_ab_mean_red);
    

%% PLOTS
fig1 = figure('name','RAW data','Position',[50 50 1500 600]);
subplot(1,4,1)
% ------------------- part 1 ----------------------------------------------
loglog([1:numel(ref_histo_mm2_vol_mean)].*(pix_ref^2),ref_histo_mm2_vol_mean,'ro')
% loglog(ref_esd_x,ref_histo_ab_mean_red,'ro');
hold on
loglog([1:numel(adj_histo_mm2_vol_mean)].*(pix_adj^2),adj_histo_mm2_vol_mean,'go');
% loglog(adj_esd_x,adj_histo_ab_mean_red,'go');
hold on
xline(pi*(esd_min/2)^2, '--b');
xline(pi*(esd_max/2)^2, '--b');
legend(uvp_ref,uvp_adj);
title(['RAW DATA (normalized/pxarea)'],'fontsize',14);
xlabel('RAW AREA [mm�]','fontsize',12);
ylabel('ABUNDANCE [#/mm�/L]','fontsize',12);
axis([0.005 2 0.01 1000000]);
% axis([0.05 2 0.001 1000]);
set(gca,'xscale','log');
set(gca,'yscale','log');

subplot(1,4,2)
% ------------------- part 2 ----------------------------------------------
% loglog([1:numel(ref_histo_mm2_vol_mean)].*(pix_ref^2),ref_histo_mm2_vol_mean,'ro')
% loglog(ref_esd_x,ref_histo_ab_mean_red,'ro');
ref_esd_x = ref_esd_x(1:end-1);
ref_histo_ab_mean_red_norm = ref_histo_ab_mean_red(1:end-1)./ref_norm_vect;
ref_histo_ab_mean_red_norm_calib = ref_histo_ab_mean_red(1:end-1)./ref_norm_vect_calib;
loglog(ref_esd_x,ref_histo_ab_mean_red_norm,'ro');
hold on
% loglog([1:numel(adj_histo_mm2_vol_mean)].*(pix_adj^2),adj_histo_mm2_vol_mean,'go');
% loglog(adj_esd_x,adj_histo_ab_mean_red,'go');
adj_esd_x = adj_esd_x(1:end-1);
adj_histo_ab_mean_red_norm = adj_histo_ab_mean_red(1:end-1)./adj_norm_vect;
loglog(adj_esd_x,adj_histo_ab_mean_red_norm,'go');
hold on
xline(esd_min, '--b');
xline(esd_max, '--b');
legend(uvp_ref,uvp_adj);
title(['RAW DATA (normalized/esd)'],'fontsize',14);
xlabel('RAW ESD [mm]','fontsize',12);
ylabel('NORMALIZED ABUNDANCE [rel]','fontsize',12);
axis([0.05 2 0.01 1000000]);
% axis([0.05 2 0.001 1000]);
set(gca,'xscale','log');
set(gca,'yscale','log');

subplot(1,4,3)
% ------------------- part 3 ----------------------------------------------
semilogy(ref_ab_vect_ecotaxa,'ro');
hold on
semilogy(adj_ab_vect_ecotaxa,'go');
hold on
% find first and last class in the esd range
class_max = 1;
class_min = 1;
for i=1:length(esd_vect_ecotaxa)
    if esd_max >= esd_vect_ecotaxa(i)
        class_max = i;
    end
    if esd_min >= esd_vect_ecotaxa(i)
        class_min = i;
    end
end
xline(class_min, '--b');
xline(class_max, '--b');
legend(uvp_ref,uvp_adj);
title(['RAW DATA [per class]'],'fontsize',14);
xlabel('ESD CLASS [#]','fontsize',12);
ylabel('ABUNDANCE [#/L]','fontsize',12);
% axis([0.005 2 0.01 1000000]);
axis([0 15 0.01 50000]);
% set(gca,'xscale','log');
set(gca,'yscale','log');

subplot(1,4,4)
% ------------------- part 4 ----------------------------------------------
% Profiles matching check
semilogx((histopx_ref(:,6)+histopx_ref(:,7))./histopx_ref(:,4)/volumeimageref, -histopx_ref(:,1), 'r');
hold on
semilogx((histopx_adj(:,6)+histopx_adj(:,7))./histopx_adj(:,4)/volumeimage, -histopx_adj(:,1), 'g');
legend(uvp_ref,uvp_adj);
title(['particles profiles for 2pix+3pix'],'fontsize',14);
xlabel('particles number [part]','fontsize',12);
ylabel('depth [m]','fontsize',12);

% ---------------------- Save figure --------------------------------------
orient tall
titre = ['RAW_data_' char(ref_cast.profilename)];
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[results_dir_ref,'\',datestr(now,30),'_',char(titre)]);
% close(fig1);


%% FUNCTION RETURNS
% ------------------- input range  ----------------------------------------
% ref
ref_histo_mm2_vol_mean = ref_histo_mm2_vol_mean(:,Smin_px_ref:Smax_px_ref);
ref_histo_ab = ref_histo_ab(:,Smin_px_ref:Smax_px_ref);
ref_histo_ab_mean_red = ref_histo_ab_mean_red(:,Smin_px_ref:Smax_px_ref);
ref_histo_ab_mean_red_norm = ref_histo_ab_mean_red_norm(:,Smin_px_ref:Smax_px_ref-1);
ref_histo_ab_mean_red_norm_calib = ref_histo_ab_mean_red_norm_calib(:,Smin_px_ref:Smax_px_ref-1);
ref_esd_x = ref_esd_x(Smin_px_ref : Smax_px_ref - 1); % -1 because we already put out the last element
ref_norm_vect = ref_norm_vect(Smin_px_ref : Smax_px_ref);
ref_norm_vect_calib = ref_norm_vect_calib(Smin_px_ref : Smax_px_ref);
ref_esd_calib = ref_esd_calib(Smin_px_ref : Smax_px_ref);
ref_esd_calib_log = ref_esd_calib_log(Smin_px_ref : Smax_px_ref);
ref_esd_calib_all = ref_esd_calib_all(Smin_px_ref : Smax_px_ref);
ref_area_mm2_calib = ref_area_mm2_calib(Smin_px_ref : Smax_px_ref);
pixsize_ref = pixsize_ref(Smin_px_ref : Smax_px_ref);
% adj
adj_histo_px = adj_histo_px(:,Smin_px_adj:Smax_px_adj);
adj_histo_mm2 = adj_histo_mm2(:,Smin_px_adj:Smax_px_adj);
adj_histo_mm2_vol_mean = adj_histo_mm2_vol_mean(:,Smin_px_adj:Smax_px_adj);
adj_vol_ech = adj_vol_ech(:,Smin_px_adj:Smax_px_adj);
adj_histo_ab = adj_histo_ab(:,Smin_px_adj:Smax_px_adj);
adj_histo_ab_mean_red = adj_histo_ab_mean_red(:,Smin_px_adj:Smax_px_adj);
adj_histo_ab_mean_red_norm = adj_histo_ab_mean_red_norm(:,Smin_px_adj:Smax_px_adj-1);
adj_esd_x = adj_esd_x(Smin_px_adj : Smax_px_adj - 1);
adj_norm_vect = adj_norm_vect(Smin_px_adj : Smax_px_adj);
pixsize_adj = pixsize_adj(Smin_px_adj : Smax_px_adj);

% ----------- return computed variables  ----------------------------------
ref_cast.pixsize = pixsize_ref;
ref_cast.Smin_px = Smin_px_ref;
ref_cast.Smax_px = Smax_px_ref;
ref_cast.aa = aa_ref;
ref_cast.expo = expo_ref;
ref_cast.esd_x = ref_esd_x;
ref_cast.esd_calib = ref_esd_calib;
ref_cast.esd_calib_log = ref_esd_calib_log;
ref_cast.esd_calib_all = ref_esd_calib_all;
ref_cast.area_mm2_calib = ref_area_mm2_calib;
ref_cast.norm_vect = ref_norm_vect;
ref_cast.norm_vect_calib = ref_norm_vect_calib;
ref_cast.histo_mm2_vol_mean = ref_histo_mm2_vol_mean;
ref_cast.histo_mm2_vol_mean_red_log = ref_histo_mm2_vol_mean_red_log;
ref_cast.histo_ab = ref_histo_ab;
ref_cast.histo_ab_mean_red = ref_histo_ab_mean_red;
ref_cast.hisot_ab_mean_red_norm = ref_histo_ab_mean_red_norm;
ref_cast.histo_ab_mean_red_norm_calib = ref_histo_ab_mean_red_norm_calib;

adj_cast.pixsize = pixsize_adj;
adj_cast.vol_ech = adj_vol_ech;
adj_cast.Smin_px = Smin_px_adj;
adj_cast.Smax_px = Smax_px_adj;
adj_cast.esd_x = adj_esd_x;
adj_cast.norm_vect = adj_norm_vect;
adj_cast.histo_px = adj_histo_px;
adj_cast.histo_mm2 = adj_histo_mm2;
adj_cast.histo_mm2_vol_mean = adj_histo_mm2_vol_mean;
adj_cast.histo_ab = adj_histo_ab;
adj_cast.histo_ab_mean_red = adj_histo_ab_mean_red;
adj_cast.histo_ab_mean_norm = adj_histo_ab_mean_red_norm;

process_params.esd_min = esd_min;
process_params.esd_max = esd_max;
process_params.fit_type = fit_type;
process_params.Fit_range = Fit_range;
process_params.EC_factor = EC_factor;
process_params.X0 = X0;
process_params.esd_vect_ecotaxa = esd_vect_ecotaxa;
process_params.depth = depth;

end

