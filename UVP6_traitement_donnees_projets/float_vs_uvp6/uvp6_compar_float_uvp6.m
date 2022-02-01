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
[taxo_ab_rs232, taxo_vol_rs232, taxo_grey_rs232, lpm_ab_rs232, lpm_grey_rs232] = Uvp6Rs232fileToArray(fullfile(uvp6_rs232_folder, uvp6_rs232_filename));
disp('---------------------------------------------------------------')



%% selection of uvp6 data
disp("Selection of the data file from uvp6")
[uvp6_filename, uvp6_folder] = uigetfile('*.txt','Select the data file from uvp6');
% read lpm data
[data, meta, taxo] = Uvp6DatafileToArray(fullfile(uvp6_folder, uvp6_filename));
% build taxo num array
[uvp6_taxo_ab, uvp6_taxo_vol, uvp6_taxo_grey] = Uvp6ReadTaxoFromTaxotable(meta, data, taxo);
[uvp6_taxo_ab_block, uvp6_taxo_vol_block, uvp6_taxo_grey_blok] = Uvp6BuildTaxoImagesBlocks(uvp6_taxo_ab, uvp6_taxo_vol, uvp6_taxo_grey);
% read data
[uvp6_time_data, uvp6_depth_data, uvp6_raw_nb, uvp6_black_nb, uvp6_raw_grey, uvp6_image_status] = Uvp6ReadDataFromDattable(meta, data);
% build num arrays
uvp6_lpm_ab = Uvp6BuildLpmArrayFromUvp6Lpm(uvp6_time_data, uvp6_depth_data, uvp6_raw_nb);
uvp6_lpm_grey = Uvp6BuildLpmArrayFromUvp6Lpm(uvp6_time_data, uvp6_depth_data, uvp6_raw_grey);


% build the lpm class vectors
[hw_line, ~, ~, ~] = Uvp6ReadMetalinesFromDatafile(fullfile(uvp6_folder, uvp6_filename));
uvp6_lpm_ab_class = Uvp6ClassDispatcher(hw_line, uvp6_lpm_ab);
%uvp6_lpm_grey_class = Uvp6ClassDispatcher(hw_line, uvp6_lpm_grey);
%uvp6_lpm_grey_class(:,4:end) = uvp6_lpm_grey_class(:,4:end) / uvp6_lpm_ab_class(:,4:end);
% grey : class dispatcher avec moyenne pondérée sur l'aire des objets pour
% coller à la version 01/2022 du firmware
% a supprimer pour la nouvelle version
uvp6_lpm_grey_class = Uvp6ClassDispatcherGrey(hw_line, uvp6_lpm_grey);
uvp6_lpm_grey_class(isnan(uvp6_lpm_grey_class)) = 0;
disp('------------------------------------------------------')


%% uvp6 concatenation of slices
% taxo ab
uvp6_taxo_ab_slices = Uvp6FloatSlicer(uvp6_taxo_ab_block);
images_uvp6_taxo_ab_slices = sum(uvp6_taxo_ab_slices(:,3));
% taxo vol
uvp6_taxo_vol_slices = Uvp6FloatSlicer(uvp6_taxo_vol_block);
uvp6_taxo_vol_slices(:,4:end) = uvp6_taxo_vol_slices(:,4:end) ./ uvp6_taxo_ab_slices(:,4:end);% average of volume, per object
uvp6_taxo_vol_slices(isnan(uvp6_taxo_vol_slices)) = 0;
images_uvp6_taxo_vol_slices = sum(uvp6_taxo_vol_slices(:,3));
% taxo grey
uvp6_taxo_grey_slices = Uvp6FloatSlicer(uvp6_taxo_grey_blok);
uvp6_taxo_grey_slices(:,4:end) = uvp6_taxo_grey_slices(:,4:end) ./ uvp6_taxo_ab_slices(:,4:end);% average of grey, per object
uvp6_taxo_grey_slices(isnan(uvp6_taxo_grey_slices)) = 0;
images_uvp6_taxo_grey_slices = sum(uvp6_taxo_grey_slices(:,3));

