%% ---------------- Fichiers ODV ---------------
% Particles + CTD normalisées
% Picheral, 2014/08

function  [base,ctddebut] = uvp5_process_odv_lpm_ctd(base,results_dir,base_new,include_ctd)

h=waitbar(0,'Processing UVP5 LPM CTD ODV file ...');%create and display a bar that show progess of the analysis

disp('-------------------- START ODV PROCESS ---------------------');
filename = [results_dir,base_new];
%% --------------- PARTICLE & CTD ----------------------------
%   fid=fopen(['D:\ARPVM\Databank\pvm\uvp5_odv_detailled_',filename(1:end-4),'.txt'],'w');
fid=fopen([filename,'_lpm_odv.txt'],'w');
%+++++++++++++++++++++++ ENTETE +++++++++++++++++++++++++++++++++++++++++++++++
fprintf(fid,'%s\n','//<Creator>marc.picheral@obs-vlfr.fr</Creator>');
s = datestr(now,31);
s(11) = 'T';
fprintf(fid,'%s\n',strcat('//<CreateTime>',s,'</CreateTime>'));
fprintf(fid,'%s\n',strcat('//<Source>',filename(1:end-4),'</Source>'));
liste=(dir(filename));
s = datestr(liste.date,31);
s(11) = 'T';
fprintf(fid,'%s\n',strcat('//<SourceLastModified>',s,'</SourceLastModified>'));
fprintf(fid,'%s\n','//<DataField>Ocean</DataField>');
fprintf(fid,'%s\n','//<DataType>Profiles</DataType>');
data1='Particle abundance and volume from the Underwater Vision Profiler. The Underwater Video Profiler is designed for the quantification of particles and of large zooplankton in the water column. Light reflected by undisturbed target objects forms a dark-field image.';
fprintf(fid,'%s\n',strcat('//<Method>',data1,'</Method>'));
name1 = 'Gaby.gorsky[at]obs-vlfr.fr http://www.obs-vlfr.fr/LOV/ZooPart/Portal/ Laboratoire d''Oceanographie de Villefranche  B.P. 28 Villefranche-Sur-Mer France +33 (0)4 93 76 38 16 +33 (0)4 93 76 38 34 http://www.obs-vlfr.fr/LOV/ZooPart/UVP/';
name2 = 'Lars.stemmann[at]obs-vlfr.fr http://www.obs-vlfr.fr/LOV/ZooPart/Portal/ Laboratoire d''Oceanographie de Villefranche  B.P. 28 Villefranche-Sur-Mer France +33 (0)4 93 76 38 11 +33 (0)4 93 76 38 34 http://www.obs-vlfr.fr/LOV/ZooPart/UVP/';
name3 = 'Marc.picheral[at]obs-vlfr.fr http://www.obs-vlfr.fr/LOV/ZooPart/Portal/ Laboratoire d''Oceanographie de Villefranche  B.P. 28 Villefranche-Sur-Mer France +33 (0)4 93 76 38 08 +33 (0)4 93 76 38 34 http://www.obs-vlfr.fr/LOV/ZooPart/UVP/';
fprintf(fid,'%s\n',strcat('//<Owner1>',name1,'</Owner1>'));
fprintf(fid,'%s\n',strcat('//<Owner1>',name2,'</Owner1>'));
fprintf(fid,'%s\n',strcat('//<Owner1>',name3,'</Owner1>'));

%+++++++++++++++++++++++ Column Labels ++++++++++++++++++++++++++++++++++++++++++++++++++
[classe0,taille0,medi0,minor,maxor,step]=pasvar;                         % Choix du pas variable (echelle octaves detaillee)
[classered,taillered,medired,minorred,maxorred,stepred]=pasvarred;            % Choix du pas variable (echelle octaves commune reduite)
classeesd=2*((3*classe0/(4*3.1416)).^(1/3));         % Conversion en ESD
classeesd=.01*ceil(classeesd*100);                    % Arrondi
fprintf(fid,'%s','Cruise:METAVAR:TEXT:20;Site:METAVAR:TEXT:20;Station:METAVAR:TEXT:20;Rawfilename:METAVAR:TEXT:20;UVPtype:METAVAR:TEXT:6;CTDrosettefilename:METAVAR:TEXT:40;yyyy-mm-dd hh:mm:METAVAR:TEXT:40;Latitude [degrees_north]:METAVAR:DOUBLE;Longitude [degrees_east]:METAVAR:DOUBLE;Depth [m]:PRIMARYVAR:DOUBLE;Sampled volume[L];');

