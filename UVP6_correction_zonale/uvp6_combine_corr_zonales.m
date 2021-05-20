%% Création de matrices de correction zonale UVP6
% utilise les matrices individuelles
% fournit matrice binaires formattées UVP6
% Picheral 2019/06/04


clear all
close all

warning('off','all')


disp('------------------- START COMBINING ZONAL MATRIX --------------')

% ------------------ Nb de matrices à combiner -----------------------
nb_mat = input('Number of matrix to combine (CR = 1) ? ');
if isempty(nb_mat)nb_mat = 1;end

mattype = input('Type of matrix (CR = 1/64, n = 1/32) ? ','s');
if isempty(mattype); mattype = 'd';end

% ------------------ Repertoire de stockage --------------------------
disp('SELECT FOLDER to save the combined BINARY MATRIX  ')
folder = uigetdir('Select Folder to save binary matrix');

% ------------------- Figure vide ----------------------------------
fig1 = figure('numbertitle','off','name','UVP6_cor_zonale','Position',[10 50 1200 700]);

% ----------------- boucle sur les matrices individuelles -----------
mat = NaN * zeros(129,154,nb_mat);
xplots = 3;
yplots = ceil((nb_mat+1)/xplots);
disp('--------------------------------------------------------------------')
for vv = 1 : nb_mat
    [FILENAME, PATHNAME, FILTERINDEX] = uigetfile(['*gauss_*.mat'], 'Select individual matrix to combine/process ');
    disp(FILENAME)
    ff = load([PATHNAME,FILENAME]);
    mat(:,:,vv)  = ff.ff;
    % --------- Figure de la matrice individuelle ----------
    subplot(yplots,xplots,vv)
    imagesc(mat(:,:,vv),[1 6]);
    mini = min(min(mat(:,:,vv)));
    maxi = max(max(mat(:,:,vv)));
    aa= FILENAME == '_';
    FILENAME(aa) = ' ';
    xlabel([FILENAME,' [1 - ',num2str(maxi,2),']'],'fontsize',7);
    title(['Matrix ',num2str(vv), 'mean : ',num2str(mean(mean(mat(:,:,vv))))]);
    disp('--------------------------------------------------------------------')
end

% --------------- Matrice finale --------------------------
long = 30;
while long > 25
    filename = input('Final name (less than 25 char, no space !) ','s');
    long = numel(filename);
    if long > 25
        disp('The name is too long !')
    end
end

ff = mean(mat,3);
subplot(yplots,xplots,nb_mat+1)
imagesc(ff,[1 6]);
mini = min(min(ff));
maxi = max(max(ff));
file = filename;
aa= find(file == '_');
file(aa) = ' ';
xlabel([file,' [1 - ',num2str(maxi,2),']'],'fontsize',6);
title(['COMBINED Matrix ', 'mean : ',num2str(mean(mean(ff)))]);

% --------------- Sauvegarde de l'image ------------------
cd(folder)
orient tall
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',filename);
disp('------------------- GRAPH SAVED -------------------------------')

%% ----------------- Sauvegarde de la matrice ---------------
if strcmp(mattype,'n')
    save_for_OCTOPUS(ff, filename, filename)
else
    save_for_OCTOPUS_d(ff, filename, filename)    
end

disp(['SAVING folder : ',folder])
disp(['Filename      : ',filename])

disp('------------------- MATRIX SAVED ------------------------------')

