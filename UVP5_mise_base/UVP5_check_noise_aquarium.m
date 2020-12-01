%% Figure contrôle Bruit UVP5hd
% Picheral, 2019/10
% Présence du champ histopx et de datfile avec temperature perltier et
% camera

function UVP5_check_noise_aquarium(base,i,results_dir)

disp('Noise figure')

zmax = 100000;
zmin = 0;

% ------------- Mise au pas histopx ------------
Histopx = base(i).histopx;

% ---------- Zmax ----------------
% zmax = min(zmax,max(Datfile(:,2)));
zmax = min(zmax,max(Histopx(:,1)));

zmax = 100 * ceil(zmax/100);

ee = find(Histopx(:,1)>= zmin);
deb = ee(1);
ee = find(Histopx(:,1)< zmax);
fin = ee(end);

% ------------ Vecteur Profondeur DATA --------------

% Z_vect = [1: numel(base(i).datfile.image)]';
Z_vect = [1:numel(base(i).datfile.image)] * (max(Histopx(:,2))/numel(base(i).datfile.image));

% ------------ Metadata image -----------------------
% ------ Correction du vecteur Z par Nb image par bloc dans Kistopx -------
Datfile = [base(i).datfile.image Z_vect' base(i).datfile.temp_interne base(i).datfile.peltier base(i).datfile.temp_cam];

Data = NaN * ones(size(base(i).histopx(deb:fin),2),5);
for j = 1: size(Data,1)-1
    aa = find( Datfile(:,2) >= base(i).histopx(j,1) & Datfile(:,2) < base(i).histopx(j+1,1) ) ; 
    if ~isempty(aa)
        Data(j,:) = nanmean(Datfile(aa,:),1);
    end
end

%% ----------- Limites regulation temperature --------------
temp_cam = base(i).datfile.temp_cam;
temp_cam_stab = temp_cam(ceil(2*numel(temp_cam)/3):end);
temp_cam_min_reg = min(temp_cam_stab);
temp_cam_max_reg = max(temp_cam_stab);
disp(['Min temp cam : ',num2str(temp_cam_min_reg,3)])
disp(['Max temp cam : ',num2str(temp_cam_max_reg,3)])

%% ----------- Peltier et Temp_cam / pressure ---------------
fig4 = figure('numbertitle','off','name','UVP5_spectres_pixels','Position',[10 50 800 1100]);
subplot(3,2,1)
% -------- data -----------
plot(base(i).datfile.peltier,[1:size(base(i).datfile.peltier,1)])
hold on
plot(base(i).datfile.temp_cam,[1:size(base(i).datfile.peltier,1)])
% -------- limites temp cam -----------
hold on
plot([temp_cam_min_reg temp_cam_min_reg],[0 numel(temp_cam)],'r');
hold on
plot([temp_cam_max_reg temp_cam_max_reg],[0 numel(temp_cam)],'r');

legend('Peltier','Camera','Location','best')
pvmtype = char(base(i).pvmtype);
aa = strfind(pvmtype,'_');
pvmtype(aa) = ' ';
title([pvmtype,' : Tcam range : ',num2str(temp_cam_min_reg,3), ' - ',num2str(temp_cam_max_reg,3),' [°C]'])
xlabel('Temperature [°C]')
ylabel('Image')
xlim([0 40]);
grid ON

%% ----------------- Boucle sur les plots -----------------------
N = 10;
disp('----------------------------')
disp('Nb 0.25 0.50 0.75 mean')
for j = 1:5
    subplot(3,2,j+1)
    semilogy(Data(:,5),movmean(Histopx(deb:fin,j+4),N),'b.')
    Smm = base(i).a0 * j^base(i).exp0;
    esd = 2 * (Smm/3.1416)^0.5;
    ylabel(['Rel abundance ',num2str(round(esd * 1000)),' µm : ',num2str(j),' px']);
    xlabel('Camera temperature [°C]');
    title(['Max = ',num2str(max(movmean(Histopx(deb:fin,j+4),N)))]);
    xlim([16,26]);
    if j == 1
%         grid ON
        limites =([1 100000]);       
    elseif j==2
        grid ON
        limites =([0.01 500]);
    elseif j==3
        limites=([0.001 1]);
        grid ON
    else        
        limites = [0.0001 1];
        grid ON
    end
    grid ON
    
    ylim(limites);
    
    % -------- limites temp cam -----------
    hold on
    semilogy([temp_cam_min_reg temp_cam_min_reg],[min(limites) max(limites)],'r');
    hold on
    semilogy([temp_cam_max_reg temp_cam_max_reg],[min(limites) max(limites)],'r');
    hold on
    
    % ------------ Affichage -------------------
    y = quantile(Histopx(deb:fin,j+4),[.25 .5 .75]);
    disp([num2str(j),' px : ',num2str(y) , '   ',num2str(nanmean(Histopx(deb:fin,j+4)))])
end
    

% ----------------- Sauvegarde IMAGE --------------------------------
orient tall
saveas(fig4,[results_dir,['cast_' char(base(i).profilename)],'_noise_a.png']);
saveas(fig4,[results_dir,['cast_' char(base(i).profilename)],'_noise_a.fig']);
close(fig4);

% %% ----------- Peltier et Temp_cam / pressure ---------------
% fig5 = figure('numbertitle','off','name','UVP5_spectres_pixels','Position',[10 50 800 1100]);
% subplot(3,2,1)
% plot(base(i).datfile.peltier,[1:size(base(i).datfile.peltier,1)])
% hold on
% 
% plot(base(i).datfile.temp_cam,[1:size(base(i).datfile.peltier,1)])
% 
% legend('Peltier','Camera','Location','best') 
% xlabel('Temperature [°C]')
% ylabel('Image')
% 
% %% ----------------- Boucle sur les plots -----------------------
% N = 10;
% disp('----------------------------')
% disp('Nb 0.25 0.50 0.75 mean')
% for j = 6:10
%     subplot(3,2,j+1-6)
%     semilogy(Data(:,5),movmean(Histopx(deb:fin,j+4),N),'.')
%     Smm = base(i).a0 * j^base(i).exp0;
%     esd = 2 * (Smm/3.1416)^0.5;
%     ylabel(['Rel abundance ',num2str(round(esd * 1000)),' µm']);
%     xlabel('Temperature [°C]');
%     xlim([16,24]);
%     % ------------ Affichage -------------------
%     y = quantile(Histopx(deb:fin,j+4),[.25 .5 .75]);
%     disp([num2str(j),' px : ',num2str(y) , '   ',num2str(nanmean(Histopx(deb:fin,j+4)))])
% end
%     
% 
% % ----------------- Sauvegarde IMAGE --------------------------------
% orient tall
% saveas(fig5,[results_dir,['cast_' char(base(i).profilename)],'_noise_b.png']);
% close(fig5);