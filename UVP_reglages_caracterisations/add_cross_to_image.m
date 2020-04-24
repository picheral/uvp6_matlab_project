%% Add a white cross centered in the image
% Open a png image
% Add a 3pix whide white cross at the centered of the image
% Save in a new png file to crossed_[...].png
% camille catalano 01/2020

clear all
close all

disp('------------------------------------------------------')
disp('-------------- image cross marker --------------------')
disp('------------------------------------------------------')

%% input image file
disp("Selection of the image file")
[image_filename, image_folder] = uigetfile('*.png','Select the image file to cross');
disp("Selected image file : " + image_filename)
image = imread([image_folder, image_filename]);
disp('------------------------------------------------------')

%% add a white cross on image
cross_width = 5; %in pix for odd number
first_middle = fix(size(image,1)/2);
second_middle = fix(size(image,2)/2);
image(first_middle-fix(cross_width/2) : first_middle+fix(cross_width/2), : ) = 255;
image( : ,second_middle-fix(cross_width/2) : second_middle+fix(cross_width/2)) = 255;

%% save the new image
cross_image_file = [image_folder, 'crossed_', image_filename];
imwrite(image, cross_image_file);
disp("Crossed image : " + cross_image_file)
disp('------------------------------------------------------')