function [table_processed] = to_modif(table_processed, table_brute, vect_image_index, n_obj);

%% to_modif(table_processed, table_brute, vect_image_index, n_obj)
% 
% Post-traitement d'une table afin de traiter les points aberrants visibles
% sur les graphiques d'aire et de trajectoire
%
% Fonction initialement pensée pour lorsque la pipette est découpée en
% plusieurs partie
%
%  Données pour 'to_modif' :
%       Input : 
%               table_processed : table déjà traitée, contenant : index,
%                   aire_total, xcenter, ycenter, area_particle. Obtenue avec
%                   la fonction process_table
%               table_brute : table obtenu avec extraction_data
%               vect_image_index : vecteur contenant les index des images à
%                   re-traiter, correspondant aux points aberrants. A
%                   déterminer par l'utilisateur.
%               n_obj : numéro d'objet qui correspondrait à la particule
%                   d'intéret (par ex, si l'on estime que la pipette est
%                   coupé en 3 et qu'il n'y a pas d'autres particules en
%                   suspension, n_obj = 4). A déterminer par l'utilisateur.
%       Output:
%               table_processed : on retourne la table d'entrée modifier, ce qui permet de relancer directement la fin du script principal 
%                  
% Blandine JACOB - 09 mai 2022

%% 

%n_iter : nombre de lignes à modifier
n_iter = length(vect_image_index);
table_ref = table_brute ; 

for j = 1 : n_iter
    num_index = vect_image_index(j);
    T = table_ref(table_ref.index==num_index,:); 
    [max, pos] = maxk(T.area,n_obj);
    xmax = T.xcenter(pos);
    ymax = T.ycenter(pos);
    area_particle_to_modif = max(n_obj) ;
    xcenter_to_modif = xmax(n_obj);
    ycenter_to_modif = ymax(n_obj);
    table_processed.xcenter(num_index) = xcenter_to_modif;
    table_processed.ycenter(num_index) = ycenter_to_modif;
    table_processed.area_particle(num_index) = area_particle_to_modif;
end

   