%% hisnb data reduite et total
x1 = num2str(classeesd(1));
x2 = num2str(classeesd(11));
fprintf(fid,'%s',strcat('LPM (',x1,'-',x2,'mm)[#/L];'));
x1 = num2str(classeesd(11));
x2 = num2str(classeesd(14));
fprintf(fid,'%s',strcat('LPM (',x1,'-',x2,'mm)[#/L];'));
x1 = num2str(classeesd(14));
x2 = num2str(classeesd(18));
fprintf(fid,'%s',strcat('LPM (',x1,'-',x2,'mm)[#/L];'));
x1 = num2str(classeesd(1));
x2 = num2str(classeesd(18));
fprintf(fid,'%s',strcat('LPM (',x1,'-',x2,'mm)[#/L];'));

%% hisbv data reduite et total
x1 = num2str(classeesd(1));
x2 = num2str(classeesd(11));
fprintf(fid,'%s',strcat('LPM biovolume (',x1,'-',x2,'mm)[ppm];'));
x1 = num2str(classeesd(11));
x2 = num2str(classeesd(14));
fprintf(fid,'%s',strcat('LPM biovolume (',x1,'-',x2,'mm)[ppm];'));
x1 = num2str(classeesd(14));
x2 = num2str(classeesd(18));
fprintf(fid,'%s',strcat('LPM biovolume (',x1,'-',x2,'mm)[ppm];'));
x1 = num2str(classeesd(1));
x2 = num2str(classeesd(18));
fprintf(fid,'%s',strcat('LPM biovolume (',x1,'-',x2,'mm)[ppm];'));

%% hisnb data
for j=1:(size(classeesd,2)-1)
    x1 = num2str(classeesd(j));
    x2 = num2str(classeesd(j+1));
    fprintf(fid,'%s',strcat('LPM (',x1,'-',x2,'mm)[#/L];'));
end
%% hisbv data
for j=1:(size(classeesd,2)-1)
    x1 = num2str(classeesd(j));
    x2 = num2str(classeesd(j+1));
    fprintf(fid,'%s',strcat('LPM biovolume (',x1,'-',x2,'mm)[ppm];'));
end

ctdnb = 0;
if strcmp(include_ctd,'y')
    %% CTD data
    % Index debut pour CTD
    ctddeb = 1;
    %  if strcmp(base(1).cruise,'lohafex2009'); ctddeb = 5;end
    while ctddeb <= size(base,2)
        if isfield(base(ctddeb),'ctdrosettedata_normalized');
            if ~isempty(base(ctddeb).ctdrosettedata_normalized)
                ctddebut = ctddeb;
                for k=2:size(base(ctddeb).ctdrosettedata_normalized.names,2)-1;
                    name = char(base(ctddeb).ctdrosettedata_normalized.names(k));
                    f = findstr(name,':');
                    if isempty(f)== 0
                        name = name(f+1:end);
                    end
                    fprintf(fid,'%s',strcat(char(name),';'));
                end
                k = size(base(ctddeb).ctdrosettedata_normalized.names,2);
                name = char(base(ctddeb).ctdrosettedata_normalized.names(k));
                f = findstr(name,':');
                if isempty(f)== 0
                    name = name(f+1:end);
                end
                fprintf(fid,'%s\n',char(name));
                ctdnb = size(base(ctddeb).ctdrosettedata_normalized.names,2);
                % ------ Sortie ----------
                ctddeb = size(base,2)+1;
            end
        end
        ctddeb = ctddeb+1;
    end
else
    fprintf(fid,'\n');
end

% ----------- Pas de CTD !!! ------------------
if ctdnb == 0; include_ctd = 'n'; ctddebut = 0; end



