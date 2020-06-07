% function to read a dat1.txt file
% made by Pieter Vandromme on june 2008 & marc Picheral 2008/10

function DATA = Chargement_uvp5_dat1txt(dat1file,pixel_size,aap,exp)
warning('off','MATLAB:dispatcher:InexactCaseMatch');
eval(['fid=fopen(dat1file,''r'');'])
liste=(dir(dat1file));
% Date du fichier
DATA.filedate = liste.datenum;
a=1;
% Default values for UVP5sn001 (prototype)
% pixel = 0.174;
% aap= 0.0030;
% exp= 1.3348;
DATA.pixel = pixel_size;
while ~feof(fid)
    tline = fgetl(fid);
    Rawc(a,1)={tline};
    % Taille pixel des metadata du fichier
    if strncmp(tline,'pixel=',6);
        pixel = tline(8:end);
        pixel = str2num(pixel);
        DATA.pixel = pixel;
    end
    if strncmp(tline,'aa=',3);
        aap = tline(5:end);
        aap = str2num(aap);
    end
    if strncmp(tline,'exp=',4);
        exp = tline(6:end);
        exp = str2num(exp);
    end
    
    a=a+1;
end

j=size(Rawc,1);
a1=[];a2=[];a3=[];a4=[];a5=[];
for k=1:j
    if strcmp('[Sample]',Rawc{k,1})==1,a1=[a1;k];
        end
    if strcmp('[Subsample]',Rawc{k,1})==1,a2=[a2;k];
    end
    if strcmp('Image_Process',Rawc{k,1})==1,a3=[a3;k];
    end
    if strcmp('[Data]',Rawc{k,1})==1,a4=[a4;k];
    end
    if strcmp('[Process]',Rawc{k,1})==1,a5=[a5;k];
    end
end

% [DATA]
a=a4(1)+1;
u=1;

while size(Rawc{a,1},2)>2
    % the following line test if the delimiter are ';' like in *.pid
    % files or not, in this case it is delimited by tab like in
    % processed files in *.txt
    %   strfind(Rawc{a,1},'CV')
    Rawc{a,1} = strrep(Rawc{a,1},'CV','cc'); 
    testdel=numel(find(Rawc{a,1}==';'));
    if testdel>0
        line=[';' Rawc{a,1} ';'];
        aa=find(line==';');
        l=size(aa,2);
        for r=1:l-1
            temp={line(aa(r)+1:aa(r+1)-1)};temp=temp{1,1};
            temp1=str2num(temp);if numel(temp1)>0,temp=temp1;end, clear temp1
            try TEMP(u,r)={temp};end
        end
    else
        line=Rawc{a,1};
        temp=textscan(line,'%s');temp=temp{1,1}';jj=size(temp,2);
        for ii=1:jj
            temp1=temp{1,ii};
            temp2=str2num(temp1);if numel(temp2)>0,temp1=temp2;end, clear temp2
            temp{1,ii}=temp1;clear temp1
        end
        try TEMP(u,:)=temp;end,clear temp
    end
    u=u+1;
    if a+1>size(Rawc,1),break,else a=a+1;end
end
[z m]=size(TEMP);
converse= pixel;
converse2=pixel^2;
area_flag = 0;
for r=1:m
    if strcmp(TEMP{1,r},'Depth')==1
        for o=1:z-1,
            val(o,1)=TEMP{o+1,r};
        end
        eval(['DATA.Depth = single(val(:,1));'])
        clear val o
    end
    
    if strcmp(TEMP{1,r},'Area')==1
        for o=1:z-1,
            val(o,1)=TEMP{o+1,r};
        end
        eval(['DATA.Area =single(val(:,1).*converse2);'])
        clear val o
    end
    if strcmp(TEMP{1,r},'Areai')==1
        area_flag = 1;
        for o=1:z-1,
            val(o,1)=TEMP{o+1,r};
        end
        eval(['DATA.Areai = single(aap*val(:,1).^exp);'])
        clear val o
    end
    if strcmp(TEMP{1,r},'Major')==1
        for o=1:z-1,
            val(o,1)=TEMP{o+1,r};
        end
        eval(['DATA.Major =single(val.*converse);'])
        clear val o
    end
    if strcmp(TEMP{1,r},'Minor')==1
        for o=1:z-1,
            val(o,1)=TEMP{o+1,r};
        end
        eval(['DATA.Minor =single(val.*converse);'])
        clear val o
    end
    if strcmp(TEMP{1,r},'ThickR')==1
        for o=1:z-1,
            val(o,1)=TEMP{o+1,r};
        end
        eval(['DATA.ThickR =single(val(:,1));'])
        clear val o
    end
    if strcmp(TEMP{1,r},'Mean')==1
        for o=1:z-1,
            val(o,1)=TEMP{o+1,r};
        end
        eval(['DATA.Mean =single(val(:,1));'])
        clear val o
    end
end

if area_flag == 0;
    DATA.Areai = [];
end
% On prend systematiquement la derniere colonne (valid)
for o=1:z-1
    if (isnumeric(TEMP{o+1,m})==1)
        id = 'surfa';
    else
        id=TEMP{o+1,m};
    end
    eval(['DATA.Pred(o,1)={id};']);
end
valid = TEMP{1,m};
eval(['DATA.method=valid;']);
%   clear val o


%   clear TEMP temp Rawc
fclose(fid);


% --------- Suppression des valeurs liees a la remontee ------
% maxz = max(DATA.Depth);
% e = find(DATA.Depth == maxz);
% DATA.Mean = DATA.Mean(1:min(e));
% DATA.Area = DATA.Area(1:min(e));
% if isempty(DATA.Areai) == 0;    DATA.Areai = DATA.Areai(1:min(e));  end;
% DATA.ThickR = DATA.ThickR(1:min(e));
% DATA.Depth = DATA.Depth(1:min(e));
% DATA.Major = DATA.Major(1:min(e));
% DATA.Minor = DATA.Minor(1:min(e));
% DATA.Pred = DATA.Pred(1:min(e));




