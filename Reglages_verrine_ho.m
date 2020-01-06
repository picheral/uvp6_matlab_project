%% ----------------------------------------------------------------------- %
%% --------------------- REGLAGE VERRINE HORIZONTAL ---------------------- %
%% ----------------------------------------------------------------------- %
%
% Editor : Louis Petiteau - petiteau@ensta.fr
% Date : 28/11/2018
% MAJ by Camille Catalano 11/2019



function Reglages_verrine_ho

clear all
close all
clc

disp("==========================================")
disp("Horizontal Lamp Adjustment Program Started")
disp("==========================================")

% Function used when clicking on "settings ok" to exit the live figures and
% tables
    function settingok(~,~,~)
        dd = 1;
        H.Visible = 'off';
    end

scrsz = get(0,'ScreenSize');
warning('OFF');

%% Settings
disp("==========================================")
disp("===============Settings===================")
% Select image folder - livecamera folder basically
disp("Selection of camera images folder")
img_folder = uigetdir([],'Select camera images folder');
disp("img_folder = " + img_folder)
cd(img_folder);

% PARAMETER TO MODIFY EACH TIME THE TESTING BENCH IS TOUCHED OR SET
% size of a pixel in mm
pixel = input('Enter the size of a pixel in the FOV in mm (default : 0.116mm) ','s');
if isempty(pixel); pixel = '0.116'; end
disp("pixel = " + pixel)

ask = input('Are you setting the middle diode up? (y/n)(default : y) : ','s');
if ask == 'n'
    ref = input('Enter the reference pixel of the middle diode mid_beam : ');
    disp("Reference pixel : " + ref)
    if isempty(ref); return; end;
    disp("Adjustment of a side led")
else
    ask = 'y';
    disp("Adjustment of the middle led")
end

% Program settings
UVP6_type = 'Ho';
segmentation = 10;
angle_limit = 2;
ref_thick_air = 14.7;
ref_int = 15.2;
hh = 0;
fin = 0;
last_date = 0;
index = 0;
diff_int = [];
ecart = [];
max_thickness = [];
mean_int = [];
max_int = [];
poly_slope = [];
beam_angle = [];
mid_position = [];
dd = 0;
disp("==========================================")

%% Analysis of images in live with infinite loop
disp("==========================================")
disp("==========Analysis of images==============")
% Set the figures position / size
Pos = get(0, 'Screensize');
fig1_pos = [Pos(1) Pos(2) round(Pos(3)*2/3) Pos(4)];
fig2_pos = [fig1_pos(3)+1 Pos(2) round(Pos(3)*1/3)-1 Pos(4)];
fig1 = figure;
fig2 = figure;
fig1.Position = fig1_pos;
fig2.Position = fig2_pos;

% creates the interactive table
% before : cnames = {'New','Last','Best parameter'};
cnames = {'New','Best parameter'};
rnames = {'STD','Max int','Mean Int','Poly Slope','Beam angle','Max thickness','mid position'};
t = uitable(fig2);
t.ColumnName = cnames;
t.RowName = rnames;
t.FontSize = 13;
z = subplot(1,1,1);
set(t,'units', 'normalized')
pos = z.Position;
pos(1) = pos(1) - 0.1;
pos(3) = pos(3)+0.15;
set(t,'position',pos);
delete(z)
t.ColumnWidth = {100 100};
disp("%%% Table lines description %%%")
disp("STD : Standard deviation of the intensity difference between upper and lower part of the beam")
disp("Max int : maximum along the horizontal axis of the vertical mean of the beam intensity")
disp("Mean int : mean along the horizontal axis of the vertical mean of the beam intensity")
disp("Poly Slope : horizontal slope of the intensity difference between upper and lower part of the beam")
disp("Beam angle : inclinaison angle of the beam compared to the reference")
disp("Max thickness : maximum of the thickness of the beam")
disp("mid position : horizontal position of the middle of the beam [in cropped image : max is 100]")
disp("%%%%%%")

figure(fig1)
%Set the exit-and-save button
H = uicontrol('Style', 'PushButton','String', 'Settings ok');
H.Callback = @settingok;
ppos = get(subplot(2,2,4),'position');
delete(subplot(2,2,4))
H.Units ='normalized';
H.Position = [ppos(1)+ppos(3) ppos(2)+0.1 0.06 0.06];

