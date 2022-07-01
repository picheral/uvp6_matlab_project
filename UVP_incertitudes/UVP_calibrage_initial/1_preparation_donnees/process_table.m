function [table_for_selection] = process_table(table_ref, presence_pipette)

% process_table(table)
% 
% Création d'une table prête à être utilisée pour la fonction
% graph_area et graph_trajectories
%
%  Données pour 'process_table' :
%       Input : 
%               table_ref : table de référence contenant les index, aires et
%                    les centres de gravité
%               presence_pipette : vecteur de booléen obtenu à partir de
%                    la fonction control_images
%       Output:
%               table_for_selection : preparation d une table dont le nombre de lignes est égal au nombre d'image composée de : 
%                   index (correspond au n° d'image) 
%                   area_total : aire totale (=somme) par image des objets vu par l'UVP)
%                   xcenter et ycenter : centre de gravite de la (supposée) particule                   
%                   area_particle : aire de la (supposée) particule
%
% Blandine JACOB - 05 mai 2022

%% pre process table :



% recuperation du nombre d'image
nb_image =  table_ref.index(size(table_ref,1));

%par défaut si un seul input qui est la table, mettre le vecteur presence_pipette à 0
if nargin < 2
    presence_pipette = zeros(nb_image,1)
end

% initialisation vecteurs 
area_total = zeros(nb_image,1);

area_particle = zeros(nb_image,1);
xcenter= zeros(nb_image,1);
ycenter = zeros(nb_image,1);


%% boucle de recherche aire totale

%initialisation compteur
counter = 1 ;

% boucle sur chaque image
for i = 1 : nb_image

    % boucle while pour prendre en compte toutes les lignes du fichier bru
    % qui correspondent à l'image n°i
    while table_ref.index(counter) == i && counter < size(table_ref,1) 
        
        %calcul de l'aire total de pixel vu dans l'image i
        area_total(i) = area_total(i) + (table_ref.area(counter));
        counter = counter +1 ;
    end

end

%% boucle de recherche des aires max (plus grande et deuxième plus grande)

for i = 1 : nb_image

    % création d'une sous-table pour chaque image (une même image = un même 'index' dans la table)  
    T = table_ref(table_ref.index==i,:); 

    %recherche des deux plus grandes valeurs dans la sous-table et
    %sauvegarde de leurs valeurs dans le vecteur max et de la position dans le
    %vecteur pos
    [max, pos] = maxk(T.area,2);

    %récupération des coordonnées des centres de gravité des deux plus gros objets
    xmax = T.xcenter(pos);
    ymax = T.ycenter(pos);
    
    % (hypothèse forte!!) : si la pipette est présente on considère que la
    % particule est le deuxième plus grand objet vu par l'UVP
    if presence_pipette(i)==1
        area_particle(i) = max(2) ;
        xcenter(i) = xmax(2);
        ycenter(i) = ymax(2);
    else
        area_particle(i) = max(1) ;
        xcenter(i) = xmax(1);
        ycenter(i) = ymax(1);
    end
end


idx = [1:nb_image]'; 

table_for_selection = table(idx,area_total,xcenter,ycenter,area_particle); 
 

