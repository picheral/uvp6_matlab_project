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
image_folder = uigetdir([],'Select images folder');
img_list = dir([image_folder,'\*.png']);
contrast = NaN(3,length(img_list));
fov = NaN(1,length(img_list));

for img_nb = 1:length(img_list)
    image_filename = img_list(img_nb).name;
    %disp("Selection of the image file")
    %[image_filename, image_folder] = uigetfile('*.jpg','Select the image file');
    disp("Analysed image file : " + image_filename)
    image_raw = imread(fullfile(image_folder, image_filename));
    image = image_raw(808:1108,1070:1420);
    %image = image_raw;
    disp('------------------------------------------------------')


    %% -------------- Recherche barycentres ----------------
    gauss_blur = 10;
    segmentation = 0.2;
    image_mask = imbinarize(imgaussfilt(image, gauss_blur), segmentation);
    targets_positions = regionprops(imclearborder(image_mask));
    % centroids is [x,y,area]
    centroids = [cat(1, targets_positions.Centroid) [targets_positions.Area]'];

    figure
    imshow(image)
    hold on
    plot(centroids(:,1), centroids(:,2),'r+')
    for i = 1 : length(centroids)
        text(centroids(i,1),centroids(i,2),[' ',num2str(i)],'FontSize',14,'Color', 'r');
    end
    savefig(fullfile(image_folder, [image_filename(1:end-4), '.fig']))
    saveas(gcf,fullfile(image_folder, [image_filename(1:end-4), '_targets.png']))

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
    usaf(1).length = 11;
    %
    % g2e2h = (x+13,y+1) [+4,+9]
    % g2e2v = (x+10,y+14) [+9,+4]
    usaf(2).x_h = 13;
    usaf(2).y_h = 1;
    usaf(2).x_v = 10;
    usaf(2).y_v = 14;
    usaf(2).width = 4;
    usaf(2).length = 10;
    %
    % g2e3h = (x+3,y+3) [+4,+8]
    % g2e3v = (x,y+14) [+8,+4]
    usaf(3).x_h = 3;
    usaf(3).y_h = 3;
    usaf(3).x_v = 0;
    usaf(3).y_v = 14;
    usaf(3).width = 4;
    usaf(3).length = 9;
    %
    %
    %{
    el_nb = 3;
    imshow(image)
    hold on 
    plot(centroids(2,1), centroids(2,2),'r+')
    hold on
    a = centroids(2,1);
    b = centroids(2,2);
    plot(a+usaf(el_nb).y_h, b+usaf(el_nb).x_h, 'r+')
    plot(a+usaf(el_nb).y_h, b+usaf(el_nb).x_h+usaf(el_nb).width,'r+')
    plot(a+usaf(el_nb).y_h+usaf(el_nb).length, b+usaf(el_nb).x_h,'r+')
    plot(a+usaf(el_nb).y_h+usaf(el_nb).length, b+usaf(el_nb).x_h+usaf(el_nb).width,'r+')
    plot(a+usaf(el_nb).y_v, b+usaf(el_nb).x_v, 'r+')
    plot(a+usaf(el_nb).y_v, b+usaf(el_nb).x_v+usaf(el_nb).length,'r+')
    plot(a+usaf(el_nb).y_v+usaf(el_nb).width, b+usaf(el_nb).x_v,'r+')
    plot(a+usaf(el_nb).y_v+usaf(el_nb).width, b+usaf(el_nb).x_v+usaf(el_nb).length,'r+')
    figure
    imshow(image(b+usaf(el_nb).x_h : b+usaf(el_nb).x_h+usaf(el_nb).width, a+usaf(el_nb).y_h : a+usaf(el_nb).y_h+usaf(el_nb).length),[0,255])
    figure
    imshow(image(b+usaf(el_nb).x_v : b+usaf(el_nb).x_v+usaf(el_nb).length, a+usaf(el_nb).y_v : a+usaf(el_nb).y_v+usaf(el_nb).width),[0,255])
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
        mins = NaN(length(centroids),1);
        maxs = NaN(length(centroids),1);
        figure
        for i = 1 : length(centroids)
            %center of each target
            x_bary = centroids(i,2);
            y_bary = centroids(i,1);

            %horizontal profile (vertical bars) of that element
            h_section(:,:,i) = image(x_bary+usaf(el_nb).x_h : x_bary+usaf(el_nb).x_h+usaf(el_nb).width, y_bary+usaf(el_nb).y_h : y_bary+usaf(el_nb).y_h+usaf(el_nb).length);
            h_profile(:,i) = mean(h_section(:,:,i),1);

            %vertical profile (horizontal bars) of that element
            v_section(:,:,i) = image(x_bary+usaf(el_nb).x_v : x_bary+usaf(el_nb).x_v+usaf(el_nb).length, y_bary+usaf(el_nb).y_v : y_bary+usaf(el_nb).y_v+usaf(el_nb).width)';
            v_profile(:,i) = mean(v_section(:,:,i),1);

            %compute diff between peak and min
            profile_mean(:,i) = mean([h_profile(:,i),v_profile(:,i)],2);
            pfmir = profile_mean(2:end-1,i);
            mins(i) = mean(pfmir(islocalmin(pfmir)));
            maxs(i) = mean(findpeaks(profile_mean(:,i)));
            plot(profile_mean(:,i),'DisplayName',[num2str(i), ' : ', num2str((maxs(i)-mins(i))/maxs(i))])
            hold on
        end
        profile_mean_mean = mean(profile_mean,2);
        plot(profile_mean_mean,'DisplayName',['mean : ', num2str(mean((maxs-mins)./maxs))],'LineWidth',2,'Color','k')
        legend
        xlabel('pixels');
        ylabel('grey level');
        title(['groupe 2 element ' num2str(el_nb)]);
        savefig(fullfile(image_folder, [image_filename(1:end-4), 'gr2el', num2str(el_nb), '.fig']))
        saveas(gcf,fullfile(image_folder, [image_filename(1:end-4), 'gr2el', num2str(el_nb), '.png']))

        data(el_nb).h_section = h_section;
        data(el_nb).h_profile = h_profile;
        data(el_nb).v_section = v_section;
        data(el_nb).v_profile = v_profile;
        data(el_nb).profile_mean = profile_mean;
        contrast(el_nb,img_nb) = mean((maxs-mins)./maxs);
    end
    fov(1,img_nb) = centroids(9,1) - centroids(1,1);
end

C = array2table(contrast);
C.Properties.VariableNames(1:img_nb) = {img_list.name};
writetable(C, fullfile(image_folder, 'contrast.csv'))
%writematrix(contrast, [image_folder, image_filename(1:end-4), '.csv'])

F = array2table(fov);
F.Properties.VariableNames(1:img_nb) = {img_list.name};
writetable(F, fullfile(image_folder, 'fov.csv'))
close all

