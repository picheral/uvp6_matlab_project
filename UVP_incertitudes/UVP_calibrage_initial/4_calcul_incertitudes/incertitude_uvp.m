function u_uvp = incertitude_uvp(pathname)
%INCERTITUDE_UVP Summary of this function goes here
%   Detailed explanation goes here

load('resultats.dat');

u_uvp = results.ecart_type / results.nombre_observations ;

end

