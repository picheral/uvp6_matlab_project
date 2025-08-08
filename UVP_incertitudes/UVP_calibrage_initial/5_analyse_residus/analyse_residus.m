%% Script Matlab : analyse_residus
%
% But : analyser les résidus d'une régression afin de détecter les points
% qui ont une influence sur la régression
% 
% Blandine JACOB - 08 juin 2022

%% load data

% --------------------------------- !!! attention chemin en dur !!! ---------------------------------
data = readtable('Z:\UVP_incertitudes\1.etude_calibrage_initial_en_aquarium\simu_monte_carlo\data');

%enlève un points abberant qui "ruine" la régression
toDelete_pts_aberrants = [66];
data(toDelete_pts_aberrants,:)=[];

% remove NaN data
toDelete = isnan(data.Area_moy);
data(toDelete,:) = [];

p=height(data); % number of particles
donnees_bino = data(:,[1:3]); 
donnees_uvp = data (:, [4:6]);

%% régression


type_fit = input('Modele linéaire ou puissance ? lineaire/puissance: ');

while  (strcmp(type_fit,'lineaire') || strcmp(type_fit,'puissance'))==0
    type_fit = input('Mauvaise réponse: modele linéaire ou puissance ? lineaire/puissance: ');
end

modele_robuste='off';

switch type_fit

    case 'lineaire'

    X = log(data.Area_moy);
    Y = log(data.Area_bino_mm_2);

    modele_ponderation = 'non' ;
    

    [res,gof, output] = fit_linear(X, Y,[], modele_ponderation,modele_robuste);

    case 'puissance'

    X = data.Area_moy;
    Y = data.Area_bino_mm_2;

    modele_ponderation = input('Modele pondéré ? oui/non: ')

    [fitresult, gof,output] = fit_power(X, Y, data.Nb_observations, modele_ponderation, modele_robuste);
end


 




%% figures pour l'analyse des résidus

% plot residuals vs fitted
figure(6)
x = res(log(data.Area_moy));
y = output.residuals;
scatter(x,y)
xlabel('fitted values');
ylabel('residuals');
title('Residuals vs fitted')

% qq plot 
figure(2)
h = leverage(log(data.Area_moy));
u = y./((gof.rmse).*sqrt(1-h)) ; %standardized residuals
qqplot(u)


% scale - location plot
figure(3)
scatter(x,sqrt(abs(u)))
xlabel('fitted values');
ylabel('squared standardized residuals');
title('scale-location plot')

% residuals vs leverage plot
figure(4)
scatter(h,u)
xlabel('leverage')
ylabel('standardized residuals')
title('residuals vs leverage plot')

% plot residuals
figure(5)
scatter([1:size(data,1)],y)
xlabel('number of particle')
ylabel('residuals')
title('Residuals')