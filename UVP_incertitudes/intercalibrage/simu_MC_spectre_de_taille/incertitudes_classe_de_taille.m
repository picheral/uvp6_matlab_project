function [ecart_type_ab] =  incertitudes_classe_de_taille(matrice_classes)

%% Fonction Matlab : classe_de_taille_et_incertitudes
%
%
% But : calculer les incertitudes par classe de taille
%
% Blandine JACOB - 1er juillet 2022

%%
ecart_type_ab = zeros(width(matrice_classes),1);
for i=1:width(matrice_classes)
    % x est composé des 10^5 valeur de la classe n°i
    x = matrice_classes(:,i);
    % récupération de l'écart type par classe
    ecart_type_ab(i)=std(x);
end






