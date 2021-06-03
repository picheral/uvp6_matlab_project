%% Uvp6 measurements from light images acquired with the tomography setup
% Picheral 2021/05/02

function [max_h_profile_i,angle_deg,thick_left,thick_right,mean_left,mean_right,Intensity] = UVP6MeasurementsLight(img,segmentation,angle_limit,pixel,figure_plot,index)

% Measure intensity profiles and limits to adjust angle
limits = [];
Intensity = [];
img_crop_mean_norm = [];
for i = 1:9  %106:200:1706
    % i=1 and i=2 for extrem part of the light beam FAUX
%     % NEW : i=3:18 for completing the intensity measurement
%     if i == 1
%         img_crop = img(100:200,700:end-700);
%     elseif i == 18
%         img_crop = img(end-200:end-100,700:end-700);
%     else
%         img_crop = img(200+100*(i-3):200+100*(i-3)+100,700:end-700);
%     end
    img_crop = img(106+(i-1)*200:106+199+(i-1)*200,700:end-700);
    img_crop_mean = mean(img_crop);
    
    % Intensity normalization
    min_plot = min(img_crop_mean);
    max_plot = max(img_crop_mean);   
    ratio = (img_crop_mean - min_plot) *(255/max_plot);
    
    % Profil normalise d'intensité
    img_crop_mean_norm(i,:) = ratio;
    
    % limites pour calcul epaisseur
    aa = find(ratio > segmentation);
    limits(i,1) = aa(1);
    limits(i,2) = aa(end);
    Intensity(i,1) = mean(img_crop_mean(aa));
end

% Process angle
shift = (limits(1,2) + limits(1,1))/2 - (limits(2,2) + limits(2,1))/2 ;
dist = (size(img,2)-300);
angle_deg = asind(abs(shift)/dist);

% Angle warning
if abs(angle_deg) > angle_limit
    disp('ANGLE of light beam > 2°, results may be biased')
end

% Correct image for rotation
if shift < 0 ; angle_deg = -1 * angle_deg; end
img_crop = img(:,round(mean(mean(limits,2))) - 500 +700:round(mean(mean(limits,2)))+500 +700);
img_rot = imrotate(img_crop,angle_deg + 90,'loose');

%% Final measurements

thick_left = pixel * (limits(index,2) - limits(index,1));
thick_right = pixel * (limits(end-index+1,2) - limits(end-index+1,1));

% Intensity measurements
mean_left = Intensity(index);
mean_right = Intensity(end-index+1);

h_profile = mean(img(:,700:end-700), 2);
[max_h_profile, max_h_profile_i] = max(h_profile);

% Figures de contrôle
if figure_plot == 1
    scrsz = get(0,'ScreenSize');
    
    % image rognée
    imshow(img_rot);
    
    % Profils gauche et droite
    fig1 = figure('name','Intensity plots','Position',[50 50 600 600]);
    plot([1:size(img_crop_mean_norm,2)]*pixel,img_crop_mean_norm(index,:),'r-')
    hold on
    plot([1+shift:size(img_crop_mean_norm,2)+shift]*pixel,img_crop_mean_norm(end-index+1,:),'g-')
    legend('right','left');
    titre = ['NORMALIZED INTENSITY'];
    title(titre,'fontsize',10);
    xlabel('THICKNESS [mm]','fontsize',12);
    ylabel('INTENSITY (normalized)','fontsize',12);
    axis([ round((limits(index,2) + limits(index,1))/2*pixel) - 15 round((limits(index,2) + limits(index,1))/2*pixel) + 15 0 300])
    
    % Intensité
    fig1 = figure('name','Intensity plots','Position',[50 50 600 600]);
    plot(h_profile)
    titre = ['Horizontal profile'];
    title(titre,'fontsize',10);
    xlabel('PIXELS','fontsize',12);
    ylabel('INTENSITY (average)','fontsize',12);
    axis([0 2056 0 inf])
end
