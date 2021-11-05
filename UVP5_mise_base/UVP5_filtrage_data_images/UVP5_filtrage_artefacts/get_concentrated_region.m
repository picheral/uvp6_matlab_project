function [mtx_mask, vertex_xy, points_xy] = get_concentrated_region(mtx)             
    [HH, WW] = size(mtx);
    mtx_log = round(log2(mtx + 1));
    mtx_log = uint8(mtx_log);
    mtx_log = imclose(mtx_log, strel('square', 3));    
    
    th = 0.3*max( mtx_log(:) );
    imbin = mtx_log >= th;
    imbin = imdilate(imbin, strel('square', 5));
    imbin = imerode(imbin, strel('square', 3));
    imbin = bwareaopen(imbin, 10000, 4);
    imbin = imfill(imbin, 'holes');
    boundaries = bwboundaries(imbin);

    vertex_xy = [];
    points_xy = [];
    mtx_mask = zeros(HH, WW);
    for k = 1:length(boundaries)
            pt = boundaries{k};
            idx = convhull(pt , 'Simplify',true);                
            xx = pt(idx,2);
            yy = pt(idx,1);
            vertex_xy(k).xx = xx';
            vertex_xy(k).yy = yy';
%                 plot(xx, yy, 'r', 'linewidth', 2)
%                 title([' threshold:2^' num2str( th) ' | #Rois:' num2str(nRoisK) 'K | ~' num2str(nRoisPer) '%']) 
%                 
            for tt = 1:length(xx)-1
                dx = xx(tt) - xx(tt+1);
                dy = yy(tt) - yy(tt+1);
                np = ceil( sqrt(dx*dx + dy*dy) ) +1;
                border_y = round(linspace(yy(tt), yy(tt+1), np));  % Row indices
                border_x = round(linspace(xx(tt), xx(tt+1), np));
                
                points_xy(k).border_x{tt} = border_x;
                points_xy(k).border_y{tt} = border_y;
                
                indexes = sub2ind([HH, WW],  border_y, border_x);
                mtx_mask(indexes) = 1;
%                     plot(border_x, border_y, 'k', 'linewidth', 1)
            end
        end

            mtx_mask = imfill(mtx_mask, 'holes');
%             nRois = sum(sum(mtx_mask.*mtx));
%             nRoisK = round(nRois/1000000, 2);
%             nRoi_tot = round( sum(mtx(:)) / 1000000, 2); 
%             nRoisPer = round(100*nRois/sum(mtx(:)));
            
end