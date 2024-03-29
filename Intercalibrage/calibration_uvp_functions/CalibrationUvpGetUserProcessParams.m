function [process_params] = CalibrationUvpGetUserProcessParams(uvp_ref, uvp_adj, pix_adj)
% CalibrationUvpGetUserProcessParams  get user inputs for the process
%
%   inputs:
%       uvp_ref: type of reference uvp "uvp6-sn..." or "uvp6-sn..."
%       uvp_adj: type of uvp to adjust "uvp6-sn..." or "uvp5-sn..."
%       pix_adj: pixel size of adjusted uvp
%
%   outputs:
%       process_params: struct to store process parameters

% ------------------- params user inputs  ---------------------------------

% user's aa and exp for uvp6 or uvp5_etalon
set_aa_exp = input('Set the aa and exp ? ([y]/n) ', 's');
if isempty(set_aa_exp); set_aa_exp = 'y'; end
    

users_aa = 2300 / 1000000;
users_exp = 1.1359;
if strcmp(set_aa_exp,'y')
    users_aa = input('Enter the aa value (default = 2300) : ');
    if isempty(users_aa); users_aa = 2300; end
    if contains(uvp_adj,'uvp6'); users_aa = users_aa / 1000000; end
    users_exp = input('Enter the exp value (default = 1.1359) : ');
    if isempty(users_exp); users_exp = 1.1359; end
end

uvps = [uvp_ref, uvp_adj];
% min of size range
if (contains(uvps,'uvp6') && contains(uvps,'uvp5')) || (contains(uvps,'uvp5-sn0') && contains(uvps,'uvp5sn-2'))
    esd_min_default = 0.4;
else
    esd_min_default = 0.13;
end
esd_min = input(['Enter raw ESD minimum for optimisation [mm] (default = ',num2str(esd_min_default),') ']);
if isempty(esd_min); esd_min = esd_min_default; end

% max of size range
esd_max_default = 1.5;
if contains(uvps,'uvp6'); esd_max_default = 1;end 
esd_max = input(['Enter raw ESD maximum for optimisation [mm] (default = ',num2str(esd_max_default),') ']);
if isempty(esd_max); esd_max = esd_max_default; end

% startng value for aa and exp
X0 = input(['Enter starting values X [',num2str(0.55*pix_adj^2),' 1.1] as d�faut ']);
if isempty(X0);      X0=[0.55*pix_adj^2 1.1];  end

% default degree of the polynome to fit
Fit_data = input(['Enter fit level for data [3-6] 3 default = 3 ']);
if isempty(Fit_data);      Fit_data=3;  end
Fit_range = input(['Enter fit level for adj [3-6] default = fit for data ']);
if isempty(Fit_range);      Fit_range=Fit_data;  end
fit_type = ['poly', num2str(Fit_data)];
Fit_range = ['poly',num2str(Fit_range)];
%EC_factor = input(['Enter EC factor (default = 0.5) ']);
%if isempty(EC_factor);      EC_factor=0.5;  end

% vecteur "ECOTAXA"
% size of particles in the class
esd_vect_ecotaxa = [0.0403 0.0508 0.064 0.0806 0.102 0.128 0.161 0.203 0.256 0.323 0.406 0.512 0.645 0.813 1.020 1.290 1.630 2.050 2.580];
% esd_vect_ecotaxa = [0.064  0.102  0.161  0.256  0.406  0.645  1.002  1.630  2.580  4.100];

% function returns
process_params.set_aa_exp = set_aa_exp;
process_params.users_aa = users_aa;
process_params.users_exp = users_exp;
process_params.esd_min = esd_min;
process_params.esd_max = esd_max;
process_params.X0 = X0;
process_params.fit_type = fit_type;
process_params.Fit_range = Fit_range;
%process_params.EC_factor = EC_factor;
process_params.esd_vect_ecotaxa = esd_vect_ecotaxa;

end