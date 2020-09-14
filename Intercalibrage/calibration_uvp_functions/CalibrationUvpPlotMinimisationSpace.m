function CalibrationUvpPlotMinimisationSpace(ref_cast, adj_cast, datahistref, aa_adj, expo_adj, fit_type, ref_esd_calib_log)
%CalibrationUvpPlotMinimisationSpace plot the 2D minimisation space and the
%optimal point
%
%   inputs:
%       ref_cast : struct storing computed variables from ref uvp
%       adj_cast : struct storing computed variables from adj uvp
%       datahistref : fited ref abundance
%       aa_adj : aa parameters of size intercalibration of adj uvp
%       expo_adj : expo parameters of size intercalibration of adj uvp
%       fit_type : type of function (polinomial degree) used for fit
%       ref_esd_calib_log : log de l'esd calibré de ref ou mean ref
%

%% MINIMISATION space
results=[];
AAs=[];
expss=[];
if (strcmp(adj_cast.project_folder(4:7),'uvp5'))
    mini_min = 0.0005;
    mini_max = 0.010;
    maxe = 1.5;
else  
    mini_min = 0.0002;
    mini_max = 0.010;   
    maxe = 1.7;
end

for i=mini_min:0.0005:mini_max
    result=[];
    aas=[];
    exps=[];
    for j=1:0.025:maxe
        X2=[i j];
        res=histofunction7_new(X2,datahistref, adj_cast.pixsize, adj_cast.histo_mm2_vol_mean, ref_esd_calib_log, fit_type);
        if (isinf(res)|| res < 0); res = NaN; end
        result=[result res];
        aas=[aas i];
        exps=[exps j];
    end
    results=[results;result];
    AAs=[AAs;aas];
    expss=[expss;exps];
end


%% Figure minimisation
fig3 = figure('name','Minimisation','Position',[250 50 400 400]);
figure(fig3);
pcolor(AAs,expss,log(results))
shading flat
xlabel('Aa','fontsize',16);
ylabel('exp','fontsize',16);
colormap(jet(256))
h=colorbar;
h.Label.String = 'Log (Sum of least square)';
figure(fig3);
hold on
plot(aa_adj,expo_adj,'mo');
hold on
plot(aa_adj,expo_adj,'m+');
title(['Minimisation landscape'],'fontsize',14);
orient tall


%% ---------------------- Save figure --------------------------------------
titre = ['Minimisation_landscape_' char(ref_cast.profilename)];
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[ref_cast.results_dir,'\',datestr(now,30),'_',char(titre)]);

end

