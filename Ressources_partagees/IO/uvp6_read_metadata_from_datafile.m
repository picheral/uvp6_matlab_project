function [sn,day,cruise,base_name,pvmtype,soft,light,shutter,threshold,volume,gain,pixel,Aa,Exp] = uvp6_read_metadata_from_datafile(folder,path)
% Lecture des metadata à partir du fichier data
% Picheral, 2020/04/17


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
[sn,day,light,shutter,threshold,volume,gain,pixel,Aa,Exp] = Uvp6ReadMetadataFromhwline(hw_line);
cruise = folder(4:end);
base_name = ['base',folder(4:end)];
pvmtype = ['uvp6_sn' sn];
soft = 'uvp6';

% ------------ LIgne ACQ ----------------------------------
tline = fgetl(fid);
tline = fgetl(fid);
acq_line = strsplit(tline,{','});
black_ratio = str2double(acq_line{15+X});

% ------------- Fermeture fichier -------------------------
fclose(fid);

end

