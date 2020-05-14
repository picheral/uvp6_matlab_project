function EC=histofunction7_new(X, datahistref, pixsize_adj, adj_histo_mm2_vol_mean, ref_esd_calib_log, fit_type)

warning('off')
aa=X(1);
expo=X(2);
camsm=2*((aa*(pixsize_adj.^expo)./pi).^0.5);

% ----------- Limitation des tailles -----------------
% rr = find(camsm <= esd_max);

% disp(['Aa = ',num2str(aa),'  Exp = ',num2str(expo)]);
% camsm_log =log(camsm(rr));
% adj_histo_mm2_vol_mean_log = log(adj_histo_mm2_vol_mean(rr));
camsm_log =log(camsm);
adj_histo_mm2_vol_mean_log = log(adj_histo_mm2_vol_mean);

if sum(isfinite(camsm_log))>6
    [fitresult gof]=create_two_fits(camsm_log,adj_histo_mm2_vol_mean_log,fit_type,0,camsm_log,adj_histo_mm2_vol_mean_log,fit_type);
    [datahist] = poly_from_fit(ref_esd_calib_log,fitresult,fit_type);
    %EC=(abs(exp(datahist)-exp(datahistref))./(exp(datahistref))).^2;    % 3.47
%     EC=(abs(exp(datahist)-exp(datahistref))./(exp(datahistref)).^EC_factor).^2;
%     EC=(abs(datahist-datahistref)./(datahistref + 4).^EC_factor).^2; % Le meilleur ! 1.89
    %EC=nansum(EC);
    EC = data_similarity_score(exp(datahist), exp(datahistref));
else
    EC = NaN;
end
