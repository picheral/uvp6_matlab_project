% crop des images pour centrage avant analyse
% Modifiee Marc Picheral 2010/11/26, 2017/12/10


function [base Centre] = Calculs_eclairages_uvp5_tr_param(rep_file,ax,bx,cx,dx,level,cor_img,Lref_pixels,corr_matrix)
% a : hauteur du centre du faisceau (1012)
% b : x fin flèche gauche (50)
% c : x fin flèche droite (1994)
% d : hauteur selectionnée (1000)
% disp('START LOADING IMAGES');
scrsz = get(0,'ScreenSize');

disp(['Rep = ',char(rep_file)]);

% rep_file contient les n images correspondant à level
list_img = dir(rep_file);

Centre = [];
%% Boucle sur les images
for gg=1:numel(level)
    % Ouverture image
    photo = ([rep_file,'\',list_img(gg+2).name]);
%     disp(['Processing ',char(photo)])
    disp(['Image : ',num2str(gg)])
    [im,map] = imread(photo);
    im = double(im);
    im = im.*corr_matrix;
    im = uint8(im);
    % Crop
    aa = double(im(ax-dx/2:ax+dx/2,bx:cx));
    
    % Resize
    aa = imresize(aa, Lref_pixels/(cx-bx));
    im = imrotate(aa,90);
    
    % Correction intensité pour mesure avec BASLER
    im = im * cor_img;
    % Moyenne des trois canaux RGB => img2
    im2 = mean(im,3);

    % Centrage de l'image, pas de traitement en rotation
    test=median(im2(:,:));
    M=max(test);
    h1=find(test>M/2);
    h2=find(test>M/3);
    centre=mean([(h1(1)+h2(2))/2,(h1(end)+h2(end))/2]);
    Centre = [Centre centre];
    
    %     disp(['Centre = ',num2str(centre)]);
    % Rognage de part et d'autre du faisceau centre
    im3=imcrop(im2,[centre-Lref_pixels/10,0,Lref_pixels/5,Lref_pixels]);
    [a,b]=size(im3);
    
    % Calcul de l'intensité dans la zone centrale
    imi = imcrop(im2,[centre-50,200,100,Lref_pixels-200]);
    intensity = mean(imi);
    intensity = mean(intensity);
    
    % Mediane mobile pour le calcul de volume.
    matr=NaN*ones(a,b);
    l=15;
    c=15;
    for i=ceil(c/2):b-floor(c/2)
        for j=ceil(l/2):a-floor(l/2)
            pA=im3([j-floor(l/2):j+floor(l/2)],[i-floor(c/2):i+floor(c/2)]);
            cr=nanmedian(nanmedian(pA));
            matr(j,i)=cr;
        end
    end
        
    %% Creation des bases
    % Image source
    Eclairage(gg).pic=photo;
    % distance au centre en cm
    Eclairage(gg).level=level(gg);
    % image retaillee
    Eclairage(gg).brut=im3;
    % image apres mediane
    Eclairage(gg).median=matr;
    % intensité
    Eclairage(gg).intensity=intensity;
    % Correction
    Eclairage(gg).img_cor=cor_img;
    
    
end
Centre = mean(Centre);
%% Sauvegarde

base = Eclairage;
cd(char(rep_file));
save eclairage_base.mat Eclairage;
% disp(['END IMAGE PROCESS']);


%% Figure couleur des images
% fig = figure('name','Eclairages UVP5 20.0mm 6000m','Position',[50 50 scrsz(3)/1.2 scrsz(4)/2-200]);
% for gg=1:numel(level)
%     subplot(1,numel(level),gg)
%     imagesc(base(gg).median,[0 255])
%     m=max(max(matr));
%     n=min(min(matr));
%     title(['Ecl #1 : (' num2str(n) '-' num2str(m) ')']);
% end
% set (gcf,'PaperPosition',[0 0 70 30]);
% saveas(fig, [char(rep_file), '\images.png']);

end
