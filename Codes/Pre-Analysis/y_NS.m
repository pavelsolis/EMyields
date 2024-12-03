function yields = y_NS(params,maturities)
% This function returns a panel of zero yield curves implied by the
% Nelson-Siegel model for the specified maturities.
%
%     INPUTS
% double: params - matrix of parameters; rows: dates, cols: beta0, beta1, beta2, tau
% double: maturities - vector of maturities
%
%     OUTPUT
% double: yields - matrix of yields; rows: dates, cols: maturities
%
% Pavel Solís (pavel.solis@gmail.com), March 2019
%%
if size(maturities,2) == 1 ; maturities = maturities'; end  % Ensure maturities is a row vector

aux1   = maturities./params(:,4);
aux2   = exp(-aux1);
yields = params(:,1) + (params(:,2) + params(:,3)).*((1-aux2)./aux1) - params(:,3).*aux2;