%% Somme eclairages UVP
% Guidi & Picheral, 2017/12


function [b max_int vol vol_100 cor_int seuil_vol_fixe] = Somme_eclairage_process(uvp5sn,drive_root,base1,base2,longpx,large,px,longmm,verrine01,verrine02,ax,bx,cx,dx,Lref_pixels,cor_img,Centre1,Centre2)

scrsz = get(0,'ScreenSize');
% disp('--------- Debut ajout et calcul volume -------------');
I1=[1:length(base1)];
tempb1=[];
templ1=[];
tempb2=[];
templ2=[];

centre = mean([Centre1 Centre2]);
seuil_net = 30;
id_start = 100;
seuil_vol_fixe = 75;
id_start = seuil_vol_fixe - 20;


[long,larg] = size(base1(I1(1)).median);
longpx = min(longpx,long);
for i=1:length(base1)
    tempb1=[tempb1;base1(I1(i)).brut];
    % Rognage sur la longueur pour calcul volume
    matr= base1(I1(i)).median;
    matrc=imcrop(matr,[0,long/2-longpx/2,larg,longpx]);
    base1(I1(i)).median = matrc;
    templ1=[templ1;matrc];
end

% Deuxieme base, ordre inverse
I2=fliplr(I1);
for i=1:length(base2)
    tempb2=[tempb2;base2(I2(i)).brut];
    % Rognage sur la longueur pour calcul volume
    matr= base2(I2(i)).median;
    matrc=imcrop(matr,[0,long/2-longpx/2,larg,longpx]);
    base2(I2(i)).median = matrc;
    templ2=[templ2;matrc];
end

Mb1=max(max(tempb1));
Nb1=min(min(tempb1));
Ml1=max(max(templ1));
Nl1=min(min(templ1));

Mb2=max(max(tempb2));
Nb2=min(min(tempb2));
Ml2=max(max(templ2));
Nl2=min(min(templ2));

