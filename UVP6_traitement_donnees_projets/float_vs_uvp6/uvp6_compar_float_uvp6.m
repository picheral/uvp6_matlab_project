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


%% selection of float data

disp("Selection of the LPM csv file from float")
[float_filename, float_folder] = uigetfile('*.csv','Select the LPM csv file from float');
[park_lpm_table, ascent_lpm_table, surface_lpm_table] = Uvp6ReadLpmFromFloatLpmCSV(fullfile(float_folder, float_filename));
float_lpm_table = ascent_lpm_table;
[float_lpm_ab, float_lpm_grey] = Uvp6BuildLpmArrayFromFloatLpm(float_lpm_table);

disp("Selection of the TAXO csv file from float")
[float_filename, float_folder] = uigetfile('*.csv','Select the TAXO csv file from float');
[park_taxo_table, ascent_taxo_table] = Uvp6ReadTaxoFromFloatTaxoCSV(fullfile(float_folder, float_filename));
float_taxo_table = ascent_taxo_table;
[float_taxo_ab, float_taxo_vol, float_taxo_grey] = Uvp6BuildTaxoArrayFromFloatTaxo(float_taxo_table);
disp('---------------------------------------------------------------')


%% selection of uvp6 data
disp("Selection of the data file from uvp6")
[uvp6_filename, uvp6_folder] = uigetfile('*.txt','Select the data file from uvp6');
[data, meta, taxo] = Uvp6DatafileToArray(fullfile(uvp6_folder, uvp6_filename));
[uvp6_taxo_ab, uvp6_taxo_vol, uvp6_taxo_grey] = Uvp6ReadTaxoFromTaxotable(meta, data, taxo);
[uvp6_time_data, uvp6_depth_data, uvp6_raw_nb, uvp6_black_nb, uvp6_image_status] = Uvp6ReadDataFromDattable(meta, data); %%%%% remonter grey
%%%% num arrays propres sans nan et par classe
% uvp6_lpm_ab [pressure time image_nb raw_nb]
% uvp6_lpm_grey [pressure time image_nb raw_grey]
disp('------------------------------------------------------')



%% plots total nb of objects
%concatenation nb of object
uvp6_taxo_ab_tot = sum(uvp6_taxo_ab(:,4:end), 1);
float_taxo_tot = sum(float_taxo_ab(:,4:end), 1);

%plots
subplot(1,2,1)
plot(uvp6_taxo_ab_tot, 'r')
hold on
plot(float_taxo_tot, 'g')
xlabel('nb of the object class')
ylabel('nb of objects of this class')
legend('uvp6', 'float')
title('total nb of object in the profile')

subplot(1,2,2)
plot(uvp6_taxo_ab_tot - float_taxo_tot)
xlabel('nb of the object class')
ylabel('nb of objects of this class')
title('difference between uvp6 and float')

saveas(gcf, fullfile(project_folder, 'results', 'TAXO_object_nb_tot.png'))


%% plots total nb of lpm
%%%% plots total nb of lpm


%}
%% concatenation of slices
%%%% slicer
% uvp6_taxo_ab_slices
% uvp6_taxo_grey_slices
% uvp6_taxo_vol_slices
% uvp6_lpm_ab_slices
% uvp6_lpm_grey_slices

uvp6_taxo_ab_slices = Uvp6FloatSlicer(uvp6_taxo_ab);
uvp6_taxo_vol_slices = Uvp6FloatSlicer(uvp6_taxo_vol);
uvp6_taxo_vol_slices(:,4:end) = uvp6_taxo_vol_slices(:,4:end) ./ uvp6_taxo_ab_slices(:,4:end);
uvp6_taxo_vol_slices(isnan(uvp6_taxo_vol_slices)) = 0;
uvp6_taxo_grey_slices = Uvp6FloatSlicer(uvp6_taxo_grey);
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
    saveas(gcf, fullfile(project_folder, 'results', ['TAXO_object_nb_' j_str '.png']))
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
    saveas(gcf, fullfile(project_folder, 'results', ['TAXO_object_vol_' j_str '.png']))
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
    saveas(gcf, fullfile(project_folder, 'results', ['TAXO_object_grey_' j_str '.png']))
    close
end



%% plots profile per lpm class

%% Read rs232 log file from uvp and good num arrays
% uvp6_tram_taxo = Uvp6ReadTramTaxoFromLog(filepath, meta);

%% profile plots









