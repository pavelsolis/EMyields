function S = forecast_cbpol(S,currEM)
% FORECAST_CBPOL Estimate policy rate forecasts using forecasts for inflation
% and real GDP growth from Consensus Economics and weights from a Taylor rule
%
%	INPUTS
% struct: S    - contains names/codes (for countries/currencies), YC data
% char: currEM - ISO currency codes for EMs in the sample
%
%	OUTPUT
% struct: S - includes estimated forecasts for the policy rates of EMs

% m-files called: read_macrovars, estimate_TR, read_surveys
% Pavel Solís (pavel.solis@gmail.com), May 2020
%%
[data_macro,hdr_macro]  = read_macrovars(S);                                % macro and policy rates
[S,weightsTR,namesWgts] = estimate_TR(S,currEM,data_macro,hdr_macro);       % estimate Taylor Rule
[data_svys,hdr_svys]    = read_surveys();                                   % CPI and GDP forecasts

tenors  = cellfun(@str2double,regexp(hdr_svys,'\d*','Match'),'UniformOutput',false); % tenors in hdr_svys
fltrSVY = ~contains(hdr_svys,'00Y');                                        % exclude current year
fltrCON = contains(namesWgts,'Intercept');                                  % in case order in namesWgts changes
fltrINF = contains(namesWgts,'INF');
fltrGDP = contains(namesWgts,'GDP');
nEMs    = length(currEM);
for k = 1:nEMs
    bCON = weightsTR(fltrCON,S(k).imf == weightsTR(1,:));                   % identify coefficients for country
    bINF = weightsTR(fltrINF,S(k).imf == weightsTR(1,:));
    bGDP = weightsTR(fltrGDP,S(k).imf == weightsTR(1,:));
    
    fltrCTY   = contains(hdr_svys,{S(k).iso,'DATE'}) & fltrSVY;             % include dates
    macrodata = data_svys(:,fltrCTY);                                       % extract variables
    macroname = hdr_svys(fltrCTY);                                          % extract headers
    macrotnr  = unique(cell2mat(tenors(fltrCTY)));                          % extract unique tenors as doubles
    
    macroINF = macrodata(:,contains(macroname,'CPI'));                      % inflation for all survey tenors
    macroGDP = macrodata(:,contains(macroname,'GDP'));                      % GDP for all survey tenors
    macroCBP = bCON + bINF*macroINF + bGDP*macroGDP;                        % policy rate for all survey tenors
    fltrMSS  = sum(isnan(macroCBP),2) == size(macroCBP,2);                  % rows w/ missing data
    S(k).svycbp = [nan macrotnr;                                            % add survey tenors in first row
                macrodata(~fltrMSS,1) macroCBP(~fltrMSS,:)];                % keep dates w/ actual data
end