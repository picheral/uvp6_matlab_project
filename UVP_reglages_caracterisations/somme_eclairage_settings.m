function [Lref_mm px orient longmm large longpx uvp a b c d level cor_img Lref_pixels] = somme_eclairage_settings(uvp5sn)

Lref_mm = 275;
Lref_pixels = 1500;
% a : hauteur du centre du faisceau (1012)
% b : x fin flèche gauche (50)
% c : x fin flèche droite (1994)
% d : hauteur selectionnée (1000)
% disp('START LOADING IMAGES');
a = input('Hauteur du centre du faisceau (1012) '); 
if isempty(a); a = 1012; end
b = input('Fin flèche gauche (50) ');
if isempty(b); b = 50; end
c = input('Fin flèche droite (1994) ');
if isempty(c); c = 1994; end
d = input('Hauteur sélectionnée (800) ');
if isempty(d); d = 800; end
Lref_mm = input(['Distance in mm beetween the two arrows : (',num2str(Lref_mm), ' mm) ']);
if isempty(Lref_mm);    Lref_mm = 275;  end
orient = input('Long side along light (y/n) ? ','s');
if isempty(orient); orient = 'y';end
longmm = input('Lenght of side parallel to light tube (default : 188 mm)  ');
if isempty(longmm);    longmm = 188;    end
level = input('Image distances from center (default : [-8:2:8]) ');
if isempty(level); level = [-8:2:8]; end
cor_img = input('Correction factor for the intensity (default = 1) ');
if isempty(cor_img); cor_img = 1;end

ee = findstr(uvp5sn,'sn');
if ~isempty(ee)
    uvp = uvp5sn(ee(1)+2:end);
else
    uvp = uvp5sn;
end
if str2num(uvp(1:3)) >= 200  
    large = longmm;
else
    large = 960*longmm/1280;
    if strcmp(orient,'n'); large = 1280*longmm/960;end
end
% longueur en pixels pour la longueur image en mm correcpondante
% longpx = longmm * Lref_mm /100;
longpx = longmm * Lref_pixels / Lref_mm;

px = Lref_mm/Lref_pixels;

scrsz = get(0,'ScreenSize');