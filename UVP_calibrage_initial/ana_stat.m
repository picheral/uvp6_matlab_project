function [results] = ana_stat(to_analyze)

% ana_stat(to_analyze)
%
% Exploitation statistique des données récupérés grâce à graph_trajectories
% / graph_area
%
%  Données pour 'ana_stat' :
%       Input : 
%            to_analyze : tableau avec  
%                   2 ou 3 colonnes
%               
%      Output : 
%            results : table de résultat contenant : le nombre de points
%               sélectionnées, l'aire moyenne, l'aire médiane,
%               l'écart-type, l'aire min et l'aire max 
%    
%
% Blandine JACOB - 05 mai 2022


%% 

%création/initialisation vecteur résultat


%boucle pour récupérer l'aire
    
if size(to_analyze,2) == 3 %cas où les données "brush" viennent de graph_trajectories
    area = to_analyze(:,3) ;

else 
    if size(to_analyze,2) ==2 %cas où les données "brush" viennent de graph_area
        area = to_analyze(:,2) ;

    end
end

nombre_observations = size(to_analyze,1);
aire_moyenne = mean(area);
aire_mediane = median(area);
ecart_type = std(area);
aire_min=min(area);
aire_max = max(area);

%creation d'une table de resultat
results = table(aire_moyenne,aire_mediane,ecart_type,aire_min,aire_max);

%ecriture de la table dans un fichier .dat
writetable(results,'resultats.dat')