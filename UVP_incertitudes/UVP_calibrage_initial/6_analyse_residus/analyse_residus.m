%% Script Matlab : analyse_residus
%
% But : analyser les résidus d'une régression afin de détecter les points
% qui ont une influence sur la régression
% 
% Blandine JACOB - 08 juin 2022

%% load data

data = readtable('C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\UVP_calibrage_initial\5_Monte-carlo\data');

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

addpath('C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\UVP_calibrage_initial\3_creation_fit')

[res,gof, output] = fit_linear(log(data.Area_moy) , log(data.Area_bino_mm_2))
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