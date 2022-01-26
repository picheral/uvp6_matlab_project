function  [Shutter, Black_level, Gain, Transferfunc, lightcorrection, Temperature] = Uvp6ReadMetaFromLivecamera(txt_file)
% Reads the acquisition parameters in Livecamera folder
%  Input :
%       Filename
%  Output :
%       Parametres

filen = fopen(txt_file,'r');

while 1                     % loop on the number of lines of the file
    tline = fgetl(filen);
    if ~ischar(tline), break, end    
    aa = split(tline,'=');
    if contains(aa(1),'Shutter')
        Shutter = str2num(char(aa(2)));
    elseif contains(aa(1),'Black_level')
        Black_level = str2num(char(aa(2)));
    elseif contains(aa(1),'Gain')
        Gain = str2num(char(aa(2)));
    elseif contains(aa(1),'transferfunc')
        Transferfunc = str2num(char(aa(2)));
    elseif contains(aa(1),'lightcorrection')
        lightcorrection = str2num(char(aa(2)));
    elseif contains(aa(1),'Temperature')
        Temperature = str2num(char(aa(2)));
    end
end
fclose(filen);
end

