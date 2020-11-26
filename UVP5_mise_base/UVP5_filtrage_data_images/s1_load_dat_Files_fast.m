clear; close all; clc

%% define the location of original DATFILEs
indir = '\\plankton.obs-vlfr.fr\uvp_b\uvp5_sn200_ilhas_2017\results';     % edit here
dat_list = dir([indir '/*_datfile.txt']);
nB = length(dat_list);

%% code leandro.ticlia
inputMat = 'm0';        % reusing the old mat files

outMat = 'm1';
mkdir(outMat);

fprintf('Loading DAT file... \n');
for i = 1:nB
    nm = dat_list(i).name;
    infile = [indir '/' nm];
    fprintf('[%d of %d] Processing file >> %s\n', i,nB, nm);
    
    idF = fopen (infile);
    vW = textscan(idF, '%f %s %f %f %f %f  %f %f %f %f  %f %f %f %s  %f %f %f %f %f ', 'Delimiter', ';');
    fclose(idF);
    
    dat_imgId =  vW{1};
    dat_imgData = vW{2};
    dat_nPG = vW{2+12+1};
    dat_nG = vW{2+12+4};
    dat_nRoi = dat_nPG + dat_nG;
    clear vW;
    
    for j = 1:length(dat_imgData)
        dt = dat_imgData{j};
        yy = str2num(dt(1:4));
        mm = str2num(dt(5:6));
        day = str2num(dt(7:8));
        hh = str2num(dt(9:10));
        mmin = str2num(dt(11:12));
        sseg = str2num([dt(13:14) '.' dt(16:end) ]);
        dat_imgDatetime(j) = datenum(yy, mm, day, hh, mmin, sseg);
    end
    brufile = [inputMat '/' nm(1:end-12) '.mat'];
    fprintf(' -- Loading bru file >> %s\n', brufile);
    load(brufile)
    nRois = length(vArea_pxl);
    vDatetime = nan(1, nRois);
    vNG = nan(1, nRois);
    vImgName = repmat({'.'}, nRois, 1);
    
    map_datatime = containers.Map(dat_imgId, dat_imgDatetime);
    map_NG = containers.Map(dat_imgId, dat_nG);
    map_ImgName = containers.Map(dat_imgId, dat_imgData);
    
    idx_bool = isKey(map_datatime, num2cell(vId_img));
    idx_ok = find(idx_bool == 1);
    
    idx_datetime = values(map_datatime, num2cell(vId_img( idx_ok )));
    idx_datetime = [idx_datetime{:}];
    vDatetime(idx_ok) = idx_datetime;
    
    idx_NG = values(map_NG, num2cell(vId_img( idx_ok )));
    idx_NG = [idx_NG{:}];
    vNG(idx_ok) = idx_NG;
    
    idx_ImgName = values(map_ImgName, num2cell(vId_img( idx_ok )));
    %idx_ImgName = [idx_ImgName{:}];
    vImgName(idx_ok) = idx_ImgName;
    
    fprintf(' Saving Mat with %d lines \n', nRois);
    oput = [outMat '/' nm(1:end-12) '.mat'];
    save(oput, 'vId_img', 'vId_roi', 'vArea_pxl', 'vGray_level', 'vXX_center', 'vYY_center', 'vDatetime', 'vNG', 'vImgName');
    
    clear vId_img vId_roi vArea_pxl vGray_level vXX_center vYY_center
    clear vDatetime dat_imgDatetime vNG vImgName;
    
    
end