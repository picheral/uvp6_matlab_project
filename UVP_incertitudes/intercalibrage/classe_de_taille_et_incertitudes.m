function [ecart_type_ab] = classe_de_taille_et_incertitudes(score, matrice_classes)

%% Fonction Matlab : classe_de_taille_et_incertitudes
%
%
% But : 
%
% Blandine JACOB - 1er juillet 2022

%%
% on enlève les simulations MC pour lesquelles l'optimisation n'avait pas
% abouti

to_remove = [];
for i=1:length(score)
    if score(i)>0.02
        disp(i)
        to_remove = [to_remove ; i];
    end
end
matrice_classes(to_remove,:) = [];
%%
% répartition et écart-type des abondances par taille
%

ecart_type_ab = zeros(width(matrice_classes),1);
for i=1:width(matrice_classes)
    figure(i)
    % x est composé des 10^5 valeur de la classe n°i
    x = matrice_classes(:,i);
    histogram(x)
    %récupération de l'écart type par classes
    ecart_type_ab(i)=std(x);
end

