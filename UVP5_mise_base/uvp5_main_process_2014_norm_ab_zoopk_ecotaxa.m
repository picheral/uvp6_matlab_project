%% Normalisation des Identifications
% Calcul ABONDANCES
% Ajout données CTD
% Picheral, 2014/08


function base = uvp5_main_process_2014_norm_ab_zoopk_ecotaxa(base,fichier,zoo_norm,processnor,volume_zoo,matvert,min_zoo_esd,config_dir,zoo_list_dir)

if isfield(base(fichier),'zoopuvp5');
    if ~isempty(base(fichier).zoopuvp5);
        if (strcmp(zoo_norm,'y'));
            % ---------- PREMIERE NORMALISATION : ECRASE IDs source ------
            DATA = base(fichier).zoopuvp5;
            norm_file = [config_dir,'Noms_zoo_UVP5_matlab_',char(base(fichier).cruise),'.xls'];
            if (exist(norm_file)==2);
                cor_idx =0;
                [numeric textid] = xlsread(norm_file);
                ident = DATA.Pred;
                % --------- Erreur --------------------------------------
                if size(DATA.Pred,1)~=size(DATA.Area,1)
                    disp(['ERREUR : ', num2str(i),'   ',num2str(size(DATA.Pred,1)),'    ',num2str(size(DATA.Area,1))                  ]);
                    pause(3);
                end
                for f = 1:size(ident,1);
                    for g=1:size(textid,1);
                        if strcmp(lower(ident(f)),lower(textid(g,1)));
                            %   disp([char(ident(i))]);
                            ident(f) = textid(g,2);
                            cor_idx = cor_idx+1;
                            %                                 disp([char(textid(g,1)),'   ',char(textid(g,2))]);
                        end
                    end
                end
                DATA.Pred = ident;
                base(fichier).zoopuvp5 = DATA;
                disp([num2str(cor_idx),' identifications normalized using ',char(norm_file)]);
            else
                disp([norm_file,' Normalisation file not found. ']);
            end
        end
        if strcmp(processnor,'y');
            % ---------- Seconde normalisation pour abondances : CREE NormId ------
            normalisation = 0;
            norm_file = [zoo_list_dir,'Noms_zoo_UVP5_matlab_generic_ecotaxa.xls'];
            if (exist(norm_file)==2);
                [numeric textid] = xlsread(norm_file);
                ident = base(fichier).zoopuvp5.Pred;
                
                
                % ------------------ LOGIQUE du mapping ---------------
                
                
                
                
                
                
                
                
                %ident = DATA.Pred;
                for f = 1:size(ident,1);
                    for g=1:size(textid,1);
                        if strcmp(ident(f),textid(g,1));
                            %   disp([char(ident(i))]);
                            ident(f) = textid(g,2);
                        end
                    end
                end
                DATA.normid = ident;
                base(fichier).zoopuvp5 = DATA;
                
                normalisation = 1;
                % ---------- Creation des données synthétiques NORMALISEES ---
                listzoonorm = unique(textid(:,2));
                Image = base(fichier).datfile.image;
                if normalisation == 1;
                    % -------------- Calcul abondances ----------------
                    dataabondances = uvp5_main_process_2014_norm_ab(base,fichier,volume_zoo,matvert,listzoonorm,min_zoo_esd);
                    
                    base(fichier).zoopuvp5.abondances = dataabondances;
                    base(fichier).zoopuvp5.abondances.esd_min = min_zoo_esd;
                    disp(['Zooplankton abundances processed using ',char(norm_file)]);
                    % -------------- Donnees CTD au même pas normalisé ----------------------
                    data_ctd_ab = [];
                    if ~isempty(base(fichier).ctdrosettedata_normalized)
                        % ---------- Boucle sur la matrice verticale --------
                        zmax = max(base(fichier).zoopuvp5.abondances.data(:,3));
                        ee = find(matvert < zmax);
                        for kk = 1:ee(end);
                            ee = find( base(fichier).ctdrosettedata_normalized.data(:,1)< matvert(kk+1));
                            ff = find(base(fichier).ctdrosettedata_normalized.data(ee,1)>= matvert(kk));
                            if isempty(ff)
                                ttt = NaN * ones (size(base(fichier).ctdrosettedata_normalized.data,2),1)';
                                data_ctd_ab = [data_ctd_ab ; ttt ];
                            elseif numel(ff) == 1
                                data_ctd_ab = [data_ctd_ab ; base(fichier).ctdrosettedata_normalized.data(ff,:)];
                            else
                                data_ctd_ab = [data_ctd_ab ; median(base(fichier).ctdrosettedata_normalized.data(ff,:))];
                            end
                        end
                    end
                    base(fichier).zoopuvp5.abondances.data_ctd_ab = data_ctd_ab;
                end
            else
                disp([norm_file ' file not found. ']);
            end
        end
    end
end
