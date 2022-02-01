%% Filtrage fichiers BRU
% Leandro Ticlio

function s7_filter_bru_files(project_name,xlsfile,shape_xx,shape_yy)

cd(project_name)

inputMat = 'filtering/m1';

% folders for bru saving
%     outdir = 'filtered_bru';
outdir = [project_name,'\results\']; 
metadir = [project_name,'\meta\'];  
[NN, TT] = xlsread([metadir xlsfile]);

xls_profName = TT(2:end, 4);
xls_th_pixelSize = NN(:, 20);

nMat = length(xls_profName);
HH = 2048;
WW = 2048;

mkdir(outdir)

%% create mask with largest triangle
% shape_xx = [ 1 1 135 1];
% shape_yy  =[1425, 2048, 2048 1425];

mtx_mask = zeros(HH, WW);
for tt = 1:length(shape_xx)-1
    dx = shape_xx(tt) - shape_xx(tt+1);
    dy = shape_yy(tt) - shape_yy(tt+1);
    np = ceil( sqrt(dx*dx + dy*dy) ) +1;
    border_y = round(linspace(shape_yy(tt), shape_yy(tt+1), np));  % Row indices
    border_x = round(linspace(shape_xx(tt), shape_xx(tt+1), np));

    indexes = sub2ind([HH, WW],  border_y, border_x);
    mtx_mask(indexes) = 1;
end
mtx_mask = imfill(mtx_mask,'holes');
mtx_mask = 1 - mtx_mask;
% imagesc(mtx_mask)

%% process mat files
for i = 1:length(xls_profName)
        matpath = [inputMat '/' xls_profName{i} '.mat'];
        fprintf('[%d of %d] Processing file >> %s\n', i,nMat, xls_profName{i});
        load(matpath)
               
        idx_nan = find( isnan(vDatetime) == 1);
        idx_in_dat = find( isnan(vDatetime) == 0);

        util_datetime = vDatetime( idx_in_dat );
        uDt = unique(util_datetime);
        tt = datevec(uDt);
        tt(:, 6) = floor( tt(:, 6) );

        uDt_round = datenum(tt);

        numbers=unique(uDt_round);       %list of elements
        count=hist(uDt_round, numbers);   %provides a count of each element's occurrence

        vFps{i} = count';
        vTime{i} = numbers;
        vName{i} = strrep(xls_profName{i}, '_', '.');

        vNan_roi(i) = length( idx_nan );
        vTot_roi(i) = length(vDatetime);

        vframes_nan(i) = length( unique( vId_img(idx_nan) ));
        vFrames_ok(i) = length( unique( vId_img(idx_in_dat) ));
        vFrames_tot(i) =  length( unique( vId_img) );

        %% all rois
        mtx = zeros(HH, WW);
        xx = 1 + round(vXX_center);
        yy = 1 + round(vYY_center);

        indexes = sub2ind([HH, WW],  yy, xx);

        uIdx = unique(indexes);       %list of elements
        count=hist(indexes, uIdx);
        mtx(uIdx) = count;    
        vMat_all = mtx;    

        %% in dat
        mtx = zeros(HH, WW);
        xx = 1 + round(vXX_center(idx_in_dat));
        yy = 1 + round(vYY_center(idx_in_dat));

        indexes = sub2ind([HH, WW],  yy, xx);

        uIdx = unique(indexes);       %list of elements
        count=hist(indexes, uIdx);
        mtx(uIdx) = count;    
        vMat_inDat = mtx;    

        %% in dat and filter by size
        vId_img_dat = vId_img(idx_in_dat);
        vId_roi_dat = vId_roi(idx_in_dat);
        vArea_dat = vArea_pxl(  idx_in_dat );   
        
        vgray_dat = vGray_level(idx_in_dat);
        xx_dat = 1 + round(vXX_center(idx_in_dat));
        yy_dat = 1 + round(vYY_center(idx_in_dat));
        
        % area
        idx_ok = find( vArea_dat > xls_th_pixelSize(i) );

        vId_img_indatSize = vId_img_dat(idx_ok);
        vId_roi_indatSize = vId_roi_dat(idx_ok);
        area_indatSize = vArea_dat(idx_ok);
        
        vgray_indatSize = vgray_dat(idx_ok);
        xx_indatSize = xx_dat(idx_ok);
        yy_indatSize = yy_dat(idx_ok);
        

        indexes = sub2ind([HH, WW],  yy_indatSize, xx_indatSize);

        mtx = zeros(HH, WW);
        uIdx = unique(indexes);       %counting particles
        count=hist(indexes, uIdx);
        mtx(uIdx) = count;    
        vMat_inDatSize = mtx;    
        
        %filter by mask
        Mout = [];
        idx_noTriangle = find( mtx_mask(indexes) == 1);
        Mout(:, 1) = vId_img_indatSize(idx_noTriangle);
        Mout(:, 2) = vId_roi_indatSize(idx_noTriangle);
        Mout(:, 3) = area_indatSize(idx_noTriangle);
        Mout(:, 4) = vgray_indatSize(idx_noTriangle);
        Mout(:, 5) = xx_indatSize(idx_noTriangle) - 1 ;
        Mout(:, 6) = yy_indatSize(idx_noTriangle) -1 ;
        
        dlmwrite([ outdir '/'  xls_profName{i} '.bru' ], Mout, 'delimiter',';')

        
%         %% num rois
%          nRoi_all = round( sum(vMat_all(:)) / 1000000, 2);
%          nRoi_dat = round( sum(vMat_inDat(:)) / 1000000, 2); 
%          
%         nRoisPoly = sum(sum((1-mtx_mask).*mtx));
%         nRois_mask = round(nRoisPoly/1000);
%         nRoisPer = round(100*nRoisPoly/sum(mtx(:)));        
%         nRoi_datSize = round( sum(mtx(:)) / 1000, 2);
%        %% plot 
%         fig = figure(1);
%         set(gcf,'Position',[0 0 1600 680])
%         subplot(1,2,1)
%             mtx = vMat_inDatSize;
%             mtx_log = mtx_to_mapviewer(mtx); 
%             imagesc(mtx_log);        hold on
%             plot(shape_xx , shape_yy, 'r', 'linewidth', 2)
%             colormap jet;            colorbar
%                                                 
%             title(['[#Rois] All: ' num2str(nRoi_all) 'M | Dat: ' num2str(nRoi_dat) 'M | Area:' num2str(nRoi_datSize) 'K | Polygon:' num2str(nRois_mask) 'K' ], 'Fontsize', 9)
%             xlabel( vName{i} )
%             xlabel([' #Rois in Dat with Area >'  num2str(xls_th_pixelSize(i)) ])
%             set(gca, 'yticklabel', {}, 'xticklabel', {})
%             
%         subplot(1,2,2)
%             mtx = vMat_inDatSize.*mtx_mask;
%             mtx_log = mtx_to_mapviewer(mtx); 
%             imagesc(mtx_log);        hold on
%             colormap jet;            colorbar
%             
%             nRois = sum(sum(mtx));
%             nRois_k =  round(nRois/1000);
%             title(['[#Rois] After filtering: ' num2str(nRois_k) 'K' ], 'Fontsize', 9)
%             xlabel( vName{i} )
%             xlabel([' #Rois in Dat with Area >'  num2str(xls_th_pixelSize(i)) ])
%             set(gca, 'yticklabel', {}, 'xticklabel', {})
%             
%     pause(0.2)
%     print(fig, [ outdir '/'  vName{i} '.png' ], '-dpng', '-r100')
%     close all
    
    
end