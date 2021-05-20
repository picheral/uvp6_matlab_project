
%% CARTE Mission
% Picheral 2015/11/16


function uvp5_main_process_2014_plot_cruise_map(base,results_dir)

load couleurs.mat;
scrsz = get(0,'ScreenSize');
cruise = base(1).cruise;
cruise_name = char(cruise);
g=findstr('_',cruise_name);
cruise_name(g) = ' ';
long = [];
latt = [];
for i = 1 : size(base,2)
    
    long(i,1) = base(i).longitude;
    latt(i,1) = base(i).latitude;
    long(i,2) = base(i).longitude;
    latt(i,2) = base(i).latitude;
end

lon_e = abs(max(long(:,1)) - min(long(:,1)));
latt_e = abs(max(latt(:,1)) - min(latt(:,1)));
range = 10;

if (lon_e < 5 || latt_e < 5) ; range = 5;end
if (lon_e < 1 || latt_e < 1) ; range = 2;end
if (lon_e < 0.5 || latt_e < 1) ; range = 1;end

% Trace de la carte
fig1=figure('numbertitle','off','name','UVPmap','Position',[10 50 scrsz(3)/4 scrsz(3)/4]);
set(gcf,'color','white');
ax=axes('NextPlot','add');
% Dimensions de la carte
% Dimensions automatiques
x=[range*floor(min(long(:,1))/range) range*ceil(max(long(:,1))/range)];
y=[max(range*floor(min(latt(:,1))/range),-89) min(range*ceil(max(latt(:,1))/range),89)];

if x(1) == x(2);
    x(1) = x(1) - 0.5;
    x(2) = x(2) + 0.5;
end
if y(1) == y(2);
    y(1) = y(1) - 0.5;
    y(2) = y(2) + 0.5;
end

m_proj('Mercator','longitudes',x,'latitudes',y);

if range > 5
%     m_gshhs_c('patch',[.7 .7 .7],'edgecolor','k','parent',ax);
    m_gshhs_l('patch',[0.5 0.5 0.5],'edgecolor','k')
    disp(['Coarse map :  [',num2str(x(1)),' ',num2str(x(2)),'] [',num2str(y(1)),' ',num2str(y(2)),']']);
else
%     m_gshhs_f('patch',[.7 .7 .7],'edgecolor','k','parent',ax);
    m_gshhs_f('patch',[0.5 0.5 0.5],'edgecolor','k')
    disp(['Detailled map :  [',num2str(x(1)),'-',num2str(x(2)),'] [',num2str(y(1)),'-',num2str(y(2)),']']);
end

set(gca,'color','none')
m_grid('box','fancy','parent',ax)
set(gca,'color','white')
%    m_tbase_cor('contour',sondes);
% Conversion des positions pour tracé sur la carte
[lon,lat]=m_ll2xy(long,latt);
[x,y]=m_ll2xy(x,y);
for i = 1 : size(base,2)
    rond2(i,1)=scatter(lon(i,1),lat(i,1),10,'r','filled');
end

xlabel(['CRUISE      ',cruise_name,'   [',num2str(size(base,2)),' profiles]'],'fontsize',13);
% ylabel('Latitude','fontsize',13);

% ------------- Sauvegarde figure ------------------------------------
orient landscape
saveas(fig1,[results_dir,char(cruise),'_map.png']);

