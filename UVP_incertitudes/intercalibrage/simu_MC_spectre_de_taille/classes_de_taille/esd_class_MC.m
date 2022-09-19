function [matrice_classes] = esd_class_MC(uvp_cast,couple_parametres)

%% Fonction Matlab : esd_class_MC
%
%
% But : récupérer les classes de tailles pour les 10^5 simu monte Carlo
%       afin de visualiser les distributions et récupérer les écarts types;
%
% Input: uvp_cast : cast de l'UVP étudié
%        couple_parametres : matrice (Aa, exp) contenant les couples issus
%                            d'une simulation MC
% Output: matrice_classes : pour enregistrer les répartitions en classes de
%                           taille via MC
%                           matrice_classes est de taille
%                           (longueur(couple_parametres),nombre classes de
%                           taille) 
%
%
% Blandine JACOB - 8 Juillet 2022

%%
esd_vect_ecotaxa = [0.0403 0.0508 0.064 0.0806 0.102 0.128 0.161 0.203 0.256 0.323 0.406 0.512 0.645 0.813 1.020 1.290 1.630 2.050 2.580];
pixsize = uvp_cast.pixsize;


matrice_classes=zeros(length(couple_parametres),length(esd_vect_ecotaxa));

aa = couple_parametres(1,:);
expo = couple_parametres(2,:);

for i=1:length(aa)
        
    % calcul taille ESD
    esd_calib = 2*((aa(i)*(pixsize.^expo(i))./pi).^0.5);
    
    % calcul de l'abondance moyenne 
    % (l'abondance dans histo_ab est en effet donnée par tranche de 5 mètres,
    % ici on prend la moyenne sur toutes les tranches)
    histo_ab_mean = nanmean(uvp_cast.histo_ab);
    
    histo_ab_mean_red = histo_ab_mean(1:numel(esd_calib));
    
    % la fonction sum_ab_classe calcule des abondances par classe de taille
    [calib_vect_ecotaxa]= sum_ab_classe(esd_calib, esd_vect_ecotaxa, histo_ab_mean_red);

    matrice_classes(i,:) =  calib_vect_ecotaxa;

end

