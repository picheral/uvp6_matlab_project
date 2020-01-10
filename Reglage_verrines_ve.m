% ----------------------------------------------------------------------- %
% --------------------- REGLAGE VERRINE HORIZONTAL ---------------------- %
% ----------------------------------------------------------------------- %
%
% Editor : Louis Petiteau - petiteau@ensta.fr
% Date : 28/11/2018


% In the text file 3 measurments of the intensity have been chosen.
% 1) mean_int(Mean Intensity) int represents the mean intensity in a 1000*100pix rectangle
% centered on the beam
% 2) int_tot (Total Intensity) is the sum of the intensity along each N
% (25) sections 
% 3) max_int (Maximum Intensity) is the max intensity of the
% int_profile_smoothed which reprensents the mean intensity of the mid 2464*100
% pixel of the beam 

function Reglage_verrine_ve

% Function used when clicking on "save figures"
    function savesetting(~,~,~)
        cc = 2;
        B.Visible = 'off';
    end

% Function used when clicking on "settings ok"
    function settingok(~,~,~)
        hh = 1;
        H.Visible = 'off';
    end


%% Octopus Characterisation of sensibility

clear all
close all
clc
scrsz = get(0,'ScreenSize');
warning('OFF');



%% Settings
segmentation = 5;
angle_limit = 2;
pixel_ve_air = 0.093;
ref_thick_air = 14.7;
ref_int = 15.2;
last_date = 0;
fin= 0 ;
base = [];
index = 0;
ecart1 = [];
ecart2 = [];
max_int = [];
max_int_location = [];
mean_int = [];
mean_thickness = [];
poly_slope = [];
beam_angle = [];
hh = 0;
cc = 0;
last_image = 0;
min_ecart_type = 30;
min_poly_slope = 1000;

% 2N + 1 corresponds to the number of section we look at on the horizontal axis
N = 20;

%Calculate the space discretisation
pas = floor((2464-350-350)/(2*N));

%% ACQUISITION PARAMETERS
zonal_cor = 'off';


%% Select orginal image
%Get the directory where the images will be stored
img_folder = uigetdir('Select image folder');
cd(img_folder);

octopus_type = 'Vertical';
% ENTER NEW PIXEL SIZE
pixel = input('Input the pixel size in mm calculated from the reference image (0.0933) :');

%Open figure full size
f=figure;
set(gcf, 'Position', get(0, 'Screensize'));

%Set the table parameters in order to upload it for each image
cnames = {'New','Last','Best parameter (min or max)'};
rnames = {'SD for fig1','SD for fig2','Location of max int','Max intensity','Slope','Beam angle'};
t = uitable(f);
t.ColumnName = cnames;
t.RowName = rnames;
t.FontSize = 13;
pos = get(subplot(2,3,3),'position');
delete(subplot(2,3,3))
set(t,'units','normalized')
set(t,'position',[pos(1)-0.02 pos(2) pos(3)+0.1 pos(4)])
t.ColumnWidth = {70 70 70};
pause(0.001)

%Set the exit and save button
H = uicontrol('Style', 'PushButton','String', 'Setting ok');
H.Callback = @settingok;
pos = get(subplot(2,3,4),'position');
delete(subplot(2,3,4))
H.Units ='normalized';
H.Position = [pos(1)-0.1 pos(2)+0.03 0.045 0.045];

B = uicontrol('Style', 'PushButton','String', 'Save figures');
B.Callback = @savesetting;
B.Units ='normalized';
B.Position = [pos(1)-0.1 pos(2)-0.02 0.045 0.045];



Button1 = uicontrol('Style', 'PushButton','String', 'Best angle');
Button1.Visible = 'off';
pos = get(subplot(2,3,1),'position');
delete(subplot(2,3,1))
Button1.Units ='normalized';
Button1.Position = [pos(1)-0.1 pos(2)-0.2  0.05 0.05];
Button1.BackgroundColor = 'r';


