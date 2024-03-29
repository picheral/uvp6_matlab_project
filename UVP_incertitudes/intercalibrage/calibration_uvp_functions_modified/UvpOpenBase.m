%% Ouverture base pour operation calibrage
% Picheral 2017/11,; 2019/03
% Jacob 2022/06
% copie de CalibrationUvpOpenBase pour renommage (en 'UvpOpenBase') pour
% modification afin que le code puisse tourner sur Marie (pas de iugetdir, utilisation de fullfile)

function[uvp_base, uvp_cast] = UvpOpenBase(type, path)
%CalibrationUvpOpenBase open the data base
%
%   inputs:
%       type : "Reference" or "Adjusted"
%       path : Selection of the UVP's project directory
%
%   outputs:
%       uvp_base : data base (struct)
%       uvp_cast : struct storing cast variables

project_folder_ref = path ;

% ------------- Liste des bases --------------------
results_dir = fullfile(project_folder_ref,'/','results');
if isfolder(results_dir)
    base_list = dir(fullfile(results_dir, 'base*.mat'));
    base_nofile = isempty(base_list);
    if base_nofile == 0
        if size(base_list) > 0
            disp('------------------------------------------------------');
            disp('----------- Base list --------------------------------');
            disp([num2str(size(base_list,1)),' database in ', results_dir]);
            for i = 1:size(base_list)
                disp(['N�= ',num2str(i),' : ',base_list(i).name]);
            end
        end
    else
        disp(['No database in ',results_dir]);
    end
else
    disp(['Process cannot continue : no base in ',results_dir]);
end
% ------------------ Chargement de la base de r�f�rence -----------------

base_selected = 1;
if length(base_list) > 1
    base_selected = input('Enter number corresponding to selected uvp database. (default = 1) ');
    if isempty(base_selected) 
        base_selected = 1;   
    end
end
disp(['Selected database : ',base_list(base_selected).name])


% ---------------- Chargement de la base choisie ------------------

load([results_dir,'/',base_list(base_selected).name]);
%try statement in order to deal with old and new base name syntaxe

if contains(project_folder_ref,'uvp5_sn002') % pour g�rer le nom d'une base qui est "originale" par rapport � ce qu'on trouve dans les projets
    try
        base = eval(base_list(base_selected).name(1:end-8));
    catch
        base = eval(base_list(base_selected).name(1:end-4));
    end
else 
    try
       base = eval(base_list(base_selected).name(1:end-4));
    catch
       base = base;
    end
end
if contains(project_folder_ref,'uvp6_sn')
    ligne_ref = size(base,2);
    for i = 1 : ligne_ref
        disp(['Number : ',num2str(i),'   >  Profile : ',char(base(i).profilename)]);
    end
end
record = input('Enter Number of the profile for the UVP (default = 1) ');
if isempty(record); record = 1; end

uvp = char(base(record).pvmtype);
ee = uvp == '_';
uvp(ee) = '-';


% --------------- Changement de r�pertoire ------------------------
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




