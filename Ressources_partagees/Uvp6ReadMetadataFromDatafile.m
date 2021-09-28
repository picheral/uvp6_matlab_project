%% Lecture entête DATA.txt
% Picheral 2021/09/27

function [sn,day,cruise,base_name,pvmtype,soft,light,shutter,threshold,volume,gain,pixel,Aa,Exp] = Uvp6ReadMetadataFromDatafile(folder,path);


fid = fopen(path);

% ----------------- Ligne HW -----------------
tline = fgetl(fid);
%tline is the first line of the text folder in which the parameters of the sequence are stored : shutter, threshold, gain, .....
hw_line = strsplit(tline,{','});

%----- Vérification longueur ligne ----------
if size(hw_line,2) == 45 || size(hw_line,2) == 44
    X = 0;
else
    X = -1;
end

% ---- get all the metadata from the hardware line of the text file --
% ---- premiere sequence ---------

    sn = hw_line{2};
    day = hw_line{25+X};
    cruise = folder(4:end);
    base_name = ['base',folder(4:end)];
    pvmtype = ['uvp6_sn' sn];
    soft = 'uvp6';
    light =  hw_line{6};

shutter = str2double(hw_line{17+X});
threshold = str2double(hw_line{19+X});
volume = str2double(hw_line{23+X});
gain = str2double(hw_line{18+X});
pixel = str2double(hw_line{22+X})/1000;
Aa = str2double(hw_line{20});
Exp = str2double(hw_line{21});