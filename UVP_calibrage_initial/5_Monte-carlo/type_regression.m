function [Aa, expo,Radjusted] = type_regression(lettre, A_uvp_px, A_bino_mm2,N)
%% 
% type_regression(lettre,A_uvp_px,A_bino_mm2,N) 
%
% Effectue N régressions sur les données A_uvp_px, A_bino_mm2
%
%  Données pour 'generation_va' :
%       Input : 
%           lettre : correspond à un type de régression souhaitée
%           N : nombre de régression à créer
%            par1, par2 :  si loi uniforme =(a,b) si loi normale
%            =(nu,sigma)
%           A_uvp_px : mesure d'aire UVP, en pixel
%           A_bino_mm2 : mesure d'aire bino, en mm2 
%               
%      Output : 
%           Aa : vecteur contenant les N Aa des N fits
%           expo : vecteur contenant les N exp des N fits
%    
%
% Blandine JACOB - 20 mai 2022

%% ajout du chemin pour les fonctions fit

addpath('C:\Users\Blandine\Documents\MATLAB\uvp6_matlab_project\UVP_calibrage_initial\3_creation_fit');

%% type_regression :

switch lettre
    case 'A'
        
        % fit puissance
        %
        % Variable explicative : A_uvp_px
        % Variable à expliquer : A_bino_mm2
        %
        % Aa et exp sont les outputs directs du fit
        
        for i=1:N  
            [res,gof]= fit_power(A_uvp_px(:,i),A_bino_mm2(:,i));
            Aa(i)=res.a;
            expo(i)=res.b;
            Radjusted(i)=gof.adjrsquare;
        end

    case 'B'
        %
        % fit puissance
        %
        % Variable explicative :  A_bino_mm2
        % Variable à expliquer : A_uvp_px
        %
        % Aa et exp sont trouvés grâce à un système linéaire réalisé à partir des outputs du fit 

        for i=1:N  
            [res,gof]= fit_power(A_bino_mm2(:,i),A_uvp_px(:,i));
            Aa(i)=(1/res.a)^(1/res.b);
            expo(i)=1/res.b;
            Radjusted(i)=gof.adjrsquare;
        end

    case 'C'

        % passage en log et fit linéaire
        %
        % Variable explicative : A_uvp_px
        % Variable à expliquer : A_bino_mm2
        %
        % Aa et exp sont déterminés grâce aux outputs du fit

        for i=1:N  
            [res,gof]= fit_linear(log(A_uvp_px(:,i)),log(A_bino_mm2(:,i)));
            Aa(i)= exp(res.p2);
            expo(i)=res.p1;
            Radjusted(i)=gof.adjrsquare;
        end
       

    case 'D'

        % passage en log et fit linéaire
        %
        % Variable explicative : A_bino_mm2
        % Variable à expliquer : A_uvp_px
        %
        % Aa et exp sont déterminés grâce aux outputs du fit

         for i=1:N  
            [res,gof]= fit_linear(log(A_bino_mm2(:,i)),log(A_uvp_px(:,i)));
            Aa(i)= exp(-res.p2/res.p1);
            expo(i)=1/res.p1;
            Radjusted(i)=gof.adjrsquare;
        end
end
