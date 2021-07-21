%% resolution caracterisation on a usaf-1951
% Catalano 2021/07/19 from Picheral, 2019/12/17

clear all
close all
clc
warning off
scrsz = get(0,'ScreenSize');


disp('---------------------------------------------------------');
%{
lens_ref = input('Enter lens reference ','s');
d_reglage = input(['Distance between lens and target ? [mm] ']);


% segmentation pour récuperer les centroides (ajuster manuellement)
seuil_segmentation = input('Segmentation (0.3) ');
if isempty(seuil_segmentation); seuil_segmentation = 0.3;end
disp(['Threshold : ',num2str(seuil_segmentation)])
%}

%% input image file
disp('------------------------------------------------------')
disp("Selection of the image file")
[image_filename, image_folder] = uigetfile('*.jpg','Select the image file to cross');
disp("Selected image file : " + image_filename)
image_raw = imread([image_folder, image_filename]);
image = image_raw(808:1108,1070:1420);
disp('------------------------------------------------------')


%% -------------- Recherche barycentres ----------------
gauss_blur = 10;
segmentation = 0.2;
image_mask = imbinarize(imgaussfilt(image, gauss_blur), segmentation);
targets_positions = regionprops(image_mask);
% centroids is [x,y,area]
centroids = [cat(1, targets_positions.Centroid) [targets_positions.Area]'];

figure
imshow(image)
hold on
plot(centroids(:,1), centroids(:,2),'r+')
for i = 1 : length(centroids)
    text(centroids(i,1),centroids(i,2),[' ',num2str(i)],'FontSize',14,'Color', 'r');
end
savefig([image_folder, image_filename(1:end-4), '.fig'])
saveas(gcf,[image_folder, image_filename(1:end-4), '.png'])

%% -------------- element poistion in esaf -------------------
% usaf group and element positions compared to barycenter
% for uvp6
% g2e1h = (x-15,y) [-4,-10]
% g2e1v = (x-12,y-15) [-10,-4]
usaf(1).x_h = -19;
usaf(1).y_h = -10;
usaf(1).x_v = -22;
usaf(1).y_v = -19;
usaf(1).width = 4;
usaf(1).length = 10;
%
% g2e2h = (x+13,y+1) [+4,+9]
% g2e2v = (x+10,y+14) [+9,+4]
usaf(2).x_h = 13;
usaf(2).y_h = 1;
usaf(2).x_v = 10;
usaf(2).y_v = 14;
usaf(2).width = 4;
usaf(2).length = 9;
%
% g2e3h = (x+3,y+3) [+4,+8]
% g2e3v = (x,y+14) [+8,+4]
usaf(3).x_h = 3;
usaf(3).y_h = 3;
usaf(3).x_v = 0;
usaf(3).y_v = 14;
usaf(3).width = 4;
usaf(3).length = 8;
%
%
%{
imshow(image)
hold on 
plot(centroids(2,1), centroids(2,2),'r+')
hold on
a = centroids(2,1);
b = centroids(2,2);
plot(a+14,b,'r+')
plot(a+14,b+8,'r+')
plot(a+18,b,'r+')
plot(a+18,b+8,'r+')
figure
imshow(image(b:b+8, a+14:a+18),[0,255])
%}

%% --------------- plot profile and mean between usaf(s) ----------

for el_nb = 1:3
    w = usaf(el_nb).width;
    len = usaf(el_nb).length;
    h_section = NaN(w+1,len+1,length(centroids));
    h_profile = NaN(len+1,length(centroids));
    v_section = NaN(w+1,len+1,length(centroids));
    v_profile = NaN(len+1,length(centroids));
    profile_mean = NaN(len+1,length(centroids));
    figure
    warning('La mire 1 est ignorée !!!')
    for i = 2 : length(centroids)
        x_bary = centroids(i,2);
        y_bary = centroids(i,1);

        h_section(:,:,i) = image(x_bary+usaf(el_nb).x_h : x_bary+usaf(el_nb).x_h+usaf(el_nb).width, y_bary+usaf(el_nb).y_h : y_bary+usaf(el_nb).y_h+usaf(el_nb).length);
        h_profile(:,i) = mean(h_section(:,:,i),1);

        v_section(:,:,i) = image(x_bary+usaf(el_nb).x_v : x_bary+usaf(el_nb).x_v+usaf(el_nb).length, y_bary+usaf(el_nb).y_v : y_bary+usaf(el_nb).y_v+usaf(el_nb).width)';
        v_profile(:,i) = mean(v_section(:,:,i),1);

        profile_mean(:,i) = mean([h_profile(:,i),v_profile(:,i)],2);
        plot(profile_mean(:,i),'DisplayName',num2str(i))
        hold on
    end
    plot(nanmean(profile_mean,2),'DisplayName','mean','LineWidth',2,'Color','k')
    legend
    xlabel('pixels');
    ylabel('grey level');
    title(['groupe 2 element ' num2str(el_nb)]);
    savefig([image_folder, image_filename(1:end-4), 'gr2el', num2str(el_nb), '.fig'])
    saveas(gcf,[image_folder, image_filename(1:end-4), 'gr2el', num2str(el_nb), '.png'])

    data(el_nb).h_section = h_section;
    data(el_nb).h_profile = h_profile;
    data(el_nb).v_section = v_section;
    data(el_nb).v_profile = v_profile;
    data(el_nb).profile_mean = profile_mean;
end