Button2 = uicontrol('Style', 'PushButton','String', 'Best ET');
Button2.Visible = 'off';
Button2.Units ='normalized';
Button2.Position = [pos(1)-0.1 pos(2)-0.05 0.05 0.05];
Button2.BackgroundColor = 'r';

%% INFINITE LOOP


% While loop which stops when clicking on "settings ok"
while fin == hh | last_image <= 10
    base_grey = dir(img_folder);
    pause(0.01)
    int_tot = 0;
    % We enter the if when a new image has been added in the livecamera
    % directory
    if ~isempty(strfind(base_grey(end).name,'.png'))
        if base_grey(end).datenum > last_date
            %if we've decided to save setting, take 10 last image
            if hh == 1
                last_image = last_image+1;
            end
            
            figure(f);
            %Index is the number of image already treated
            index = index + 1;
            last_date = base_grey(end).datenum;
            Image_name = base_grey(end).name;
            base(index).Image_name = Image_name;
            img=imread(Image_name);
            img = imrotate(img,90,'loose');
            
            %% Intensity profile & Find the max of intensity 
            
            limits = [];
            Intensity = [];
            img_crop_mean_o = [];
            img_crop_mean_norm = [];
            
            %First we look at 2 sections left and right of the beam to
            %check if the beam is horizontal
            for i = 1 : 2
                if i == 1
                    img_crop = img(300:350,700:end-700);
                    
                else
                    img_crop = img(end-350:end-300,700:end-700);
                end
                img_crop_mean = mean(img_crop);
                min_plot = min(img_crop_mean);
                max_plot = max(img_crop_mean);
                ratio = (img_crop_mean - min_plot) *(255/max_plot);
                img_crop_mean_norm(i,:) = ratio;
                img_crop_mean_o(i,:) = img_crop_mean;
                aa = find(img_crop_mean > segmentation);
                limits(i,1) = aa(1);
                limits(i,2) = aa(end);
                Intensity(i,1) = mean(img_crop_mean(aa));
            end
            
            % Process angle
            shift = (limits(1,2) + limits(1,1))/2 - (limits(2,2) + limits(2,1))/2 ;
            dist = (size(img,2)-650);
            angle_deg = atand(abs(shift)/dist);
            
            % Angle warning
            if abs(angle_deg) > angle_limit
                disp('ANGLE of light beam > 2°, results may be biased')
            end
            
            % Correct image for rotation if not horizontal
            if shift < 0 ; angle_deg = -1 * angle_deg; end
            img_crop = img(:,round(mean(mean(limits,2))) - 500 +700:round(mean(mean(limits,2)))+500 +700);
            img_rot = imrotate(img_crop,angle_deg - 90,'loose');
            
            % Calculate the intensity profile on X axis and the maximum of
            % it
            dim = size(img_rot);
            int_profile = mean(img_rot(dim(1)/2-50:dim(1)/2+50,:));
            int_profile_smooth = smooth(int_profile,150);
            max_beam =  max(int_profile_smooth);
            position_x = 100 * (find(int_profile_smooth >= max_beam)/numel(int_profile));
            intensity_x = sum(int_profile)/size(int_profile,2);
            
            %Aproximate the intensity profile with a polynome to find
            %the maximum and the location of it.
            p = polyfit([1:size(int_profile_smooth(800:2464-800),1)],int_profile_smooth(800:2464-800)',6);
            x = [1:size(int_profile_smooth(800:2464-800),1)];
            P = p(1)*x.^6 + p(2)*x.^5 + p(3)*x.^4 + p(4)*x.^3 + p(5)*x.^2 + p(6)*x.^1 + p(7);
            [maximum,mid] = max(P);
            mid = 800 + round(mid);
            if last_image == 9
            disp(mid)
            end
            if mid+10>mid+pas-10
                disp('N trop grand, diminuer N ou diminuer la taille de la tranche d''intégration (actuellement 20)')
            end
            
            intervalles = [];
            img_crop_mean_orig = [];
            
            %Position and value of the 2 peaks on a vertical cut of the
            %image
            peak_l = [];
            max_l = [];
            peak_r = [];
            max_r = [];
            
            %Variable in which we store the informations we need
            indice = zeros(2*N+1,3);
            thickness = zeros(2*N+1,1);
            
            %% Au centre de l'intensité
            %img_crop_mean_orig is a mean of a 21 pixels wide section
            img_crop_mean_orig(N+1,:) = mean(img(mid-10:mid+10,700:end-700));
            %intervalles is the X position of the section calculated (which is a surface) : here
            %10 pixel left and right of the beam's mid
            intervalles(N+1,:) = [mid-10:mid+10];
            
            % find the section with intensity > 5
            aa = find(img_crop_mean_orig(N+1,:)>5); %0.5*max(img_crop_mean_orig(N+1,:)));
            limit_l = aa(1);
            limit_r = aa(end);
            % get the vertical mid of the beam 
            m = round((limit_r+limit_l)/2);
            
            
            int_tot = int_tot + sum(img_crop_mean_orig(N+1,limit_l:limit_r));
            
            % Find the peaks to adjust the segmentation
            [max_l(N+1),peak_l(N+1)] = max(img_crop_mean_orig(N+1,limit_l:m));
            peak_l(N+1) = peak_l(N+1) + limit_l-1;
            [max_r(N+1),peak_r(N+1)] = max(img_crop_mean_orig(N+1,m:limit_r));
            peak_r(N+1) = peak_r(N+1) + m-1;
            
            inter =  img_crop_mean_orig(N+1,peak_l(N+1)-3:peak_r(N+1)+3); %intensity profile between the 2 peaks +3 & -3 means we look abit at right and left of the peaks
            intensity_l = 0;
            intensity_r = 0;
            centre = floor((peak_l(N+1)+peak_r(N+1))/2)-peak_l(N+1)+3;
            
            % depending on the parity of the size of the thickness
            % make the comparison between upper and lower part on the same number of pixel (ignoring the middle pixel or not)            
            if mod(size(inter,2),2) == 0
                X = 0;
            else
                X = 1;
            end
            
            % For each part (upper and lower) Calculate the sum of intensity
            for j = 1:centre
                intensity_l = intensity_l+inter(j);
            end
            for j = centre+1+X:size(inter,2)
                intensity_r = intensity_r+inter(j);
            end
            total_intensity = intensity_l+intensity_r;
            
            
            indice(N+1,1) = intensity_l/centre;
            indice(N+1,2) = intensity_r/size([centre+1+X:size(inter,2)],2);
            indice(N+1,3) = (intensity_l-intensity_r)/total_intensity;
            thickness(N+1) = size(inter,2);
            
            
            %if loop that goes through the beam's lenghts and each step
            %integrates a 21 pixels wide section spaced by pas pixels which
            %a step calculated a the beginnng of the code
            
            for i = 1 : N
                
                %% Left part of the beam
                %each section is the mean of a 21 pixels wide section
                img_crop_mean_orig(N+1-i,:) = mean(img(mid-pas*i-10:mid-pas*i+10,700:end-700));
                intervalles(N+1-i,:) = [mid-pas*i-10:mid-pas*i+10];
                
                
                aa = find(img_crop_mean_orig(N+1-i,:)>5);  %0.5*max(img_crop_mean_orig(N+1-i,:)));
                limit_l = aa(1);
                limit_r = aa(end);
                m = round((limit_r+limit_l)/2);
                int_tot = int_tot + sum(img_crop_mean_orig(N+1-i,limit_l:limit_r));
                
                [max_l(N+1-i),peak_l(N+1-i)] = max(img_crop_mean_orig(N+1-i,limit_l:m));
                peak_l(N+1-i) = peak_l(N+1-i) + limit_l-1;
                [max_r(N+1-i),peak_r(N+1-i)] = max(img_crop_mean_orig(N+1-i,m:limit_r));
                peak_r(N+1-i) = peak_r(N+1-i) + m-1;
                
                inter =  img_crop_mean_orig(N+1-i,peak_l(N+1-i)-3:peak_r(N+1-i)+3);
                intensity_l = 0;
                intensity_r = 0;
                centre = floor((peak_l(N+1-i)+peak_r(N+1-i))/2)-peak_l(N+1-i)+3;
                
                if mod(size(inter,2),2) == 0
                    X = 0;
                else
                    X = 1;
                end
                
                for j = 1:centre
                    intensity_l = intensity_l+inter(j);
                end
                for j = centre+1+X:size(inter,2)
                    intensity_r = intensity_r+inter(j);
                end
                total_intensity = intensity_l+intensity_r;
                
                indice(N+1-i,1) = intensity_l/centre;
                indice(N+1-i,2) = intensity_r/size([centre+1+X:size(inter,2)],2);
                indice(N+1-i,3) = (intensity_l-intensity_r)/total_intensity;
                thickness(N+1-i) = size(inter,2);
                
                
                %% Right part of the beam
                %each section is the mean of a 21 pixels wide section
                img_crop_mean_orig(N+1+i,:) = mean(img(mid+pas*i-10:mid+pas*i+10,700:end-700));
                intervalles(N+1+i,:) = [mid+pas*i-10:mid+pas*i+10];
                
                aa = find(img_crop_mean_orig(N+1+i,:)> 5);%0.5*max(img_crop_mean_orig(N+1+i,:)));
                limit_l = aa(1);
                limit_r = aa(end);
                m = round((limit_r+limit_l)/2);
                int_tot = int_tot + sum(img_crop_mean_orig(N+1+i,limit_l:limit_r));
                
                [max_l(N+1+i),peak_l(N+1+i)] = max(img_crop_mean_orig(N+1+i,limit_l:m));
                peak_l(N+1+i) = peak_l(N+1+i) + limit_l-1;
                [max_r(N+1+i),peak_r(N+1+i)] = max(img_crop_mean_orig(N+1+i,m:limit_r));
                peak_r(N+1+i) = peak_r(N+1+i) + m-1;
                
                inter =  img_crop_mean_orig(N+1+i,peak_l(N+1+i)-3:peak_r(N+1+i)+3);
                intensity_l = 0;
                intensity_r = 0;
                centre = floor((peak_l(N+1+i)+peak_r(N+1+i))/2)-peak_l(N+1+i)+3;
                
                if mod(size(inter,2),2) == 0
                    X = 0;
                else
                    X = 1;
                end
                
                for j = 1:centre
                    intensity_l = intensity_l+inter(j);
                end
                for j = centre+1+x:size(inter,2)
                    intensity_r = intensity_r+inter(j);
                end
                total_intensity = intensity_l+intensity_r;
                                
                indice(N+1+i,1) = intensity_l/centre;
                indice(N+1+i,2) = intensity_r/size([centre+1+X:size(inter,2)],2);
                indice(N+1+i,3) = (intensity_l-intensity_r)/total_intensity;
                thickness(N+1+i) = size(inter,2);               
            end
            
            
            diff_max = 2*(max_l(:)-max_r(:))./(max_l(:)+max_r(:));
            
            %Update of the matrixs in which the intressting parameters are
            %stored
            ecart_type1 = sqrt(10000*indice(:,3)'*indice(:,3))/(2*N+1);
            ecart1 = [ecart1 ecart_type1];
            ecart_type2 = sqrt(diff_max'*diff_max)/(2*N+1);
            ecart2 = [ecart2 ecart_type2];
            max_int = [max_int max_beam];
            
            %Mean int is the mean grey level in the 1000 pixels * 100
            %pixels rectangle centered on the beam
            mean_int = [mean_int mean(int_profile_smooth([mid-500;mid+500]))];
            max_int_location = [max_int_location (mid-1232)];
            mean_thickness = [mean_thickness round(mean(thickness)*pixel,3)];
            beam_angle = [beam_angle angle_deg];
            
            %Define the 1 degree polynom related to the rotation of the beam
            poly1 = polyfit(intervalles([1:2*N+1],11)*pixel,indice(:,3),1);
            diff_peak_poly = poly1(1)*intervalles([1:2*N+1],11)*pixel+poly1(2);
            poly2 = polyfit(intervalles([1:2*N+1],11)*pixel,diff_max,1);
            diff_max_poly = poly2(1)*intervalles([1:2*N+1],11)*pixel+poly2(2);
            %Angle related to this rotation
            diff_peak_angle = atand((diff_peak_poly(N+1+floor(N/2))-diff_peak_poly(N+1))/(floor(N/2)*pas));
            diff_max_angle = atand((diff_max_poly(N+1+floor(N/2))-diff_max_poly(N+1))/(floor(N/2)*pas));
            
            poly_slope = [poly_slope poly1(1)];
            
            %Update the table with the intresting variables
            if index > 1
                t.Data = {10*ecart1(end),10*ecart1(end-1),10*min(ecart1);ecart2(end),ecart2(end-1),min(ecart2);max_int_location(end),max_int_location(end-1),min(abs(max_int_location));max_int(end),max_int(end-1),max(max_int);...
                    100000*poly_slope(end), 100000*poly_slope(end-1),min(abs(100000*poly_slope));beam_angle(end),beam_angle(end-1),[]};
            end
            
            % Activate the red button for standard deviation if setting is
            % good
            if 10*ecart_type1 <= min_ecart_type*(1.05)
                Button2.Visible = 'on';
                if 10*ecart_type1 <min_ecart_type
                    min_ecart_type = 10*ecart_type1;
                end
            else
                Button2.Visible = 'off';
            end
            
            % Activate the red button for angle if setting is good
            if abs(100000*poly1(1)) <= min_poly_slope*(1.05)
                Button1.Visible = 'on';
                if abs(100000*poly1(1)) < min_poly_slope
                    min_poly_slope = abs(100000*poly1(1));
                end
            else
                Button1.Visible = 'off';
            end
            
            
            %Set the previous plots'colors to green as the 'background'
            if hh == 0
                plot1.Color = 'g';
                plot2.Color = 'g';
                plot3.Color = 'g';
                plot4.Color = 'g';
                plot7.Color = 'g';
            end
            if index > 1
                delete(plot5)
                delete(plot6)
                delete(text1)
                delete(text2)
                delete(plot8)
            end
            
            %% Plot section
            subplot(2,3,1)
            plot3 = plot(intervalles([1:2*N+1],11)*pixel,indice(:,3),'b');
            hold on
            plot([mid-pas*N-100 mid+pas*N+100]*pixel,[0,0],'r')
            plot6 = plot(intervalles([1:2*N+1],11)*pixel,diff_peak_poly,'k');
            title({'fig 1 - Intensity diffrence between upper and lower part of ','the beam divided by the total intensity ZOOM'})
            xlabel('Lenght of the beam (mm)')
            ylabel('Normalized intensity')
            axis([0 2464*pixel -0.08 0.08])
            if size(poly_slope,2) > 7
                text1 = text(20,-0.080,['slope :' num2str(100000*mean(poly_slope(end-5:end)),'%.3g')]);
            else
                text1 = text(20,-0.080,['slope :' num2str(100000*poly1(1),'%.3g')]);
            end
            
            subplot(2,3,2)
            plot2 = plot(intervalles([1:2*N+1],11)*pixel,diff_max,'b');
            hold on
            plot([mid-pas*N-100 mid+pas*N+100]*pixel,[0 0],'r')
            plot5 = plot(intervalles([1:2*N+1],11)*pixel,diff_max_poly,'k');
            title({'fig2 - Diffrence between max of the bottom','and top peaks divided by the mean'})
            xlabel('Lenght of the beam (mm)')
            ylabel('Normalized intensity')
            axis([0 2464*pixel -0.8 0.8])
            text2 = text(20,-0.7,['pente :' num2str(1000*poly2(1),'%.3g')]);
            
            subplot(2,3,5)
            plot1 = plot(intervalles([1:2*N+1],11)*pixel,thickness*pixel,'b');
            hold on
            title('Beam''s thickness')
            xlabel('Lenght of the beam (mm)')
            ylabel('Thickness of the beam (mm)')
            xlim([0 2464*pixel])
            
            subplot(2,3,6)
            plot4 = plot([1:dim(2)]*pixel,int_profile_smooth(:),'b');
            hold on
            title('Intensity Profile')
            xlabel('Lenght of the beam (mm)')
            ylabel('Intensity')
            
             subplot(2,3,4)
            plot7 = plot(intervalles([1:2*N+1],11)*pixel,indice(:,3),'b');
            hold on
            plot([mid-pas*N-100 mid+pas*N+100]*pixel,[0,0],'r')
            plot8 = plot(intervalles([1:2*N+1],11)*pixel,diff_peak_poly,'k');
            title({'fig 2 - Intensity diffrence between upper and lower part of ','the beam divided by the total intensity'})
            xlabel('Lenght of the beam (mm)')
            ylabel('Normalized intensity')
            
            pause(0.01)
        end
    end
    pause(0.3)
end


for i = 4:5
    subplot(2,3,i)
    l2 = plot([NaN,NaN], 'color', 'g');
    l3 = plot([NaN,NaN], 'color', 'b');
    legend([l2 l3],{'lasts','new'})
end
for i = 1:2
    subplot(2,3,i)
    l1 = plot([NaN,NaN], 'color', 'r');
    l2 = plot([NaN,NaN], 'color', 'g');
    l3 = plot([NaN,NaN], 'color', 'b');
    legend([l1 l2 l3],{'Best profile','lasts','new'})
end


while cc == 0
    cc = ~ishandle(f);
    pause(0.3)
end

%If we've decided to save figures by clicking on the Save Figure button
if cc == 2
    
    %% Ask metadata
    
    octopus_cam = input('Input Octopus CAMERA serial number (xxx) ','s');
    octopus_light = input('Input Octopus LIGHT serial number (xxx) ','s');
    people = input('Enter people first and last name (default : Marc Picheral) ','s');
    if isempty(people); people = 'Marc Picheral'; end
    shutter = input('Input exposure setting of the livecamera acqusition ','s');
    if isempty(shutter); shutter = '80'; end
    gain = input('Input gain setting of the livecamera acquisition ','s');
    if isempty(gain); gain = '0'; end
%     suppl = input('Input supplement for the name of the text and graph file ','s');
%     if isempty(suppl); suppl = ''; end
    
    
    %% Modify figure
    
    Button1.Visible = 'off';
    Button2.Visible = 'off';
    delete(t)
    f.Name = 'Final settings graphs';
    
    
    ss = subplot(2,3,3);
    ppos = ss.Position;
    ss.Position = [ppos(1)-0.045 ppos(2) ppos(3)+0.12 ppos(4)];
    
    %Sow image and print a line for each section that
    imshow(img_rot);
    hold on
    plot([mid mid],[150 size(img_rot,1)-150],'r-')
    title('Location of the 2N+1 areas processed')
    hold on
    
    for i = 1:N
        plot([mid+pas*i mid+pas*i],[150 size(img_rot,1)-150],'g-')
        plot([mid-pas*i mid-pas*i],[150 size(img_rot,1)-150],'g-')
    end
    

    %% Save Results
    path = uigetdir('Select save folder');
    cd(path);
    mkdir([datestr(now,10) datestr(now,5) datestr(now,7) '_Reglage_verrines_ve_' octopus_light]);
    cd([datestr(now,10) datestr(now,5) datestr(now,7) '_Reglage_verrines_ve_' octopus_light]);
    
    fid_uvp = fopen(fullfile(cd,[datestr(now,10) datestr(now,5) datestr(now,7) '_Reglage_verrines_ve_' octopus_light '.txt']),'w');
    fprintf(fid_uvp,'%s\r','WARNING : AIR measurements and references !');
    fprintf(fid_uvp,'%s\r',['Processing date                : ',datestr(now,31)]);
    fprintf(fid_uvp,'%s\r',['Image acquisition date         : ',datestr(base_grey(end).datenum,31)]);
    fprintf(fid_uvp,'%s\r',['Octopus CAMERA s/n             : ',num2str(octopus_cam)]);
    fprintf(fid_uvp,'%s\r',['Octopus LIGHT s/n              : ',num2str(octopus_light)]);
    fprintf(fid_uvp,'%s\r',['Octopus LIGHT type             : ',char(octopus_type)]);
    fprintf(fid_uvp,'%s\r',['Livecamera shutter             : ',shutter]);
    fprintf(fid_uvp,'%s\r',['Livecamera gain                : ',gain]);
    fprintf(fid_uvp,'%s\r',['BEAM ANGLE [degre]             : ',num2str(round(angle_deg,2))]);
    fprintf(fid_uvp,'%s\r',['Octopus pixel in air [mm]      : ',num2str(pixel)]);
    fprintf(fid_uvp,'%s\r',['Octopus mean thickness L [mm]  : ',num2str(pixel*mean(thickness(end-9:end)))]);
    fprintf(fid_uvp,'%s\r',['Octopus max Intensity          : ',num2str(round(mean(max_int(end-9:end)),2))]);
    fprintf(fid_uvp,'%s\r',['Octopus mean Intensity         : ',num2str(round(mean(mean_int(end-9:end)),2))]);
    fprintf(fid_uvp,'%s\r',['Octopus total Intensity        : ',num2str(int_tot)]);
    fprintf(fid_uvp,'%s\r',['Octopus angle of Intensity diffrence between upper and lower part of the beam       : ',num2str((mean(poly_slope(end-9:end))))]);
    fprintf(fid_uvp,'%s\r',['Octopus standard deviation of Intensity difference between upper and lower part of the beam : ',num2str(round(mean(ecart1(end-9:end))*10,3))]);
    
    
    
%     fprintf(fid_uvp,'%s\r',['REFERENCE THICNESS [mm]  : ',num2str(ref_thick_air)]);
%     fprintf(fid_uvp,'%s\r',['REFERENCE MEAN INTENSITY : ',num2str(ref_int)]);
    
    saveas(f,fullfile(cd,[datestr(now,10) datestr(now,5) datestr(now,7) '_Reglage_verrives_' octopus_light '_graphs.png']))
    fclose(fid_uvp);
    close(f)
    
    
    fig = figure;

if max(max_int)-min(max_int)>1
    N_min = size(max_int(find(max_int < min(max_int)+1)),2);
    N_max = size(max_int(find(max_int > max(max_int)-1)),2);
else
    N_min = 0;
    N_max = 0;
end

    
    plot(max_int,'x')
    title(['Max intensity taken from the intensity profile with a suhtter = ' shutter])
    xlabel('Number of image')
    ylabel('max intensity')
    fig.Units = 'normalized';
    
    annotation('textbox',[0.2 0.5 0.3 0.3],'String',['N' '_max = ' num2str(N_max)],'FitBoxToText','on')
    annotation('textbox',[0.2 0.2 0.3 0.3],'String',['N' '_min = ' num2str(N_min)],'FitBoxToText','on')   
    
    saveas(fig,fullfile(cd,[datestr(now,10) datestr(now,5) datestr(now,7) '_Reglage_verrives_' char(octopus_light) '_int_evolution.png']));
    copyfile([ img_folder '\' Image_name],cd,'f');
    
    
    close(fig)
    
end

end