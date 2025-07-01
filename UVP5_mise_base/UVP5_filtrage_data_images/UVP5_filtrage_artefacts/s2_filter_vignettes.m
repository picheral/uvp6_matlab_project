function s2_filter_vignettes(project_name,xlsfile,th_area)

% clear;
% close all; clc

%% input variables
root_projectsPath = [project_name,'\raw'];   % projects start with HDR
meta_projectsPath = [project_name,'\meta'];   % projects start with HDR
[NN, TT] = xlsread([meta_projectsPath,'\',xlsfile]);
cd(project_name);

inputMat = 'filtering/m1';        % mat files
flag_moveFiles = 1;     % 1 for moving files, -- 0 for skipping

%% output variables
outDir = 'filtering/logDir';
mkdir(outDir);

ignoredDir = 'ignored';
full_ignoredDir = ''; % it will be composed by image profile path + ignoredDir;
ignored_rois_name = 'Vignette_not_Bru';         % temporal name for rois that will be removed

%% code leandro.ticlia
%% constants
HH_frame = 2048;
WW_frame = 2048;


%% global variables
vig_listProjects = dir( [root_projectsPath '/HDR*'] );
idx = find([vig_listProjects.isdir] == 1);
vig_listProjects = vig_listProjects(idx);
vig_nProj = length(vig_listProjects);


%% loading xlsx information
xls_profName = TT(2:end, 4);
xls_th_pixelSize = NN(:, 20);
xls_hdrName = cellstr(num2str(NN(:,1)));

%% vignettes filtering
% for i = 1:vig_nProj
for i = 11:14
    hdr_name = vig_listProjects(i).name;
    hdr_name_id = hdr_name(4:end);         %% excel table does not contain prefix HDR
    disp(hdr_name_id);
    disp(xls_hdrName)
    idx = find(  strcmp( hdr_name_id, xls_hdrName) == 1 );
    ilha_name = xls_profName{idx};
    
    bru_name = [ilha_name '.mat'];
    fprintf('\n[%d/%d]Processing HDR%s <--> %s\n', i, vig_nProj, hdr_name_id, ilha_name);
    fprintf('>> Loading BRU file -->%s\n', bru_name);
    load([inputMat '/' bru_name]);
    fprintf('-- BRU file was loaded sucessfully :-)\n');
    fprintf('-- #lines >> %d\n', length(vImgName));
    
    % id_roi --> '0000' format
    part2 = cellstr(num2str( vId_roi,  '%04d'));
    part2 = strcat('_', part2);
    vRoiName = strcat( vImgName,  part2);
    
    fprintf('>> Loading images list \n');
    vig_imgList = dir( [root_projectsPath '/' hdr_name '/*.bmp' ] );
    vig_nImg = length(vig_imgList);
    fprintf('-- #Images found >> %d\n', vig_nImg);
    
    map_frameName_ID = containers.Map(vRoiName, [1:length(vRoiName)]);
    hist_NG_ok = [];
    hist_NG_Area = [];
    hist_Img_name = {};
    for j = 1:vig_nImg
        roi_name = vig_imgList(j).name;     % 20170212195251_313_0003.bmp
        roi_key = roi_name(1:end-4);
        roi_exist = isKey(map_frameName_ID, roi_key);
        if(roi_exist)   % ROI is in the filtered bru file
            idx = map_frameName_ID( roi_key );
            hist_Img_name{j} = vImgName{idx};
            hist_NG_ok(j) = vNG(idx);
            hist_NG_Area(j) = vArea_pxl(idx);
        else
            hist_NG_ok(j) = -1;
            hist_NG_Area(j) = 0;
            hist_Img_name{j} = ignored_rois_name;
        end
    end
    
    [uFrames, ~, J]  = unique(hist_Img_name, 'stable');
    count_fr = histc(J, 1:numel(uFrames));
    
    %% reporting resume table
    fid = fopen([outDir '/resume_' ilha_name '.txt'], 'w');
    fprintf(fid, 'Frame_name\t#NG_datfile\t#Rois\t#Area79\tNeedSelection\n' );         % example >> 20170208002414_789_0002
    for j = 1:length(uFrames)
        cur = uFrames{j};
        idx = find(strcmp(cur, hist_Img_name) == 1);
        
        fn = uFrames{j};
        ngDat = mean(hist_NG_ok(idx));
        vigBru = length(idx);
        vigBru79 = sum(hist_NG_Area(idx) > th_area);
        needSelection = (vigBru > vigBru79);
        fprintf(fid,  '%s\t%d\t%d\t%d\t%d\n',  fn , ngDat, vigBru, vigBru79, needSelection);
    end
    fprintf(fid, 'total\t\t%d\n', sum(count_fr) );
    fclose(fid);
    
    
    idx = find(strcmp(ignored_rois_name, hist_Img_name) == 1);
    fprintf('-- #Imgs to be ingored>> %d\n', length(idx));
    fprintf('-- -- please wait  .... \n');
    %% moving ignored images into the subfolder
    if(flag_moveFiles == 1)
        full_ignoredDir = [root_projectsPath '/' hdr_name '/' ignoredDir];
        mkdir(full_ignoredDir);
        for j = 1:length(idx)
            pos = idx(j);
            in_img =  [root_projectsPath '/' hdr_name '/' vig_imgList(pos).name];
            movefile(in_img, full_ignoredDir);
            if( mod (j, 3000) == 0)
                fprintf('-- -- -- moving %d of %d\n', j, length(idx));
            end
        end
    end
    
    %% reporting ignored images into the subfolder
    fid = fopen([outDir '/'  ignoredDir '_' ilha_name '.txt'], 'w');
    for j = 1:length(idx)
        pos = idx(j);
        fprintf(fid, '%s\n',  vig_imgList(pos).name );
    end
    
    fprintf('\n');
end

