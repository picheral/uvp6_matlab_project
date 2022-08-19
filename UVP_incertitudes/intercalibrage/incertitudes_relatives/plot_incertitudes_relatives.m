% Script : plot_incertitudes_relatives
%
% Objectif :  tracer les incertitudes relatives des quatre UVP étudié : 
%               - uvp5-s203
%               - uvp5-sn002
%               - uvp5-sn201
%               - uvp6-sn000008LP
%
% Blandine Jacob - 28 Juillet 2022
%
%% Chargement des données

% incertitudes relatives calculées à partir du script
% incertitude_relatives.m
load('Z:\UVP_incertitudes\3_etude_incertitudes_relatives_produits_scientifiques\donnees_matlab\incertitudes_relatives.mat')
% téléchargement des 6 cast correspondant aux trois intercalibrages étudiés
load('Z:\UVP_incertitudes\3_etude_incertitudes_relatives_produits_scientifiques\donnees_matlab\les_6_cast.mat')

%% area
figure(1)
set(gcf,'Position',[200 200 800 800])
subplot(2,1,1)
plot(cast_sn203.area_mm2_calib, incert_relatives_203.area,'-r')
hold on
plot(cast_sn203_bis.area_mm2_calib, incert_relatives_203_bis.area,'-r')
hold on
plot(cast_sn201.area_mm2_calib, incert_relatives_201.area,'-b')
hold on
plot(cast_sn002.area_mm2_calib, incert_relatives_002.area,'-g')
hold on
plot(cast_sn002_bis.area_mm2_calib, incert_relatives_002_bis.area,'-g')
hold on
plot(cast_sn000008lp.area_mm2_calib, incert_relatives_000008lp.area,'-k')
xline(0.0491,'--')
xline(1.7671, '--')
yline(33,':')


ylim([0 100])
xlabel('taille en mm²')
ylabel('pourcentage')
title('Incertitudes relatives sur les tailles en mm²')
%% esd

subplot(2,1,2)
plot(cast_sn203.esd_calib, incert_relatives_203.esd,'-r')
hold on
plot(cast_sn203_bis.esd_calib, incert_relatives_203_bis.esd,'-r')
hold on
plot(cast_sn201.esd_calib, incert_relatives_201.esd,'-b')
hold on
plot(cast_sn002.esd_calib, incert_relatives_002.esd,'-g')
hold on
plot(cast_sn002_bis.esd_calib, incert_relatives_002_bis.esd,'-g')
hold on
plot(cast_sn000008lp.esd_calib, incert_relatives_000008lp.esd,'-k')
xline(0.250,'--')  %bornes d'utilisation empirique (se base sur l'article de lionel guidi et al. 2008)
xline(1.5,'--')  %bornes d'utilisation empirique (se base sur l'article de lionel guidi et al. 2008)
yline(16,':')

ylim([0 100])
legend(cast_sn203.uvp,cast_sn203_bis.uvp, cast_sn201.uvp, cast_sn002.uvp,cast_sn002_bis.uvp, cast_sn000008lp.uvp,'limite empirique basse', 'limite empirique haute')
xlabel('taille ESD')
ylabel('pourcentage')
title('Incertitudes relatives sur les tailles ESD')

%% esd class

esd_vect_ecotaxa = [0.0403 0.0508 0.064 0.0806 0.102 0.128 0.161 0.203 0.256 0.323 0.406 0.512 0.645 0.813 1.020 1.290 1.630 2.050 2.580];
milieu_classe =length(esd_vect_ecotaxa);

for i=1:(length(esd_vect_ecotaxa)-1)
    milieu_classe(i) = (esd_vect_ecotaxa(i+1)+esd_vect_ecotaxa(i))/2;
end

%pour gérer la dernière classe qui contient les objets + grands que la
%dernière borne
milieu_classe(length(esd_vect_ecotaxa))=esd_vect_ecotaxa(length(esd_vect_ecotaxa));

figure()

plot(milieu_classe, incert_relatives_203.esd_class,'o:r')
hold on
plot(milieu_classe, incert_relatives_203_bis.esd_class,'o--r')
hold on
plot(milieu_classe, incert_relatives_201.esd_class,'o--b')
hold on
plot(milieu_classe, incert_relatives_002.esd_class,'o:g')
hold on
plot(milieu_classe, incert_relatives_002_bis.esd_class,'o--g')
hold on
plot(milieu_classe, incert_relatives_000008lp.esd_class,'o--k')
xline(0.250,'--') %bornes d'utilisation empirique (se base sur l'article de lionel guidi et al. 2008)
xline(1.5,'--') %bornes d'utilisation empirique (se base sur l'article de lionel guidi et al. 2008)
yline(91.4,':')

ylim([0 100])
legend(cast_sn203.uvp,cast_sn203_bis.uvp, cast_sn201.uvp, cast_sn002.uvp,cast_sn002_bis.uvp, cast_sn000008lp.uvp,'limite empirique basse', 'limite empirique haute')
xlabel('abondance par classe de taille ESD')
ylabel('pourcentage')
title('Incertitudes relatives sur les abondances par classe de taille ESD')
