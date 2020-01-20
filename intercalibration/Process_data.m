%% Process 

function [y] = Process_data(x,fitresult,fit_type)
if strcmp(fit_type,'poly1')
        y = (fitresult.p1*x + fitresult.p2);
elseif strcmp(fit_type,'poly2')
        y = (fitresult.p1*x.^2 + fitresult.p2*x + fitresult.p3);
elseif strcmp(fit_type,'poly3')
        y = (fitresult.p1*x.^3 + fitresult.p2*x.^2 + fitresult.p3*x + fitresult.p4);
elseif strcmp(fit_type,'poly4')
        y = (fitresult.p1*x.^4 + fitresult.p2*x.^3 + fitresult.p3*x.^2 + fitresult.p4*x + fitresult.p5);
elseif strcmp(fit_type,'poly5')
        y = (fitresult.p1*x.^5 + fitresult.p2*x.^4 + fitresult.p3*x.^3 + fitresult.p4*x.^2 + fitresult.p5*x + fitresult.p6);
elseif strcmp(fit_type,'poly6')       
    y = (fitresult.p1*x.^6 + fitresult.p2*x.^5 + fitresult.p3*x.^4 + fitresult.p4*x.^3 + fitresult.p5*x.^2 + fitresult.p6*x + fitresult.p7);
end