%% Somme abondances par classes
% Picheral 2018/05/29

function [ab_vect_final]= sum_ab_classe(esd_x,esd_vect,ab_vect_source)

ab_vect_final = [];
for i=1:numel(esd_vect)-1
    aa = find(esd_x >= esd_vect(i) & esd_x < esd_vect(i+1));
    ab_vect_final(i) = sum(ab_vect_source(aa));
end