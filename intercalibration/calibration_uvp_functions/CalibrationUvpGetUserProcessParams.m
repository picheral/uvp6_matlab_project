function [process_params] = CalibrationUvpGetUserProcessParams(uvp_adj, pix_adj)
% CalibrationUvpGetUserProcessParams  get user inputs for the process
%
%   inputs:
%       uvp_adj: type of uvp to adjust "uvp6" or "uvp5"
%       pix_adj: pixel size of adjusted uvp
%
%   outputs:
%       process_params: struct to store process parameters

% ------------------- params user inputs  ---------------------------------

% min of size range
esd_min = input('Enter ESD minimum for minimisation [mm] (default = 0.13) ');
if isempty(esd_min); esd_min = 0.13; end

% max of size range
tt = 1.5;
if contains(uvp_adj,'uvp6'); tt = 1;end 
esd_max = input(['Enter ESD maximum for minimisation [mm] (default = ',num2str(tt),') ']);
if isempty(esd_max); esd_max = tt; end

% startng value for aa and exp
X0 = input(['Enter starting values X [',num2str(0.55*pix_adj^2),' 1.1] as défaut ']);
if isempty(X0);      X0=[0.55*pix_adj^2 1.1];  end

% default degree of the polynome to fit
Fit_data = input(['Enter fit level for data [3-6] 3 default = 3 ']);
if isempty(Fit_data);      Fit_data=3;  end
Fit_range = input(['Enter fit level for adj [3-6] default = fit for data ']);
if isempty(Fit_range);      Fit_range=Fit_data;  end
fit_type = ['poly', num2str(Fit_data)];
Fit_range = ['poly',num2str(Fit_range)];
EC_factor = input(['Enter EC factor (default = 0.5) ']);
if isempty(EC_factor);      EC_factor=0.5;  end

% vecteur "ECOTAXA"
% size of particles in the class
esd_vect_ecotaxa = [0.00403 0.00508 0.064 0.0806 0.102 0.128 0.161 0.203 0.256 0.323 0.406 0.512 0.645 0.813 1.002 1.290 1.630 2.050 2.580];
% esd_vect_ecotaxa = [0.064  0.102  0.161  0.256  0.406  0.645  1.002  1.630  2.580  4.100];

% function returns
process_params.esd_min = esd_min;
process_params.esd_max = esd_max;
process_params.X0 = X0;
process_params.fit_type = fit_type;
process_params.Fit_range = Fit_range;
process_params.EC_factor = EC_factor;
process_params.esd_vect_ecotaxa = esd_vect_ecotaxa;

end