function [matrice_reduced, matrice_detailed] = esd_class_ecopart_MC(uvp_cast,couple_parametres)

%% Fonction Matlab : esd_class_ecopart_MC
%
%
% But : récupérer les classes de tailles pour les 10^5 simu monte Carlo
% afin de visualiser les distributions et récupérer les écarts types;
%
%
% Input: uvp_cast : cast de l'UVP étudié
%        couple_parametres : matrice (Aa, exp) contenant les couples issus
%                            d'une simulation MC
% Output: matrice_reduced: pour enregistrer les répartitions en classes de
%                          taille via MC
%         matrice_detailed: pour enregistrer les répartitions en classes de
%                           taille via MC
%   --> Les classes de taille sont celles d'ecopart
%   --> Les matrices sont de taille (longueur(couple_parametres),nombre
%                                                                   classes de taille) 
%
% Blandine JACOB - 28 Juillet 2022
%

%%
% NB : cette fonction a été créée parce que les classes ecopart et celles
%      nommées "ecotaxa" dans les codes d'intercalibrage étaient différentes
% Cepdendant : c'est une erreur de typo, les classes detailed de ecopart sont les même que celles d'ecotaxa
%
% Donc : l'intéret de cette fonction devient limité, d'autant plus que les
%       classes de taille reduced ne sont pas très utilisées

%% vecteurs de classe de taille ecopart

% classe de 'reduced particle histogram'
esd_vect_ecopart_reduced = [0.032 0.064 0.128 0.256 0.512 1.02 2.05 4.1] ;

% classe de 'detailed particle histogram'
esd_vect_ecopart_detailed = [0.0403 0.0508 0.064 0.0806 0.102 0.128 0.161 0.203 0.256 0.323 0.406 0.512 0.645 0.813 1.02 1.29 1.63 2.05 2.58 3.25 4.1 5.16 6.5 8.19 10.3 13 16.4 20.6 26  ] ;

% matrice_reduced et matrice_detailed pour enregistrer les répartitions en
% classes de taille via MC
matrice_reduced = zeros(length(couple_parametres),length(esd_vect_ecopart_reduced));
matrice_detailed=zeros(length(couple_parametres),length(esd_vect_ecopart_detailed));

pixsize = uvp_cast.pixsize;
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

    % calcul des abondances par classe de taille
    [calib_vect_ecopart_reduced]= sum_ab_classe(esd_calib, esd_vect_ecopart_reduced, histo_ab_mean_red);
    
    matrice_reduced(i,:)= calib_vect_ecopart_reduced ;
    
    histo_ab_mean = nanmean(uvp_cast.histo_ab);  
    histo_ab_mean_red = histo_ab_mean(1:numel(esd_calib));
    [calib_vect_ecopart_detailed]= sum_ab_classe(esd_calib, esd_vect_ecopart_detailed, histo_ab_mean_red);

    matrice_detailed(i,:)=  calib_vect_ecopart_detailed ;

end

