%---------------------------2019/11/07-----------------------------
%---------------------------- Camille Catalano --------------------
%GET_LINES_INDICES compute the indices of analysed lines for overexposition
%depending on a specified interval
% in an square array, place a line at the center. Then places lines
% bellow and above separated by lines_interval
% return : i_lines = list of lines indices
%%
function i_lines = get_lines_indices(array_size, lines_interval)
    middle_indice = round(array_size/2);
    inf_ilines = middle_indice : - (lines_interval+1) : 0;
    inf_ilines = flip(inf_ilines);
    sup_ilines = middle_indice : lines_interval+1 : array_size;
    i_lines = [inf_ilines sup_ilines(2:end)];
end