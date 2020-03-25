% Construction d'un verteur à pas variable pour les histogrammes (ves)
% Construction d'un vesteur mesurant la taille des intervals entre les valeurs extremes (new)
% Construction d'un vecteur avec les valeurs médianes des pas (med)

function [ves,new,med,minor,maxor,step]=pasvarred


% minor=3*10^-4;                                          % Calcul du volume minimum des objet de la caméra 0
% Modif du 20 juin 2005
minor=7.5*10^-5;                                          % Calcul du volume minimum des objet de la caméra 0
maxor=7*10^3;                                           % Calcul du volume maximal des objet de la caméra 1
stepred=(2^(3*1.61/2));
step=stepred;
ves=minor;
n=maxor;
for i=2:n
    ves(i)=step*ves(i-1);
    if ves(i)>maxor
        break
    end
end

ves; 
h=length(ves);
sous=[ves(:,2:end)];
new=sous-ves(1:h-1);

for i=1:h-1
    med(i)=(ves(i)+ves(i+1))/2;
end