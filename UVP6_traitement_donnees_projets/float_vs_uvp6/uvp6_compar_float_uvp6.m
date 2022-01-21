%% Compare data from uvp6 with from float
% Catalano, 2022/01

clear all
close all
warning('off')

disp('---------------------------------------------------------------')
disp('----------------- Compare float and uvp6 data -----------------')
disp('Select PROJECT folder ')
project_folder = uigetdir('', 'Select PROJECT Folder ');
disp('---------------------------------------------------------------')
disp(['Project Folder : ',char(project_folder)])
[~] = cd(project_folder);
disp('---------------------------------------------------------------')

results_folder = fullfile(project_folder,'\results\');
raw_folder = fullfile(project_folder,'\raw\');
[~] = mkdir(results_folder, 'lpm_ab');
[~] = mkdir(results_folder, 'lpm_grey');
[~] = mkdir(results_folder, 'taxo_ab');
[~] = mkdir(results_folder, 'taxo_vol');
[~] = mkdir(results_folder, 'taxo_grey');



%% selection of float data

disp("Selection of the LPM csv file from float")
[float_filename, float_folder] = uigetfile('*.csv','Select the LPM csv file from float');
% read CSV
[park_lpm_table, ascent_lpm_table, surface_lpm_table] = Uvp6ReadLpmFromFloatLpmCSV(fullfile(float_folder, float_filename));
float_lpm_table = ascent_lpm_table;
% build num arrays
[float_lpm_ab, float_lpm_grey] = Uvp6BuildLpmArrayFromFloatLpm(float_lpm_table);

disp("Selection of the TAXO csv file from float")
[float_filename, float_folder] = uigetfile('*.csv','Select the TAXO csv file from float');
% read csv
[park_taxo_table, ascent_taxo_table] = Uvp6ReadTaxoFromFloatTaxoCSV(fullfile(float_folder, float_filename));
float_taxo_table = ascent_taxo_table;
% build num array
[float_taxo_ab, float_taxo_vol, float_taxo_grey] = Uvp6BuildTaxoArrayFromFloatTaxo(float_taxo_table);
disp('---------------------------------------------------------------')


%% selection of the rs232 data from uvp6
disp("Selection of the rs232 data from uvp6")
[uvp6_rs232_filename, uvp6_rs232_folder] = uigetfile('*.txt','Select the rs232 data file from uvp6');
% read the file
[taxo_ab_rs232, taxo_vo_rs232, taxo_grey_rs232, lpm_ab_rs232, lpm_grey_rs232] = Uvp6Rs232fileToArray(fullfile(uvp6_rs232_folder, uvp6_rs232_filename));
disp('---------------------------------------------------------------')



%% selection of uvp6 data
disp("Selection of the data file from uvp6")
[uvp6_filename, uvp6_folder] = uigetfile('*.txt','Select the data file from uvp6');
% read lpm data
[data, meta, taxo] = Uvp6DatafileToArray(fullfile(uvp6_folder, uvp6_filename));
% build taxo num array
[uvp6_taxo_ab, uvp6_taxo_vol, uvp6_taxo_grey] = Uvp6ReadTaxoFromTaxotable(meta, data, taxo);
% read data
[uvp6_time_data, uvp6_depth_data, uvp6_raw_nb, uvp6_black_nb, uvp6_image_status, raw_grey] = Uvp6ReadDataFromDattable(meta, data);
% build num arrays
uvp6_lpm_ab = Uvp6BuildLpmArrayFromUvp6Lpm(uvp6_time_data, uvp6_depth_data, uvp6_raw_nb);
%uvp6_lpm_grey = Uvp6BuildLpmArrayFromUvp6Lpm(uvp6_time_data, uvp6_depth_data, uvp6_raw_grey);

% build the lpm class vector
[hw_line, ~, ~, ~] = Uvp6ReadMetalinesFromDatafile(fullfile(uvp6_folder, uvp6_filename));
uvp6_lpm_ab_class = Uvp6ClassDispatcher(hw_line, uvp6_lpm_ab);
disp('------------------------------------------------------')


%% plots total nb of objects
%concatenation nb of object
uvp6_taxo_ab_tot = sum(uvp6_taxo_ab(:,4:end), 1);
float_taxo_tot = sum(float_taxo_ab(:,4:end), 1);
taxo_ab_rs232_tot = sum(taxo_ab_rs232(:,4:end), 1);

%plots
figure
subplot(1,3,1)
plot(uvp6_taxo_ab_tot, 'r')
hold on
plot(float_taxo_tot, 'g')
hold on
plot(taxo_ab_rs232_tot, 'b')
xlabel('nb of the object class')
ylabel('nb of objects of this class')
legend('uvp6', 'float', 'rs232')
title('total nb of object in the profile')

subplot(1,3,2)
plot(uvp6_taxo_ab_tot - float_taxo_tot)
xlabel('nb of the object class')
ylabel('nb of objects of this class')
title('difference between uvp6 and float')

subplot(1,3,3)
plot(uvp6_taxo_ab_tot - taxo_ab_rs232_tot)
xlabel('nb of the object class')
ylabel('nb of objects of this class')
title('difference between uvp6 and rs232')

saveas(gcf, fullfile(project_folder, 'results', 'taxo_ab', 'TAXO_object_nb_tot.png'))


%% plots total nb of lpm
%concatenation nb of part
uvp6_lpm_ab_class_tot = sum(uvp6_lpm_ab_class(:,4:end), 1);
float_lpm_ab_tot = sum(float_lpm_ab(:,5:end), 1);
lpm_ab_rs232_tot = sum(lpm_ab_rs232(:,4:end), 1);

%plots
figure
subplot(1,3,1)
plot(uvp6_lpm_ab_class_tot, 'r')
hold on
plot(float_lpm_ab_tot, 'g')
hold on
plot(lpm_ab_rs232_tot, 'b')
xlabel('nb of the part class')
ylabel('nb of particles of this class')
legend('uvp6', 'float', 'rs232')
title('total nb of particles in the profile')

subplot(1,3,2)
plot(uvp6_lpm_ab_class_tot - float_lpm_ab_tot)
xlabel('nb of the part class')
ylabel('nb of particles of this class')
title('difference between uvp6 and float')

subplot(1,3,3)
plot(uvp6_lpm_ab_class_tot - lpm_ab_rs232_tot)
xlabel('nb of the part class')
ylabel('nb of particles of this class')
title('difference between uvp6 and rs232')

saveas(gcf, fullfile(project_folder, 'results', 'lpm_ab', 'LPM_object_nb_tot.png'))


%% concatenation of slices
% ab
uvp6_taxo_ab_slices = Uvp6FloatSlicer(uvp6_taxo_ab);

% vol
uvp6_taxo_vol_slices = Uvp6FloatSlicer(uvp6_taxo_vol);
% average of volume
uvp6_taxo_vol_slices(:,4:end) = uvp6_taxo_vol_slices(:,4:end) ./ uvp6_taxo_ab_slices(:,4:end);
uvp6_taxo_vol_slices(isnan(uvp6_taxo_vol_slices)) = 0;

% grey
uvp6_taxo_grey_slices = Uvp6FloatSlicer(uvp6_taxo_grey);
% average of grey
uvp6_taxo_grey_slices(:,4:end) = uvp6_taxo_grey_slices(:,4:end) ./ uvp6_taxo_ab_slices(:,4:end);
uvp6_taxo_grey_slices(isnan(uvp6_taxo_grey_slices)) = 0;



%% plot depth slices nb of objects
for j=1:12
    figure
    j_str = num2str(j);
    plot(uvp6_taxo_ab_slices(:,1), uvp6_taxo_ab_slices(:,j+3), 'r')
    hold on
    plot(float_taxo_ab(:,1), float_taxo_ab(:,j+3), 'g')
    xlabel('pressure')
    ylabel(['nb of objects of class ' j_str])
    legend('uvp6', 'float')
    title(['profile of class ' j_str])
    saveas(gcf, fullfile(project_folder, 'results', 'taxo_ab', ['TAXO_object_nb_' j_str '.png']))
    close
end


%% plot depth slices vol
for j=1:11
    figure
    j_str = num2str(j);
    plot(uvp6_taxo_vol_slices(:,1), uvp6_taxo_vol_slices(:,j+3), 'r')
    hold on
    plot(float_taxo_vol(:,1), float_taxo_vol(:,j+3), 'g')
    xlabel('pressure')
    ylabel(['volume of objects of class ' j_str])
    legend('uvp6', 'float')
    title(['profile of class ' j_str])
    saveas(gcf, fullfile(project_folder, 'results', 'taxo_vol', ['TAXO_object_vol_' j_str '.png']))
    close
end

%% plot depth slices grey
for j=1:11
    figure
    j_str = num2str(j);
    plot(uvp6_taxo_grey_slices(:,1), uvp6_taxo_grey_slices(:,j+3), 'r')
    hold on
    plot(float_taxo_grey(:,1), float_taxo_grey(:,j+3), 'g')
    xlabel('pressure')
    ylabel(['grey of objects of class ' j_str])
    legend('uvp6', 'float')
    title(['profile of class ' j_str])
    saveas(gcf, fullfile(project_folder, 'results', 'taxo_grey', ['TAXO_object_grey_' j_str '.png']))
    close
end



%% plots profile per lpm class
% concatenation of slices
uvp6_lpm_ab_slices = Uvp6FloatSlicer(uvp6_lpm_ab_class);
for j=1:12
    figure
    j_str = num2str(j);
    plot(uvp6_lpm_ab_slices(:,1), uvp6_lpm_ab_slices(:,j+3), 'r')
    hold on
    plot(float_lpm_ab(:,1), float_lpm_ab(:,j+4), 'g')
    xlabel('pressure')
    ylabel(['nb of part of class ' j_str])
    legend('uvp6', 'float')
    title(['profile of particles ' j_str])
    saveas(gcf, fullfile(project_folder, 'results', 'lpm_ab', ['LPM_object_nb_' j_str '.png']))
    close
end


%% profile plots


%}






