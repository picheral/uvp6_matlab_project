%% ------------- Affichage Annuel AWI --------------
% Picheral 2019/12/24

fig1 = figure('numbertitle','off','name','UVP6_AWI','Position',[10 50 1300 900]);

% ---------------- Depth -----------------
subplot(2,1,1)
plot(AWIall.yyyymmddhhmm,AWIall.Depthm)
xlabel('Time','fontsize',12);
ylabel('Pressure (dB)','fontsize',12);

% ---------------- LPM -------------------
A = table2array(AWIall(:,4:13));
subplot(2,1,2)
plot(AWIall.yyyymmddhhmm,AWIall.Depthm)


for i = 2 : size(A,2)
    semilogy(AWIall.yyyymmddhhmm,A(:,i))
    hold on
end
xlabel('Time','fontsize',12);
ylabel('LPM ','fontsize',12);