%% ---------------- Fichiers ODV ---------------
% ZOOPLANKTON + CTD normalisées
% Picheral, 2014/08

function  [base] = uvp5_process_odv_zoo_ctd(base,results_dir,base_new,ctddebut,include_zoo_det,exclude_detritus)

warning off MATLAB:divideByZero
% Warning off MATLAB:NaN found in Y interpolation at undefined values will result in undefined values
         

h=waitbar(0,'Processing UVP5 Zooplankton abundance file ...');%create and display a bar that show progess of the analysis

filename = [results_dir,base_new];
fid=fopen([filename,'_zoo_odv.txt'],'w');
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
% ----------- Fixes ! ----------------
fprintf(fid,'%s','Cruise:METAVAR:TEXT:20;Site:METAVAR:TEXT:20;Station:METAVAR:TEXT:20;Rawfilename:METAVAR:TEXT:20;UVPtype:METAVAR:TEXT:6;CTDrosettefilename:METAVAR:TEXT:20;yyyy-mm-dd hh:mm;Latitude [degrees_north]:METAVAR:DOUBLE;Longitude [degrees_east]:METAVAR:DOUBLE;');
% ----------- Variables --------------
i = 1;
startindex = 1;
if strcmp(base(i).cruise,'lohafex2009'); i = 3;end
while i <= size(base,2)
    if isfield(base(i),'zoopuvp5');
        if isempty(base(i).zoopuvp5)== 0
            % ------ Ecriture des entetes -----
            kend = size(base(i).zoopuvp5.abondances.names,1);
            for k = 1:kend
                fprintf(fid,'%s',char(strcat(base(i).zoopuvp5.abondances.names(k),':DOUBLE;')));
            end
            disp(['ZOO header filled using record #',num2str(i)]);
            startindex = i;
            i = size(base,2)+1;
        else
            i = i+1;
        end
    end
end

% -------------------- Entete CTD normalisee ------------------------
ctddata_names = base(ctddebut).ctdrosettedata_normalized.names;
for tt = 1:numel(ctddata_names)-1
    fprintf(fid,'%s',strcat(char(ctddata_names(tt)),':DOUBLE;'));
end
fprintf(fid,'%s\n',strcat(char(ctddata_names(end)),':DOUBLE'));


%+++++++++++++++++++++++ METADATA & DATA +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
zoodeb = 1;
%   if strcmp(base(1).cruise,'lohafex2009'); startindex = 3;end
for i=startindex:size(base,2);
    waitbar(i / size(base,2));
    %% Test sur la presence de base.zoopkuvp5
    fid=fopen([filename,'_zoo_odv.txt'],'a');
    if isfield(base(i),'zoopuvp5');
        if isempty(base(i).zoopuvp5)== 0
            for j=1:size(base(i).zoopuvp5.abondances.data,1);
                % ---------------- Test sur Id -------------------------
                % Cruise; Site ; Profilename ; Histfile;UVPtype;CTDrosette;
                f=char(base(i).pvmtype);
                f(1:3) = 'uvp';
                profilename = char(base(i).profilename);
                Site = base(i).stationname;
                if strncmp(base(i).profilename,'cce_p1106',9); aa = char(base(i).profilename); profilename = aa(11:end);end
                fprintf(fid,'%s',strcat(char(base(i).cruise),';',char(Site),';',profilename,';HDR',char(base(i).histfile),';',f,';',char(base(i).ctdrosette),';'));
                % Date ISO8601
                s = datestr(base(i).datem,31);
                %       s(11) = 'T';
                fprintf(fid,'%s',strcat(s,';'));
                % Latitude
                fprintf(fid,'%s',strcat(num2str(base(i).latitude)),';');
                % Longitude
                fprintf(fid,'%s',strcat(num2str(base(i).longitude)),';');
                % DATA abondances
                for k = 1:kend
                    fprintf(fid,'%s',strcat(num2str(base(i).zoopuvp5.abondances.data(j,k)),';'));
                end
                if ~isempty(base(i).zoopuvp5.abondances.data_ctd_ab)
                    for hh = 1 : numel(ctddata_names) - 1;
                        fprintf(fid,'%s',strcat(num2str(base(i).zoopuvp5.abondances.data_ctd_ab(j,hh)),';'));
                    end
                    fprintf(fid,'%s\n',strcat(num2str(base(i).zoopuvp5.abondances.data_ctd_ab(j,hh+1))));
                else
                    % -------- NaN ----------------
                    for hh = 1 : numel(ctddata_names) - 1;
                        fprintf(fid,'%s','NaN;');
                    end
                    fprintf(fid,'%s\n','NaN');
                end
            end
            disp([num2str(i),'  ZOO abundancces ',char(base(i).histfile),' processed']);
        else
            disp([num2str(i),'  ZOO  ',char(base(i).histfile),' EMPTY']);
        end
        %   disp(['ZOO  ',char(base(i).histfile),' does not exist.']);
    end
    fclose(fid);
