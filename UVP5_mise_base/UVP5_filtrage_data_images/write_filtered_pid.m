function [nb_vig] = write_filtered_pid(file_s,file_f)

%% -------------- Ecriture d'un DATFILE filtre des images retirées ------------------
% fichier source
fid_s = fopen(file_s);
% fichier filtre
fid_f = fopen(file_f,'w');
% boucle sur les lignes

while 1
    tline = fgetl(fid_s);
    if ~ischar(tline), break, end
    dotcom = findstr(tline,';');  % find the end of petit gros column
    image = str2num(tline(1:dotcom(1)-1));
    aa = find(im_filtered == image);
    % ecriture fichier filtre
    if isfinite(aa);                fprintf(fid_f,'%s\n',char(tline));            end
end
% fprintf(fid_f,'%s\n','');
fclose(fid_s);
fclose(fid_f);
end

