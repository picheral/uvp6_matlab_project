%% Compare taxo data from uvp6 with from float
% Catalano, 2022/01


clear all
close all
warning('off')

disp('---------------------------------------------------------------')
disp('------------------- Compare taxo data -------------------------')
disp('Select PROJECT folder ')
project_folder = uigetdir('', 'Select PROJECT Folder ');
disp('---------------------------------------------------------------')
disp(['Project Folder : ',char(project_folder)])
[~] = cd(project_folder);
disp('---------------------------------------------------------------')

%% get sequences
results_folder = fullfile(project_folder,'\results\');
raw_folder = fullfile(project_folder,'\raw\');

disp("Selection of the data csv file from float")
[float_filename, float_folder] = uigetfile('*.csv','Select the data csv file from float');
[park_taxo_table, ascent_taxo_table] = Uvp6ReadTaxoFromFloatTaxoCSV(fullfile(float_folder, float_filename));
%float_taxo_table = [park_taxo_table; ascent_taxo_table];
float_taxo_table = ascent_taxo_table;
%float_taxo_table = park_taxo_table;

taxo = [];
meta = [];
another_sequence='y';
while strcmp(another_sequence,'y')
    disp("Selection of the data file from uvp6")
    [uvp6_filename, uvp6_folder] = uigetfile('*.txt','Select the data file from uvp6');
    [data, meta_i, taxo_i] = Uvp6DatafileToArray(fullfile(uvp6_folder, uvp6_filename));
    taxo = [taxo; taxo_i];
    meta = [meta; meta_i];
    another_sequence = input('Add another sequence ? ([n]/y) ','s');
    if isempty(another_sequence);another_sequence = 'n';end
end
disp('------------------------------------------------------')


%% build uvp6_taxo_array
uvp6_taxo_table = cell(length(taxo), 123);
uvp6_taxo_table(:,:) = {0};
for i=1:length(taxo)
    %get meta data
    raw_meta_line = strsplit(meta{i}, {',', ';'});
    date = raw_meta_line{1};
    date = date(1:end-2);
    uvp6_taxo_table(i,1) = {date}; %datetime
    uvp6_taxo_table(i,2) = {str2double(raw_meta_line{2})}; %pression
    
    %get taxo data
    raw_taxo_line = strsplit(taxo{i}, {',', ';'});
    raw_taxo_line = raw_taxo_line(1:end-1);
    uvp6_taxo_table(i,3) = {str2double(raw_taxo_line{1})}; % image nb
    % sum objects of same category
    for j=1:(length(raw_taxo_line)-1)/3
        t = j*3 - 1;
        class_nb = str2double(raw_taxo_line{t});
        class_nb_indice = (class_nb)*3 + 4;
        uvp6_taxo_table(i,class_nb_indice) = {uvp6_taxo_table{i,class_nb_indice} + 1};
        uvp6_taxo_table(i,class_nb_indice+1) = {uvp6_taxo_table{i,class_nb_indice+1} + str2double(raw_taxo_line{t+1})};
        uvp6_taxo_table(i,class_nb_indice+2) = {uvp6_taxo_table{i,class_nb_indice+2} + str2double(raw_taxo_line{t+2})};
    end
    %mean of area and grey
    for j=1:40
        class_nb_indice = j*3 + 1;
        if uvp6_taxo_table{i,class_nb_indice} ~= 0
            uvp6_taxo_table(i,class_nb_indice+1) = {uvp6_taxo_table{i,class_nb_indice+1} / uvp6_taxo_table{i,class_nb_indice}};
            uvp6_taxo_table(i,class_nb_indice+2) = {uvp6_taxo_table{i,class_nb_indice+2} / uvp6_taxo_table{i,class_nb_indice}};
        end
    end

end

disp('------------------------------------------------------')


%% plots total nb of objects
float_taxo_array = cellfun(@str2num, float_taxo_table(:,2:end));
uvp6_taxo_array = cell2mat(uvp6_taxo_table(:,2:end));

%concatenation nb of object
uvp6_taxo_tot = zeros(40,1);
for j=1:40
    class_nb_indice = j*3;
    uvp6_taxo_tot(j) = sum(uvp6_taxo_array(:,class_nb_indice));
end
float_taxo_tot = zeros(40,1);
for j=1:40
    class_nb_indice = j*3;
    float_taxo_tot(j) = sum(float_taxo_array(:,class_nb_indice));
end

subplot(1,2,1)
plot(uvp6_taxo_tot, 'r')
hold on
plot(float_taxo_tot, 'g')
xlabel('nb of the object class')
ylabel('nb of objects of this class')
legend('uvp6', 'float')
title('total nb of object in the profile')

subplot(1,2,2)
plot(uvp6_taxo_tot - float_taxo_tot)
xlabel('nb of the object class')
ylabel('nb of objects of this class')
title('difference between uvp6 and float')

saveas(gcf, fullfile(project_folder, 'results', 'TAXO_object_nb_tot.png'))


%}
%% plot depth slices nb of objects
%concatenation of slices
uvp6_taxo_slices = zeros(1,41);
uvp6_taxo_slices(1,1) = uvp6_taxo_array(1,1);
slice_size = 20;
for i=1:length(uvp6_taxo_array)
    if uvp6_taxo_array(i,1) > uvp6_taxo_slices(end,1) - slice_size
        for j=1:40
            class_nb_indice = j*3;
            uvp6_taxo_slices(end,j+1) = uvp6_taxo_slices(end,j+1) + uvp6_taxo_array(i,class_nb_indice);
        end
    else
        new_slice = [uvp6_taxo_array(i,1) uvp6_taxo_array(i,3:3:121)];
        uvp6_taxo_slices = [uvp6_taxo_slices; new_slice];
    end
    if uvp6_taxo_slices(end,1) < 100
        slice_size = 5;
    elseif uvp6_taxo_slices(end,1) < 500
        slice_size = 10;
    end
end

for j=1:12
    figure
    j_str = num2str(j);
    plot(uvp6_taxo_slices(:,1), uvp6_taxo_slices(:,j+1), 'r')
    hold on
    plot(float_taxo_array(:,1), float_taxo_array(:,j*3), 'g')
    xlabel('pressure')
    ylabel(['nb of objects of class ' j_str])
    legend('uvp6', 'float')
    title(['profile of class ' j_str])
    saveas(gcf, fullfile(project_folder, 'results', ['TAXO_object_nb_' j_str '.png']))
    close
end

