function [sn,day,cruise,base_name,pvmtype,soft,light,shutter,threshold,volume,gain,pixel,Aa,Exp] = Uvp6ReadMetadataFromDatafile(folder,path)
% Lecture des metadata à partir du fichier data
% Picheral, 2020/04/17


[hw_line, empty_line, acq_line] = Uvp6ReadMetalinesFromDatafile(path);

% ----------------- Ligne HW -----------------
%hw_line is the first line of the text folder in which the parameters of the sequence are stored : shutter, threshold, gain, .....
hw_line = strsplit(hw_line,{','});

%----- Vérification longueur ligne ----------
if size(hw_line,2) == 45 || size(hw_line,2) == 44
    X = 0;
else
    X = -1;
end

% ---- get all the metadata from the hardware line of the text file --
% ---- premiere sequence ---------
[sn,day,light,shutter,threshold,volume,gain,pixel,Aa,Exp] = Uvp6ReadMetadataFromhwline(hw_line);
cruise = folder(4:end);
base_name = ['base',folder(4:end)];
pvmtype = ['uvp6_sn' sn];
soft = 'uvp6';

% ------------ LIgne ACQ ----------------------------------
acq_line = strsplit(acq_line,{','});
black_ratio = str2double(acq_line{15+X});


end