% lpm ab
uvp6_lpm_ab_slices = Uvp6FloatSlicer(uvp6_lpm_ab_class);
images_uvp6_lpm_ab_slices = sum(uvp6_lpm_ab_slices(:,3));
% lpm grey
uvp6_lpm_grey_class_temp = uvp6_lpm_grey_class;
uvp6_lpm_grey_class_temp(:,4:end) = uvp6_lpm_grey_class_temp(:,4:end) .* uvp6_lpm_ab_class(:,4:end);
uvp6_lpm_grey_slices = Uvp6FloatSlicer(uvp6_lpm_grey_class_temp);
uvp6_lpm_grey_slices(:,4:end) = round(uvp6_lpm_grey_slices(:,4:end) ./ uvp6_lpm_ab_slices(:,4:end));% average of grey, per object
uvp6_lpm_grey_slices(isnan(uvp6_lpm_grey_slices)) = 0;
images_uvp6_lpm_grey_slices = sum(uvp6_lpm_grey_slices(:,3));


%% RS232 concatenation of slices
% taxo ab
taxo_ab_rs232_slices = Uvp6FloatSlicer(taxo_ab_rs232);
images_taxo_ab_rs232_slices = sum(taxo_ab_rs232_slices(:,3));
% taxo vol
taxo_vol_rs232_slices = Uvp6FloatSlicer(taxo_vol_rs232);
taxo_vol_rs232_slices(:,4:end) = taxo_vol_rs232_slices(:,4:end) ./ taxo_ab_rs232_slices(:,4:end);
taxo_vol_rs232_slices(isnan(taxo_vol_rs232_slices)) = 0;
images_taxo_vol_rs232_slices = sum(taxo_vol_rs232_slices(:,3));
% taxo grey
taxo_grey_rs232_slices = Uvp6FloatSlicer(taxo_grey_rs232);
taxo_grey_rs232_slices(:, 4:end) = taxo_grey_rs232_slices(:,4:end) ./ taxo_ab_rs232_slices(:,4:end);
taxo_grey_rs232_slices(isnan(taxo_grey_rs232_slices)) = 0;
images_taxo_grey_rs232_slices = sum(taxo_grey_rs232_slices(:,3));

% lpm ab
lpm_ab_rs232_slices = Uvp6FloatSlicer(lpm_ab_rs232);
images_lpm_ab_rs232_slices = sum(lpm_ab_rs232_slices(:,3));
% lpm grey
lpm_grey_rs232_temp = lpm_grey_rs232;
lpm_grey_rs232_temp(:,4:end) = lpm_grey_rs232_temp(:,4:end) .* lpm_ab_rs232(:,4:end);
lpm_grey_rs232_slices = Uvp6FloatSlicer(lpm_grey_rs232_temp);
lpm_grey_rs232_slices(:,4:end) = round(lpm_grey_rs232_slices(:,4:end) ./ lpm_ab_rs232_slices(:,4:end));% average of grey, per object
lpm_grey_rs232_slices(isnan(lpm_grey_rs232_slices)) = 0;
images_lpm_grey_rs232_slices = sum(lpm_grey_rs232_slices(:,3));


%% Float nb of images
images_float_lpm_ab = sum(float_lpm_ab(:,3));
images_float_lpm_grey = sum(float_lpm_grey(:,3));
images_float_taxo_ab = sum(float_taxo_ab(:,3));
images_float_taxo_grey = sum(float_taxo_grey(:,3));
images_float_taxo_vol = sum(float_taxo_vol(:,3));


