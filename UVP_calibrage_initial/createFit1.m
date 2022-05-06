function [fitresult, gof] = createFit1(X, Y, poids)
%CREATEFIT1(X,Y,POIDS)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input: X
%      Y Output: Y
%      Weights: poids
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 29-Apr-2022 09:41:28


%% Fit: 'untitled fit 1'.
[xData, yData, weights] = prepareCurveData( X, Y, poids );

% Set up fittype and options.
ft = fittype( 'power1' );
excludedPoints = excludedata( xData, yData, 'Indices', [53 80] );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Robust = 'LAR';
opts.StartPoint = [0.0556302918341509 0.665659567483676];
opts.Weights = weights;
opts.Exclude = excludedPoints;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData, excludedPoints, 'predobs' );
legend( h, 'Y vs. X with poids', 'Excluded Y vs. X with poids', 'untitled fit 1', 'Lower bounds (untitled fit 1)', 'Upper bounds (untitled fit 1)', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'X', 'Interpreter', 'none' );
ylabel( 'Y', 'Interpreter', 'none' );
grid on


