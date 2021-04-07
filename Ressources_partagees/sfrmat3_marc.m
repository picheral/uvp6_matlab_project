% MatLab function: sfrmat3   Slanted-edge Analysis for digital camera and scanner
%                            evaluation. Updated version of sfrmat2.
%  [status, dat, fitme, esf, nbin, del2] = sfrmat3(io, del, weight, a, oecfname);
%       From a selected edge area of an image, the program computes
%       the ISO slanted edge SFR. Input file can be single or
%       three-record file. Many image formats are supported. The image
%       is displayed and a region of interest (ROI) can be chosen, or
%       the entire field will be selected by not moving the mouse
%       when defining an ROI (simple click). Either a vertical or horizontal
%       edge features can be analized.
%
% Returns:
%       status = 0 if normal execution
%       dat = computed sfr data
%       fitme = coefficients for the linear equations for the fit to
%               edge locations for each color-record. For a 3-record
%               data file, fitme is a (4 x 3) array, with the last column
%               being the color misregistration value (with green as
%               reference).
%       esf = supersampled edge-spread functin array
%       nbin = binning factor used
%       del2 = sampling interval for esf, from which the SFR spatial
%              frequency sampling is was computed. This will be
%              approximately  4  times the original image sampling.
%
%Author: Peter Burns, 24 July 2009
%                     12 May 2015  updated legend title to be compatible
%                     with current Matlab version (legendTitle.m)
% Copyright (c) 2009-2015 Peter D. Burns, pdburns@ieee.org
%******************************************************************
% Modifié Picheral, 2017/10/28

function [e, nfreq, esf,freqval, sfrval] = sfrmat3_marc(filename,image_crop,del,plot_figure) %io, del, weight, a, oename)

status = 0;
defpath = path;            % save original path
home = pwd;                % add current directory to path
addpath(home);
name =    'sfrmat3';
version = '2.0';
when =    '12 May 2015';

%ITU-R Recommendation  BT.709 weighting
guidefweight =  ['0.213'
    '0.715'
    '0.072'];
%Previously used weighting
defweight = [0.213   0.715   0.072];

oecfdatflag = 0;
oldflag = 0;
nbin = 4;

sflag = 0;
pflag=0;

% -------- CAs appel par fonction MTF LOV -----------
io =0;
weight = guidefweight;
oename = 'none';
funit = 'cy/mm';
smax = 255;
a = double(image_crop);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Suppresses interpreting of e.g. filenames
set(0, 'DefaultTextInterpreter', 'none');

[nlin npix ncol] = size(a);

[a, nlin, npix, rflag] = rotatev2(a);  %based on data values

loc = zeros(ncol, nlin);

fil1 = [0.5 -0.5];
fil2 = [0.5 0 -0.5];
% We Need 'positive' edge
tleft  = sum(sum(a(:,      1:5,  1),2));
tright = sum(sum(a(:, npix-5:npix,1),2));
if tleft>tright;
    fil1 = [-0.5 0.5];
    fil2 = [-0.5 0 0.5];
end
% Test for low contrast edge;
test = abs( (tleft-tright)/(tleft+tright) );
if test < 0.2;
    disp(' ** WARNING: Edge contrast is less that 20%, this can');
    disp('             lead to high error in the SFR measurement.');
end;

fitme = zeros(ncol, 3);
slout = zeros(ncol, 1);

% Smoothing window for first part of edge location estimation -
%  to be used on each line of ROI
win1 = ahamming(npix, (npix+1)/2);    % Symmetric window

