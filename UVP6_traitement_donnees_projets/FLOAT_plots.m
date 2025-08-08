%% Plot data from float csv
% Catalano, 2022/05

clear all
close all
warning('off')

disp('---------------------------------------------------------------')
disp('------------------- Plots from float csv ----------------------')
disp('---------------------------------------------------------------')

park_flag = 0;
nb_of_classes = 20;

%% select taxo csv
disp("Selection of the TAXO csv file from float")
[float_filename, float_folder] = uigetfile('*.csv','Select the TAXO csv file from float');
% read csv
[park_taxo_table, ascent_taxo_table] = Uvp6ReadTaxoFromFloatTaxoCSV(fullfile(float_folder, float_filename));
if park_flag
    float_taxo_table = park_taxo_table;
else
    float_taxo_table = ascent_taxo_table;
end
% build num array
float_taxo_table = strrep(float_taxo_table, '+INF', 'NaN');
[float_taxo_ab, float_taxo_vol, float_taxo_grey] = Uvp6BuildTaxoArrayFromFloatTaxo(float_taxo_table);
disp('---------------------------------------------------------------')

plots_folder = [float_filename '_plots'];
[~] = mkdir(float_folder, plots_folder)
[~] = mkdir(fullfile(float_folder, plots_folder), 'taxo_ab');
[~] = mkdir(fullfile(float_folder, plots_folder), 'taxo_vol');
[~] = mkdir(fullfile(float_folder, plots_folder), 'taxo_grey');


%% plot depth slices taxo nb of objects
disp('Save plots...')
for j=1:20
    figure
    j_str = num2str(j);
    plot(float_taxo_ab(:,1), float_taxo_ab(:,j+3)./float_taxo_ab(:,3))
    xlabel('pressure')
    ylabel(['nb of objects of class' j_str ' per image'])
    title(['taxo ab profile of class ' j_str])
    saveas(gcf, fullfile(float_folder, plots_folder, 'taxo_ab', ['TAXO_object_nb_' j_str '.png']))
    close
end

%% plot depth slices taxo vol
for j=1:20
    figure
    j_str = num2str(j);
    plot(float_taxo_vol(:,1), float_taxo_vol(:,j+3))
    xlabel('pressure')
    ylabel(['volume of objects of class ' j_str])
    title(['taxo vol profile of class ' j_str])
    saveas(gcf, fullfile(float_folder, plots_folder, 'taxo_vol', ['TAXO_object_vol_' j_str '.png']))
    close
end

%% plot depth slices taxo grey
for j=1:20
    figure
    j_str = num2str(j);
    plot(float_taxo_grey(:,1), float_taxo_grey(:,j+3))
    xlabel('pressure')
    ylabel(['grey of objects of class ' j_str])
    title(['taxo grey profile of class ' j_str])
    saveas(gcf, fullfile(float_folder, plots_folder, 'taxo_grey', ['TAXO_object_grey_' j_str '.png']))
    close
end


disp('---------------------------------------------------------------')
disp('----------------------- End of process ------------------------')
disp('---------------------------------------------------------------')
disp('---------------------------------------------------------------')