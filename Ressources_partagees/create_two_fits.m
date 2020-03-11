function [fitresult1, gof1] = create_two_fits(x1,y1,fit_type1,plot_figure,x2,y2,fit_type2)
%CREATE_two_FITS(x1,y1,plot_figure,fit_type,x2,y2,fit_type2)
%  Create a fit for x1 and y1 data based on fit_type
%
%  inputs:
%       x1: X data input of first function to fit
%       y1: Y data output of first function to fit
%       fit_type1: fit type object for fiting x1,y1 data
%       plot_figure: if=1, plot fit1 and fit2 in two subplots (optional)
%       x2: X data input of second function to fit
%       y2: Y data output of second function to fit
%       fit_type2: fit type object for fiting x2,y2 data
%  Output:
%      fitresult1 : a fit object representing the first fit.
%      gof1 : structure with goodness-of first fit info.
%
%  See also FIT, CFIT, SFIT.

%% Fit1
[xData, yData] = prepareCurveData( x1, y1 );

% Set up fittype and options.
ft = fittype( fit_type1 );

% Fit model to data.
[fitresult1, gof1] = fit( xData, yData, ft );

%% Fit2
[xData2, yData2] = prepareCurveData( x2, y2 );

% Set up fittype and options.
ft = fittype( fit_type2 );

% Fit model to data.
[fitresult2, gof2] = fit( xData2, yData2, ft );

%% plot the two fits
if plot_figure == 1
    figure( 'Name', 'untitled fit 1' );
    subplot(1,2,1)
    h = plot( fitresult1, xData, yData );
    legend( h, 'ref', fit_type1, 'Location', 'NorthEast' );
    
    subplot(1,2,2)
    h = plot( fitresult2, xData2, yData2 );
    legend( h, 'to adj', fit_type2, 'Location', 'NorthEast' );
    grid on
end