%% concatenation of total data for control
%concatenation nb of object
uvp6_taxo_ab_tot = sum(uvp6_taxo_ab_block(:,4:end), 1);
float_taxo_tot = sum(float_taxo_ab(:,4:end), 1);
taxo_ab_rs232_tot = sum(taxo_ab_rs232(:,4:end), 1);
%concatenation vol taxo
uvp6_taxo_vol_tot = sum(uvp6_taxo_vol_slices(:,4:end), 1);
float_taxo_vol_tot = sum(float_taxo_vol(:,4:end), 1);
taxo_vol_rs232_tot = sum(taxo_vol_rs232_slices(:,4:end), 1);
%concatenation grey taxo
uvp6_taxo_grey_tot = sum(uvp6_taxo_grey_slices(:,4:end), 1);
float_taxo_grey_tot = sum(float_taxo_grey(:,4:end), 1);
taxo_grey_rs232_tot = sum(taxo_grey_rs232_slices(:,4:end), 1);
%concatenation nb of part
uvp6_lpm_ab_class_tot = sum(uvp6_lpm_ab_class(:,4:end), 1);
float_lpm_ab_tot = sum(float_lpm_ab(:,5:end), 1);
lpm_ab_rs232_tot = sum(lpm_ab_rs232(:,4:end), 1);
%concatenation grey of part
uvp6_lpm_grey_class_tot = sum(uvp6_lpm_grey_slices(:,4:end), 1);
float_lpm_grey_tot = sum(float_lpm_grey(:,5:end), 1);
lpm_grey_rs232_tot = sum(lpm_grey_rs232_slices(:,4:end), 1);






%% plots total nb of objects

%plots
figure
subplot(1,3,1)
plot(uvp6_taxo_ab_tot, 'r')
hold on
plot(float_taxo_tot, 'g-.')
hold on
plot(taxo_ab_rs232_tot, 'b:')
xlabel('nb of the object class')
ylabel('nb of objects of this class')
legend('uvp6', 'float', 'rs232')
title('total nb of objects')

subplot(1,3,2)
plot(uvp6_taxo_ab_tot - float_taxo_tot)
xlabel('nb of the object class')
ylabel('nb of objects of this class')
title('uvp6 - float')

subplot(1,3,3)
plot(uvp6_taxo_ab_tot - taxo_ab_rs232_tot)
xlabel('nb of the object class')
ylabel('nb of objects of this class')
title('uvp6 - rs232')

saveas(gcf, fullfile(project_folder, 'results', 'taxo_ab', 'TAXO_object_nb_tot.png'))


%% plots total vol of objects

%plots
figure
subplot(1,3,1)
plot(uvp6_taxo_vol_tot, 'r')
hold on
plot(float_taxo_vol_tot, 'g-.')
hold on
plot(taxo_vol_rs232_tot, 'b:')
xlabel('nb of the object class')
ylabel('vol of objects of this class')
legend('uvp6', 'float', 'rs232')
title('total vol of objects')

subplot(1,3,2)
plot(uvp6_taxo_vol_tot - float_taxo_vol_tot)
xlabel('nb of the object class')
ylabel('vol of objects of this class')
title('uvp6 - float')

subplot(1,3,3)
plot(uvp6_taxo_vol_tot - taxo_vol_rs232_tot)
xlabel('nb of the object class')
ylabel('vol of objects of this class')
title('uvp6 - rs232')

saveas(gcf, fullfile(project_folder, 'results', 'taxo_vol', 'TAXO_vol_tot.png'))


%% plots total grey of objects

%plots
figure
subplot(1,3,1)
plot(uvp6_taxo_grey_tot, 'r')
hold on
plot(float_taxo_grey_tot, 'g-.')
hold on
plot(taxo_grey_rs232_tot, 'b:')
xlabel('nb of the object class')
ylabel('grey of objects of this class')
legend('uvp6', 'float', 'rs232')
title('total grey of objects')

subplot(1,3,2)
plot(uvp6_taxo_grey_tot - float_taxo_grey_tot)
xlabel('nb of the object class')
ylabel('grey of objects of this class')
title('uvp6 - float')

subplot(1,3,3)
plot(uvp6_taxo_grey_tot - taxo_grey_rs232_tot)
xlabel('nb of the object class')
ylabel('grey of objects of this class')
title('uvp6 - rs232')

saveas(gcf, fullfile(project_folder, 'results', 'taxo_grey', 'TAXO_object_grey_tot.png'))


