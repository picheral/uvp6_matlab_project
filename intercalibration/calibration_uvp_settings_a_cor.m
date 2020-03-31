%% UVP5 calibration settings & analyses
% Picheral Lombard 2017/11
% Updated 2019/06/11

function [ref_cast, adj_cast, Srange_px_ref, Srange_px_adj] = calibration_uvp_settings_a_cor(process_params, ref_cast, adj_cast, ref_base, adj_base)

% ----------------- used variables  ---------------------------------------
project_folder_ref = ref_cast.project_folder;
pix_ref = ref_cast.pix;
img_vol_data_ref = ref_cast.img_vol_data;
aa_data_ref = ref_cast.aa_data;
expo_data_ref = ref_cast.expo_data;

pix_adj = adj_cast.pix;
img_vol_data_adj = adj_cast.img_vol_data;

esd_min = process_params.esd_min;
esd_max = process_params.esd_max;
esd_vect_ecotaxa = process_params.esd_vect_ecotaxa;

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
    ref_cast.img_vol_data = volumeimageref;
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
    adj_cast.img_vol_data = volumeimage;
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

ref_esd_x = ref_esd_x(1:end-1);
ref_histo_ab_mean_red_norm = ref_histo_ab_mean_red(1:end-1)./ref_norm_vect;
ref_histo_ab_mean_red_norm_calib = ref_histo_ab_mean_red(1:end-1)./ref_norm_vect_calib;
adj_esd_x = adj_esd_x(1:end-1);
adj_histo_ab_mean_red_norm = adj_histo_ab_mean_red(1:end-1)./adj_norm_vect;

% -------- Vecteurs finaux par classe -------------------------------------
[ref_ab_vect_ecotaxa]= sum_ab_classe(ref_esd_x,esd_vect_ecotaxa,ref_histo_ab_mean_red);
[adj_ab_vect_ecotaxa]= sum_ab_classe(adj_esd_x,esd_vect_ecotaxa,adj_histo_ab_mean_red);


%% FUNCTION RETURNS

% ----------- return computed variables  ----------------------------------
ref_cast.pixsize = pixsize_ref;
ref_cast.Smin_px = Smin_px_ref;
ref_cast.Smax_px = Smax_px_ref;
ref_cast.vol_ech = ref_vol_ech;
ref_cast.aa = aa_ref;
ref_cast.expo = expo_ref;
ref_cast.esd_x = ref_esd_x;
ref_cast.esd_calib = ref_esd_calib;
ref_cast.esd_calib_log = ref_esd_calib_log;
ref_cast.esd_calib_all = ref_esd_calib_all;
ref_cast.area_mm2_calib = ref_area_mm2_calib;
ref_cast.norm_vect = ref_norm_vect;
ref_cast.norm_vect_calib = ref_norm_vect_calib;
ref_cast.histopx = histopx_ref;
ref_cast.histo_mm2 = ref_histo_mm2;
ref_cast.histo_mm2_vol_mean = ref_histo_mm2_vol_mean;
ref_cast.histo_mm2_vol_mean_red_log = ref_histo_mm2_vol_mean_red_log;
ref_cast.histo_ab = ref_histo_ab;
ref_cast.histo_ab_mean_red = ref_histo_ab_mean_red;
ref_cast.histo_ab_mean_red_norm = ref_histo_ab_mean_red_norm;
ref_cast.histo_ab_mean_red_norm_calib = ref_histo_ab_mean_red_norm_calib;
ref_cast.depth = depth;
ref_cast.ab_vect_ecotaxa = ref_ab_vect_ecotaxa;

adj_cast.pixsize = pixsize_adj;
adj_cast.vol_ech = adj_vol_ech;
adj_cast.Smin_px = Smin_px_adj;
adj_cast.Smax_px = Smax_px_adj;
adj_cast.esd_x = adj_esd_x;
adj_cast.norm_vect = adj_norm_vect;
adj_cast.histopx = histopx_adj;
adj_cast.histo_mm2 = adj_histo_mm2;
adj_cast.histo_mm2_vol_mean = adj_histo_mm2_vol_mean;
adj_cast.histo_ab = adj_histo_ab;
adj_cast.histo_ab_mean_red = adj_histo_ab_mean_red;
adj_cast.histo_ab_mean_red_norm = adj_histo_ab_mean_red_norm;
adj_cast.depth = depth;
adj_cast.ab_vect_ecotaxa = adj_ab_vect_ecotaxa;

Srange_px_ref = [Smin_px_ref, Smax_px_ref];
Srange_px_adj = [Smin_px_adj, Smax_px_adj];

end