end
disp('-----------------------------------------------------');
close(h);


if strcmp(include_zoo_det,'y');
    h=waitbar(0,'Processing UVP5 Zooplankton individual data file ...');%create and display a bar that show progess of the analysis
    %% ----------------------- ZOOPLANKTON individuel -----------------
    %fid=fopen(['D:\ARPVM\Databank\pvm\uvp5_zoo_',filename(1:end-4),'.txt'],'w');
    filename = [results_dir,base_new];
    fid=fopen([filename,'_zoo.txt'],'w');
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
    if isfield(base(i),'zoopuvp5.Areai');
        if isempty(base(i).zoopuvp5.Areai) == 1;
            fprintf(fid,'%s','Cruise:METAVAR:TEXT:20;Site:METAVAR:TEXT:20;Station:METAVAR:TEXT:20;Rawfilename:METAVAR:TEXT:20;UVPtype:METAVAR:TEXT:6;CTDrosettefilename:METAVAR:TEXT:20;yyyy-mm-dd hh:mm;Latitude [degrees_north]:METAVAR:DOUBLE;Longitude [degrees_east]:METAVAR:DOUBLE;Depth [m]:PRIMARYVAR:DOUBLE;Zooplankton Id:TEXT;Zooplankton ESD[mm]:DOUBLE;MEAN grey (0-255):DOUBLE;Major (mm):DOUBLE;Minor (mm):DOUBLE;');
        else
            fprintf(fid,'%s','Cruise:METAVAR:TEXT:20;Site:METAVAR:TEXT:20;Station:METAVAR:TEXT:20;Rawfilename:METAVAR:TEXT:20;UVPtype:METAVAR:TEXT:6;CTDrosettefilename:METAVAR:TEXT:20;yyyy-mm-dd hh:mm;Latitude [degrees_north]:METAVAR:DOUBLE;Longitude [degrees_east]:METAVAR:DOUBLE;Depth [m]:PRIMARYVAR:DOUBLE;Zooplankton Id:TEXT;Zooplankton ESD[mm]:DOUBLE;Zooplankton ESDi[mm]:DOUBLE;MEAN grey (0-255):DOUBLE;Major (mm):DOUBLE;Minor (mm):DOUBLE;');
        end
    else
        fprintf(fid,'%s','Cruise:METAVAR:TEXT:20;Site:METAVAR:TEXT:20;Station:METAVAR:TEXT:20;Rawfilename:METAVAR:TEXT:20;UVPtype:METAVAR:TEXT:6;CTDrosettefilename:METAVAR:TEXT:20;yyyy-mm-dd hh:mm;Latitude [degrees_north]:METAVAR:DOUBLE;Longitude [degrees_east]:METAVAR:DOUBLE;Depth [m]:PRIMARYVAR:DOUBLE;Zooplankton Id:TEXT;Zooplankton ESD[mm]:DOUBLE;MEAN grey (0-255):DOUBLE;Major (mm):DOUBLE;Minor (mm):DOUBLE;');
    end
    % -------------------- Entete CTD normalisee ------------------------
    ctddata_names = base(ctddebut).ctdrosettedata_normalized.names;
    for tt = 2:numel(ctddata_names)-1
        fprintf(fid,'%s',strcat(char(ctddata_names(tt)),':DOUBLE;'));
    end
    fprintf(fid,'%s\n',strcat(char(ctddata_names(end)),':DOUBLE'));
    
    %+++++++++++++++++++++++ METADATA & DATA +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    zoodeb = 1;
    if strcmp(base(1).cruise,'lohafex2009'); zoodeb = 3;end
    for i= zoodeb:size(base,2);
        waitbar(i / size(base,2));
        %% Test sur la presence de base.zoopkuvp5
        if isfield(base(i),'zoopuvp5');
            % --------------- Donnees CTD associées --------------------
            if ~isempty(base(i).ctdrosettedata_normalized)
                ctddata = base(i).ctdrosettedata_normalized.data;
            end
            if isempty(base(i).zoopuvp5)== 0
                for j=1:size(base(i).zoopuvp5.Depth,1);
                    % --------- DETRITUS exclus ----------------
                    if strcmp(exclude_detritus,'y') &&...
                            ~strncmp(base(i).zoopuvp5.Pred(j),'artefact',4)...
                            && ~strncmp(base(i).zoopuvp5.Pred(j),'other_to_check',4)...
                            && ~strncmp(base(i).zoopuvp5.Pred(j),'duplicate',4)...
                            && ~strncmp(base(i).zoopuvp5.Pred(j),'det_',4)...
                            && ~strncmp(base(i).zoopuvp5.Pred(j),'bad_',4)...
                            && ~strncmp(base(i).zoopuvp5.Pred(j),'to_skip',4)...
                            && ~strncmp(base(i).zoopuvp5.Pred(j),'not-living',10)
                        
                        % ---------------- Test sur Id -------------------------
                        % Cruise; Site ; Profilename ; Histfile;UVPtype;CTDrosette;
                        f=char(base(i).pvmtype);
                        f(1:3) = 'uvp';
                        if strncmp(base(i).profilename,'cce_p1106',9);
                            aa = char(base(i).profilename);
                            profilename = aa(11:end);
                        else
                            profilename = char(base(i).profilename);
                        end
                        if strncmp(base(i).stationname,'cce_p1106',9);
                            aa = char(base(i).stationname);
                            Site = aa(11:end);
                        else
                            Site = char(base(i).stationname);
                        end
                        fprintf(fid,'%s',strcat(char(base(i).cruise),';',Site,';',profilename,';HDR',char(base(i).histfile),';',f,';',char(base(i).ctdrosette),';'));
                        % Date ISO8601
                        s = datestr(base(i).datem,31);
                        %       s(11) = 'T';
                        fprintf(fid,'%s',strcat(s,';'));
                        % Latitude
                        fprintf(fid,'%s',strcat(num2str(base(i).latitude)),';');
                        % Longitude
                        fprintf(fid,'%s',strcat(num2str(base(i).longitude)),';');
                        % Depth
                        fprintf(fid,'%s',strcat(num2str(base(i).zoopuvp5.Depth(j)),';'));
                        % ZoopkId
                        fprintf(fid,'%s',strcat(char(base(i).zoopuvp5.Pred(j)),';'));
                        % ZoopESD(mm)
                        % base(i).zoopuvp5.Area est en mm²
                        aream = base(i).zoopuvp5.Area(j);
                        esd=2*((aream/(3.1416)).^(1/2));         % Conversion en ESD
                        esd =.01*ceil(esd*100);                    % Arrondi
                        % fprintf(fid,'%s\n',num2str(esd));
                        fprintf(fid,'%s',strcat(num2str(esd),';'));
                        if isfield(base(i),'zoopuvp5.Areai');
                            if isempty(base(i).zoopuvp5.Areai) == 0;
                                % Areami est en mm² utilisant 'aa'
                                % et 'exp' du dat1 file
                                areami = base(i).zoopuvp5.Areai(j);
                                esdi=2*((areami/(3.1416)).^(1/2));         % Conversion en ESD
                                esdi =.01*ceil(esdi*100);                    % Arrondi
                                % fprintf(fid,'%s\n',num2str(esd));
                                fprintf(fid,'%s',strcat(num2str(esdi),';'));
                            end
                        end
                        fprintf(fid,'%s',strcat(num2str(base(i).zoopuvp5.Mean(j))),';');
                        fprintf(fid,'%s',strcat(num2str(base(i).zoopuvp5.Major(j))),';');
                        fprintf(fid,'%s',strcat(num2str(base(i).zoopuvp5.Minor(j))),';');
                        % --------------- Donnees CTD associées --------------------
                        if ~isempty(base(i).ctdrosettedata_normalized)
                            if base(i).zoopuvp5.Depth(j) >= ctddata(1,2);
                                % -------------- La valeur la plus proche --------
                                oo = dsearchn(ctddata(:,1),base(i).zoopuvp5.Depth(j));
                                ctdresult = ctddata(oo,:);
                                % -------------- Valeur interpolée : pb NaN --------
%                                 ctdresult = interp1(ctddata(:,1),ctddata,base(i).zoopuvp5.Depth(j),'linear');
                            else
                                % ----- premieres donnees CTD pour objets au dessus -----
                                ee = find(ctddata(:,1) >= ctddata(1,1));
                                ctdresult = ctddata(ee(1),:);
                            end
                        else
                            ctdresult = NaN * ones(numel(ctddata_names),1);
                        end
                        for tt = 2:size(ctddata,2)-1
                            fprintf(fid,'%s',strcat(num2str(ctdresult(tt))),';');
                        end
                        fprintf(fid,'%s\n',num2str(ctdresult(end)));
                    end
                end
                disp([num2str(i),'  ZOO  ',char(base(i).histfile),' processed']);
            else
                disp([num2str(i),'  ZOO  ',char(base(i).histfile),' EMPTY']);
            end
        else
            disp('Abundance file is empty');
        end
    end
    fclose(fid);
    close(h);
end
disp('-------------------- END ZOO ---------------------');
