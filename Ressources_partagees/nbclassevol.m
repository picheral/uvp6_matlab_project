% calcul du Nombre et du BIOVOLUME TOTAL par classe

function [N,nbvol]=nbclasse(matrice,classes)

n=length(classes);

for i=1:n-1                                                     % D'une classe a la suivante
    trouve=find(matrice>=classes(i)&matrice<classes(i+1));
    N(i)=length(trouve);                                        % Nombre total dans la classe    
    nbvol(i)=sum(matrice(trouve));                                 % Biovolume total pour la classe
end