%% plots total nb of lpm

%plots
figure
subplot(1,3,1)
plot(uvp6_lpm_ab_class_tot, 'r')
hold on
plot(float_lpm_ab_tot, 'g-.')
hold on
plot(lpm_ab_rs232_tot, 'b:')
xlabel('nb of the part class')
ylabel('nb of particles of this class')
legend('uvp6', 'float', 'rs232')
title('total nb of particles')

subplot(1,3,2)
plot(uvp6_lpm_ab_class_tot(1:end-1) - float_lpm_ab_tot(1:end-1))
xlabel('nb of the part class')
ylabel('nb of particles of this class')
title('uvp6 - float')

subplot(1,3,3)
plot(uvp6_lpm_ab_class_tot(1:end-1) - lpm_ab_rs232_tot(1:end-1))
xlabel('nb of the part class')
ylabel('nb of particles of this class')
title('uvp6 - rs232')

saveas(gcf, fullfile(project_folder, 'results', 'lpm_ab', 'LPM_part_nb_tot.png'))


%% plots total grey of lpm

%plots
figure
subplot(1,3,1)
plot(uvp6_lpm_grey_class_tot, 'r')
hold on
plot(float_lpm_grey_tot, 'g-.')
hold on
plot(lpm_grey_rs232_tot, 'b:')
xlabel('nb of the part class')
ylabel('grey of particles of this class')
legend('uvp6', 'float', 'rs232')
title('total grey of particles')

subplot(1,3,2)
plot(uvp6_lpm_grey_class_tot(1:end-1) - float_lpm_grey_tot(1:end-1))
xlabel('nb of the part class')
ylabel('grey of particles of this class')
title('uvp6 - float')

subplot(1,3,3)
plot(uvp6_lpm_grey_class_tot(1:end-1) - lpm_grey_rs232_tot(1:end-1))
xlabel('nb of the part class')
ylabel('grey of particles of this class')
title('uvp6 - rs232')

saveas(gcf, fullfile(project_folder, 'results', 'lpm_grey', 'LPM_grey_tot.png'))




%% plot depth slices taxo nb of objects
for j=1:12
    figure
    j_str = num2str(j);
    plot(uvp6_taxo_ab_slices(:,1), uvp6_taxo_ab_slices(:,j+3), 'r')
    hold on
    plot(float_taxo_ab(:,1), float_taxo_ab(:,j+3), 'g-.')
    hold on
    plot(taxo_ab_rs232_slices(:,1), taxo_ab_rs232_slices(:,j+3), 'b:')
    xlabel('pressure')
    ylabel(['nb of objects of class ' j_str])
    legend('uvp6', 'float', 'rs232')
    title(['taxo ab profile of class ' j_str])
    saveas(gcf, fullfile(project_folder, 'results', 'taxo_ab', ['TAXO_object_nb_' j_str '.png']))
    close
end


%% plot depth slices taxo vol
for j=1:11
    figure
    j_str = num2str(j);
    plot(uvp6_taxo_vol_slices(:,1), uvp6_taxo_vol_slices(:,j+3), 'r')
    hold on
    plot(float_taxo_vol(:,1), float_taxo_vol(:,j+3), 'g-.')
    hold on
    plot(taxo_vol_rs232_slices(:,1), taxo_vol_rs232_slices(:,j+3), 'b:')
    xlabel('pressure')
    ylabel(['volume of objects of class ' j_str])
    legend('uvp6', 'float', 'rs232')
    title(['taxo vol profile of class ' j_str])
    saveas(gcf, fullfile(project_folder, 'results', 'taxo_vol', ['TAXO_object_vol_' j_str '.png']))
    close
end

