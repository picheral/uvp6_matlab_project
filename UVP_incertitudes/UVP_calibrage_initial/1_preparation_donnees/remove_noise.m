function [update_table] = remove_noise(table_a_modifier,size_px_to_rmv)

% remove_noise(table_a_modifier,size_px_to_rmv)
%
%  Enlever d'une table les donnees qui correspondent au bruit 
%
%  Données pour 'remove_noise' :
%       Input : 
%               size_px_to_rmv : taille (en px) en dessous de laquelle on
%               estime que ce qui a été détecté par l'UVP est du bruit

%               table_a_modifier : table à modifier
%               
%       Output:
%            update_table : table dont a enlevé les objets de taille
%            inférieure ou égale à size_px_to_rmv
%
% Blandine JACOB - 04 mai 2022

%% remove_noise:

change = 0 ;

%commande nécessaire si table_a_modifier est l'output de 'process_table',
%(car il n'y a plus de colonne area)
if ~isempty(strmatch('area_particle',table_a_modifier.Properties.VariableNames)) %retourne 1 si la colonne area n'existe pas, 0 sinon
    table_a_modifier=renamevars(table_a_modifier,'area_particle','area');
    change = 1; %pour faire la modification à la fin de la fonction
end

% si on souhaite connaitre la taille initiale de la table avant suppression du bruit
% initial_size = size(table_a_modifier);

%identification des aires inférieures à size_px_to_rmv et modification de
%la table
toDelete = table_a_modifier.area <= size_px_to_rmv; 
table_a_modifier(toDelete,:) = [];
        
% si on souhaite connaitre la taille de la table après suppression du bruit
% update_size = size(table_a_modifier);

% si on souhaite calculer le nombre de lignes supprimées par l'UVP
% nb_obj_rmv = initial_size(1) - update_size(1); 


if change == 1
    table_a_modifier=renamevars(table_a_modifier,'area','area_particle')
end

update_table = table_a_modifier;