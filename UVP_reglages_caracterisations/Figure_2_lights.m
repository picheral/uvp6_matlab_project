%% Figure images 2 lights
%% Picheral 2017/12/11

function Figure_2_lights(base1,base2,date_vue,drive_root,uvp5sn,light_1,light_2)

scrsz = get(0,'ScreenSize');
% --------------- Fichiers DATA Verrines et UVP5 ---------------------
fid_v1 = fopen([drive_root,'\',date_vue,'_light_',light_1,'.txt'],'w');
fid_v2 = fopen([drive_root,'\',date_vue,'_light_',light_2,'.txt'],'w');

fig = figure('name','Eclairages UVP5','Position',[50 50 scrsz(3)/1.2 scrsz(4)-200]);
for gg=1:numel(base1)
    subplot(2,numel(base1),gg)
    matr = base1(gg).median;
    imagesc(base1(gg).median,[0 255])
    m=round(max(max(matr)));
    n=round(min(min(matr)));
    title(['Ecl #1 : (' num2str(n) '-' num2str(m) ')']);
    fprintf(fid_v1,'%s\r',[num2str(gg),';',num2str(n),';',num2str(m)]);
end
fclose(fid_v1);

for gg=1:numel(base1)
    subplot(2,numel(base1),gg+numel(base2))
    matr = base2(gg).median;
    imagesc(base2(gg).median,[0 255])
    m=round(max(max(matr)));
    n=round(min(min(matr)));
    title(['Ecl #2 : (' num2str(n) '-' num2str(m) ')']);
    fprintf(fid_v2,'%s\r',[num2str(gg),';',num2str(n),';',num2str(m)]);
end
fclose(fid_v2);
set (gcf,'PaperPosition',[0 0 70 30]);
saveas(fig, [drive_root,char(uvp5sn), '_images.png']);