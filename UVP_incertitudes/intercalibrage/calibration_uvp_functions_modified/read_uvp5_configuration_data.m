function [a e v p light1 light2 g t exp shutter smbase] = read_uvp5_configuration_data( filename ,type)
% Lecture des données de calibrage UVP
% Picheral 2017/10/31

pix_data_ref = '9999';
aa_data_ref = '9999';
expo_data_ref = '9999';
img_vol_data_ref = '9999';
Gain = '9999';
Thresh = '9999';
Exposure = '9999';
ShutterSpeed = '9999';
SMbase = '9999';
light1 = '9999';
light2 = '9999';


fid = fopen(filename);
while 1                     % loop on the number of lines of the file
    tline = fgetl(fid);
    %                                 disp(tline)
    if ~ischar(tline), break, end
    if strcmp(type,'data')
        % ------------- Data --------------------------------------------------
        if strncmp(tline,'pixel',5); [x pix_data_ref] = strtok(tline,' '); end
        if strncmp(tline,'aa_calib',5); [x aa_data_ref] = strtok(tline,' '); end
        if strncmp(tline,'exp_calib',5); [x expo_data_ref] = strtok(tline,' '); end
        if strncmp(tline,'img_vol',5); [x img_vol_data_ref] = strtok(tline,' '); end
        if strncmp(tline,'light1',6); [x light1] = strtok(tline,' '); end
        if strncmp(tline,'light2',6); [x light2] = strtok(tline,' '); end
    else
        % ------------- HDR ---------------------------------------------------
        if strncmp(tline,'Gain',4); [x tline] = strtok(tline,'='); [x Gain] = strtok(tline,' '); end
        if strncmp(tline,'Thresh',5); [x tline] = strtok(tline,'='); [x Thresh] = strtok(tline,' ');end
        if strncmp(tline,'SMbase',5); [x tline] = strtok(tline,'='); [x SMbase] = strtok(tline,' ');end
        % ------------- HD ----------------------------------------------------
        if strncmp(tline,'Exposure',5); [x tline] = strtok(tline,'='); [x Exposure] = strtok(tline,' '); end
        % ------------- STD ---------------------------------------------------
        if strncmp(tline,'ShutterSpeed',5); [x tline] = strtok(tline,'='); [x ShutterSpeed] = strtok(tline,' '); end
    end
    
end
fclose(fid);

p = str2num(pix_data_ref);
a = str2num(aa_data_ref);
e = str2num(expo_data_ref);
v = str2num(img_vol_data_ref);
g = str2num(Gain);
t = str2num(Thresh);
exp = str2num(Exposure);
shutter = str2num(ShutterSpeed);
smbase = str2num(SMbase);
end