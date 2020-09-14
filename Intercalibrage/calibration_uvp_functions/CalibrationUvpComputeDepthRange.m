function [histopx_1,histopx_2, depth] = CalibrationUvpComputeDepthRange(histopx_1,histopx_2)
%CalibrationUvpComputeDepthRange cut the two histopx in order to met the
%same depth range
%
%   inputs:
%       histopx_1 : first histopx
%       histopx_2 : second histopx
%
%   outputs:
%       histopx_1 : cuted first histopx
%       histopx_2 : cuted second histopx
%       depth : used depth vector
%

% ------------------- Depth min ------------------
% find the deepest first depth between the two base, in order to compare
% profiles in the same range of depth
firstdepth_1 = nanmin(histopx_1(:,1));
firstdepth_2 = nanmin(histopx_2(:,1));
if max(firstdepth_1, firstdepth_2) == firstdepth_1
    first_depth = firstdepth_1;
else
    first_depth = firstdepth_2;
end

% take only useful profile
aa = find(histopx_1(:,1) >= first_depth);
histopx_1 = histopx_1(aa,:);
aa = find(histopx_2(:,1) >= first_depth);
histopx_2 = histopx_2(aa,:);

% ------------------- Depth max ------------------
[i,j]=size(histopx_1);
[k,l]=size(histopx_2);
maxdepth_indice=min(i,k);
histopx_1=histopx_1(1:maxdepth_indice,:);
histopx_2=histopx_2(1:maxdepth_indice,:);

% ------------------- Missing values -------------
aaa = ~isnan(histopx_1(:,5));
histopx_1 = histopx_1(aaa,:);
histopx_2 = histopx_2(aaa,:);
aaa = ~isnan(histopx_2(:,5));
histopx_1 = histopx_1(aaa,:);
histopx_2 = histopx_2(aaa,:);

%depth vector
depth = histopx_1(:,1);
end
