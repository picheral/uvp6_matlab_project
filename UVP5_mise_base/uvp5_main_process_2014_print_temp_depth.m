%% Chargement des données DATFILE dans base UVP5
% Picheral, 2017/03


function base = uvp5_main_process_2014_print_temp_depth(base,results_dir)
scrsz = get(0,'ScreenSize');
fig = figure('numbertitle','off','name',strcat('UVP5_',char(base(1).profilename)),'Position',[10 50 scrsz(3)/2.2 scrsz(4)-150]);
titre=([char(base(1).cruise)]);

%% ---------- Plot Temp versus depth ----------------
subplot(2,1,1)
gg = find(titre == '_');
titre(gg) = ' ';
min_temp = 30;
max_depth = 0;
for i=1 : size(base,2)
    % Trace du profil de descente
    if isfield(base(i).datfile,'temp_interne')
        min_temp = min(min_temp,min(base(i).datfile.temp_interne));
        max_depth = max(max_depth,max(base(i).datfile.pressure));
        hh=plot(base(i).datfile.temp_interne,-base(i).datfile.pressure,'b');
        hold on
    end
end
xlabel(['UVP internal temperature'],'fontsize',12);
ylabel(['Pressure (dbars)'],'fontsize',12);
text(min_temp,max_depth*.05,titre,'fontsize',15);


subplot(2,1,2)
%% ------------------ Plot Tint versus Tctd ---------------------
for i = 1 : size(base,2)
    % -------- Existence des données DATFILE -------------
    if isfield(base(i),'datfile')
        if isfield(base(i).datfile,'temp_interne')
            % --------- Existence des données CTD normalized ------------
            if isfield(base(i),'ctdrosettedata_normalized')
                if ~isempty(base(i).ctdrosettedata_normalized)
                    % ---------- On peut travailler !!!! -----
                    oo = dsearchn(base(i).datfile.pressure,base(i).ctdrosettedata_normalized.data(:,28));
                    plot(base(i).ctdrosettedata_normalized.data(:,28),base(i).datfile.temp_interne(oo),'k+');
                    hold on
                end
            end
        end
    end
end

% -------------- Enregistrement --------------------
xlabel(['CTD WATER temperature (°C)'],'fontsize',12);
ylabel(['UVP INSIDE temperature (°C)'],'fontsize',12);
% ----------------- Sauvegarde IMAGE --------------------------------
orient tall
saveas(fig,[results_dir,'\',char(base(1).cruise) '_temperature.png']);
close(fig);