%% ++++++++++++++++++ METADATA et DATA ++++++++++++++++
for i=1:size(base,2);
    waitbar(i / size(base,2));
    [a,b]=size(base(i).hisnb);
    if strcmp(include_ctd,'y') && isfield(base(i),'ctdrosettedata_normalized')
        %% CTD Data Interpolation au meme pas que LPM
        if (isstruct(base(i).ctdrosettedata_normalized) && isempty(base(i).ctdrosettedata_normalized.data)==0)
            if i==ctddebut;
                nbctdfielddeb = size(base(i).ctdrosettedata_normalized.data,2);
            end
            nbctdfield = size(base(i).ctdrosettedata_normalized.data,2);
            % -------- CAS Cascade ----------
            if strcmp(base(i).cruise,'cascade2011')
                %                     f=find([base(i).ctdrosettedata_normalized.data(:,2)]==max([base(i).ctdrosettedata_normalized.data(:,2)]));
                f=find([base(i).ctdrosettedata_normalized.data(:,1)]==max([base(i).ctdrosettedata_normalized.data(:,1)]));
                indexz = f;
                nbctdfield = size(base(i).ctdrosettedata_normalized.data,2);
                % si remontee
                if f==1
                    base(i).ctdrosettedata_normalized.data = flipud(base(i).ctdrosettedata_normalized.data);
                    indexz = size(base(i).ctdrosettedata_normalized.data,1);
                end
                ctdresult = interp1([base(i).ctdrosettedata_normalized.data(1:indexz,2)],[base(i).ctdrosettedata_normalized.data(1:indexz,1:end)],[base(i).hisnb(:,1)],'linear');
            elseif nbctdfielddeb == nbctdfield;
                f=find([base(i).ctdrosettedata_normalized.data(:,1)]==max([base(i).ctdrosettedata_normalized.data(:,1)]));
                indexz = f;
                nbctdfield = size(base(i).ctdrosettedata_normalized.data,2);
                % si remontee
                if f==1
                    base(i).ctdrosettedata_normalized.data = flipud(base(i).ctdrosettedata_normalized.data);
                    indexz = size(base(i).ctdrosettedata_normalized.data,1);
                end
                %                 ctdresult = interp1([base(i).ctdrosettedata_normalized.data(1:indexz,1)],[base(i).ctdrosettedata_normalized.data(1:indexz,1:end)],[base(i).hisnb(:,1)],'linear');
                % ---------------- BIN au pas des données UVP5 ---------
                x = base(i).ctdrosettedata_normalized.data(1:indexz,1);
                dp =  base(i).hisnb(end,1) - base(i).hisnb(1,1);
                zdim = length(base(i).hisnb(:,1)) - 1;
                if dp > 0;
                    z_step = dp/zdim;
                else
                    z_step = 5;
                end
                xi_d = [min(base(i).hisnb(:,1))- z_step/2 : z_step : 5*z_step+max(base(i).hisnb(:,1))+z_step/2];
                ctdresult = [];
                for t = 1:size(base(i).hisnb(:,1),1);
                    aa = find(x > xi_d(t));
                    datas = base(i).ctdrosettedata_normalized.data(aa,1:end);
                    bb = find(datas(:,1) <= xi_d(t+1));
                    ligne = nanmean(datas(bb,1:end),1);
                    ligne(1) = xi_d(t) + z_step/2;
                    ctdresult = [ctdresult;ligne];
                end
            end
        else
            disp([num2str(i),'  No CTD data for the record of the database ! ']);
        end
    end
    % -------- METADATA ------------
    for bb = 1 : a
        % Cruise; Site; Profilename ; Histfile;UVPtype;CTDrosette;
        f=char(base(i).pvmtype);
        f(1:3) = 'uvp';
        Site = base(i).stationname;
        profilename = base(i).profilename;
        if strncmp(base(i).profilename,'cce_p1106',9); aa = char(base(i).profilename); profilename = aa(11:end);end
        fprintf(fid,'%s',strcat(char(base(i).cruise),';',char(Site),';',char(profilename),';HDR',char(base(i).histfile),';',f,';',char(base(i).ctdrosette),';'));
        % Date ISO8601
        s = datestr(base(i).datem,31);
        %     s(11) = 'T';
        fprintf(fid,'%s',strcat(s,';'));
        % Latitude
        fprintf(fid,'%s',strcat(num2str(base(i).latitude)),';');
        % Longitude
        fprintf(fid,'%s',strcat(num2str(base(i).longitude)),';');
        % Averaged depth
        fprintf(fid,'%s',strcat(num2str(base(i).hisnb(bb,1))),';');
        % Sampled Volume
        if(strcmp(base(i).pvmtype,'pvm4'))
            fprintf(fid,'%s',strcat(num2str(base(i).hisnb(bb,3)*base(i).volimg1),';'));
        else
            fprintf(fid,'%s',strcat(num2str(base(i).hisnb(bb,3)*base(i).volimg0),';'));
        end
        % ------------ the data -------------------
        %% hisnb data reduite et total
        x3 = num2str(sum(base(i).hisnb(bb,4:13),2, "omitnan"));
        x4 = num2str(sum(base(i).hisnb(bb,14:16),2, "omitnan"));
        x5 = num2str(sum(base(i).hisnb(bb,17:20),2, "omitnan"));
        x6 = num2str(sum(base(i).hisnb(bb,4:20),2, "omitnan"));
        fprintf(fid,'%s',strcat(x3,';',x4,';',x5,';',x6,';'));
        %% hisbv data reduite et total
        x3 = num2str(sum(base(i).hisbv(bb,4:13),2, "omitnan"));
        x4 = num2str(sum(base(i).hisbv(bb,14:16),2, "omitnan"));
        x5 = num2str(sum(base(i).hisbv(bb,17:20),2, "omitnan"));
        x6 = num2str(sum(base(i).hisbv(bb,4:20),2, "omitnan"));
        fprintf(fid,'%s',strcat(x3,';',x4,';',x5,';',x6,';'));
        %% hisnb data
        for j=4:b
            fprintf(fid,'%f',base(i).hisnb(bb,j));
            fprintf(fid,'%s',';');
        end
        %% hisbv data
        for j=4:b-1
            fprintf(fid,'%f',base(i).hisbv(bb,j));
            fprintf(fid,'%s',';');
        end
        fprintf(fid,'%f',base(i).hisbv(bb,b));
        if strcmp(include_ctd,'y')
            fprintf(fid,'%s',';');  
