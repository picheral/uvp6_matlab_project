function [sn,day,light,shutter,threshold,volume,gain,pixel,Aa,Exp] = Uvp6ReadMetadataFromhwline(splited_hwline)
% read metadata from a hwline of a uvp6 data file
% Picheral, 2020/04/17
%
% hwline entries must be splited before
% fid = fopen(path);
% tline = fgetl(fid);
% splited_hwline = strsplit(tline,{','});
%
%   input:
%       splited_hwline : splited hw line from the uvp6 dat file
%
%   outputs:
%       sn,day,light,shutter,threshold,volume,gain,pixel,Aa,Exp
%


%% ----- Check line length ----------
if size(splited_hwline,2) == 45 || size(splited_hwline,2) == 44
    X = 0;
else
    X = -1;
end

%% ---- get all the metadata from the hardware line of the text file --
sn = splited_hwline{2};
day = splited_hwline{25+X};
light =  splited_hwline{6};
shutter = str2double(splited_hwline{17+X});
threshold = str2double(splited_hwline{19+X});
volume = str2double(splited_hwline{23+X});
gain = str2double(splited_hwline{18+X});
pixel = str2double(splited_hwline{22+X})/1000;
Aa = str2double(splited_hwline{20});
Exp = str2double(splited_hwline{21});


end