color=1;                % Loop for each color
    %%%%
    c = deriv1(a(:,:,color), nlin, npix, fil1);
    
    % compute centroid for derivative array for each line in ROI. NOTE WINDOW array 'win'
    for n=1:nlin
        loc(color, n) = centroid( c(n, 1:npix )'.*win1) - 0.5;   % -0.5 shift for FIR phase
    end;
    % clear c
    
    fitme(color,1:2) = findedge(loc(color,:), nlin);
    place = zeros(nlin,1);
    for n=1:nlin;
        place(n) = fitme(color,2) + fitme(color,1)*n;
        win2 = ahamming(npix, place(n));
        loc(color, n) = centroid( c(n, 1:npix )'.*win2) -0.5;
    end;
    
    fitme(color,1:2) = findedge(loc(color,:), nlin);
summary{1} = ' '; % initialize

if oldflag ~= 1;
    %   disp(['Input lines: ',num2str(nlin)])
    nlin1 = round(floor(nlin*abs(fitme(1,1)))/abs(fitme(1,1)));
    %   disp(['Integer cycle lines: ',num2str(nlin1)])
    a = a(1:nlin1, :, 1:ncol);
end
%%%%
vslope = fitme(1,1);
slope_deg= 180*atan(abs(vslope))/pi;
% disp(['Edge angle: ',num2str(slope_deg, 3),' degrees'])
if slope_deg < 3.5
%     disp(['WARNING : Edge angle < 3.5 ° : ',num2str(slope_deg, 3),' degrees'])
%     disp('angle');
end
%%%%
del2=0;
if oldflag ~= 1;
    %Correct sampling inverval for sampling parallel to edge
    delfac = cos(atan(vslope));
    del = del*delfac;
    del2 = del/nbin;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ns = length(summary);
summary{ns+1} = [del, del2];

nn =   floor(npix *nbin);
mtf =  zeros(nn, ncol);
nn2 =  floor(nn/2) + 1;

if oldflag ~=1;
%     disp('Derivative correction')
    dcorr = fir2fix(nn2, 3);    % dcorr corrects SFR for response of FIR filter
end

freq = zeros(nn, 1);
for n=1:nn;
    freq(n) = nbin*(n-1)/(del*nn);
end;

freqlim = 1;
if nbin == 1;
    freqlim = 2;
end
nn2out = round(nn2*freqlim/2);

nfreq = n/(2*del*nn);    % half-sampling frequency

nfreq4= n/(4*del*nn);

win = ahamming(nbin*npix,(nbin*npix+1)/2);      % centered Hamming window


% **************                      Large SFR loop for each color record
esf = zeros(nn,ncol);

% project and bin data in 4x sampled array
[point, status] = project(a(:,:,color), loc(color, 1), fitme(color,1), nbin);

esf(:,color) = point;
%---------------------------------------------------
%la variable 'point' n'est autre que la esf
%---------------------------------------------------
% compute first derivative via FIR (1x3) filter fil
c = deriv1(point', 1, nn, fil2); %%ignore edge effects, preserve size
c = c';
%---------------------------------------------------
%la variable 'c' est la psf
%---------------------------------------------------
psf(:,color) = c;
mid = centroid(c);
temp = cent(c, round(mid));              % shift array so it is centered
c = temp;
clear temp;

% apply window (symmetric Hamming)
c = win.*c;

%%%%
% Transform, scale and correct for FIR filter response

temp = abs(fft(c, nn));
mtf(1:nn2, color) = temp(1:nn2)/temp(1);
if oldflag ~=1;
    mtf(1:nn2, color) = mtf(1:nn2, color).*dcorr;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


dat = zeros(nn2out, ncol+1);
for i=1:nn2out;
    dat(i,:) = [freq(i), mtf(i,:)];
end;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Sampling efficiency
%Values used to report: note lowest (10%) is used for sampling efficiency
val = [0.1, 0.5];
[e, freqval, sfrval] = sampeff(dat, val, del, 0, 0); %efficacité d'echantillonnage
%avec    dat   = SFR/MTF data
%        del = sampling interval in mm (le pitch=1 pixel)
%        e = efficiency based on first value
%        freqval = frequency values corresponding to val
%        sfrval = sfr values for freqval
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ns = length(summary);
summary{ns+1} = e;

% Plot SFRs on same axes

ttext = filename;
sym{1} = 'k';

%% ------------ Tracé optionnel de la figure ---------------------
if plot_figure == 1
    screen = get(0, 'ScreenSize');
    pos = round(centerfig(1, 0.6,0.6));
    
    %%%%%%%%%%%%%%%%%%%
    nn4 =  floor(nn/8) + 1;
    cc = [.5 .5 .8];
    
    figure('Position',pos)
    plot( freq( 1:nn2out), mtf(1:nn2out, 1), sym{1});
    hold on;
    title(ttext);
    xlabel(['     Frequency, ', funit]);
    ylabel('SFR');
    
    h = legend([num2str(e),'%']);
    get(h,'Position');
    pos1 =  get(h,'Position');
    set(h,'Position', [0.97*pos1(1) 0.93*pos1(2) pos1(3) pos1(4)])
    hTitle = legendTitle (h, 'Sampling Efficiency');
    line([nfreq ,nfreq],[.05,0]);
    
    text(.95*nfreq,+.08,'Half-sampling'),
    
    hold off;
    axis([0 freq(round(0.75*nn2out)),0,max(max(mtf))]);
    
    drawnow
end

