%% Ouverture base pour operation calibrage
% Picheral 2017/11,; 2019/03

function[uvp_base, uvp_cast] = CalibrationUvpOpenBase(type)
%CalibrationUvpOpenBase open the data base
%
%   inputs:
%       type : "Reference" or "Adjusted"
%
%   outputs:
%       uvp_base : data base (struct)
%       uvp_cast : struct storing cast variables

selectprojet = 0;
while (selectprojet == 0)
    disp(['>> Select UVP ',char(type),' project directory']);
    project_folder_ref = uigetdir('',['Select UVP ',char(type),' project directory']);
    if strcmp(project_folder_ref(4:6),'uvp')
        selectprojet = 1;
    else
        disp(['Selected project ' project_folder_ref ' is not correct. ']);
    end
end
% ------------- Liste des bases --------------------
results_dir = [project_folder_ref,'\results\'];
if isfolder(results_dir)
    base_list = dir([results_dir, 'base*.mat']);
    base_nofile = isempty(base_list);
    if base_nofile == 0
        disp('----------- Base list --------------------------------');
        disp([num2str(size(base_list,1)),' database in ', results_dir]);
        for i = 1:size(base_list)
            disp(['N°= ',num2str(i),' : ',base_list(i).name]);
        end
    else
        disp(['No database in ',results_dir]);
    end
else
    disp(['Process cannot continue : no reference base in ',results_dir]);
end
% ------------------ Chargement de la base de référence -----------------
disp('------------------------------------------------------');
base_selected = 1;
if size(base_list) > 1
    base_selected = input('Enter number corresponding to selected uvp database. (default = 2) ');
    if isempty(base_selected); base_selected = 2;   end
end

% ---------------- Chargement de la base choisie ------------------
load([results_dir,base_list(base_selected).name]);
% try statement in order to deal with old and new base name syntaxe
try
    base = eval(base_list(base_selected).name(1:end-4));
catch
    base = base;
end
ligne_ref = size(base,2);
for i = 1 : ligne_ref
%     disp(['Number : ',num2str(i),'   >  Profile : ',char(base(i).profilename)]);
end
record = input('Enter Number of the profile for the UVP (default = 1) ');
if isempty(record); record = 1; end

uvp = char(base(record).pvmtype);
ee = uvp == '_';
uvp(ee) = '-';

% --------------- Changement de répertoire ------------------------
cd(project_folder_ref);

%---------------- Build return stucture -----------------------------------
uvp_cast.project_folder = project_folder_ref;
uvp_cast.results_dir = results_dir;
uvp_cast.record = record;
uvp_cast.uvp = uvp;
uvp_cast.profilename = base(record).profilename;
if strcmp(type,"Reference")
    uvp_cast.label = 'ref';
elseif strcmp(type, "Adjusted")
    uvp_cast.label = 'adj';
else
    disp("WARNING : Unkown uvp type, ref or adj ?")
end

uvp_base = base(record);

end




