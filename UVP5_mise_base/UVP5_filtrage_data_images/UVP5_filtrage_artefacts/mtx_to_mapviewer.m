function mtxviewer = mtx_to_mapviewer(mtx)
        mtx_log = round(log2(mtx + 1));
        mtx_log = uint8(mtx_log);            
        mtxviewer = imclose(mtx_log, strel('square', 3));        
end