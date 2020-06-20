%% Convertisseur TSV/XLSX (Ecotaxa) to dat1.txt (Zooprocess/PKId)
% Picheral 2016/12
% Merci Fabien !!!!
% Les fichiers déjà convertis ne le sont pas à nouveau => les PURGER pour nouveaux fichiers

% clear all
% close all
function tsv_to_dat1_uvp(validated_dir)

id_all = [];

disp('================= Renaming to TXT ===========================================');
liste_tsv = dir([validated_dir,'\*.tsv']);
index = 0;
for i=1:numel(liste_tsv);
    movefile([validated_dir,'\',liste_tsv(i).name],[[validated_dir,'\',liste_tsv(i).name(1:end-4) '.txt']]); %renaming the TSV in txt for easier reading
    index = index+1;
end
liste_tsv = dir([validated_dir,'\*.txt']);
disp([num2str(index),'  files converted to TXT']);

index = 0;
for p = 1: numel(liste_tsv)
    tsv_table = [liste_tsv(p).name(1:end-4),'.txt'];
    % %     disp(['TSV table : ',tsv_table]);
    % ----------------------- Les fichiers déjà convertis ne le sont pas à nouveau => les PURGER pour nouveaux fichiers --------------
    if exist([validated_dir,'\',liste_tsv(p).name(1:end-4),'_dat1.txt']) == 2
        disp([num2str(p),' : ',liste_tsv(p).name(1:end-4),'_dat1.txt is not created because it exists already !'])
    else if isempty(findstr(liste_tsv(p).name,'dat1.txt')) && isempty(findstr(liste_tsv(p).name(1:end-4),'category_list')) && exist([validated_dir,'\',liste_tsv(p).name(1:end-4),'_dat1.txt']) == 0
        % tsv_table = 'export_14_20160615_0609.xlsx';
        disp('============ CONVERSION OF TXT (ecotaxa) to DAT1.txt ===============');
        disp([num2str(p),' : ',tsv_table ' : reading ']);
        
        table = readtable([validated_dir,'\',tsv_table]);
        disp([tsv_table ' : read']);
        %         disp('------------ Sorting data ------------------------------------------');
        
        % -------------- Gestion des erreurs --------------------------
        names = fieldnames(table);
        if  ~isempty(find(strcmp(names,'acq_exp'), 1));
            expv = str2double(table.acq_exp(1));
        else
            disp('acq_exp field does not exist');
            pause
        end
        if  ~isempty(find(strcmp(names,'acq_aa'), 1));
            aav = str2double(table.acq_aa(1));
        else
            disp('acq_aa field does not exist');
            pause
        end
        if  ~isempty(find(strcmp(names,'acq_pixel'), 1));
            pixelv = str2double(table.acq_pixel(1));
        else
            disp('acq_pixel field does not exist');
            pause
        end
        % ------------ Vérification des MAJ TSV dans Ecotaxa ---------
        %         if  ~isempty(find(strcmp(names,'acq_id'), 1));
        %             acq_id = table.acq_id(1);
        %             if strcmp(acq_id,'uvp5')
        %                 disp(['acq_id = uvp5 instead of uvp5_', tsv_table   ,'. The metadata and data must be re-imported in Ecotaxa !']);
        %                 disp('Application is paused !');
        %                 pause
        %             end
        %         else
        %             disp('acq_id field does not exist');
        %             pause
        %         end
        
        % ------------ Autres champs -------------------
        sampleId = table.sample_id;
        object = table.object_id;
        predv_cat = table.object_annotation_category;
        predv_par = table.object_annotation_parent_category;
        predv = table.object_annotation_hierarchy;
        predv_status = table.object_annotation_status;
        depthv = table.object_depth_min;
        areav = table.object_area;
        
        meanv = table.object_mean;
        if  ~isempty(find(strcmp(names,'object_areai'), 1));
            areaiv = table.object_areai;
            if strcmp(table.object_areai(1),''); areaiv = table.object_area; end
        else
            areaiv = table.object_area;
        end
        
        thickrv = table.object_thickr;
        majorv = table.object_major;
        minorv = table.object_minor;
        
        % ---------- N° objets ----------------------
        itemv = [];
        itemv_txt = [];
        pred_comp = {};
        %     label_txt = [];
        for g = 1 : numel(object)
            object_id = char(object(g));
            ee = find(object_id == '_');
            %             label = object_id(1:ee(end)-1);
            item = object_id(ee(end)+1:numel(object_id));
            if numel(item) == 1;        itemcor = ['000000' item];
            elseif numel(item) == 2;    itemcor = ['00000' item];
            elseif numel(item) == 3;    itemcor = ['0000' item];
            elseif numel(item) == 4;    itemcor = ['000' item];
            elseif numel(item) == 5;    itemcor = ['00' item];
            elseif numel(item) == 6;    itemcor = ['0' item];
            else itemcor = item;
            end
            itemv = [itemv str2num(itemcor)];
            itemv_txt = [itemv_txt; {itemcor} ];
            pred_comp_cor = [char(predv_par(g)),'_',char(predv_cat(g))];
            pred_comp = {pred_comp;pred_comp_cor};
            
            %             label_txt = [label_txt; {label}];
        end
        
        % ----------- Correction pour champs vides qui forcent colonne à CELL ----------------
        
        if iscellstr(depthv)
            index = (cellfun(@isempty,  depthv) ==1);
            if sum(index)>0
                depthv(index)={'NaN'};
                depthv=(cellfun(@str2num,  depthv));
            end
        end
        
        if iscellstr(areav)
            index = (cellfun(@isempty,  areav) ==1);
            if sum(index)>0
                areav(index)={'NaN'};
                areav=(cellfun(@str2num,  areav));
            end
        end
        
        if iscellstr(meanv)
            index = (cellfun(@isempty,  meanv) ==1);
            if sum(index)>0
                meanv(index)={'NaN'};
                meanv=(cellfun(@str2num,  meanv));
            end
        end
        
        if iscellstr(areaiv)
            index = (cellfun(@isempty,  areaiv) ==1);
            if sum(index)>0
                areaiv(index)={'NaN'};
                areaiv=(cellfun(@str2num,  areaiv));
            end
        end
        if iscellstr(thickrv)
            index = (cellfun(@isempty,  thickrv) ==1);
            if sum(index)>0
                thickrv(index)={'NaN'};
                thickrv=(cellfun(@str2num,  thickrv));
            end
        end
        if iscellstr(majorv)
            index = (cellfun(@isempty,  majorv) ==1);
            if sum(index)>0
                majorv(index)={'NaN'};
                majorv=(cellfun(@str2num,  majorv));
            end
        end
        
        data = [ itemv' depthv areav meanv areaiv thickrv majorv minorv];
        texte = [itemv_txt sampleId object predv];
        % ----------- Tri par N° d'objet -------------------------
        data = sortrows(data,1);
        texte = sortrows(texte,1);
        
        % ----------- Liste des catégories présentes --------------
        idnames=unique(predv);
        id_all = [id_all;idnames];
        
        %     id_all = [ id_all ; idnames];
        
        % ----------- Liste des PROFILS --------------------
        samplenames=unique(sampleId);
        % samplenames = sortrows(samplenames);
        
        % Valeurs temporaires
        pixelv = 0.088;
        aav = 0.0036;
        expv = 1.149;
        
        %% =================== BOUCLE sur les PROFILS ==============
        for i = 1 : numel(samplenames);
            
            % -------------- Nom du cast ---------------------------
            filename = [char(samplenames(i)),'_dat1.txt'];
            disp([num2str(p),'/',num2str(numel(liste_tsv)),'  ',filename]);
            
            % ------------------------ Recherche SUBSET du sampleId --------------
            tf = strcmp(texte(:,2),char(samplenames(i)));
            %         select_ligne = find(tf == 1);
            data_sel = data(tf,:);
            text_sel = texte(tf,:);
            
            % ------------- Gestion du status -----------
            if ~isempty(find(strcmp(predv_status(tf),'predicted'), 1));
                disp(['Some objects are NOT validated. The profile ',filename,' is skipped and the DAT1 file is not created.'])
                disp('-----------------------------------------------------------------------------')
                break
            end
            
            % -------------- Création fichier DAT1.txt -------------
            fid=fopen([validated_dir,'\',filename],'w');
            fprintf(fid,'%s\n','[PID]');
            fprintf(fid,'\n');
            fprintf(fid,'%s\n','[Metadata]');
            fprintf(fid,'%s\n',['pixel= ',num2str(pixelv)]);
            fprintf(fid,'%s\n',['aa= ',num2str(aav)]);
            fprintf(fid,'%s\n',['exp= ',num2str(expv)]);
            fprintf(fid,'\n');
            fprintf(fid,'%s\n','[Data]');
            fprintf(fid,'%s\n','!Item;Label;Depth;Area;Mean;Areai;ThickR;Major;Minor;pred_valid_Id_ecotaxa');
            
            
            % ------------------------ Boucle sur les données du sample ----------
            for g = 1 : size(data_sel,1)
                % ------------- Recherche dernier parent>enfant ---------------------
                Pred = char(text_sel(g,4));
                %             ee = find(Pred == '>');
                %             if numel(ee) > 1;
                %                 Pred = Pred(ee(end-1)+1:end);
                %             end
                depth = data_sel(g,2);
                Area = data_sel(g,3);
                Mean = data_sel(g,4);
                Areai = data_sel(g,5);
                ThickR = data_sel(g,6);
                Major = data_sel(g,7);
                Minor = data_sel(g,8);
                
                fprintf(fid,'%s\n',[num2str(data_sel(g,1)),';',char(samplenames(i)),';',num2str(depth),';',num2str(Area),';',num2str(Mean),';',num2str(Areai),';',num2str(ThickR),';',num2str(Major),';',num2str(Minor),';',lower(Pred)]);
            end
            fclose(fid);
            index = index+1;
        end
    end
end
end
disp('================ ALL DAT1.txt files created =================');

if index > 0;
    %% -------------- Liste des categories -------------------------
    disp('---------------- CATEGORIES ---------------------------------');
    id_all = unique(id_all);
    %% ---------- Sauvegarde du fichier d'inventaire --------------
    fid=fopen([validated_dir,'\category_list.txt'],'w');
    for i = 1 : numel(id_all)
        fprintf(fid,'%s\n',char(id_all(i)));
    end
    fclose(fid);
    
    % for i = 1 : numel(id_all);
    %     Pred = char(id_all(i));
    %     ee = find(Pred == '>');
    %     if numel(ee) > 1;
    %         Pred = Pred(ee(end-1)+1:end);
    %     end
    %     disp(lower(Pred));
    % end
end


