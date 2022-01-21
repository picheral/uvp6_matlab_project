%% Somme abondances par classes
% Picheral 2018/05/29

function [ab_vect_final]= sum_ab_classe(esd_x,esd_vect,ab_vect_source)
%
%
%   inputs:
%       esd_x: num vect of calib, pix class size
%       esd_vect: num vect of class limit in µm
%       ab_vect_source: num vect of abundance per pix class
%   output:
%       ab_vect_final : num vector of abundance per class

ab_vect_final = [];
for i=1:numel(esd_vect)-1
    aa = find(esd_x >= esd_vect(i) & esd_x < esd_vect(i+1));
    ab_vect_final(i) = sum(ab_vect_source(aa));
end

aa = find(esd_x >= esd_vect(i+1));
ab_vect_final(i+1) = sum(ab_vect_source(aa));

end