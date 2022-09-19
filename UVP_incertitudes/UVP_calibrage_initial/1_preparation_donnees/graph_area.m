function [] = graph_area(table)

% graph_area(table)
%  Creation de graphiques a partir d'une table de donnees
%
%  Données pour 'graph_area' :
%       Input : 
%            table : table de donnees créee  partir de la fonction
%            process_table
%           
%               
%   
%    
%
% Blandine JACOB - 04 mai 2022

%% graph_area


subplot(2,1,1);
scatter([1:size(table.area_total,1)],table.area_total,'+')
title('Aire totale')
xlabel('Numero d image')
ylabel('Aire totale - en pixel')

subplot(2,1,2);
scatter([1:size(table.area_total,1)],table.area_particle, '+', 'r')
title('Aire supposée de la particule')
xlabel('Numero d image')
ylabel('Aire du plus gros objet - en pixel')
brush('on')






