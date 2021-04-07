
function   [corr_matrix] =  get_correction_matrix(drive_root)

disp('--------- Reading correction matrix ------------');
img_corr = imread ([drive_root,'\background_image.tiff']);

dim = size(img_corr);
corr_matrix = ones(dim);
max_int = mean(mean(img_corr(dim(1)/2-75:dim(1)/2+75,dim(2)/2-75:dim(2)/2+75)));
if max_int == 255
   disp('Image might be saturated -- max intensity is esqual to 255')
end
for i = 6:dim(1)-5
    for j = 6:dim(2)-5
        if img_corr(i,j)>5
            corr_matrix(i,j) = max_int/mean(mean((img_corr(i-5:i+5,j-5:j+5))));
        end
    end
end

end