%% plot depth slices taxo grey
for j=1:11
    figure
    j_str = num2str(j);
    plot(uvp6_taxo_grey_slices(:,1), uvp6_taxo_grey_slices(:,j+3), 'r')
    hold on
    plot(float_taxo_grey(:,1), float_taxo_grey(:,j+3), 'g-.')
    hold on
    plot(taxo_grey_rs232_slices(:,1), taxo_grey_rs232_slices(:,j+3), 'b:')
    xlabel('pressure')
    ylabel(['grey of objects of class ' j_str])
    legend('uvp6', 'float', 'rs232')
    title(['taxo grey profile of class ' j_str])
    saveas(gcf, fullfile(project_folder, 'results', 'taxo_grey', ['TAXO_object_grey_' j_str '.png']))
    close
end



%% plot depth slices lpm abundance
for j=1:12
    figure
    j_str = num2str(j);
    plot(uvp6_lpm_ab_slices(:,1), uvp6_lpm_ab_slices(:,j+3), 'r')
    hold on
    plot(float_lpm_ab(:,1), float_lpm_ab(:,j+4), 'g-.')
    hold on
    plot(lpm_ab_rs232_slices(:,1), lpm_ab_rs232_slices(:,j+3), 'b:')
    xlabel('pressure')
    ylabel(['nb of part of class ' j_str])
    legend('uvp6', 'float', 'rs232')
    title(['lpm profile of particles ' j_str])
    saveas(gcf, fullfile(project_folder, 'results', 'lpm_ab', ['LPM_part_nb_' j_str '.png']))
    close
end



%% plot depth slices lpm grey
for j=1:12
    figure
    j_str = num2str(j);
    plot(uvp6_lpm_grey_slices(:,1), uvp6_lpm_grey_slices(:,j+3), 'r')
    hold on
    plot(float_lpm_grey(:,1), float_lpm_grey(:,j+4), 'g-.')
    hold on
    plot(lpm_grey_rs232_slices(:,1), lpm_grey_rs232_slices(:,j+3), 'b:')
    xlabel('pressure')
    ylabel(['average grey lvl of class ' j_str])
    legend('uvp6', 'float', 'rs232')
    title(['lpm profile of grey ' j_str])
    saveas(gcf, fullfile(project_folder, 'results', 'lpm_grey', ['LPM_grey_' j_str '.png']))
    close
end


%% file images nb
fid = fopen(fullfile(results_folder, 'caract_uvp6_float.txt'), 'w');
fprintf(fid, ['uvp6 lpm ab images number     : ' num2str(images_uvp6_lpm_ab_slices) '\n']);
fprintf(fid, ['uvp6 lpm grey images number   : ' num2str(images_uvp6_lpm_grey_slices) '\n']);
fprintf(fid, ['uvp6 taxo ab images number    : ' num2str(images_uvp6_taxo_ab_slices) '\n']);
fprintf(fid, ['uvp6 taxo grey images number  : ' num2str(images_uvp6_taxo_grey_slices) '\n']);
fprintf(fid, ['uvp6 taxo vol images number   : ' num2str(images_uvp6_taxo_vol_slices) '\n']);
fprintf(fid, '\n');
fprintf(fid, ['rs232 lpm ab images number    : ' num2str(images_lpm_ab_rs232_slices) '\n']);
fprintf(fid, ['rs232 lpm grey images number  : ' num2str(images_lpm_grey_rs232_slices) '\n']);
fprintf(fid, ['rs232 taxo ab images number   : ' num2str(images_taxo_ab_rs232_slices) '\n']);
fprintf(fid, ['rs232 taxo grey images number : ' num2str(images_taxo_grey_rs232_slices) '\n']);
fprintf(fid, ['rs232 taxo vol images number  : ' num2str(images_taxo_vol_rs232_slices) '\n']);
fprintf(fid, '\n');
fprintf(fid, ['float lpm ab images number    : ' num2str(images_float_lpm_ab) '\n']);
fprintf(fid, ['float lpm grey images number  : ' num2str(images_float_lpm_grey) '\n']);
fprintf(fid, ['float taxo ab images number   : ' num2str(images_float_taxo_ab) '\n']);
fprintf(fid, ['float taxo grey images number : ' num2str(images_float_taxo_grey) '\n']);
fprintf(fid, ['float taxo vol images number  : ' num2str(images_float_taxo_vol) '\n']);
fclose(fid);

