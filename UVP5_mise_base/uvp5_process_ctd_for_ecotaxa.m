%% ---------------- Fichiers ODV ---------------
% Particles + CTD normalisées
% Picheral, 2014/08

function  [base] = uvp5_process_ctd_for_ecotaxa(base,ctdcnv_dir)

h=waitbar(0,'Processing UVP5 CTD file for Ecotaxa...');%create and display a bar that show progess of the analysis

disp('-------------------- START PROCESS ---------------------');
for i = 1:numel(base);
    if isfield(base(i),'ctdrosettedata_normalized');
        if ~isempty(base(i).ctdrosettedata_normalized)
            if ~isempty(base(i).ctdrosettedata_normalized.data_ecotaxa)
                filename = [ctdcnv_dir,char(base(i).profilename),'.ctd'];
                fid=fopen(filename,'w');
                disp(['Processing ',filename,' WAIT !!!!']);
                
                %+++++++++++++++++++++++ ENTETE +++++++++++++++++++++++++++++++++++++++++++++++
                names = base(i).ctdrosettedata_normalized.names_ecotaxa;
                for k=1:size(names,2)-1;
                    name = char(names(k));
                    f = findstr(name,':');
                    if isempty(f)== 0
                        name = name(f+1:end);
                    end
                    fprintf(fid,'%s \t',strcat(char(name)));
                end
                k = size(names,2);
                name = char(names(k));
                f = findstr(name,':');
                if isempty(f)== 0
                    name = name(f+1:end);
                end
                fprintf(fid,'%s\n',char(name));
%                 ctdnb = size(names,2);
                % ++++++++++++++++++++++++ DATA ++++++++++++++++++++++++++++++++++++++++++
                for bb=1 : size(base(i).ctdrosettedata_normalized.data_ecotaxa,1)
%                     disp(num2str(bb))
                    for k=1:size(names,2)-1;
                        fprintf(fid,'%f \t',(base(i).ctdrosettedata_normalized.data_ecotaxa(bb,k)));
                    end
                    fprintf(fid,'%f \n',(base(i).ctdrosettedata_normalized.data_ecotaxa(bb,k+1)));
                end
                fclose(fid);
                disp([char(base(i).ctdrosette),' normalized for ECOTAXA']);
            end
        end
    end
end
disp('-------------------- END CTD for ECOTAXA ---------------------');
close(h);