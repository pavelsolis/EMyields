function yields = y_NSS(params,maturities)
% This function returns a panel of zero yield curves implied by the
% Nelson-Siegel-Svensson model for the specified maturities.
% m-files called: y_NS.m
%
%     INPUTS
% double: params - matrix of parameters; rows: dates, cols: beta0 to beta3, tau1, tau2
% double: maturities - vector of maturities
%
%     OUTPUT
% double: yields - vector of yields; rows: dates, cols: maturities
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
if size(maturities,2) == 1 ; maturities = maturities'; end  % Ensure maturities is a row vector

ylds_NS = y_NS(params(:,[1:3 5]),maturities);
aux3    = maturities./params(:,6);
aux4    = exp(-aux3);
yields  = ylds_NS + params(:,4).*((1-aux4)./aux3 - aux4);