%         else
%             fprintf(fid,'%s\n','');  
        end
        if strcmp(include_ctd,'y')
            %% CTD data
            if isfield(base(i),'ctdrosettedata_normalized');
                if (isstruct(base(i).ctdrosettedata) && isempty(base(i).ctdrosettedata_normalized.data)==0) && ( nbctdfielddeb == nbctdfield)
%                if (isstruct(base(i).ctdrosettedata) && isempty(base(i).ctdrosettedata_normalized.data)==0) && (size(base(i).ctdrosettedata_normalized.data,1)>=h && nbctdfielddeb == nbctdfield)
                     for k=2:size(base(i).ctdrosettedata_normalized.names,2)-1;
                        fprintf(fid,'%f',(ctdresult(bb,k)));
                        fprintf(fid,'%s',';');
                    end
                    k = size(base(i).ctdrosettedata_normalized.names,2);
                    fprintf(fid,'%f',(ctdresult(bb,k)));
                    fprintf(fid,'%s\n','');
                else
                    for k=2:ctdnb-1;
                        fprintf(fid,'%s','NaN;');
                    end
                    fprintf(fid,'%s\n','NaN');
                    disp(['LPM & CTD  ',char(base(i).histfile),'  replaced by NaNs ! ']);
                end
            else
                for k=2:ctdnb-1;
                    fprintf(fid,'%s','NaN;');
                end
                fprintf(fid,'%s\n','NaN');
                %   disp(['LPM & CTD  ',char(base(i).histfile),'  replaced by NaNs ! ']);
            end
        else
            fprintf(fid,'\n');
        end
    end
    if isfield(base(i),'ctdrosettedata_normalized');
        disp([num2str(i),'  LPM & CTD  ',char(base(i).histfile),'  processed']);
    else
        disp([num2str(i),'  LPM  ',char(base(i).histfile),'  processed']);
    end
    
end
fclose(fid);
disp('-------------------- END LPM CTD ---------------------');
close(h);