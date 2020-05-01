% Calcul des abondances du Zoo
% Picheral 2014/09

function dataabondances = uvp5_main_process_2014_norm_ab(base,fichier,volume_zoo,matvert,listzoonorm,min_zoo_esd)

eval('warning off MATLAB:divideByZero');
DATA = base(fichier).zoopuvp5;
pressure = base(fichier).datfile.pressure;

% --------------- Selection objets >= min_zoo_esd ------
if isempty(DATA.Areai)
    aream = DATA.Area;
else
    aream = DATA.Areai;
end
esd=2*((aream/(3.1416)).^(1/2));         % Conversion en ESD  
if isnan(esd)
     z_ident = DATA.normid(:);   
     z_zoopk = double(DATA.Depth(:));
else
    aa = find(esd >= min_zoo_esd);
    z_ident = DATA.normid(aa);   
    z_zoopk = double(DATA.Depth(aa));
end

% --------------- COLONNES ----------------------------------
% --------- Ajout des unités --------------------------------
listzoo = listzoonorm;
for m = 1:size(listzoonorm,1);
    listzoo(m) = strcat(listzoonorm(m),'(#/m3)');
end
names = [{'Zm (m)'} {'Zi (m)'} {'Ze (m)'} {'Sampled vol. (m3)'}]';
dataabondances.names = [names ; listzoo];

% ------------ Parametres --------------------------------
%   vol = 1/volume_zoo;
vol = volume_zoo;
indexdeb = 1;
depthmin = 0.5;
dataab= [];

% --------- Derniere ---------------
fin = find(pressure == max(pressure));
indexfin = max(fin);
depthmax = max(pressure);
pressure = pressure(indexdeb:indexfin);

% --------- limitation nb lignes ------
if depthmax > max(matvert); 
    matvertred = matvert;
else
    tt = find(matvert < depthmax);
    matvertred = [matvert(tt) matvert(size(tt,2)+1)];
end

% ---------- Recherche des ident dans l'intervalle de pressure --
depthmin = max(min(pressure),depthmin);
h= find(z_zoopk >= depthmin);
identdeb = h(1);
h= find([z_zoopk] < depthmax);
identfin = h(end);
ident = z_ident(identdeb:identfin);
pressureident = z_zoopk(identdeb:identfin);

% -------- Nb images par intervalle Z ----------------------------------
[ap,b]=hist(pressure,matvertred);
dataab(:,4) = ap(1:end-1)*vol/1000;

% -------- Immersion moyenne -------------------------------------------
for i = 1: size(matvertred,2)-1;
    dataab(i,2) = matvertred(i);
    dataab(i,3) = matvertred(i+1);
    a = pressureident < matvertred(i+1);
    b = pressureident >= matvertred(i);
    rr = find(a & b);
    dataab(i,1) = nanmean(pressureident(rr));   
    % ------- Remplacement des NaN par Z théorique ------------------
    if isnan(dataab(i,1));
        dataab(i,1) = mean([matvertred(i+1) matvertred(i)]);
    end
end

% ------------ BOUCLE sur les Id ------------------------------------
for i=1:size(listzoonorm,1);
    % ------------- recherche des Id dans le profil ---------
    h= strcmp(listzoonorm(i),ident);
    % ------------ Calcul des abondances -------------
    deptht= pressureident(h);
    [ad,b]=hist(deptht,matvertred);
    [sad1,sad2]=size(ad);
    if sad2==1
        ad=ad';
    end
    abondance = ad./(ap(1:end)*vol/1000);
    ff = find(isfinite(abondance));
    abond = abondance(ff);
    dataab(:,i+4) = abondance(1:end-1);
end
dataabondances.data = dataab;
