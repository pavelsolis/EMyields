function rollcor = rollingcorrs(S,cntrs,fname,tnr)
% ROLLINGCORRS Returns the average rolling correlations of changes in fname

% m-files called: syncdatasets
% Pavel Solís (pavel.solis@gmail.com)
%%
if ismember(S(1).iso,cntrs)
    ctr1 = 1;                               ctrn = length(cntrs);           % emerging markets
else
    ctr1 = length(S) - length(cntrs) + 1;   ctrn = length(S);               % advanced countries
end
for k1 = ctr1:ctrn
    fltrTNR = ismember(S(k1).(fname)(1,:),tnr);
    datesd  = S(k1).(fname)(2:end,1);
    dseries = S(k1).(fname)(2:end,fltrTNR);
    dchange = dseries(2:end) - dseries(1:end-1);                            % series of daily changes
    dtstaux = [nan tnr; datesd(2:end) dchange];                             % include header and dates
    if k1 == ctr1
        dtst = dtstaux;
    else
        dtst = syncdatasets(dtst,dtstaux,'union');                          % append series
    end
end
fltrCTR = [true; sum(isnan(dtst(2:end,2:end)),2) <= 4];                     % at least 11 countries with data
fltrDT  = dtst(:,1) > datenum('31-Jul-2021');                               % out of sample observations
dtst    = dtst(fltrCTR & ~fltrDT,:);                                        % adjust dataset
datemin = dtst(2,1) + 365;                                                  % one year after first observation
dates   = dtst(dtst(:,1) >= datemin,1);                                     % dates for rolling windows
nobs    = size(dates,1);
rollcor = nan(nobs,2);
for k2  = 1:nobs
    fltrRL = (dtst(:,1) >= dates(k2) - 365) & (dtst(:,1) <= dates(k2));
    rho    = corr(dtst(fltrRL,2:end),'Rows','pairwise');                    % correlations within the window
    rollcor(k2,:) = [dates(k2) mean(rho(tril(ones(size(rho)),-1) == 1),'omitnan')]; % average correlation
end