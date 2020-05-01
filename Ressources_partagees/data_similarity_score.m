function [similarity_score] = data_similarity_score(data,data_ref, optional_score_type)
%DATA_SIMILARITY_SCORE compare two set of data
%   compare two set of data computing a similarity score
%
% inputs :
%   data : experimental data to compare [array of number]
%   data_ref : reference data to compare to [array of number]
%   optional_score_type : way to compute the score (optional).
%   Default='relative_error'
%
% output :
%   similarity_score : computed similarity score [float]
%
if nargin > 2
  score_type = optional_score_type;
else
  score_type = 'relative_error_norm';
end
if strcmp(score_type, 'relative_error_norm')
    similarity_score = relative_error_norm(data, data_ref);
elseif strcmp(score_type, 'relative_error')
    similarity_score = relative_error(data, data_ref);
else
    disp('ERROR : similarity score type not reconized !')
end
end


function rel_err_score = relative_error(data, data_ref)
%RELATIVE_ERROR compute relative error score
%   compute the similarity score between data and data_ref, summing the
%   squared relative errors
%
% inputs:
%   data : experimental data to compare [array of number]
%   data_ref : reference data to compare to [array of number]
%
% output:
%   rel_err_score : squared relative error score [float]
%
data_score = (abs(data-data_ref)./(data_ref)).^2;
rel_err_score = nansum(data_score);
end


function rel_err_norm_score = relative_error_norm(data, data_ref)
%RELATIVE_ERROR_norm compute normalized relative error score
%   compute the similarity score between data and data_ref, summing the
%   squared relative errors and normalized by the number of points
%
% inputs:
%   data : experimental data to compare [array of number]
%   data_ref : reference data to compare to [array of number]
%
% output:
%   rel_err_norm_score : normalized squared relative error score [float]
%
data_score = (abs(data-data_ref)./(data_ref)).^2;
rel_err_norm_score = nansum(data_score) / length(data_score);
end
