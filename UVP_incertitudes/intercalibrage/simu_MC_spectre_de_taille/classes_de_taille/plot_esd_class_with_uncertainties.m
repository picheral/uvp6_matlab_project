function [] = plot_esd_class_with_uncertainties(uvp_cast,matrice_classes, ecart_type_ab);

%% Fonction :  plot_esd_class_with_uncertainties
%
% Objectif : tracer les spectres de taille avec les classes ESD avec des
% enveloppes d'incertitudes, en partie extrapolées (pour les + petites
% classes)
%
% Input : uvp_cast : qui est ajd_cast ou ref_cast, pour récupérer le
%                    vecteur calib_esd_vect_ecotaxa
%         matrice_classes : qui est matrice_classes ou matrice_classes_adj
%                           matrices issue d'une simu Monte-Carlo pour
%                           récupérer les classes de taille 
%         ecart_type_ab : idem, ecart_type_ab_adj ou ecart_type_ab_ref
%                         écart-type des abondances par classe de taille
% 
% Blandine Jacob - 8 juillet 2022

%% NB :
%
% Cette fonction n'est pas utilisée dans un script: j'importais directement
% les données matlab res_MC_propag_incert_spectre_taille.mat,
% puis j'appelais la fonction dans la fenêtre de commande afin de tracer
% les spectres de taille
%
% Pour appeler la fonction:
%    matrice_classes : matrice_classe_ref ou matrice_classe_adj
%    ecart_type_ab :  ecart_type_ab_ref ou ecart_type_ab_adj 
%    uvp_cast : ref_cast ou adj_cast


%% color of the plot

if strcmp(uvp_cast.label, 'ref')
    color_symbol = 'r';
else
    color_symbol = 'g';
end

%% calcul des enveloppes

% indices où on extrapole les enveloppes
indices_extrap = 4:9;

% les classes de taille 9 à 16 sont celles utilisées pour calculer les flux de carbone
xi = 9:16; 

% enveloppes élargies
yi_sup_elargie = mean(matrice_classes)  + 1.96*ecart_type_ab';
yi_inf_elargie = mean(matrice_classes)  - 1.96*ecart_type_ab';
yi_sup_elargie = yi_sup_elargie(xi);
yi_inf_elargie = yi_inf_elargie(xi);

y_sup_elargie =interp1(xi,yi_sup_elargie,xi);
y_inf_elargie =interp1(xi,yi_inf_elargie,xi);

% partie de l'enveloppe extrapolée - élargie
y_sup_elargie_extrap =interp1(xi,yi_sup_elargie,indices_extrap,'linear','extrap');
y_inf_elargie_extrap =interp1(xi,yi_inf_elargie,indices_extrap, 'linear','extrap');


% enveloppes non élargies
yi_sup = mean(matrice_classes) + ecart_type_ab';
yi_inf = mean(matrice_classes)  - ecart_type_ab';
yi_sup = yi_sup(xi);
yi_inf = yi_inf(xi);

y_sup = interp1(xi,yi_sup,xi);
y_inf = interp1(xi,yi_inf,xi);

% partie de l'enveloppe extrapolée - non élargie
y_sup_extrap =interp1(xi,yi_sup,indices_extrap,'linear','extrap');
y_inf_extrap =interp1(xi,yi_inf,indices_extrap, 'linear','extrap');



%% particles class plot

% plot des résultats de l'intercalibrage
semilogy(uvp_cast.calib_esd_vect_ecotaxa,strcat(color_symbol,'o'));
hold on

% plot du résultats MC en prenant la moyenne (on peut imaginer prendre le
% mode aussi)
moy = mean(matrice_classes);
plot([4:16],moy(4:16),'k+')

% plot enveloppes 
hold on
plot(xi,y_sup,strcat(color_symbol,'-'))
hold on
plot(xi,y_inf,strcat(color_symbol,'-'))
hold on
plot(indices_extrap,y_sup_extrap,strcat(color_symbol,'--'))
hold on
plot(indices_extrap,y_inf_extrap,strcat(color_symbol,'--'))

% plot enveloppes élargies
plot(xi,y_sup_elargie,strcat(color_symbol,'-'))
hold on
plot(xi,y_inf_elargie,strcat(color_symbol,'-'))
hold on
hold on
plot(indices_extrap,y_sup_elargie_extrap,strcat(color_symbol,':'))
hold on
plot(indices_extrap,y_inf_elargie_extrap,strcat(color_symbol,':'))
hold on

set(gca, 'XScale','linear', 'YScale','log')
legend('résultat intercalibrage ', 'résultat Monte-Carlo', 'enveloppes d incertitudes simple','enveloppes d incertitudes simple','enveloppes d incertitudes elargies','enveloppes d incertitudes elargies')
title(['CALIBRATED DATA'],'fontsize',14);
subtitle(uvp_cast.uvp)
xlabel('ESD CLASS [#]','fontsize',12);
ylabel('ABUNDANCE [#/L]','fontsize',12);
axis([0 15 0.01 50000]);