% INFINITE LOOP
disp("Analysing images in live...")
%loop which stops when clicking on "settings ok"
while fin == dd
    
    base_grey = dir(img_folder);
    pause(0.01)
    % We enter the if when a new image has been added in the livecamera
    % directory
    if ~isempty(strfind(base_grey(end).name,'.png'))
        if base_grey(end).datenum > last_date
            index = index+1;
            last_date = base_grey(end).datenum;
            Image_name = base_grey(end).name;
            base(index).Image_name = Image_name;
            img=imread(Image_name);
            img = imrotate(img,90,'loose');     
            
            % Color the previous plots in green
            if index > 1
                p1.Color = 'g';
                p3.Color = 'g';
                p4.Color = 'g';
                p5.Color = 'g';
                delete(p6)
                delete(p2)
                delete(p7)
                delete(s1)
                delete(h)
                delete(txt)
                delete(p8)
            end
            
            %% PARAMETERS SETUP
            % Important parameters in order to characterize the beam
            img_crop_mean_orig = [];
            thickness = [];
            intervalles = [];
            limits = [];
            aa = [];
            
            % Spatial segmentation
            N = 100;            %Along all the image (vertical segmentation)
            M = 25;             %Segmentation left or right of the maximal thckness of the beam 
            
            % calculates the thickness and save the vertical intensity profiles
            % along the beam
            for i=N:-1:1
                img_crop_mean_orig(101-i,:) = mean(img(20+24*i-10:20+24*i+10,700:end-700));
                aa = find(img_crop_mean_orig(101-i,:) > 0.3*max(img_crop_mean_orig(101-i,:)) & img_crop_mean_orig(101-i,:)> 7 );
                intervalles(i) = 20+24*i;
                if ~isempty(aa)
                    thickness(101-i) = aa(end) - aa(1);
                    limits(101-i,1) = aa(1);
                    limits(101-i,2) = aa(end);
                else
                    thickness(101-i) = 0; %%%%ok de mettre des 0 et des NAN car on va pas regarder que ça
                    limits(101-i,1) = NaN;
                    limits(101-i,2) = NaN;
                end
            end
            
            % Find the mid of the beam
            thickness_smooth = smooth(thickness,20)';
            [maximum, mid] = max(thickness_smooth);
            dist = M*24;
            
            % Decides to look at the left side of the beam or the right
            % side depending on the position of the max
            if mid > 50
                side = -1;
            else
                side = 1;
            end
            
            if ask == 'y'
                side = 1;
            end
            
            %%%% BUG? ATTENTION, on peut avoir que des NAN en fonction des valeurs de mid et side...
            %%%% renvoyer un msg d'erreur?
            %Process angle (useless in fact, another better measurment is done after that)
            shift = -(limits(mid,2) + limits(mid,1))/2 + (limits(mid+side*dist/24,2) + limits(mid+side*dist/24,1))/2 ;
            angle_deg = atand(shift/dist);
            
            %% CALCULATION OF SIGNIFICANT PARAMETERS
            %
            % Calculating parameters needed to say 'the led is well set'
            for j = 0:M
                intensity_l = 0;
                intensity_r = 0;
                centre = floor((limits(mid+side*j,1)+limits(mid+side*j,2))/2);      %vertical mid of the beam
                
                % depending on the parity of the size of the thickness I
                % make the comparison between upper and lower part on the same number of pixel (ignoring the middle one or not) 
                if mod(limits(mid+side*j,2)-limits(mid+side*j,1)+1,2) == 0          
                    X = 0;
                else
                    X = 1;
                end
                
                % For each part (upper and lower) Calculate the sum of intensity
                %%%%%%%%%% WARNING: isnan protect from bug but it is not a
                %%%%%%%%%% good solution
                for k = limits(mid+side*j,1):centre
                    if isnan(k)
                        intensity_1 = nan;
                    else
                        intensity_l = intensity_l+img_crop_mean_orig(mid+side*j,k);
                    end
                end
                for k = centre+1+X:limits(mid+side*j,2)
                    if isnan(k)
                        intensity_r = nan;
                    else
                        intensity_r = intensity_r+img_crop_mean_orig(mid+side*j,k);
                    end
                end
                
                total_intensity = intensity_l+intensity_r;
                diff_int(j+1) = (intensity_l-intensity_r)/total_intensity;
            end
            
            %Calculate the vertical position of the beam, also we can get
            %the angle from this
            if side == 1
                mean_thickness_pos = (limits(mid:mid+M,2)+limits(mid:mid+M,1))/2;       %that's the vertical position of the mid of the thickness for each segmentation
            else
                mean_thickness_pos = (limits(mid-M:mid,2)+limits(mid-M:mid,1))/2;
            end
            
            mean_thickness_pos = mean_thickness_pos';
            %mean_thickness_pos(isnan(mean_thickness_pos))=[];
            p=polyfit([1:size(mean_thickness_pos,2)],mean_thickness_pos,1);
            mean_thickness_fit = p(1)*[1:M+1] + p(2);
            
            %Calculates the angle
            angle = atand(p(1)/24);
            
            %Calculates the angle of the light repartition and the standard
            %deviation
            %%%%%%%%%%%%%%%%%%%%%%%% WARNING: withoutnan is not a good
            %%%%%%%%%%%%%%%%%%%%%%%% thing
            diff_int_withoutnan = diff_int(~isnan(diff_int));
            ecart_type = sqrt(10000*diff_int_withoutnan(:)'*diff_int_withoutnan(:))/(M+1);
            poly = polyfit([1:size(diff_int_withoutnan,2)],diff_int_withoutnan,1);
            P = [1:size(diff_int,2)]*poly(1) + poly(2);
            
            %%%%%%%%%%%%%%%%%%% WARNING: nanmean is not a good thing
            cc = nanmean([(limits(mid,2) + limits(mid,1))/2 (limits(mid+side*dist/24,2) + limits(mid+side*dist/24,1))/2]);
            img_crop = img(:,cc - 500 +700:cc +500 +700);
            dim = size(img_crop);
            int_profile = mean((img_crop(:,dim(2)/2-50:dim(2)/2+50))');
            int_profile_smooth = smooth(int_profile,200); 
           
            % Update the list of the main paramaters
            ecart = [ecart ecart_type];
            max_thickness = [max_thickness maximum];
            mean_int = [mean_int mean(int_profile_smooth(find(int_profile_smooth>3)))];
            max_int = [max_int max(int_profile_smooth)];
            poly_slope = [poly_slope 100*poly(1)];
            beam_angle = [beam_angle angle];
            mid_position = [mid_position mid];
            
            %Update the table with the new parameters
            if index > 1
                t.Data = {ecart(end),min(ecart);max_int(end),max(max_int);mean_int(end),max(mean_int);...
                    poly_slope(end),min(abs(poly_slope));beam_angle(end),min(abs(beam_angle));...
                    max_thickness(end),max(max_thickness);mid_position(end),0};
                pause(0.01)
            else
                t.Data = {ecart(end),min(ecart);max_int(end),max(max_int);mean_int(end),max(mean_int);...
                    poly_slope(end),min(abs(poly_slope));beam_angle(end),min(abs(beam_angle));...
                    max_thickness(end),max(max_thickness);mid_position(end),0};
                pause(0.01)
            end
            
            %% Ploting Section
            figure(fig1)
            if side == 1
                L = intervalles(mid:mid+M);
            else
                L = intervalles(mid-M:mid);
            end
            subplot(2,2,1)
            p1 = plot(L,diff_int,'b');
            hold on
            p2 = plot(L,P,'k');
            p8 = plot([L(1) L(end)],[0 0],'r');
            title('Intensity difference between upper and lower part')
            xlabel('Horizontal axis (image pixel)')
            ylabel('Intensity difference (ADU)')
            
            subplot(2,2,2)
            p3 = plot(intervalles, thickness_smooth,'b');
            title('Smoothed thickness of the beam')
            xlabel('Horizontal axis image (pixel)')
            ylabel('Thickness (pixel)')
            hold on
            
            
            subplot(2,2,3)
            p4 = plot(imrotate(int_profile_smooth,180),'b');
            title('Intensity along the beam')
            xlabel('Horizontal axis (image pixel)')
            ylabel('Smoothed mean intensity (ADU)')
            hold on
            
            sub4 = subplot(2,2,4);
            
            p5 = plot(24*[1:(M+1)],mean_thickness_pos,'b');
            hold on
            xlim([0 24*(M+2)]);
            p6 = plot([1:(M+1)]*24,mean_thickness_fit,'k');
            if side == 1
                s1 = scatter(24,mean_thickness_fit(1),30,'k','filled');
                p7 = plot([1 M+1]*24, [mean_thickness_fit(1) mean_thickness_fit(1)],'k');
            else
                s1 = scatter((M+1)*24,mean_thickness_fit(end),30,'k','filled');
                p7 = plot([1 M+1]*24, [mean_thickness_fit(end) mean_thickness_fit(end)],'k');
            end
            if ask == 'n'
                p9 = plot([0 (M+1)]*24, [ref ref],'r');
                ylim([ref-15 ref+15]);
            end
            
            %plot the angle aspect and value
            nsegments = 100;
            angle2 = angle*sqrt((240^2 + 15^2)/(15^2));
            th = 0:angle2*pi/180/nsegments:angle2*pi/180;
            if side == 1
                xunit = 10*24 * cos(th) +24 ;
                yunit = 15 * sin(th) + mean_thickness_fit(1);
            else
                xunit = -10*24 * cos(th) + 24*(M+1);
                yunit = 15 * sin(th) + mean_thickness_fit(end);
            end
            h = plot(xunit, yunit,'k');
            
            if side == 1
                txt = text(xunit(round(size(xunit,2)/2))+20,yunit(round(size(yunit,2)/2)), [num2str(angle) '°']);
            else
                txt = text(xunit(round(size(xunit,2)/2))-100,yunit(round(size(yunit,2)/2)), [num2str(angle) '°']);
            end
            
            title('Beam vertical poisition and angle compared to the reference')
            xlabel('Horizontal axis (cropped image pixel)')
            ylabel('Vertical position of the center of the beam (image pixel)')
            
            pause(0.02)
        end
    end
    pause(0.7)
end
disp("Analysing images stopped")

% Return the value of the ref which is IMPORTANT when setting the middle
% card up
disp("Vertical position of the center of the beam")
fprintf('ref = %d\n',round(p(2)));
close(fig2)
disp("==========================================")

%% SAVING FIGURES AND TEXT FILES 
disp("==========================================")
disp("========Builing the results files=========")
%Ask metadata
UVP6_cam = input('Enter UVP6 CAMERA serial number (xxx) ','s');
disp("UVP6 camera : " + UVP6_cam)
UVP6_light = input('Enter UVP6 LIGHT serial number (xxx) ','s');
disp("ocotpus light : " + UVP6_light)
operator = input('Enter people first and last name (default : Marc Picheral) ','s');
if isempty(operator); operator = 'Marc Picheral'; end
disp("operator : " + operator)
shutter = input('Enter exposure setting of the livecamera acqusition in µs (default : 150µs) ','s');
if isempty(shutter); shutter = '150'; end
disp("shutter : " + shutter)
gain = input('Enter gain setting of the livecamera acquisition (default : 0) ','s');
if isempty(gain); gain = '0'; end
disp("gain : " + gain)
% IMPORTANT TO FIL WELL THIS PART
id_light = input('Enter id of the electronic card you want to set up (1:left,...,4:mid,...,7:right) ','s');
disp("light id : " + id_light)

% Path to change depending on where you want to save the report directory
disp("Selection of the results folder location")
save_folder = uigetdir([], 'Select the location for results folder');
cd(save_folder)


if ask == 'y'
    folder_name = [datestr(now,10) '_' datestr(now,5) '_' datestr(now,7) '_Reglage_verrine_' UVP6_light];
    mkdir(folder_name)
else
    %last_dir = dir;
    if exist([datestr(now,10) '_' datestr(now,5) '_' datestr(now,7) '_Reglage_verrine_' UVP6_light],'dir');
        folder_name = [datestr(now,10) '_' datestr(now,5) '_' datestr(now,7) '_Reglage_verrine_' UVP6_light];
    else
        error('error no folder found from a previous middle light set up')
        return
    end
    
end


fid_uvp = fopen(fullfile(save_folder,folder_name,['Reglage_verrine_ho_' UVP6_light '.txt']),'a+');
if ask == 'y'
    fprintf(fid_uvp, '%s\r', '\\ ---------------------- REFERENCE MIDDLE LIGHT SETTINGS ---------------------- //');
    fprintf(fid_uvp, '%s\r', '\\ ----------------------------------------------------------------------------- //');
else
    fprintf(fid_uvp, '%s\r', '');
    fprintf(fid_uvp, '%s\r', '');
    fprintf(fid_uvp, '%s\r', ['\\ --------------------------- SETTINGS FOR LIGHT ' id_light ' --------------------------- //']);
    fprintf(fid_uvp, '%s\r', '\\ ----------------------------------------------------------------------------- //');
end

fprintf(fid_uvp,'%s\r',['Light id (1:left 4:mid 7:right): ',id_light]);
fprintf(fid_uvp,'%s\r',['Processing date                : ',datestr(now,31)]);
fprintf(fid_uvp,'%s\r',['Image acquisition date         : ',datestr(base_grey(end).datenum,31)]);
fprintf(fid_uvp,'%s\r',['Operator                       : ',operator]);
fprintf(fid_uvp,'%s\r',['UVP6 CAMERA s/n                : ',num2str(UVP6_cam)]);
fprintf(fid_uvp,'%s\r',['UVP6 LIGHT s/n                 : ',num2str(UVP6_light)]);
fprintf(fid_uvp,'%s\r',['UVP6 LIGHT type                : ',char(UVP6_type)]);
fprintf(fid_uvp,'%s\r',['Livecamera shutter             : ',shutter]);
fprintf(fid_uvp,'%s\r',['Livecamera gain                : ',gain]);
fprintf(fid_uvp,'%s\r',['BEAM ANGLE [degre]             : ',num2str(round(mean(beam_angle(end-4:end)),2))]);
fprintf(fid_uvp,'%s\r',['UVP6 pixel size in FOV [mm]    : ',num2str(pixel)]);
fprintf(fid_uvp,'%s\r',['UVP6 max thickness L [mm]      : ',num2str(pixel*mean(max_thickness(end-4:end)))]);
fprintf(fid_uvp,'%s\r',['UVP6 max intensity             : ',num2str(round(mean(max_int(end-4:end)),2))]);
fprintf(fid_uvp,'%s\r',['UVP6 mean intensity            : ',num2str(round(mean(mean_int(end-4:end)),2))]);
fprintf(fid_uvp,'%s\r',['UVP6 horizontal slope of the intensity difference between upper and lower part of the beam : ',num2str((mean(poly_slope(end-4:end))))]);
fprintf(fid_uvp,'%s\r',['UVP6 standard deviation of the intensity difference between upper and lower part of the beam : ',num2str(round(mean(ecart(end-4:end)),2))]);
if ask == 'n'
    fprintf(fid_uvp,'%s\r',['Vertical position of the middle led beam (reference light) [pixel]                       : ',num2str(ref)]);
    fprintf(fid_uvp,'%s\r',['Vertical position of light n°' id_light ' beam [pixel]                                              : ',num2str(round(p(2)))]);
else
    fprintf(fid_uvp,'%s\r',['Vertical position of the middle led beam (reference light) [pixel]                       : ',num2str(round(p(2)))]);
end

saveas(fig1,fullfile(save_folder,folder_name,['Reglage_verrine_ho' UVP6_light '_' id_light '_graphs.png']))
fclose(fid_uvp);
close(fig1)

img = imrotate(img,-90,'loose');

fig3 = figure;
imshow(img)
saveas(fig3,fullfile(save_folder,folder_name,['Reglage_verrine_ho' UVP6_light '_' id_light '_raw_image.png']))
close(fig3)


disp("Results files saved in " + fullfile(save_folder,folder_name))
disp("==========================================")
disp("==========================================")
disp("Horizontal Lamp Adjustment Program Finished")
disp("==========================================")
cd(img_folder);
end
