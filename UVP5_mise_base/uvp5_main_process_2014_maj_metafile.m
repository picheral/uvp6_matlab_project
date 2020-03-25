%% Update metadata UVP5 from NMEA of CTD files
% Picheral 2015/11/16


function uvp5_main_process_2014_maj_metafile(base,meta_dir,meta_file)

fid=fopen([meta_dir,meta_file],'w');

fprintf(fid,'%s\n','cruise;ship;filename;profileid;bottomdepth;ctdrosettefilename;latitude;longitude;firstimage;volimage;aa;exp;dn;winddir;windspeed;seastate;nebuloussness;comment;endimg;yoyo;stationid');
for i=1:size(base,2);
    % ----- Correction LAT / LON -------------
    latitude = base(i).latitude;
    longitude = base(i).longitude;
%     disp(num2str(i))
    
    sign = 1;
    if latitude <1; sign = -1;end
    oo = abs(latitude);
    oo_int = floor(oo);
    latitude = sign * (oo_int + 60 * (oo - oo_int) / 100);
    
    sign = 1;
    if longitude <1; sign = -1;end
    oo = abs(longitude);
    oo_int = floor(oo);
    longitude = sign * (oo_int + 60 * (oo - oo_int) / 100);
    
    fprintf(fid,'%s',[char(base(i).cruise),';']);
    fprintf(fid,'%s',[char(base(i).ship),';']);
    fprintf(fid,'%s',[char(base(i).bru0),';']);
    fprintf(fid,'%s',[char(base(i).profilename),';']);
    fprintf(fid,'%s',[num2str(base(i).depth),';']);
    fprintf(fid,'%s',[char(base(i).ctdrosette),';']);
    fprintf(fid,'%s',[num2str(latitude),';']);
    fprintf(fid,'%s',[num2str(longitude),';']);
    fprintf(fid,'%s',[num2str(base(i).firstimage),';']);
    fprintf(fid,'%s',[num2str(base(i).volimg0),';']);
    fprintf(fid,'%s',[num2str(base(i).a0),';']);
    fprintf(fid,'%s',[num2str(base(i).exp0),';']);
    fprintf(fid,'%s',[char(base(i).dn),';']);
    fprintf(fid,'%s',[num2str(base(i).winddir),';']);
    fprintf(fid,'%s',[num2str(base(i).windspeed),';']);
    fprintf(fid,'%s',[num2str(base(i).seastate),';']);
    fprintf(fid,'%s',[num2str(base(i).nebuloussness),';']);
    fprintf(fid,'%s',[char(base(i).comment),';']);
    fprintf(fid,'%s',[num2str(base(i).lastimage),';']);
    fprintf(fid,'%s',[char(base(i).yoyo),';']);
    fprintf(fid,'%s',[char(base(i).stationname)]);
    fprintf(fid,'%s\n','');
end
fclose(fid);


