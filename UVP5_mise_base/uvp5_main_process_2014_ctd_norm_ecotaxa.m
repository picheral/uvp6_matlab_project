%% Normalisation données CTD pour bases UVP5
% Picheral, 2014/08

function base = uvp5_main_process_2014_ctd_norm_ecotaxa(base,fichier,zoo_list_dir)

ctd_norm_file = [zoo_list_dir,'ctd_uvp_normalisation_for_ecotaxa.xlsx'];

if (exist(ctd_norm_file)==2)
    
    if isempty(base(fichier).ctdrosettedata)
        base(fichier).ctdrosettedata_normalized = [];
    elseif isempty(base(fichier).ctdrosettedata.data)
        base(fichier).ctdrosettedata_normalized = [];
    else
        disp(['Normalisation ECOTAXA ',char(base(fichier).ctdrosette)]);
        
        [numeric text_ctd] = xlsread(ctd_norm_file);
        names =  base(fichier).ctdrosettedata.names;
        % --------- La liste des noms CTD normalisée est issue de 'ctd_uvp_normalisation.xls' ----------------
        liste_norm_ecotaxa = cellstr(char(text_ctd(:,2)));
        liste_source = cellstr(char(text_ctd(:,1)));
        ee = ~strcmp(liste_norm_ecotaxa,'');
        ee = ee==1;
        names_norm = sort(unique(liste_norm_ecotaxa(ee)));
        names_norm_final = {};
        
        % --------- Matrice de NaN que l'on remplit --------------
        data_ctd = NaN*ones(size(base(fichier).ctdrosettedata.data,1),numel(names_norm));
        
        % --------- Organisation des données --------------
        % PRESSION
        names_norm_final(1) = {'pressure in water column [db]'};
        aa = strcmp(liste_norm_ecotaxa,'pressure in water column [db]');
        names_source_associes = liste_source(aa);
        % Recherche col pression dans source
        for mm = 1 : numel(names_source_associes)
            bb = find(strcmp(names_source_associes(mm),names));
            if ~isempty(bb);
                data_ctd(:,1) = base(fichier).ctdrosettedata.data(:,bb(1));
            end
        end
        % depth
        names_norm_final(2) = {'depth [m]'};
        aa = strcmp('depth [m]',liste_norm_ecotaxa);
        names_source_associes = liste_source(aa);
        % Recherche col depth dans source
        for mm = 1 : numel(names_source_associes)
            bb = find(strcmp(names_source_associes(mm),names));
            if ~isempty(bb);
                data_ctd(:,2) = base(fichier).ctdrosettedata.data(:,bb(1));
            end
        end
        
        % qc flag
        names_norm_final(3) = {'qc flag'};
        aa = strcmp(liste_norm_ecotaxa,'qc flag');
        names_source_associes = liste_source(aa);
        % Recherche col flag dans source
        for mm = 1 : numel(names_source_associes)
            bb = find(strcmp(names_source_associes(mm),names));
            if ~isempty(bb);
                data_ctd(:,3) = base(fichier).ctdrosettedata.data(:,bb(1));
            end
        end
        
        % --------- Boucle sur NAMES NORM -------
        index = 4;
        for kk = 1 : numel(names_norm);
            names_norm_final(index) = {'Not_In_Source'};
            name_norm_checked = (names_norm(kk));
            if ~strcmp(name_norm_checked,'pressure in water column [db]') && ~strcmp(name_norm_checked,'depth [m]') && ~strcmp(name_norm_checked,'qc flag')
                names_norm_final(index) = {char(name_norm_checked)};
                aa = strcmp(liste_norm_ecotaxa,name_norm_checked);
                names_source_associes = liste_source(aa);
                % Recherche col dans source
                for mm = 1 : numel(names_source_associes)
                    bb = find(strcmp(names,names_source_associes(mm)));
                    if ~isempty(bb);
                        %                             names_norm_final(index) = {char(name_norm_checked)};
                        data_ctd(:,index) = base(fichier).ctdrosettedata.data(:,bb(1));
                    end
                end
                index = index + 1;
            end
        end
        base(fichier).ctdrosettedata_normalized.data_ecotaxa = data_ctd;
        base(fichier).ctdrosettedata_normalized.names_ecotaxa = names_norm_final;
    end
else
    disp([ctd_norm_file,'  does not exist !!!']);
end