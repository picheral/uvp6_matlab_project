function [] = graph_trajectories(table_processed)

% graph_trajectories(table)
%  Creation de graphiques a partir d'une table de donnees
%
%  Données pour 'graph_trajectories' :
%       Input : 
%           table_processed :  table de donnees créée à partir de la
%               fonction process_table
%               
%       
%    
%
% Blandine JACOB - 04 mai 2022

%% graph_trajectoires :

figure()


%trajectoire X, Y particules brutes 
% commenté : on peut rajouter table_brute en input et tracées la
% trajectoire de toutes les particules

% subplot(2,1,1);
% scatter3(table_brute.xcenter, table_brute.ycenter, table_brute.area , '+')
% title ('Trajectoire des particules - brutes - 3D ');
% xlabel('X')
% ylabel('Y')
% zlabel('Aire')


%trajectoire 3D X,Y de la (supposée) particule : intérêt on récupère
%l'aire
subplot(2,1,1);
scatter3(table_processed.xcenter, table_processed.ycenter, table_processed.area_particle,'+')
title ('Trajectoire 3D de la particule d interet') 
xlabel('X')
ylabel('Y')
zlabel('Aire')
%outil brush afin de récupérer sur les graphiques les points qui nous
%intéressent 


%trajectoire X,Y de la (supposée) particule 
subplot(2,1,2);
brush on
scatter(table_processed.xcenter, table_processed.ycenter,'+')
title ('Trajectoire 2D de la particule d interet')
xlabel('X')
ylabel('Y')
%outil brush afin de récupérer sur les graphiques les points qui nous
%intéressent






