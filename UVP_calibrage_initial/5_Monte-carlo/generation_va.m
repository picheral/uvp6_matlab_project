function X = generation_va(var,loi,N,donnees_uvp, donnees_bino,j) 
%% 
% generation_va(loi,N,par1,par2) 
%
% Génération de variables aléatoires iid
%
%  Données pour 'generation_va' :
%       Input : 
%            var : variable aléatoire à simuler
%            loi : nom de la loi (uniforme ou normale)
%            N : nombre de variables iid à créer
%            donnees_uvp : table avec les data uvp 
%            donnees_bino : table avec les data bino
%            j : numéro de la particule 
%               
%      Output : 
%            X : vecteur composé des variables aléatoires iid
%    
%
% Blandine JACOB - 20 mai 2022

%% 

%initialisation vecteur
X=zeros(N,1);

switch var
   

   %génération d'un N-échantillon de la variable aléatoire a_bino_px
   case 'a_bino_px'

        switch loi

            %cas où on fait l'hypothèse que a_bino_px suit une loi normale
            case 'normale'
                for i=1:N
                    r = rand(1,1);
                    u=rand(1,1);
                    X(i) = sqrt(-2*log(r))*cos(2*pi*u) ; % algorithme de Box-Muller pour simuler vecteur iid de loi centrée réduite
                    mu = donnees_bino.Area_bino_px(j);
                    sigma = (0.03*donnees_bino.Area_bino_px(j))/3 ;
                    X(i) = sigma*X(i) + mu ; %si la loi n'est pas centrée réduite
                end
            
           %cas où on fait l'hypothèse que a_bino_px suit une loi uniforme
            case 'uniforme'
                a = donnees_bino.Area_bino_px(j) - 0.03*donnees_bino.Area_bino_px(j);
                b = donnees_bino.Area_bino_px(j) + 0.03*donnees_bino.Area_bino_px(j);
                for i=1:N
                    X(i) = a + (b-a)*rand(1,1); %rand : générateur de loi uniforme
                end
        end



   %génération d'un N-échantillon de la variable aléatoire L_ref
    case 'L_ref'

        switch loi
            case 'normale'
                for i=1:N
                    r = rand(1,1);
                    u= rand(1,1);
                    X(i) = sqrt(-2*log(r))*cos(2*pi*u) ; % algorithme de Box-Muller pour simuler vecteur iid de loi centrée réduite
                    mu = donnees_bino.Lref(j);
                    sigma =  0.05/3 ;
                    X(i) = sigma*X(i) + mu ; %si la loi n'est pas centrée réduite
                end

            case 'uniforme'
                a = donnees_bino.Lref(j) - 0.05;
                b = donnees_bino.Lref(j) + 0.05;
                for i=1:N
                    X(i) = a + (b-a)*rand(1,1); %rand : générateur de loi uniforme
                end
        end
    


    %génération d'un N-échantillon de la variable aléatoire n_px
    case 'n_px'

        switch loi
            case 'normale'
                for i=1:N
                    r = rand(1,1);
                    u = rand(1,1);
                    X(i) = sqrt(-2*log(r))*cos(2*pi*u) ; % algorithme de Box-Muller pour simuler vecteur iid de loi centrée réduite
                    mu = donnees_bino.npx(j);
                    sigma = sqrt(10)/3;
                    X(i) = sigma*X(i) + mu ; %si la loi n'est pas centrée réduite
                end
                
            case 'uniforme'
                a = donnees_bino.npx(j) - sqrt(10);
                b = donnees_bino.npx(j) + sqrt(10);
                for i=1:N
                    X(i) = a + (b-a)*rand(1,1); %rand : générateur de loi uniforme
                end
        end

    
     %génération d'un N-échantillon de la variable aléatoire uvp_px suivant
     %une loi normale
    case 'uvp_px'
        
        for i=1:N
            X(i)= -1 ;
            while X(i)<=0;
                r = rand(1,1);
                u=rand(1,1);
                X(i) = sqrt(-2*log(r))*cos(2*pi*u) ; % algorithme de Box-Muller pour simuler vecteur iid de loi centrée réduite
                mu = donnees_uvp.Area_moy(j);
                sigma = donnees_uvp.std(j);
                X(i) = sigma*X(i) + mu ;
            end 
        end

end

