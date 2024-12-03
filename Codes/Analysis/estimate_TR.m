function [S,weightsLT,namesWgts,outputLT,outputTR] = estimate_TR(S,currEM,data_macro,hdr_macro)
% ESTIMATE_TR Estimate a Taylor rule for each emerging market (EM)
%
%	INPUTS
% struct: S    - contains names of countries/currencies, codes and YC data
% char: currEM - ISO currency codes of EMs in the sample
% double: data_macro - stores historical data
% cell: hdr_macro - stores headers
%
%	OUTPUT
% struct: S         - adds end-ofmonth and end-of-quarter macro variables for each EM
% double: weightsLT - coefficients to apply to LT inflation and output growth forecasts
% cell: namesWgts   - names of the coefficients
% cell: outputLT    - reports coefficients for LT inflation and output growth forecasts
% cell: outputTR    - reports coefficients for Taylor rules

% Pavel Solís (pavel.solis@gmail.com), May 2020
%%
nEMs     = length(currEM);
vars     = {'CCY','INF','UNE','IP','GDP','CBP'};                    % variables to save in structure S
fltrMAC  = ismember(hdr_macro(:,2),vars);
outputTR = cell(11,nEMs);	  outputLT  = cell(4,nEMs);
hdr_cty  = cell(nEMs,1);      weightsLT = nan(4,nEMs);

for k = 1:nEMs
    % Monthly and quarterly frequency
    fltrCTY       = ismember(hdr_macro(:,1),S(k).iso) & fltrMAC;
    fltrCTY(1)    = true;                                           % include dates
    S(k).macromth = data_macro(:,fltrCTY);                          % monthly data
    S(k).macroqtr = end_of_quarter(S(k).macromth);                  % quarterly data
    hdr_cty{k}    = hdr_macro(fltrCTY,2)';
    
    % If multiple matches, choose first appearance
    [~,idxUnq] = unique(hdr_macro(fltrCTY,2),'stable');
    idxUnq     = idxUnq(2:end);                                     % exclude dates
    data_mvar  = S(k).macroqtr(:,idxUnq);
    hdr_mvar   = hdr_cty{k}(idxUnq);
    
    % Save data as table to report variable names after estimation
    TblQtr = array2table(data_mvar,'VariableNames',hdr_mvar);
    
    % Prepare variables for regression: CBP ~ 1 + CBPlag + INF + GDP
    idxTR  = ismember(TblQtr.Properties.VariableNames,{'INF','GDP','CBP'});
    idxCBP = ismember(TblQtr.Properties.VariableNames,{'CBP'});
    TblLag = TblQtr(1:end-1,idxCBP);
    TblLag.Properties.VariableNames{'CBP'} = 'CBPlag';
    TblTR = [TblQtr(2:end,idxTR) TblLag];
    TblTR = movevars(TblTR,'CBPlag','Before',1);    
    tTR   = sum(~any(ismissing(TblTR),2));                          % remove NaNs to obtain sample size
    
%     % Plot the series
%     figure, plot(S(k).macroqtr(2:end,1),TblTR{:,2:end})
%     legend(TblTR.Properties.VariableNames{2:end})
%     title(S(k).cty), datetick('x','YYQQ')
    
    % Estimate Taylor Rule (with smoothing)
    MdlTR = fitlm(TblTR);
    
%     % NW standard errors
%     plot([min(MdlTR.Fitted) max(MdlTR.Fitted)],[0 0],'k-'), hold on
%     plotResiduals(MdlTR,'fitted'), title([S(k).iso ' Residual Plot']), ylabel('Residuals')
%     resid  = MdlTR.Residuals.Raw(~isnan(MdlTR.Residuals.Raw)); autocorr(resid)
%     maxLag = floor(4*(tTR/100)^(2/9));                             % lag for the NW HAC estimate
%     EstCov = hac(TblTR,'bandwidth',maxLag+1,'display','off');
    
    % Report output
    aux1 = MdlTR.Coefficients{:,1:2}';                              % extract estimates and SE
    aux1 = num2cell(round(aux1,2));                                 % round and save them as cells
    aux1 = cellfun(@num2str,aux1,'UniformOutput',false);            % store them as strings
    aux1(2,:) = strcat('(',aux1(2,:),')');                          % add parenthesis to SE
    if strcmp(S(k).iso,'ZAR')                                       % no GDP data for ZAR 
        aux2    = cell(2,1);
        aux2(:) = {''};
        aux1    = [aux1 aux2];
    end
    outputTR(1,k)   = {S(k).iso};
    outputTR(2:9,k) = reshape(aux1,[],1);
    outputTR(10,k)  = {num2str(round(MdlTR.Rsquared.Ordinary,2),'%.2f')};
    outputTR(11,k)  = {num2str(MdlTR.NumObservations)};
    
    % Report output for long-term interest rates
    aux3  = MdlTR.Coefficients{:,1};                                % extract estimates
    bsmth = aux3(2);
    brest = aux3([1 3:end]);
    aux3  = brest./(1-bsmth);                                       % long-term transformation
    aux4  = num2cell(round(aux3,2));
    if strcmp(S(k).iso,'ZAR')                                       % no GDP data for ZAR
        aux3 = [aux3; 0];
        aux4 = [aux4; {''}];
    end
    weightsLT(1,k)     = S(k).imf;
    weightsLT(2:end,k) = aux3;
    outputLT(1,k)      = {S(k).iso};
    outputLT(2:end,k)  = cellfun(@num2str,aux4,'UniformOutput',false);
    
    % Save coefficient names
    if k == 1
        namesWgts = MdlTR.CoefficientNames';
        namesWgts = ['IMF Code'; namesWgts([1 3:end])];
    end
end
end

function dataset_qrtrly = end_of_quarter(dataset_monthly)
% Return end-of-quarter observations from a monthly dataset (all columns)
%   dataset_monthly - monthly observations as rows (top-down old-new obs), col1 has dates
%   dataset_qrtrly - end-of-quarter observations as rows, same columns as input
%%
dates          = dataset_monthly(:,1);
mnths          = month(dates);
idxEndQt       = any(mnths == [3 6 9 12],2);
dataset_qrtrly = dataset_monthly(idxEndQt,:);
end