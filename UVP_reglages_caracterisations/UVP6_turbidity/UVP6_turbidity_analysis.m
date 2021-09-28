%% Mise en matrice des données manip turbidite uvp6 
% Picheral & Catalano 2021/08

clear all
close all

%lettre du disque de uvp_dvlt
uvp_dvlpt = 'Z';

% Vase : 2021/07/21 - 22  7:08 - 7:04
% path_vase = 'M:\uvp6_sn000001lp_20210607_limite_turbidite\raw\20210721-070832\20210721-070832_data.txt';
excel_vase = [uvp_dvlpt ':\_UVP6\Conception\Essais verification specifications\Rapports Manip\Limite_turbidite\Vase\Manip_vase.xlsx'];
% time_vect_vase = [datenum(2021,07,21,07,8,0):datenum(0,0,0,0,0,10):datenum(2021,07,21,15,20,0)];
path_vase = [uvp_dvlpt ':\_UVP6\Conception\Essais verification specifications\Rapports Manip\Limite_turbidite\Vase\'];

% Phyto2 : 2021/07/26 12:26 - 13:16
% path_phyto2 = 'M:\uvp6_sn000001lp_20210607_limite_turbidite\raw\20210726-122253\20210726-122253_data.txt';
excel_phyto2 = [uvp_dvlpt ':\_UVP6\Conception\Essais verification specifications\Rapports Manip\Limite_turbidite\Phyto2\Manip_Phyto2_mp.xlsx'];

path_phyto2 = [uvp_dvlpt ':\_UVP6\Conception\Essais verification specifications\Rapports Manip\Limite_turbidite\Phyto2\'];

% %% -------------- lecture données UVP6 et mise en matrice
% % VASE
% %   Fichiers UVP6
% [data, meta] = Uvp6DatafileToArray(path_vase);
% [time_data, prof_data, raw_nb, black_nb, image_status] = Uvp6ReadDataFromDattable(meta, data);
% 
% %   Retrait des NaN (black)
% aa = isfinite(raw_nb(:,1));
% bb = find(aa==1);
% data_vase = [time_data(bb) raw_nb(bb,:)];
% 
% % PHYTO2
% %   Fichiers UVP6
% [data, meta] = Uvp6DatafileToArray(path_phyto2);
% [time_data, prof_data, raw_nb, black_nb, image_status] = Uvp6ReadDataFromDattable(meta, data);
% 
% %   Retrait des NaN (black)
% aa = isfinite(raw_nb(:,1));
% bb = find(aa==1);
% data_phyto2 = [time_data(bb) raw_nb(bb,:)];


%% --------------- lecture des fichiers XLS
% VASE
[num_vase_c_rover] = xlsread(excel_vase,'C_ROVER_Vase');
% La colonne N°1 est la date numerique absolue
num_vase_c_rover(:,1) = num_vase_c_rover(:,1) + datenum(2021,07,21);

[num_vase_bbp] = xlsread(excel_vase,'BBP_Vase');
% La colonne N°1 est la date numerique absolue
num_vase_bbp(:,1) = num_vase_bbp(:,1) + datenum(2021,07,21);

[num_vase_turbi] = xlsread(excel_vase,'TURBI_Vase');
% La colonne N°1 est la date numerique absolue
num_vase_turbi(:,1) = num_vase_turbi(:,1) + datenum(2021,07,21);

% PHYTO2
[num_phyto2_c_rover text] = xlsread(excel_phyto2,'C_ROVER_Phyto2');
% La colonne N°1 est la date numerique absolue
num_phyto2_c_rover(:,2:6) = num_phyto2_c_rover(:,1:5);
for i=1 : size(text(:,1),1)
    num_phyto2_c_rover(i,1) = datenum([char(text(i,1)),'-',char(text(i,2))],'dd/mm/yyyy-HH:MM:SS');
end

[num_phyto2_bbp] = xlsread(excel_phyto2,'BBP_Phyto2');
% La colonne N°1 est la date numerique absolue
num_phyto2_bbp(:,1) = num_phyto2_bbp(:,1) + datenum(2021,07,26);

[num_phyto2_turbi] = xlsread(excel_phyto2,'TURB_Phyto2');
% La colonne N°1 est la date numerique absolue
num_phyto2_turbi(:,1) = num_phyto2_turbi(:,1) + datenum(2021,07,26);


%% -------------- Lecture fichiers vignettes turbid 
path_vignettes = [uvp_dvlpt ':\_UVP6\Conception\Essais verification specifications\Rapports Manip\Limite_turbidite\export_4600_20210830_1448\turbid.xlsx'];
[num_vignettes] = xlsread(path_vignettes);
num_vig = [];
% Conversion temporelle
for i=1:numel(num_vignettes(:,3))
    if num_vignettes(i,4) > 99999
%         disp([num2str(num_vignettes(i,3)) num2str(num_vignettes(i,4))])
        num_vig(i) = datenum([num2str(num_vignettes(i,3)) num2str(num_vignettes(i,4))],'yyyymmddHHMMSS');
    else
%         disp([num2str(num_vignettes(i,3)) '0' num2str(num_vignettes(i,4))])
        num_vig(i) = datenum([num2str(num_vignettes(i,3)) '0' num2str(num_vignettes(i,4))],'yyyymmddHHMMSS');
    end
end
num_vig_unique = unique(num_vig)';
% Comptage par date
for i=1:numel(num_vig_unique)
    aa= find(num_vig == num_vig_unique(i));
    num_vig_unique(i,2) = numel(aa);
end
% split VASE et PHYTO
aa = num_vig_unique(:,1) >= num_vase_c_rover(1,1) & num_vig_unique(:,1) <= num_vase_c_rover(end,1);
num_vig_unique_vase = num_vig_unique(aa,:);
aa = num_vig_unique(:,1) >= num_phyto2_c_rover(1,1) & num_vig_unique(:,1) <= num_phyto2_c_rover(end,1);
num_vig_unique_phyto2 = num_vig_unique(aa,:);

%% ----------------- interpolation aux points des vignettes
% VASE
[C ia] = unique(num_vase_c_rover(:,1));
num_vase_c_rover_unique = num_vase_c_rover(ia,:);
vase_c_rover = interp1(num_vase_c_rover_unique(:,1),num_vase_c_rover_unique,num_vig_unique_vase(:,1));

[C ia] = unique(num_vase_bbp(:,1));
num_vase_bbp_unique = num_vase_bbp(ia,:);
vase_bbp = interp1(num_vase_bbp_unique(:,1),num_vase_bbp_unique,num_vig_unique_vase(:,1));

[C ia] = unique(num_vase_turbi(:,1));
num_vase_turbi_unique = num_vase_turbi(ia,:);
vase_turbi = interp1(num_vase_turbi_unique(:,1),num_vase_turbi_unique,num_vig_unique_vase(:,1));

%PHYTO2
[C ia] = unique(num_phyto2_c_rover(:,1));
num_phyto2_c_rover_unique = num_phyto2_c_rover(ia,:);
phyto2_c_rover = interp1(num_phyto2_c_rover_unique(:,1),num_phyto2_c_rover_unique,num_vig_unique_phyto2(:,1));

[C ia] = unique(num_phyto2_bbp(:,1));
num_phyto2_bbp_unique = num_phyto2_bbp(ia,:);
phyto2_bbp = interp1(num_phyto2_bbp_unique(:,1),num_phyto2_bbp_unique,num_vig_unique_phyto2(:,1));

[C ia] = unique(num_phyto2_turbi(:,1));
num_phyto2_turbi_unique = num_phyto2_turbi(ia,:);
phyto2_turbi = interp1(num_phyto2_turbi_unique(:,1),num_phyto2_turbi_unique,num_vig_unique_phyto2(:,1));

%% Conversion en unités scientifiques
% C-ROVER
% transmittance = exp(- c * optical_pathlength)
optical_pathlength = 0.25; % optical pathlength of c-rover in [m]
vase_c_rover_tr = exp(- optical_pathlength * vase_c_rover);
num_vase_c_rover_tr = exp(- optical_pathlength * num_vase_c_rover(:,5));
phyto2_c_rover_tr = exp(- optical_pathlength * phyto2_c_rover);
num_phyto2_c_rover_tr = exp(- optical_pathlength * num_phyto2_c_rover(:,5));
% ECHO-OCR REM-A
% bbp in [m-1]
% bbp700 = 2*pi*khi *((scater-dark_bbp)*scale_bbp-betasw700)
khi = 1.076;
betasw700 = 0.000049183;
bbp_dark = 47;
bbp_scale = 1.8e-6;
vase_bbp700 = 2*pi*khi*((vase_bbp(:,3) - bbp_dark) * bbp_scale - betasw700);
num_vase_bbp700 = 2*pi*khi*((num_vase_bbp(:,3) - bbp_dark) * bbp_scale - betasw700);
phyto2_bbp700 = 2*pi*khi*((phyto2_bbp(:,3) - bbp_dark) * bbp_scale - betasw700);
num_phyto2_bbp700 = 2*pi*khi*((num_phyto2_bbp(:,3) - bbp_dark) * bbp_scale - betasw700);
% cdom in [µg/L]
% cdom = (cdom_raw - cdom_dark) * cdom_scale
cdom_dark = 42;
cdom_scale = 0.0814;
vase_bbp_cdom = cdom_scale * (vase_bbp(:,4) - cdom_dark);
num_vase_bbp_cdom = cdom_scale * (num_vase_bbp(:,4) - cdom_dark);
phyto2_bbp_cdom = cdom_scale * (phyto2_bbp(:,4) - cdom_dark);
num_phyto2_bbp_cdom = cdom_scale * (num_phyto2_bbp(:,4) - cdom_dark);
% fluo in [µg/L]
% fluo = (fluo_raw - fluo_dark) * fluo_scale
fluo_dark = 44;
fluo_scale = 0.0066;
vase_bbp_fluo = fluo_scale * (vase_bbp(:,2) - fluo_dark);
num_vase_bbp_fluo = fluo_scale * (num_vase_bbp(:,2) - fluo_dark);
phyto2_bbp_fluo = fluo_scale * (phyto2_bbp(:,2) - fluo_dark);
num_phyto2_bbp_fluo = fluo_scale * (num_phyto2_bbp(:,2) - fluo_dark);
% fluo_turb in [µg/L]
% fluo_turb = (fluo_turb_raw - fluo_turb_dark) * fluo_turb_scale
fluo_turb_dark = 50;
fluo_turb_scale = 0.0072;
vase_turbi_fluo = fluo_turb_scale * (vase_turbi(:,5) - fluo_turb_dark);
num_vase_turbi_fluo = fluo_turb_scale * (num_vase_turbi(:,5) - fluo_turb_dark);
phyto2_turbi_fluo = fluo_turb_scale * (phyto2_turbi(:,5) - fluo_turb_dark);
num_phyto2_turbi_fluo = fluo_turb_scale * (num_phyto2_turbi(:,5) - fluo_turb_dark);
% turb in [µg/L]
% turb = (turb_raw - turb_dark) * turb_scale
turb_dark = 50;
turb_scale = 0.0024;
vase_turbi_turb = turb_scale * (vase_turbi(:,7) - turb_dark);
num_vase_turbi_turb = turb_scale * (num_vase_turbi(:,7) - turb_dark);
phyto2_turbi_turb = turb_scale * (phyto2_turbi(:,7) - turb_dark);
num_phyto2_turbi_turb = turb_scale * (num_phyto2_turbi(:,7) - turb_dark);



%% figure VASE
fig_vase = figure('numbertitle','off','name','VASE','Position',[10 150 1200 1200]);
% -------------------- Droite
subplot(7,2,4)
plot(vase_c_rover_tr,num_vig_unique_vase(:,2),'b.');
% xlim([num_vig_unique_vase(1,1) num_vig_unique_vase(end,1)]);
xlim([0 1]);
ylabel('Nb vignettes UVP6');
xlabel('Transmittance (C rover)');
title('VASE');

subplot(7,2,6)
plot(vase_bbp700,num_vig_unique_vase(:,2),'b.');
ylabel('Nb vignettes UVP6');
xlabel('BBp700 in m-1');

subplot(7,2,8)
plot(vase_bbp_cdom,num_vig_unique_vase(:,2),'b.');
ylabel('Nb vignettes UVP6');
xlabel('FL CDOM in µg/L');

subplot(7,2,10)
plot(vase_bbp_fluo,num_vig_unique_vase(:,2),'b.');
ylabel('Nb vignettes UVP6');
xlabel('FL (ECO) in µg/L');

subplot(7,2,12)
plot(vase_turbi_fluo,num_vig_unique_vase(:,2),'b.');
ylabel('Nb vignettes UVP6');
xlabel('FL (Turb) in µg/L');

subplot(7,2,14)
plot(vase_turbi_turb,num_vig_unique_vase(:,2),'b.');
ylabel('Nb vignettes UVP6');
xlabel('Turbidity (NTU)');

% ------------------- Gauche
num_vig_unique_vase_time = datetime(num_vig_unique_vase(:,1), 'ConvertFrom', 'datenum');
num_vase_c_rover_time = datetime(num_vase_c_rover(:,1), 'ConvertFrom', 'datenum');
num_vase_bbp_time = datetime(num_vase_bbp(:,1), 'ConvertFrom', 'datenum');
num_vase_turbi_time = datetime(num_vase_turbi(:,1), 'ConvertFrom', 'datenum');

subplot(7,2,1)
plot(num_vig_unique_vase_time,num_vig_unique_vase(:,2),'r.');
xlim([num_vig_unique_vase_time(1) num_vig_unique_vase_time(end)]);
xlabel('Time');
ylabel('Nb vignettes UVP6');

subplot(7,2,3)
plot(num_vase_c_rover_time,num_vase_c_rover_tr,'b.');
xlim([num_vig_unique_vase_time(1) num_vig_unique_vase_time(end)]);
xlabel('Time');
ylabel('Transmittance (C rover)');
ylim([0 1]);

subplot(7,2,5)
plot(num_vase_bbp_time,num_vase_bbp700,'b.');
xlim([num_vig_unique_vase_time(1) num_vig_unique_vase_time(end)]);
xlabel('Time');
ylabel('BBp700 in m-1');

subplot(7,2,7)
plot(num_vase_bbp_time,num_vase_bbp_cdom,'b.');
xlim([num_vig_unique_vase_time(1) num_vig_unique_vase_time(end)]);
xlabel('Time');
ylabel('FL CDOM in µg/L');

subplot(7,2,9)
plot(num_vase_bbp_time,num_vase_bbp_fluo,'b.');
xlim([num_vig_unique_vase_time(1) num_vig_unique_vase_time(end)]);
xlabel('Time');
ylabel('FL (ECO) in µg/L');

subplot(7,2,11)
plot(num_vase_turbi_time,num_vase_turbi_fluo,'b.');
xlim([num_vig_unique_vase_time(1) num_vig_unique_vase_time(end)]);
xlabel('Time');
ylabel('FL (Turb) in µg/L');

subplot(7,2,13)
plot(num_vase_turbi_time,num_vase_turbi_turb,'b.');
xlim([num_vig_unique_vase_time(1) num_vig_unique_vase_time(end)]);
xlabel('Time');
ylabel('Turbidity (NTU)');

% --------------- Enregistrement
orient tall
set(gcf,'PaperPositionMode','auto')
saveas(fig_vase,[path_vase,'vase.png']);
savefig(fig_vase,[path_vase,'vase.fig']);

%% figure PHYTO2
fig_phyto2 = figure('numbertitle','off','name','PHYTO2','Position',[10 150 1200 1200]);
% -------------------- Droite
subplot(7,2,4)
plot(phyto2_c_rover_tr,num_vig_unique_phyto2(:,2),'b.');
% xlim([num_vig_unique_phyto2(1,1) num_vig_unique_phyto2(end,1)]);
xlim([0 1]);
ylabel('Nb vignettes UVP6');
xlabel('Transmittance (C rover)');
title('Phyto2');

subplot(7,2,6)
plot(phyto2_bbp700,num_vig_unique_phyto2(:,2),'b.');
ylabel('Nb vignettes UVP6');
xlabel('BBp700 in m-1');

subplot(7,2,8)
plot(phyto2_bbp_cdom,num_vig_unique_phyto2(:,2),'b.');
ylabel('Nb vignettes UVP6');
xlabel('FL CDOM in µg/L');

subplot(7,2,10)
plot(phyto2_bbp_fluo,num_vig_unique_phyto2(:,2),'b.');
ylabel('Nb vignettes UVP6');
xlabel('FL (ECO) in µg/L');

subplot(7,2,12)
plot(phyto2_turbi_fluo,num_vig_unique_phyto2(:,2),'b.');
ylabel('Nb vignettes UVP6');
xlabel('FL (Turb) in µg/L');

subplot(7,2,14)
plot(phyto2_turbi_turb,num_vig_unique_phyto2(:,2),'b.');
ylabel('Nb vignettes UVP6');
xlabel('Turbidity (NTU)');

% ------------------- Gauche
num_vig_unique_phyto2_time = datetime(num_vig_unique_phyto2(:,1), 'ConvertFrom', 'datenum');
num_phyto2_c_rover_time = datetime(num_phyto2_c_rover(:,1), 'ConvertFrom', 'datenum');
num_phyto2_bbp_time = datetime(num_phyto2_bbp(:,1), 'ConvertFrom', 'datenum');
num_phyto2_turbi_time = datetime(num_phyto2_turbi(:,1), 'ConvertFrom', 'datenum');

subplot(7,2,1)
plot(num_vig_unique_phyto2_time,num_vig_unique_phyto2(:,2),'r.');
xlim([num_vig_unique_phyto2_time(1) num_vig_unique_phyto2_time(end)]);
xlabel('Time');
ylabel('Nb vignettes UVP6');

subplot(7,2,3)
plot(num_phyto2_c_rover_time,num_phyto2_c_rover_tr,'b.');
xlim([num_vig_unique_phyto2_time(1) num_vig_unique_phyto2_time(end)]);
xlabel('Time');
ylabel('Transmittance (C rover)');
ylim([0 1]);

subplot(7,2,5)
plot(num_phyto2_bbp_time,num_phyto2_bbp700,'b.');
xlim([num_vig_unique_phyto2_time(1) num_vig_unique_phyto2_time(end)]);
xlabel('Time');
ylabel('BBp700 in m-1');

subplot(7,2,7)
plot(num_phyto2_bbp_time,num_phyto2_bbp_cdom,'b.');
xlim([num_vig_unique_phyto2_time(1) num_vig_unique_phyto2_time(end)]);
xlabel('Time');
ylabel('FL CDOM in µg/L');

subplot(7,2,9)
plot(num_phyto2_bbp_time,num_phyto2_bbp_fluo,'b.');
xlim([num_vig_unique_phyto2_time(1) num_vig_unique_phyto2_time(end)]);
xlabel('Time');
ylabel('FL (ECO) in µg/L');

subplot(7,2,11)
plot(num_phyto2_turbi_time,num_phyto2_turbi_fluo,'b.');
xlim([num_vig_unique_phyto2_time(1) num_vig_unique_phyto2_time(end)]);
xlabel('Time');
ylabel('FL (Turb) in µg/L');

subplot(7,2,13)
plot(num_phyto2_turbi_time,num_phyto2_turbi_turb,'b.');
xlim([num_vig_unique_phyto2_time(1) num_vig_unique_phyto2_time(end)]);
xlabel('Time');
ylabel('Turbidity (NTU)');

% --------------- Enregistrement
orient tall
set(gcf,'PaperPositionMode','auto')
saveas(fig_phyto2,[path_phyto2,'phyto2.png']);
savefig(fig_phyto2,[path_phyto2,'phyto2.fig']);