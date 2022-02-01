
%% code leandro.ticlia
% Detection zone to remove

function s5_heatmap_rois_indat_size_nfilter_bounder(project_name,type)
cd(project_name);

% clear; 
% close all; clc

inputMat = 'filtering/m1';
mat_list = dir([inputMat '/*.mat']);
nMat = length(mat_list);

HH = 2048;
WW = 2048;


vNan_roi = [];
vTot_roi = [];

vMat_all = {};
vMat_inDat = {};
vMat_inDatSize = {};

vTh_area = [1:5:50];
outdir = 'filtering/map_filter';
mkdir(outdir)

fprintf('----------------------------------------------------------- \n');
fprintf('Zone detection .... \n');
fprintf('----------------------------------------------------------- \n');

for i = 1:nMat
    nm = mat_list(i).name;
    infile = [inputMat '/' nm];
    fprintf('[%d of %d] Processing file >> %s\n', i,nMat, nm);
    load(infile)    

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
    vName{i} = strrep(nm(1:end-4), '_', '.');
    
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
    xx_dat = 1 + round(vXX_center(idx_in_dat));
    yy_dat = 1 + round(vYY_center(idx_in_dat));
    vArea_dat = vArea_pxl(  idx_in_dat );   
    
    for k = 1:length(vTh_area)
        idx_ok = find( vArea_dat > vTh_area(k) );

        xx_indatSize = xx_dat(idx_ok);
        yy_indatSize = yy_dat(idx_ok);
        area_indatSize = vArea_dat(idx_ok);

        indexes = sub2ind([HH, WW],  yy_indatSize, xx_indatSize);

        mtx = zeros(HH, WW);
        uIdx = unique(indexes);       %list of elements
        count=hist(indexes, uIdx);
        mtx(uIdx) = count;    
        vMat_inDatSize{k} = mtx;    
    end
    
    strRois = [];
    strPoly = [];
    fig = figure(1);
    set(gcf,'Position',[0 0 1920 960])
    
    subplot(3, 5, 1)
        mtx_log = mtx_to_mapviewer(vMat_all);        
        imagesc(mtx_log);        hold on
        colormap jet;   colorbar

        nRoi_tot = round( sum(vMat_all(:)) / 1000000, 2); 
        title([ '#Frame: ' num2str( vFrames_ok(i)) '/'  num2str( vFrames_tot(i))  ' | #Rois: ' num2str(nRoi_tot) 'Mi' ], 'Fontsize', 9)

        ylabel( vName{i} )
        xlabel('M1 = All Rois in BRU file')
        set(gca, 'yticklabel', {}, 'xticklabel', {})
        
        strRois(1).inFrame = sum(vMat_all(:));
        strRois(1).inPolygon = 0;
        strRois(1).text = 'M1=BRU';
        strRois(2).polyVertex =  [];
        
    subplot(3, 5, 2) 
        mtx_log = mtx_to_mapviewer(vMat_inDat);     
        imagesc(mtx_log); hold on
        
        [mtx_mask, vertex_xy, points_xy] = get_concentrated_region(vMat_inDat);        
        colormap jet;           colorbar;
         for rr = 1:length(points_xy)
             for ss = 1:length(points_xy(rr).border_x)
                    plot(points_xy(rr).border_x{ss}, points_xy(rr).border_y{ss}, 'm', 'linewidth', 2)
             end
         end
        nRoisPoly = sum(sum(mtx_mask.*vMat_inDat));
        nRoisK = round(nRoisPoly/1000);
        nRoi_tot = round( sum(vMat_inDat(:)) / 1000000, 2); 
        title([ '#Frame: ' num2str( vFrames_ok(i)) ' | #Rois: ' num2str(nRoisK) 'K/' num2str(nRoi_tot) 'Mi' ], 'Fontsize', 9)

        ylabel( vName{i} )
        xlabel('M2 = Rois linked to DAT file')
        set(gca, 'yticklabel', {}, 'xticklabel', {})
        
        strRois(2).inFrame = sum(vMat_inDat(:)) ;
        strRois(2).inPolygon = nRoisPoly;
        strRois(2).text = 'M2=In.Datfile';
        strRois(2).polyVertex =  vertex_xy;
        
    for j = 1:length(vTh_area)
        subplot(3,5, 2+j)
            mtx = vMat_inDatSize{j};
            mtx_log = mtx_to_mapviewer(mtx); 
            imagesc(mtx_log);        hold on
            colormap jet;            colorbar

        [mtx_mask, vertex_xy, points_xy] = get_concentrated_region(vMat_inDatSize{j});        
        colormap jet;           colorbar;
         for rr = 1:length(points_xy)
             for ss = 1:length(points_xy(rr).border_x)
                    plot(points_xy(rr).border_x{ss}, points_xy(rr).border_y{ss}, 'm', 'linewidth', 2)
             end
         end
        nRoisPoly = sum(sum(mtx_mask.*mtx));
        nRoisK = round(nRoisPoly/1000);
        nRoisPer = round(100*nRoisPoly/sum(mtx(:)));        
        nRoi_tot = round( sum(mtx(:)) / 1000, 2);
        
        title(['#Rois: ' num2str(nRoisK) 'K/' num2str(nRoi_tot) 'K | ~' num2str(nRoisPer) '%' ], 'Fontsize', 9)
        xlabel( vName{i} )
        xlabel(['M2 && A>' num2str(vTh_area(j)) ])
        set(gca, 'yticklabel', {}, 'xticklabel', {})

        strRois(2+j).inFrame = sum(mtx(:)) ;
        strRois(2+j).inPolygon = nRoisPoly;
        strRois(2+j).text = ['In.M2 & Area>' num2str( vTh_area(j))];
        strRois(2+j).polyVertex =  vertex_xy;
    end
    
    pause(0.2)
    print(fig, [ outdir '/'  vName{i} '_' type '.png' ], '-dpng', '-r100')
    savefig(fig, [ outdir '/'  vName{i} '_' type '.fig' ])
    
    close all
    
    fid = fopen( [ outdir '/table_area_'  vName{i} '.txt' ], 'w' );
    fprintf( fid, '#Rois in Frame; #Rois in Polygon; Description\n');
    for j = 1:length(strRois)      
      fprintf( fid, '%f;%f;%s\n', strRois(j).inFrame, strRois(j).inPolygon, strRois(j).text);
    end
    fclose(fid);
    
    fid = fopen( [ outdir '/coordinates_'  vName{i} '.txt' ], 'w' );    
    for j = 1:length(strRois)      
      fprintf( fid, 'Figure:%s\n', strRois(j).text);
      for kk = 1:length(strRois(j).polyVertex)
            fprintf( fid, 'Polygon %f >> x >> %s \n', kk, num2str(strRois(j).polyVertex(kk).xx));
            fprintf( fid, 'Polygon %f >> y >> %s \n', kk, num2str(strRois(j).polyVertex(kk).yy));
            fprintf( fid, '\n');
      end
      fprintf( fid, '\n');
    end
    fclose(fid);
    
    
    
end





