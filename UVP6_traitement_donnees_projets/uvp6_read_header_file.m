%% Lecture des metadata et HDR
% Picheral, 2023/06/29


function [header] = uvp6_read_header_file(meta_dir,header_file)


disp([meta_dir,header_file]);


if exist([meta_dir,header_file])==2
    fid=fopen([meta_dir,header_file]);
    header = [];
    compteur = 0;
    disp('-------------------------- METADATA ----------------------------------');
    %  Open one file
    while 1                     % loop on the number of lines of the file
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        % Suppression ligne d'entete
        if compteur > 0
            disp(tline);
            dotcom=findstr(tline,';');  % find the dotcoma index
            header(compteur).cruise = tline(1:dotcom(1)-1);
            header(compteur).ship = tline(dotcom(1)+1:dotcom(2)-1);
            header(compteur).filename = tline(dotcom(2)+1:dotcom(3)-1);
            header(compteur).sampleid = tline(dotcom(3)+1:dotcom(4)-1);
            header(compteur).bottomdepth = tline(dotcom(4)+1:dotcom(5)-1);
            header(compteur).ctdrosettefilename = tline(dotcom(5)+1:dotcom(6)-1);
            header(compteur).latitude = tline(dotcom(6)+1:dotcom(7)-1);
            header(compteur).longitude = tline(dotcom(7)+1:dotcom(8)-1);
            header(compteur).firstimage = tline(dotcom(8)+1:dotcom(9)-1);
            header(compteur).volimage = tline(dotcom(9)+1:dotcom(10)-1);
            header(compteur).aa = tline(dotcom(10)+1:dotcom(11)-1);
            header(compteur).exp = tline(dotcom(11)+1:dotcom(12)-1);
            header(compteur).comment = tline(dotcom(17)+1:dotcom(18)-1);
            header(compteur).lastimage = tline(dotcom(18)+1:dotcom(19)-1);
            header(compteur).sampletype = tline(dotcom(21)+1:dotcom(22)-1);

            header(compteur).pvmtype =               {'uvp6'};

            % Date Time
            date = str2num(header(compteur).filename(1:8));
            time = str2num(header(compteur).filename(9:end));
            an=floor(date/10000);
            mois=floor((floor(date)-10000*floor(date/10000))/100);
            jour=floor(date)-an*10000-mois*100;
            heure=floor(time/10000);
            minute=floor((floor(time)-10000*floor(time/10000))/100);
            seconde=floor(time)-heure*10000-minute*100;
            header(compteur).datem=              datenum(an,mois,jour,heure,minute,seconde);

            % LAT / LON
            latitude  = replace(header(compteur).latitude,'°',' ');
            latitude_array = split(latitude,' ');
            latitude_deg = str2num(char(latitude_array(1)));
            latitude_min = str2num(char(latitude_array(2)));
            latitude_sec = str2num(char(latitude_array(3)));
            latitude_min = latitude_min + latitude_sec/60;
            header(compteur).latitude = abs(latitude_deg) + latitude_min/60;

            longitude  = replace(header(compteur).longitude,'°',' ');
            longitude_array = split(longitude,' ');
            longitude_deg = str2num(char(longitude_array(1)));
            longitude_min = str2num(char(longitude_array(2)));
            longitude_sec = str2num(char(longitude_array(3)));
            longitude_min = longitude_min + longitude_sec/60;
            header(compteur).longitude = abs(longitude_deg) + longitude_min/60;

        end
        compteur  = compteur+1;
    end
    fclose(fid);

else
    disp('NO METADATA file or name incorrect.');
end
