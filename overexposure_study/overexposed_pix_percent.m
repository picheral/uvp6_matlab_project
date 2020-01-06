%---------------------------2019/11/07-----------------------------
%---------------------------- Camille Catalano --------------------
% overexposition study
% for a given size of particle, compute the percent of overexposed pixels
% for different number of analysed lines
%%
close all;
clear all;
profile on
% detector parameters
nb_lines_detect = 2056;
nb_columns_detect = 2464;
pix_size_in_fov_cm = 0.0073;
% size of the particle
part_diameter_cm = 2.5;
% study paramters
step_analysed_lines = 1;
nb_analysed_lines_max = 20;
% study
percents_list = [];
for nb_analysed_lines = 1:step_analysed_lines:nb_analysed_lines_max
    percent = overexposed_percent(nb_analysed_lines, part_diameter_cm, nb_lines_detect, nb_columns_detect, pix_size_in_fov_cm);
    percents_list = [percents_list, percent];
end
% check the computing
computing_max_percent = overexposed_percent(nb_lines_detect, part_diameter_cm, nb_lines_detect, nb_columns_detect, pix_size_in_fov_cm)
theoretical_percent = pi*(part_diameter_cm/2)^2 / (nb_lines_detect*nb_columns_detect*pix_size_in_fov_cm^2) * 100
% plot the results
x = (1:step_analysed_lines:nb_analysed_lines_max)';
plot(x, percents_list)
hold on
plot([0,20],[theoretical_percent, theoretical_percent])
hold off
title("overexposition for a " + part_diameter_cm + "cm object")
xlabel("nb of analyzed lines")
ylabel("percent of overexposed pixels")
dim = [.2 .5 .3 .3];
annotation('textbox', dim, 'string', "theoretical percent = " + theoretical_percent, 'FitBoxToText', 'on')
%profile viewer
%%
function percent = overexposed_percent(nb_analysed_lines, part_diameter_cm, nb_lines_detect, nb_columns_detect, pix_size_in_fov_cm)
    %compute the percent of pixels of the particle within the nb_analysed_lines
    %   the particle is a circle of part_diameter_cm size
    %   there are nb_analysed_lines equally spread across the detector
    interval_pix_size = ceil((nb_lines_detect-nb_analysed_lines) / (nb_analysed_lines + 1)); % compute the size of intervals between lines
    part_diameter_pix = ceil(part_diameter_cm / pix_size_in_fov_cm); % particle diameter in pixel rounded up
    
    i_lines = get_lines_indices(part_diameter_pix, interval_pix_size); %indices of analysed lines
    [iline_part, icol_part] = get_particles_indices(part_diameter_pix); %indices of pixels inside the particle
    nb_overexposed_pix = sum(ismember(iline_part,i_lines)); %number of pix of analysed lines inside the particle
    percent = nb_overexposed_pix / (nb_analysed_lines * nb_columns_detect) *100;
end
%%
function [iline_part, icol_part] = get_particles_indices(part_diameter_pix)
    %return indices of pixels inside the particle
    %
    radius = part_diameter_pix / 2;
    iline_part = [];
    icol_part = [];
    for iline = 1:part_diameter_pix
        for icol = 1:part_diameter_pix
            if sqrt((iline-radius)^2+(icol-radius)^2) <= radius
                iline_part = [iline_part, iline];
                icol_part = [icol_part, icol];
            end
        end
    end
end