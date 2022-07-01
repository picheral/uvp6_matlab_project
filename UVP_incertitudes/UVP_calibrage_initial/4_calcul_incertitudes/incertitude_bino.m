function u_bino = incertitude_bino(data_bino)
%INCERTITUDE_UVP Summary of this function goes here
%   Detailed explanation goes here

data = readtable('Z:\UVP_incertitudes\calibrage_initial_2016\Original_data\calibrage_aquarium_sn203_20160322.xlsx','sheet','incertitude_bino');
u_bino = data(:,18);

end

