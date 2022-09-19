% Jacob 2022/06
% copie de CalibrationUvpGetUserProcessParams pour renommage (en
% 'UvpGetUserProcessParams') pour modification: esd_min, esd_max et
% Fit_data en entrée de la fonction et non pas demandés à l'utilisateur 

function [process_params] = UvpGetUserProcessParams(pix_adj,esd_min,esd_max,Fit_data)
% CalibrationUvpGetUserProcessParams  get user inputs for the process
%
%   inputs:
%       
%       pix_adj: pixel size of adjusted uvp
%       esd_min: min de la gamme de taille
%       esd_max: max de la gamme de taille
%       Fit_data: degré du polynôme pour le fit
%
%   outputs:
%       process_params: struct to store process parameters

% ------------------- params user inputs  ---------------------------------

% user's aa and exp for uvp6

users_aa = 2300;
users_exp = 1.1359;
set_aa_exp = 'n';


% startng value for aa and exp
X0=[0.55*pix_adj^2 1.1];

% degree of the polynome to fit

Fit_range=Fit_data;
fit_type = ['poly', num2str(Fit_data)];
Fit_range = ['poly',num2str(Fit_range)];

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