clear; close all; clc

%% input variable
indir = 'bru_filtered_files';               % define the full path of the filtered BRU file location.
bru_list = dir([indir '/*.bru']);
nB = length(bru_list);

%% code -- leandro.ticlia
dout = 'm0';
mkdir(dout);

fprintf('Loading BRU files ... \n');
for i = 1:nB
    nm = bru_list(i).name;
    infile = [indir '/' nm];
    fprintf('[%d of %d] Processing file >> %s\n', i,nB, nm);
    
    idF = fopen (infile);
    
    j = 0;
    vId_img = [];
    vId_roi = [];
    vArea_pxl = [];
    vGray_level = [];
    vXX_center= [];
    vYY_center = [];
    
    vW = textscan(idF, '%f %f %f %f %f %f', 'Delimiter', ';');
    
    vId_img  = vW{1};
    vId_roi  = vW{2};
    vArea_pxl  = vW{3};
    
    vGray_level  = vW{4};
    vXX_center = vW{5};
    vYY_center  = vW{6};
    j = length(vId_img);
    
    fclose(idF);
    
    fprintf(' Saving %d lines \n', j);
    oput = [dout '/' nm(1:end-4) '.mat'];
    save(oput, 'vId_img', 'vId_roi', 'vArea_pxl', 'vGray_level', 'vXX_center', 'vYY_center');
    %
    
end