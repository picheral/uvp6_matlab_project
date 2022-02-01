% script building a set of uvp6 images from a set of vignettes
% The vignettes are in a folder (test_folder) but can be in subfolders.
% There are 4 objects in each created images taken randomly.
% A folder is created for each images with the utilized vignettes (in there
% subfolders if any).
%
% WARNING : there is no test. A big vignette can be a problem.
% 
%
% catalano 2021


vignettes_folder = 'img_sample'; % input vignettes folder or pathfolder
images_folder = 'test_images'; % output images folder or pathfolder
images_numbers = 10; % nb of images to create
objects_perimage = 4; % nb of image per image (4 max)
% coordinates of objets in image
obj_coord = [[200,200];[1500,200];[200,1500];[1500,1500]];

filelist = dir(fullfile(vignettes_folder, '**', '*.png'));
for image_nb = 1:images_numbers
    img = zeros(2464,2056, 'uint8');
    image_folder = fullfile(images_folder, ['image_', num2str(image_nb)]);
    mkdir(image_folder);
    Index    = randperm(numel(filelist), objects_perimage);
    for object_nb = 1:objects_perimage
        path = strsplit(filelist(Index(object_nb)).folder, filesep);
        taxo_folder = fullfile(image_folder, path{end});
        mkdir(taxo_folder);
        dest = fullfile(taxo_folder, filelist(Index(object_nb)).name);
        source = fullfile(filelist(Index(object_nb)).folder, filelist(Index(object_nb)).name);
        copyfile(source, dest);
        vig = imread(dest);
        [x_len, y_len] = size(vig);
        x=obj_coord(object_nb,1);
        y=obj_coord(object_nb,2);
        img(x:x+x_len-1, y:y+y_len-1) = vig;
    end
    imwrite(img, fullfile(image_folder, ['image_', num2str(image_nb), '.png']));
end
