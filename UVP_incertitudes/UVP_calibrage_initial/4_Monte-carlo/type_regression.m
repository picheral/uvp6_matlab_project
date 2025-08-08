function [Aa, expo,Radjusted,conf] = type_regression(modele_ponderation, modele_robuste,lettre, A_uvp_px, A_bino_mm2,N,Nb_obs)
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



%% type_regression :

Aa = zeros(1,N);
expo = zeros(1,N);
Radjusted = zeros(1,N);


switch lettre
    case 'A'
        
        % fit puissance
        %
        % Variable explicative : A_uvp_px
        % Variable à expliquer : A_bino_mm2
        %
        % Aa et exp sont les outputs directs du fit
        
        for i=1:N  
            [res,gof,output]= fit_power(A_uvp_px(:,i),A_bino_mm2(:,i),Nb_obs,modele_ponderation, modele_robuste);
            Aa(i)=res.a;
            expo(i)=res.b;
            Radjusted(i)=gof.adjrsquare;
            temp = confint(res);
            conf_b_aa(i,:) = temp(:,1);
            conf_b_exp(i,:) = temp(:,2);
        end
        conf = table(conf_b_aa,conf_b_exp);

    case 'B'
        %
        % fit puissance
        %
        % Variable explicative :  A_bino_mm2
        % Variable à expliquer : A_uvp_px
        %
        % Aa et exp sont trouvés grâce à un système linéaire réalisé à partir des outputs du fit 

        for i=1:N  
            [res,gof,output]= fit_power(A_bino_mm2(:,i),A_uvp_px(:,i),Nb_obs,modele_ponderation, modele_robuste);
            Aa(i)=(1/res.a)^(1/res.b);
            expo(i)=1/res.b;
            Radjusted(i)=gof.adjrsquare;
            temp = confint(res);
            conf_b_aa(i,:) = temp(:,1);
            conf_b_exp(i,:) = temp(:,2);
        end
        conf = table(conf_b_aa,conf_b_exp);

        case 'C'
        %
        % fit lineaire loglog
        %
        % Variable explicative :  A_bino_mm2
        % Variable à expliquer : A_uvp_px
        %
        % Aa et exp sont trouvés grâce à un système réalisé à partir des outputs du fit 

        for i=1:N  
            [res,gof,output]= fit_linear(log(A_bino_mm2(:,i)),log(A_uvp_px(:,i)),Nb_obs,modele_ponderation, modele_robuste);     
            Aa(i)=1/exp(res.p2/res.p1);
            expo(i)=1/res.p1;
            Radjusted(i)=gof.adjrsquare;
            temp = confint(res);
            conf_b_aa(i,:) = temp(:,1);
            conf_b_exp(i,:) = temp(:,2);
        end
        conf = table(conf_b_aa,conf_b_exp);

        case 'D'
        %
        % fit lineaire loglog
        %
        % Variable explicative : A_uvp_px
        % Variable à expliquer : A_bino_mm2 
        %
        % Aa et exp sont trouvés grâce à un système réalisé à partir des outputs du fit 

        for i=1:N  
            [res,gof,output]= fit_linear(log(A_uvp_px(:,i)),log(A_bino_mm2(:,i)),Nb_obs,modele_ponderation, modele_robuste);
            Aa(i)=exp(res.p2);
            expo(i)=res.p1;
            Radjusted(i)=gof.adjrsquare;
            temp = confint(res);
            conf_b_aa(i,:) = temp(:,1);
            conf_b_exp(i,:) = temp(:,2);
        end
        conf = table(conf_b_aa,conf_b_exp);

end