% -------------- PLOT PROFILE ------------------------
fig1 = figure('name','Eclairages UVP5 profiles','Position',[50 50 scrsz(3)/1.1 scrsz(4)/5]);
fig2 = figure('name','Eclairages UVP5 somme','Position',[50 50 scrsz(3)/1.1 scrsz(4)/3]);

    
%% --------------- Boucle sur les images (9) ----------------------
max_int = [];
cor_int = [];
for i=1:length(base1)
    %     disp(i);
    brut1=base1(I1(i)).brut;
    lisse1=base1(I1(i)).median;
    % Normalisation
    %     brut1=(brut1-Nb1)/(Mb1-Nb1);
    %     lisse1=(lisse1-Nl1)/(Ml1-Nl1);
    % -------- Correction vignetage -----------------  
    J3=double(lisse1);
    I3=J3<seuil_net;
    lisse1=J3;
    lisse1(I3) = 0;  
    
    brut2=fliplr(base2(I2(i)).brut);
    lisse2=fliplr(base2(I2(i)).median);
    % Normalisation
    %     brut2=(brut2-Nb2)/(Mb2-Nb2);
    %     lisse2=(lisse2-Nl2)/(Ml2-Nl2);

    % -------- Correction vignetage -----------------  
    J3=double(lisse2);
    I3=J3<seuil_net;
    lisse2 = J3;
    lisse2(I3) = 0; 
    
    % -------- Decalage latéral si verrine pas centrée -----------
    
    
    
    
    % -------- Ajout des images issues des deux sources ----------
    brut=brut1+brut2;
    lisse=lisse1+lisse2;
    
    % ------------ Intensité moyenne de la somme ---------
    [x y] = size(lisse);
    cor_int_img = nanmean(nanmean( imcrop(lisse,[y/2-50,0,100,x]))); 
    cor_int = [ cor_int cor_int_img];
    
    % ------------ Option calcul volume avec une seule verrine -------
    %     brut=brut1+ones(size(brut1));
    %     lisse=lisse1+ones(size(lisse2));
    
    
    
    %         figure(1)
    %         subplot(3,3,i)
    %         h=pcolor(brut);
    %         set(h,'edgeColor','none')
    %         m=max(max(brut));
    %         n=min(min(brut));
    %         title(['Min: ' num2str(n) ' Max: ' num2str(m)])
    %         figure(2)
    %         subplot(3,3,i)
    %         plot(brut')
    
    %% Unites metriques (px)
    [a,b]=size(lisse);
    Z=repmat([1:b]*px,a,1);
    Y=repmat([1:a]'*px,1,b);
    X=ones(a,b)*base1(I1(i)).level*10+large/2;
    
    %% Creation base A
    A(i).level=base1(I1(i)).level;
    A(i).pic1=base1(I1(i)).pic;
    A(i).pic2=base2(I2(i)).pic;
    A(i).brut=brut;
    A(i).median=lisse;
    A(i).X=X;
    A(i).Y=Y;
    A(i).Z=Z;
    
    %     figure(1)
    %     hold on
    %     h=surf(X,Y,Z,lisse);
    %     set(h,'edgecolor','none')
    %     hold on
    %     view(-14,36)
    
    % ------------- Figure sommee (lisse) ---------------
    figure(fig2);
    subplot(1,numel(base1),i)
    if i==1
        ylabel(['Total length = ',num2str(longmm),'mm']);
    end
    
    %h=pcolor(lisse);
    h = imagesc(lisse,[0 512]);
    % set(h,'edgeColor','none')
    m=round(max(max(lisse)));
    n=round(min(min(lisse)));
    % --------- Vecteur intensités max ------------------
    max_int = [max_int m];
    title(['Min: ' num2str(n) ' Max: ' num2str(m)])
    %     figure(4)
    %     subplot(3,3,i)
    %     plot(lisse')
    
    % -------------- PLOT PROFILE / IMG ------------------------
    %     fig1 = figure('name','Eclairages UVP5 profiles','Position',[50 50 scrsz(3)/1.1 scrsz(4)-200]);
    figure(fig1);
    subplot(1,numel(base1),i)
    plot(Z'-mean(Z(1,:)),lisse','k')
    ylabel('Sum of relative intensity (2 lights) ','fontname','times new roman','fontsize',8)
    xlabel('Z: Dist. from the center in mm','fontname','times new roman','fontsize',8)
    set(gca,'fontname','times new roman','fontsize',10)
    set(gca,'xlim',[-40 40])
    set(gca,'ylim',[0 300])
        
    % ------------ TOUS Profiles ---------------------
    figure(10);
    plot(Z'-mean(Z(1,:)),lisse','k')
    hold on
    ylabel('Normalized intensity','fontname','times new roman','fontsize',10)
    xlabel('Z: Distance from the center in mm','fontname','times new roman','fontsize',10)
    set(gca,'fontname','times new roman','fontsize',10)
    set(gca,'xlim',[-40 40])
    set(gca,'ylim',[0 300])
    title([char(verrine01),'  ',char(verrine02)],'fontsize',12);
    %     end
end

figure(fig2);
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[drive_root,'\uvp5sn',char(uvp5sn), '_images_sum_',num2str(longmm),'mm']);

figure(fig1);
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[drive_root,'\uvp5sn',char(uvp5sn), '_all_profiles']);

X=[];
Y=[];
Z=[];
V=[];

%% Boucle sur les images (9)
for i=1:length(A)
    [l,c]=size(A(i).X);
    Xt=reshape(A(i).X,l*c,1);
    Yt=reshape(A(i).Y,l*c,1);
    Zt=reshape(A(i).Z,l*c,1);
    Vt=reshape(A(i).median,l*c,1);
    
    X=[X;Xt];
    Y=[Y;Yt];
    Z=[Z;Zt];
    V=[V;Vt];
end


Epais_Z=linspace(min(Z)-5,max(Z)+5,20);
Haut_Y=linspace(min(Y)-5,max(Y)+5,10);

% 2008 = 178.6, 2010 = large
Large_X=linspace(0,large,10);
%Large_X=linspace(0,178.6,10);

[Xi,Yi,Zi]=meshgrid(Large_X,Haut_Y,Epais_Z);
% Vi=griddata3(X(1:50:end),Y(1:50:end),Z(1:50:end),V(1:50:end),Xi,Yi,Zi,'nearest');
Vi=griddata(X(1:50:end),Y(1:50:end),Z(1:50:end),V(1:50:end),Xi,Yi,Zi,'nearest');

Xi=Xi-mean(mean(mean(Xi)));
Zi=Zi-mean(mean(mean(Zi)));

% %% --------------------- Figure 3D -----------------------------
% figure;
% p = patch(isosurface(Xi,Yi,Zi,Vi,0.6*512));
% isonormals(Xi,Yi,Zi,Vi, p)
% set(p, 'FaceColor', 'red', 'EdgeColor', 'none','FaceAlpha',0.6);
% hold on
% p = patch(isosurface(Xi,Yi,Zi,Vi,0.8*512));
% isonormals(Xi,Yi,Zi,Vi, p)
% set(p, 'FaceColor', 'green', 'EdgeColor', 'none','FaceAlpha',0.7);
% hold on
% p = patch(isosurface(Xi,Yi,Zi,Vi,1*512));
% isonormals(Xi,Yi,Zi,Vi, p)
% set(p, 'FaceColor', 'yellow', 'EdgeColor', 'none','FaceAlpha',0.9);
% hold on
% p = patch(isosurface(Xi,Yi,Zi,Vi,1.2*512));
% isonormals(Xi,Yi,Zi,Vi, p)
% set(p, 'FaceColor', 'cyan', 'EdgeColor', 'none','FaceAlpha',1);
% 
% box on
% camlight left;
% lighting gouraud
% 
% view(220,30)
% 
% h=xlabel('Y: Distance from center in mm','fontname','times new roman','fontsize',10);
% set(h,'rotation',350)
% zlabel('Z: Distance from center in mm','fontname','times new roman','fontsize',10)
% h=ylabel('X: Beam width in mm','fontname','times new roman','fontsize',10);
% set(h,'rotation',17)
% set(gca,'fontname','times new roman','fontsize',10)
% set(gca,'position',[0.2 0.3 0.7 0.5])
% set(gcf,'paperposition',[0 0 4 3])

%% ------------------ Calcul des volumes ---------------------
z=diff(Epais_Z);z=z(1);
y=diff(Haut_Y);y=y(1);
x=diff(Large_X);x=x(1);

vol = [];
g=0;

for i=id_start:2:round(min(max_int))   %500;%100:2:450%0.5:0.01:2;
    h=length(find(Vi>i));
    g=g+1;
    vol(g)=h*(x*y*z)*10^-6;
%     disp(num2str(vol(g)))
end

% Volume seuil 100 (mesure normalisee mise en place 2018/01
vol_100 = vol(seuil_vol_fixe-id_start);

% figure
% plot([0.5:0.01:2],vol);
% xlabel('Threshold','fontname','times new roman','fontsize',10);
% ylabel('Volume in Liter','fontname','times new roman','fontsize',10)
% set(gca,'fontname','times new roman','fontsize',10)

%% --------------------- Figure 12 ------------------------
% fig = figure(12);
% ax=axes('position',[0.20 0.15 0.6 0.7]);
% x=[102:2:round(min(max_int))];%[0.51:0.01:2];
% % ------------------ Brut ------------------------------------
% plot(x,diff(vol),'k','parent',ax)
% h=moy_mob(diff(vol),7);
% figure(12);hold on;plot(x,h,'r','parent',ax)
% h=moy_mob(diff(vol),15);
% figure(12);hold on;plot(x,h,'g','parent',ax)
% Valeur a modifiereventuellement: 2008 = 25, 2010 = 15, 2016 = 13

% % -------------------- FIGURE VOLUME --------------------------
% figure(12);
% hold on;
% % -------- Lisse ---------------
% h = moy_mob(diff(vol),29);
% plot(x,h,'g','parent',ax')
% % Intervalle a modifier eventuellement : 2008 = 90, 2010 = 30, Hydroptic :90
% % Permet la définition du seuil
% % [a,b]=max(h(15:120));
% [ee ff] = min(h);
% [a,b]=max(h(30:end));
% xlabel(['Light intensity '],'fontname','times new roman','fontsize',10)
% ylabel('Volume approximate derivative','fontname','times new roman','fontsize',10)
% % title(['UVP5',num2str(uvp5sn),'  ',num2str(longmm) 'x' num2str(large) 'mm  Thres.: ' num2str(x(b-1)) ' Volume: ' num2str(vol(b))],'fontname','times new roman','fontsize',10)
% title(['UVP5',num2str(uvp5sn),'  ',num2str(longmm) 'x' num2str(large) 'mm '],'fontname','times new roman','fontsize',10)
% set(ax,'fontname','times new roman','fontsize',10,'box','off','xlim',[100 500])
% % figure(12)
% ax2=axes('position',[0.20 0.15 0.6 0.7]);
% % ------------------ Profile volume -----------------
% plot([100:2:round(min(max_int))],vol,'r','parent',ax2);
% hold on
% % plot(x(b-1),vol(b),'or','markersize',6,'markerfacecolor','red','parent',ax2)
% set(ax2,'YColor','red','YAxisLocation','right','color','none','box','off','xtick',[],'fontname','times new roman','fontsize',10,'xlim',[100 500])
% h=ylabel('Volume in Liter','fontname','times new roman','fontsize',10,'rotation',-90);
% pos=get(h,'position');
% pos(1)=550;
% set(h,'position',pos)
% % set(gcf,'paperposition',[0 0 3.15 2.5])
% saveas(fig, [drive_root,'\uvp5sn',char(uvp5sn), '_vol_',num2str(longmm),'mm.png']);
% [Y,conf,decal]=autocor_lio(diff(vol'),70,'pearson','opt');

% -------------- AJOUT trait SEUIL -------------------------
fig = figure(10);
hold on
% plot([-40 40],[x(b-1) x(b-1)],'-b','linewidth',2);
hold on
plot([-40 40],[seuil_vol_fixe seuil_vol_fixe],'-r','linewidth',2);
saveas(fig, ['uvp5sn',char(uvp5sn), '_profiles_',num2str(longmm),'mm.png']);